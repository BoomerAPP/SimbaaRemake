import { createClient, type SupabaseClient } from 'npm:@supabase/supabase-js@2.119.0';

const corsHeaders = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type, x-supabase-api-version, x-supabase-client-platform, x-supabase-client-platform-version, x-supabase-client-runtime, x-supabase-client-runtime-version',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Access-Control-Max-Age': '86400',
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store',
  'Vary': 'Origin',
};

const reply = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), { status, headers: corsHeaders });
const WINDOW_MS = 15 * 60 * 1000;
const MAX_ATTEMPTS = 8;
const localAttempts = new Map<string, { count: number; resetAt: number }>();

function readDefaultKey(variable: string, legacyVariable: string): string {
  const raw = Deno.env.get(variable) || '';
  if (raw) {
    try {
      const parsed = JSON.parse(raw);
      if (parsed && typeof parsed === 'object' && typeof parsed.default === 'string') return parsed.default;
    } catch {
      // Some older projects expose the legacy single-key string instead of a JSON key map.
      return raw;
    }
  }
  return Deno.env.get(legacyVariable) || '';
}

function readPublishableKeyCandidates(): string[] {
  const values = new Set<string>();
  const raw = Deno.env.get('SUPABASE_PUBLISHABLE_KEYS') || '';
  if (raw) {
    try {
      const parsed = JSON.parse(raw);
      if (parsed && typeof parsed === 'object') {
        for (const value of Object.values(parsed)) {
          if (typeof value === 'string' && value.trim()) values.add(value.trim());
        }
      }
    } catch {
      values.add(raw.trim());
    }
  }
  for (const name of ['SUPABASE_PUBLISHABLE_KEY', 'SUPABASE_ANON_KEY']) {
    const value = Deno.env.get(name)?.trim();
    if (value) values.add(value);
  }
  return [...values];
}

async function hmacAddress(value: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey(
    'raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign'],
  );
  const digest = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(value || 'unknown'));
  return [...new Uint8Array(digest)].map(x => x.toString(16).padStart(2, '0')).join('');
}

function clientAddress(req: Request): string {
  return req.headers.get('cf-connecting-ip')?.trim()
    || req.headers.get('x-real-ip')?.trim()
    || req.headers.get('x-forwarded-for')?.split(',')[0]?.trim()
    || 'unknown';
}

function recordLocalFailure(key: string): void {
  const now = Date.now();
  const previous = localAttempts.get(key);
  if (!previous || now > previous.resetAt) localAttempts.set(key, { count: 1, resetAt: now + WINDOW_MS });
  else previous.count += 1;
  if (localAttempts.size > 5000) {
    for (const [entry, value] of localAttempts) if (now > value.resetAt) localAttempts.delete(entry);
  }
}

function isLocallyBlocked(key: string): boolean {
  const previous = localAttempts.get(key);
  return Boolean(previous && Date.now() <= previous.resetAt && previous.count >= MAX_ATTEMPTS);
}

async function resolveOwnerId(
  admin: SupabaseClient,
  identity: string,
): Promise<{ ownerId: string | null; unavailable: boolean }> {
  // Read only Owner IDs and usernames. Email remains in Auth and is never returned to the browser.
  const { data: owners, error } = await admin.from('store_owners').select('user_id, username').limit(100);
  if (error) {
    console.error('SIMBAA_OWNER_LOOKUP_DATABASE_ERROR', error.code || 'unknown');
    return { ownerId: null, unavailable: true };
  }
  if (!owners?.length) return { ownerId: null, unavailable: false };

  const isEmail = identity.includes('@');
  for (const owner of owners) {
    let matches = false;
    if (isEmail) {
      const { data, error: userError } = await admin.auth.admin.getUserById(owner.user_id);
      if (userError) {
        console.error('SIMBAA_OWNER_AUTH_LOOKUP_ERROR', userError.status || 'unknown');
        return { ownerId: null, unavailable: true };
      }
      matches = Boolean(data.user?.email && data.user.email.toLowerCase() === identity.toLowerCase());
    } else {
      matches = Boolean(owner.username && owner.username.toLowerCase() === identity.toLowerCase());
    }
    if (matches) return { ownerId: owner.user_id, unavailable: false };
  }
  return { ownerId: null, unavailable: false };
}

Deno.serve(async (req: Request) => {
  if (req.method === 'OPTIONS') return new Response('ok', { status: 200, headers: corsHeaders });
  if (req.method !== 'POST') return reply(405, { code: 'METHOD_NOT_ALLOWED', error: 'Method tidak diizinkan.' });

  let input: Record<string, unknown>;
  try {
    input = await req.json();
  } catch {
    return reply(400, { code: 'INVALID_REQUEST', error: 'Format permintaan login tidak valid.' });
  }

  const identityRaw = typeof input.identity === 'string'
    ? input.identity
    : (typeof input.username === 'string' ? input.username : '');
  const identity = identityRaw.trim();
  const password = input.password;
  const validIdentity = identity.includes('@')
    ? /^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(identity) && identity.length <= 120
    : /^[a-zA-Z0-9._-]{3,40}$/.test(identity);
  if (!validIdentity || typeof password !== 'string' || password.length < 1 || password.length > 256) {
    return reply(401, { code: 'LOGIN_INVALID', error: 'Username atau password tidak cocok.' });
  }

  try {
    const url = Deno.env.get('SUPABASE_URL') || '';
    // New Supabase projects expose named key maps. The default key is selected explicitly;
    // never pick an arbitrary key from the map.
    const secretKey = readDefaultKey('SUPABASE_SECRET_KEYS', 'SUPABASE_SERVICE_ROLE_KEY')
      || Deno.env.get('SUPABASE_SECRET_KEY') || '';
    const allowedPublishableKeys = readPublishableKeyCandidates();
    if (!url || !secretKey || allowedPublishableKeys.length === 0) {
      console.error('SIMBAA_LOGIN_CONFIG_MISSING', { hasUrl: Boolean(url), hasSecret: Boolean(secretKey), hasPublishable: allowedPublishableKeys.length > 0 });
      return reply(503, { code: 'SERVER_CONFIG_MISSING', error: 'Konfigurasi login server belum lengkap. Periksa Secrets Edge Function.' });
    }
    // Accept only a publishable/legacy anon key issued for this project. Use the exact
    // matching key for Auth so projects retaining the legacy anon key also work.
    // It is sent in `apikey`, never in Authorization (which is reserved for user JWTs).
    const requestApiKey = req.headers.get('apikey') || '';
    if (!allowedPublishableKeys.includes(requestApiKey)) {
      return reply(401, { code: 'PUBLISHABLE_KEY_REQUIRED', error: 'Publishable key tidak cocok dengan project Supabase fungsi ini. Periksa supabase-config.js.' });
    }

    const ipHash = await hmacAddress(clientAddress(req), secretKey);
    if (isLocallyBlocked(ipHash)) {
      return reply(429, { code: 'RATE_LIMITED', error: 'Terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.' });
    }

    const admin = createClient(url, secretKey, { auth: { persistSession: false, autoRefreshToken: false } });
    const since = new Date(Date.now() - WINDOW_MS).toISOString();
    const attemptQuery = await admin.from('owner_login_attempts')
      .select('id', { count: 'exact', head: true }).eq('ip_hash', ipHash).gte('attempted_at', since);
    const persistentLimitReady = !attemptQuery.error;
    if (persistentLimitReady && (attemptQuery.count || 0) >= MAX_ATTEMPTS) {
      return reply(429, { code: 'RATE_LIMITED', error: 'Terlalu banyak percobaan gagal. Coba lagi dalam 15 menit.' });
    }
    const rememberFailure = async () => {
      recordLocalFailure(ipHash);
      if (persistentLimitReady) {
        const { error } = await admin.from('owner_login_attempts').insert({ ip_hash: ipHash });
        if (error) console.warn('SIMBAA_LOGIN_RATE_LIMIT_WRITE_FAILED', error.code || 'unknown');
      }
    };

    const resolved = await resolveOwnerId(admin, identity);
    if (resolved.unavailable) {
      return reply(503, { code: 'OWNER_LOOKUP_UNAVAILABLE', error: 'Data Owner belum dapat diperiksa. Periksa Edge Function Secrets, tabel store_owners, dan migration login.' });
    }
    if (!resolved.ownerId) {
      console.warn('SIMBAA_OWNER_IDENTITY_NOT_FOUND', { identityType: identity.includes('@') ? 'email' : 'username' });
      await rememberFailure();
      return reply(401, { code: 'LOGIN_INVALID', error: 'Username atau password tidak cocok.' });
    }

    const { data: ownerUser, error: ownerUserError } = await admin.auth.admin.getUserById(resolved.ownerId);
    const ownerEmail = ownerUser?.user?.email;
    if (ownerUserError || !ownerEmail || ownerUser?.user?.id !== resolved.ownerId) {
      console.error('SIMBAA_OWNER_AUTH_USER_MISSING', ownerUserError?.status || 'no-email');
      return reply(503, { code: 'OWNER_AUTH_LOOKUP_UNAVAILABLE', error: 'Akun Owner ditemukan, tetapi data Auth tidak dapat diperiksa.' });
    }

    // Call GoTrue directly so a modern sb_publishable_* key is sent ONLY in
    // `apikey`. Supabase's newer API-key guidance warns against sending these
    // keys as `Authorization: Bearer ...` because that header is reserved for JWTs.
    const authResponse = await fetch(`${url.replace(/\/$/, '')}/auth/v1/token?grant_type=password`, {
      method: 'POST',
      headers: { apikey: requestApiKey, 'Content-Type': 'application/json' },
      body: JSON.stringify({ email: ownerEmail, password }),
    });
    const signed = await authResponse.json().catch(() => ({}));
    if (!authResponse.ok || !signed?.access_token || !signed?.refresh_token || signed?.user?.id !== resolved.ownerId) {
      console.warn('SIMBAA_OWNER_PASSWORD_AUTH_REJECTED', { status: authResponse.status, authCode: typeof signed?.code === 'string' ? signed.code : 'unknown' });
      await rememberFailure();
      return reply(401, { code: 'LOGIN_INVALID', error: 'Username atau password tidak cocok.' });
    }

    return reply(200, {
      access_token: signed.access_token,
      refresh_token: signed.refresh_token,
      expires_in: signed.expires_in,
      expires_at: signed.expires_at,
      token_type: signed.token_type || 'bearer',
    });
  } catch (error) {
    console.error('SIMBAA_OWNER_LOGIN_UNEXPECTED_ERROR', error instanceof Error ? error.name : 'unknown');
    return reply(500, { code: 'LOGIN_SERVICE_ERROR', error: 'Layanan login sementara bermasalah. Periksa Edge Function Logs.' });
  }
});
