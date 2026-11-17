# SIMBAA Fresh v5 — QA Report

## Static checks completed

- JavaScript syntax check: `app.js` and `admin/admin.js`.
- Edge Function TypeScript sanity check using local ambient Deno/Supabase type stubs.
- CSS parse check using `tinycss2`.
- HTML structure checks: duplicate IDs, local asset/script/link targets, login/dashboard default visibility, and static login-field content.
- Translation coverage checks for Indonesian and English `data-i18n` keys and homepage search placeholder.
- Admin JavaScript selector-to-HTML ID checks.
- ZIP integrity check after packaging.

## Not verified against live services

- The SQL migration has not been executed against the owner's live Supabase database.
- The `simbaa-owner-login` Edge Function has not been deployed to Supabase.
- Real Supabase Auth, RLS, Storage upload, live database CRUD, and WhatsApp handoff have not been tested against the owner's project.
- A full in-browser mobile visual test has not been completed because a browser runtime was not available in this build environment.

## Before production

1. Configure `supabase-config.js` with the correct Project URL and Publishable key. Never put a Secret/service-role key in browser code.
2. Back up the Supabase project, then run only `supabase/migration-v5-experience.sql`.
3. Deploy `supabase/functions/simbaa-owner-login/index.ts` as `simbaa-owner-login`, with platform JWT verification disabled for this pre-login endpoint. The function performs its own password and exact Owner UID checks.
4. Confirm the Edge Function server-side environment variables are available; keep Secret keys server-side.
5. Confirm `simbaa-owner-login` can authenticate `SimbaaOwner` and `simbaagorncs@gmail.com` with the existing Auth password.
6. Test public reads, Owner-only writes, image upload, product/category/banner/promo/portfolio/testimonial/FAQ management, responsive navigation, light/dark themes, English translation, and WhatsApp messages.
7. Verify the WhatsApp destination in `supabase-config.js` before publishing. The default currently comes from the existing SIMBAA project context and must be checked by the Owner.
8. Deploy to a preview domain first. Keep v4 available for rollback until all tests pass.

## Data integrity and trust safeguards

- No fabricated testimonials, user counts, ratings, uptime claims, portfolio items, or discounts are seeded as proof.
- Testimonials are public only when active and consent is recorded.
- Portfolio items are hidden until explicitly published by Owner.
- Price is treated as a reference where appropriate; the customer is asked to confirm final price, service scope, timeline, terms, and payment instructions before paying.
- The initial WhatsApp handoff does not ask for OTP, PIN, account password, API secret, or other credentials.
