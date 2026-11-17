import { createClient } from 'npm:@supabase/supabase-js@2';

const cors = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Headers': 'authorization, x-client-info, apikey, content-type',
  'Access-Control-Allow-Methods': 'POST, OPTIONS',
  'Content-Type': 'application/json; charset=utf-8',
  'Cache-Control': 'no-store',
};
const json = (status: number, body: Record<string, unknown>) =>
  new Response(JSON.stringify(body), { status, headers: cors });

function readKeyMap(name: string): string {
  const raw = Deno.env.get(name) || '';
  if (!raw) return '';
  try { const parsed = JSON.parse(raw); if (parsed?.default) return String(parsed.default); } catch { /* legacy string */ }
  return raw;
}
async function hashAddress(value: string, secret: string): Promise<string> {
  const key = await crypto.subtle.importKey('raw', new TextEncoder().encode(secret), { name: 'HMAC', hash: 'SHA-256' }, false, ['sign']);
  const digest = await crypto.subtle.sign('HMAC', key, new TextEncoder().encode(value || 'unknown'));
  return [...new Uint8Array(digest)].map(v => v.toString(16).padStart(2, '0')).join('');
}
Deno.serve(async (req) => {
  if (req.method === 'OPTIONS') return new Response('ok', { headers: cors });
  if (req.method !== 'POST') return json(405, { error: 'Method tidak diizinkan.' });
  try {
    const url = Deno.env.get('SUPABASE_URL') || '';
    const secret = readKeyMap('SUPABASE_SECRET_KEYS') || Deno.env.get('SUPABASE_SECRET_KEY') || Deno.env.get('SUPABASE_SERVICE_ROLE_KEY') || '';
    if (!url || !secret) return json(503, { error: 'Layanan ulasan belum dikonfigurasi.' });
    const body = await req.json();
    const customer_name = typeof body.customer_name === 'string' ? body.customer_name.trim() : '';
    const customer_title = typeof body.customer_title === 'string' ? body.customer_title.trim().slice(0, 100) : '';
    const message = typeof body.message === 'string' ? body.message.trim() : '';
    const rating = Number(body.rating || 5);
    if (customer_name.length < 2 || customer_name.length > 80 || message.length < 12 || message.length > 500 || !Number.isInteger(rating) || rating < 1 || rating > 5 || body.consent_confirmed !== true) {
      return json(400, { error: 'Periksa nama, isi ulasan, rating, dan persetujuan publikasi.' });
    }
    const ip = req.headers.get('cf-connecting-ip') || req.headers.get('x-real-ip') || req.headers.get('x-forwarded-for')?.split(',')[0] || 'unknown';
    const ip_hash = await hashAddress(ip, secret);
    const admin = createClient(url, secret, { auth: { persistSession: false, autoRefreshToken: false } });
    const since = new Date(Date.now() - 60 * 60 * 1000).toISOString();
    const { count, error: countError } = await admin.from('review_submission_attempts').select('id', { count: 'exact', head: true }).eq('ip_hash', ip_hash).gte('attempted_at', since);
    if (countError) return json(503, { error: 'Proteksi formulir sedang tidak tersedia. Coba lagi nanti.' });
    if ((count || 0) >= 4) return json(429, { error: 'Batas pengiriman ulasan tercapai. Coba kembali nanti.' });
    const { error: rateError } = await admin.from('review_submission_attempts').insert({ ip_hash });
    if (rateError) return json(503, { error: 'Proteksi formulir sedang tidak tersedia. Coba lagi nanti.' });
    const { error } = await admin.from('testimonial_submissions').insert({ customer_name, customer_title: customer_title || null, message, rating, consent_confirmed: true, status: 'pending' });
    if (error) return json(400, { error: 'Ulasan belum dapat dikirim. Periksa kembali isian formulir.' });
    return json(200, { ok: true, message: 'Ulasan terkirim dan menunggu pemeriksaan admin.' });
  } catch {
    return json(400, { error: 'Permintaan tidak dapat diproses.' });
  }
});
