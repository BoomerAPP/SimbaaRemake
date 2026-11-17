# SIMBAA v14 QA report

## Static checks completed
- `node --check admin/admin.js`: PASS.
- `node --check app.js`: PASS.
- HTML parser: PASS for `Simbaa.html`, `index.html`, and `layanan.html`; no duplicate IDs.
- Admin JS static element reference scan: no missing static IDs.
- Direct admin event-listener bindings: all referenced IDs exist in `Simbaa.html`.
- Edge Function source reviewed; CORS preflight header list corrected to include `authorization`.
- ZIP integrity: PASS.

## Fixes
- Bound `supabase/config.toml` to project ref `npztpcjthdwjawtojmrv`.
- Fixed username login CORS preflight by allowing `authorization` and Supabase client headers.
- Added a consolidated additive migration for the existing key/value `store_settings` schema, Owner-only activity DELETE, login rate-limit table privileges, and username lookup index.
- Added read-only verification for Owner mapping, RLS, settings, media bucket, policies, and content counts.

## Not claimed as verified
Live username/password Auth, Edge Function deployment, RLS CRUD, Storage uploads, Vercel deployment, and mobile browser behavior require testing in the user's project. The previous admin source has event handlers and all static referenced IDs are present, but only live browser testing can prove taps/clicks and data operations.
