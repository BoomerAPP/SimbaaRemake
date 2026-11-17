# SIMBAA Fresh v17.0.0

This version continues from SIMBAA v7.1 and preserves its existing pages and Supabase data model.

## What changed
- Hero copy is displayed vertically in a left column with the official transparent SIMBAA mascot on the right.
- Carousel arrow buttons were removed; users swipe/scroll the slides manually.
- Recently viewed products are remembered in the current browser only.
- Product configuration is simplified: first four fields are shown immediately; extra configuration and buyer details are collapsible.
- WhatsApp text includes the exact selected configuration and optional selected product-eligible promo.
- Email Owner login uses Supabase Auth directly followed by Owner UID verification and an explicit RLS-safe Owner row policy. Username login uses the Edge Function and server-side Owner mapping. Missing username schema now returns a setup error instead of a misleading bad-password message.
- The v8 login migration safely ensures the Owner can read only their own `store_owners` row and prepares persistent login throttling.

## Configure frontend
1. Open `supabase-config.js`.
2. Set the new SIMBAA Supabase Project URL and Publishable/anon key.
3. Never put a Secret or service_role key in frontend files.

## Database migration order
The original base schema and Owner mapping must exist first. Do not reset the database.

If the v5 migration has not been installed, run `supabase/migration-v5-experience.sql` once, then `supabase/verify-v5.sql`. If the v6 migration has not been installed, run `supabase/migration-v6-portfolio-reviews.sql` once, then `supabase/verify-v6.sql`. Finally run `supabase/migration-v8-login-guard.sql` and `supabase/verify-v8-login.sql`. The v8 migration does not change passwords or Auth users. The migrations are additive; do not run files in `supabase/legacy/`.

## Owner login
- Email: the existing Auth email for the Owner.
- Username: `SimbaaOwner`.
- Password: the existing Supabase Auth password; this project does not change it.
- Email path: Supabase Auth `signInWithPassword`, followed by exact UID lookup in `store_owners`.
- Username path: deploy `supabase/functions/simbaa-owner-login/index.ts`.

### Deploy the username login function
From the Supabase project root (the folder containing `supabase/config.toml`):

```bash
supabase functions deploy simbaa-owner-login --no-verify-jwt
```

`verify_jwt=false` is intentional because the user has not authenticated when calling the login endpoint. The function validates the submitted password against Supabase Auth, resolves only existing Owner mappings, applies throttling, and returns a session only when the authenticated UID is that Owner. Never put `SUPABASE_SECRET_KEYS` or `service_role` in the browser.

If you cannot use the CLI, create/update the Edge Function named `simbaa-owner-login` in Supabase Dashboard and paste the full `index.ts` contents. Confirm the function is configured to skip gateway JWT verification, then deploy it. Email login should work without this function; username login will not work until it is deployed.

## Test checklist
1. Login with the Owner email and existing password.
2. Login with `SimbaaOwner` and the same password.
3. Confirm a non-Owner Auth user is rejected.
4. Add one product from `Simbaa.html`; verify it appears in the catalog.
5. Open a product, fill one configuration, select an eligible promo, and verify the WhatsApp draft.
6. Change between dark and light mode; verify mascot and all text remain visible.

If login by email works but username returns an error, deploy `simbaa-owner-login`. If both fail, first verify `supabase-config.js`, then inspect Supabase Auth logs and the exact status message shown on the login page.

## Known verification limits
HTML, CSS, JavaScript syntax, Edge Function TypeScript syntax, asset paths, SQL file structure, and ZIP integrity are checked locally. The user's live Supabase project, Edge Function deployment, password, Vercel deployment, and physical Android browser are not accessible from this build environment and must be tested by the project owner.

## v11 Admin Workspace

Admin menu is grouped into Ringkasan, Katalog, Konten, and Pengaturan. Run `supabase/migration-v11-admin-history.sql` after the existing v5 schema to enable Owner-only deletion of activity history. Deploy `supabase/functions/simbaa-owner-login` for username login. See `CHANGELOG-v11.md` and `QA-REPORT-v11.md`.

## v15 notes
- Storefront settings are read from `store_settings.key = 'main'` and the JSONB `value` object.
- `show_on_home` and `is_best_seller` control the homepage curated services section.
- Community WhatsApp group and channel links can be edited in Owner → Pengaturan → Platform.
- Promotions are listed in Owner → Konten → Promo; public promotion cards are shown only on `promo.html` when active and inside their date window.
- Run `supabase/diagnose-v15.sql` to check why a promotion is not visible.
- For username login deployment and log diagnosis, see `supabase/LOGIN-TROUBLESHOOT-v15.md`.


## SIMBAA Fresh v17
- Buka `index.html` untuk beranda, `layanan.html` untuk katalog, dan `Simbaa.html` untuk dashboard Owner.
- Aset banner yang diberikan sudah berada di `assets/banners/`; source gambar asli disimpan di `assets/source-gallery/`; avatar layanan hasil crop non-generatif ada di `assets/product-avatars/`.
- Jalankan `supabase/migration-v17-storefront.sql` setelah migration dasar v5/v14. Verifikasi dengan `supabase/verify-v17-storefront.sql`.
- Atur domain publik dan nomor WhatsApp dari dashboard. Gunakan Supabase Publishable/anon key pada frontend; jangan pernah memasukkan service_role/secret key.

For the exact v17 migration order and Data API checks, read `supabase/INSTALL-ORDER-v17.md` and `supabase/DATA-API-TROUBLESHOOT-v17.md`.
