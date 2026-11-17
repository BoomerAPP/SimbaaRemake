# QA Report — SIMBAA v12

- `node --check admin/admin.js`: PASS
- `node --check app.js`: PASS
- HTML parsing for all public pages and `Simbaa.html`: PASS
- Duplicate HTML IDs: none found
- Static admin JS-to-HTML ID references: PASS
- Every static admin button has an explicit type; all admin forms have submit controls: PASS
- Rupiah parser: `25000`, `25.000`, `250.000`, `400001`, `Rp 1.500.000`, `0`, and empty value: PASS
- Headless browser test with a simulated Supabase Owner session: PASS
  - All 11 admin panels opened through menu/submenu clicks
  - New product form opened and a configuration field was added
  - Product save accepted `400001` and sent integer `400001` to the mocked database client
  - Fixed promo save accepted `450000` (above the legacy `7999` cap)
  - Three banner updates were sent
  - Store settings upsert was sent
  - No browser JavaScript runtime errors during the test
- SQL migration: statically reviewed only; not executed against the user's Supabase project
- Live Supabase Auth / Edge Function / RLS / Storage / CRUD: NOT RUN (requires the user's deployed project)

Operational requirement: apply `supabase/migration-v12-dashboard-settings.sql` after the already-installed base, v5, v6, v8, and v11 migrations, then run `supabase/verify-v12.sql`.
