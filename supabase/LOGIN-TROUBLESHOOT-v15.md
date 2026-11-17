# SIMBAA Owner username login — v15

The Owner row is already mapped to Auth. Do not create a second Owner row.

## Deploy the function

From the project root:

```bash
supabase login
supabase functions deploy simbaa-owner-login --project-ref npztpcjthdwjawtojmrv --no-verify-jwt
```

`supabase/config.toml` must retain:

```toml
[functions.simbaa-owner-login]
verify_jwt = false
```

## Why v15 changes password sign-in

The function now calls the Supabase Auth password-token endpoint directly and sends the publishable key only in the `apikey` header. This avoids using a modern `sb_publishable_*` key as a Bearer JWT. The returned Auth user ID must still match the Owner `user_id` before the session is returned to the browser.

## Diagnose a failed attempt

Open Supabase Dashboard → Edge Functions → `simbaa-owner-login` → Logs / Invocations. Search for:

- `SIMBAA_LOGIN_CONFIG_MISSING`: platform-injected URL/key environment is missing.
- `SIMBAA_OWNER_LOOKUP_DATABASE_ERROR`: service secret cannot read `store_owners`.
- `SIMBAA_OWNER_IDENTITY_NOT_FOUND`: username does not match a row.
- `SIMBAA_OWNER_PASSWORD_AUTH_REJECTED`: username was resolved but Supabase Auth rejected the password, or returned a different UID.

Never paste the password, publishable key, or secret key into chat. If logs show password rejection, reset the existing Auth user's password through Supabase Authentication → Users for the same UID; do not change `store_owners.user_id`.
