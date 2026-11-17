# SIMBAA v8 — QA Report

## Local static checks
- HTML documents parsed with Python HTMLParser.
- Public app JavaScript and Admin JavaScript passed `node --check`.
- Edge Function TypeScript parsed/transpiled with the locally available TypeScript compiler when available.
- Local asset references checked against files in the package.
- Migration/verification SQL files are present and ordered in README.
- Archive integrity tested after packaging.

## Not performed
- No live Supabase credentials were available, so Owner sign-in and database policies were not exercised against the user's project.
- No Vercel preview was deployed.
- No Android visual/browser run was available.
- WhatsApp draft construction is statically inspected; opening the user's WhatsApp app must be tested on the device.

## Login diagnosis
- Email sign-in is independent from the custom username Edge Function, then checks the exact UID in `store_owners`.
- Username sign-in still requires the `simbaa-owner-login` Edge Function to be deployed. The UI now explains when the function is absent instead of disguising it as a password error.
- The v8 migration ensures the username index and rate-limit table exist without changing Auth credentials.

## Login hardening follow-up
- Added explicit `store_owners` SELECT grant and RLS policy for the authenticated user to read only their own row.
- Username lookup schema/permission errors now surface as setup errors (503), not generic invalid credentials.
- Login rate-limit table lookup safely falls back to isolate memory throttling while the v8 migration is absent.
- Live Supabase Auth, Edge Function deployment, and actual credentials were not tested in this container.
