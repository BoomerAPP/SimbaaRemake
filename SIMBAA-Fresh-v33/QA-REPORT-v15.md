# SIMBAA v15 QA report

## Static checks completed
- `node --check app.js`: PASS.
- `node --check admin/admin.js`: PASS.
- HTML parser checks for index, layanan, promo, tentang, bantuan and Simbaa admin: PASS; no duplicate IDs.
- Product admin references confirmed for `show_on_home`: PASS.
- Public products query includes `show_on_home`: PASS.
- Public store settings query uses `store_settings.key/value` JSONB schema: PASS.
- WhatsApp contexts are distinct for hero, home, help, about, catalog, promo, floating contact, and product category: PASS by source inspection.
- Community notice and links are rendered on homepage using the supplied group/channel URLs and can be changed in Store Settings: PASS by source inspection.
- Admin promotions list now renders all records, including inactive, scheduled and expired records: PASS by source inspection.
- Edge Function username flow updated to send the publishable API key only in `apikey` for password grant and confirm returned Auth UID matches Owner UID: source review PASS.

## Not verified live
- Deno compilation/runtime and deployed Edge Function.
- Actual username/password sign-in.
- Supabase CRUD/RLS operations and live promo row visibility.
- Storage upload from production browser.
- Vercel deployment and Android browser touch behavior.

A static check does not prove live Supabase behavior. Use `supabase/LOGIN-TROUBLESHOOT-v15.md` and `supabase/diagnose-v15.sql` for the remaining live checks.
