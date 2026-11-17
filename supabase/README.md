# SIMBAA Fresh v14 — pre-deploy package

## Project binding
This source is configured for Supabase project ref `npztpcjthdwjawtojmrv`.
The browser config contains only the public publishable key. Never add a secret/service-role key to frontend files.

## Important: database state
The supplied database inspection confirms:
- `store_settings` uses `key`, `value`, `updated_at` (not `id`).
- Owner row exists for UID `d75b59dd-de05-4a2a-8a76-a0cd72f0d289`, username `SimbaaOwner`.
- Core tables have RLS enabled.
- v5/v6/v8 structures are already present based on the supplied policies and columns.

Do not run `migration-v12-dashboard-settings.sql`.
Do not rerun v5/v6/v8 on the existing database if they have already succeeded.

## Required steps before deploy
1. Back up the Supabase project.
2. Run `supabase/migration-v14-predeploy.sql` once in Supabase SQL Editor. It is safe to rerun and preserves existing content. It normalizes `store_settings` key/value policies and adds Owner-only activity DELETE plus the server-only login rate-limit table/index.
3. Run `supabase/verify-v14-predeploy.sql`. Confirm the Owner row is present, RLS is enabled, `store_settings` remains key/value, and the media bucket exists.
4. Deploy the username login Edge Function from this folder:
   `supabase functions deploy simbaa-owner-login --project-ref npztpcjthdwjawtojmrv --no-verify-jwt`
5. Verify deployment in Supabase Dashboard > Edge Functions > `simbaa-owner-login`. The function must be deployed with JWT verification disabled because it runs before the user has an Auth session; the handler itself validates the project publishable key and performs password authentication server-side.
6. Deploy this entire source folder to Vercel. Do not deploy only `Simbaa.html`; include `admin/`, `assets/`, `supabase-config.js`, `app.js`, and all other referenced files.
7. Open `/Simbaa.html`, test Owner username, then test the admin CRUD checklist below.

## Username login
- Username: `SimbaaOwner`
- The existing Auth UID mapping is retained.
- Password is the existing Supabase Auth password. This package does not reset or store it.
- Login uses `simbaa-owner-login`; the function resolves the username server-side, obtains the linked Auth email privately, signs in through Auth, and returns session tokens only.
- The Edge Function CORS allow-list includes `authorization`, which is needed by browser invocation preflight.
- `supabase/config.toml` is bound to this project and sets `verify_jwt = false` for the pre-auth username login function.
- Do not add the Supabase secret/service-role key to `supabase-config.js`.

## Test in this order
A. Login:
- Username `SimbaaOwner` + existing Auth password.
- Confirm dashboard opens and owner label is visible.
- Log out; test email login if desired.
- If it fails, read Edge Functions > `simbaa-owner-login` > Invocations and Logs; share the HTTP status and function error code only. Never share password or secret keys.

B. CRUD:
- Create a test product with price `400001`, status `ready`, active off; save; edit it; delete it.
- Create/edit/delete a temporary category not used by products.
- Create/edit/toggle/delete a promotion; test fixed amount `450000` and percent `100`.
- Update banner copy and save.
- Create/edit/delete a portfolio item.
- Create a draft testimonial with consent unchecked; then test consent-gated publish only with genuine permission.
- Create/edit/delete a FAQ.
- Save store settings and reload page to confirm persistence.
- Upload a JPG/PNG/WebP/AVIF smaller than 5 MB to products, banner, portfolio and testimonial if needed.
- Clear activity history and confirm the latest clear log is recorded.

C. Public storefront:
- Verify only active products/categories/banners/promotions/portfolio/testimonials/FAQs are visible.
- Check WhatsApp links, product configuration form, mobile layout, and homepage best-seller section.

## Honest QA boundary
Static code checks do not prove live Auth, RLS, Storage, or CRUD. Complete the live checklist above before calling the site production-ready.
