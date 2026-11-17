# SIMBAA Fresh v18

v18 is a usability and catalog update layered over the v17 source tree. It keeps the existing static pages, Supabase client setup, Owner login flow, storage bucket naming, key/value `store_settings`, and current product schema conventions.

## Main changes
- Admin navigation is a compact menu in the top toolbar rather than a left-side drawer occupying the workspace.
- Admin product management uses image-led cards instead of a wide table that clipped on mobile.
- Product configuration builder is collapsible and limited to eight fields per product; category `config_profile` provides the suggested configuration for new products.
- Image upload offers crop/position/zoom controls (product 1:1, banner 2.75:1, portfolio 4:3).
- Adds Owner-managed `store_announcements` used by the public notification panel and a slim home announcement strip.
- Language and dark/light theme are placed in one preferences drawer; notification remains a separate bell/panel.
- Product CTAs are “Beli Sekarang” and “Konsultasi”.
- All WhatsApp messages append the configured WhatsApp Group and Channel links when those links are set in Platform.
- Removes the extra floating WhatsApp shortcut; product/consultation CTAs remain contextual.
- Adds catalog seed products only for missing slugs; it does not overwrite existing products.

## Supabase install
1. Keep a backup of the currently deployed v17 source and database.
2. Run `supabase/migration-v18-admin-storefront.sql` once in Supabase SQL Editor.
3. Run `supabase/verify-v18.sql` and confirm the new announcement table, category profiles, seeded catalog, RLS policy, and explicit Data API grants.
4. Ensure the existing `simbaa-store-media` bucket and its Owner upload policies remain in place. v18 does not replace the bucket or Owner mapping.
5. Deploy the entire v18 folder to Vercel. Keep `supabase-config.js` on the Publishable/anon key only; never put a Secret/service-role key in frontend code.

The migration adds grants for the public Data API while relying on RLS for row-level authorization. It does not drop or replace existing product/category/promotion policies.

## Notes
- Existing rows are preserved. Seed rows use `ON CONFLICT (slug) DO NOTHING` so customized products remain untouched.
- New categories have a `config_profile` so products created in that category inherit the right suggested fields.
- OG image is intentionally not generated in this release.
- Live Supabase CRUD, RLS behavior, login, crop interaction on device, and external WhatsApp navigation still need a production/staging test against the user's actual project.
