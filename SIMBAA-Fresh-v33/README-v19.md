# SIMBAA Fresh v19

v19 is a usability-focused remake of the v18 admin dashboard and storefront. It preserves the existing design identity and the v18 Supabase schema while reorganizing navigation, making forms more compact, improving product selection, and adding clearer announcements and voice behavior.

## What changed
See `CHANGELOG-v19.md` for the full change list and `QA-REPORT-v19.md` for checks and limitations.

## Deploy
1. Back up the currently deployed source and database before replacing files.
2. Deploy the complete v19 folder to the same Vercel project.
3. Keep the current `supabase-config.js` values, with a Publishable/anon key only. Never expose a service-role/Secret key in frontend code.
4. No new v19 SQL migration is required. Continue using the existing v18 database schema and migrations.
5. Test Owner sign-in, admin CRUD, upload, homepage selection, announcement behavior, product checkout via WhatsApp, and mobile layout against the real Supabase project after deployment.

## Important notes
- `show_on_home` controls whether an active product appears in the home selection; `is_best_seller` is only a badge.
- The Owner login and UID verification remain. Only the public footer Owner Access shortcut was removed.
- Welcome voice is enabled by default and attempts playback on entry to a public page once per browser tab session. Browser autoplay restrictions may block the initial attempt; v19 retries on the first pointer/keyboard interaction. Visitors can mute or re-enable it with the speaker control.
- The internal price calculator does not save cost values. Include all supplier, server, API, labor, fee, and support costs in the amount entered.
