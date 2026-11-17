# SIMBAA v18 — Install Order

## Before SQL
1. Backup the current v17 website ZIP/source and make a database backup or Supabase branch.
2. Keep the current Owner account and `store_owners` mapping. Do not create a new Owner.
3. Confirm the existing core objects still exist: `private.is_store_owner()`, `store_owners`, `products`, `categories`, `store_banners`, `promotions`, `portfolio_items`, `testimonials`, `faqs`, `store_activity_logs`, and `store_settings`.
4. Keep `store_settings` in its existing `key/value/updated_at` format.

## Migration
- For an existing SIMBAA v15/v17 database with the core schema already installed, run **only** `supabase/migration-v18-admin-storefront.sql`.
- Do not rerun legacy v5/v6/v8/v14/v16/v17 migrations just because this ZIP contains their historical files.
- The v18 migration adds category presets, product price mode/benefit text, starter catalog data, announcements, explicit Data API grants, and announcement RLS. It does not drop existing catalog rows or Owner mapping.
- The product catalog seed uses missing slugs only. If an existing product uses the same slug, its Owner-edited content is preserved.

## Verification
1. Run `supabase/verify-v18.sql`.
2. Confirm the seeded product count increased, `is_active` is true on new products, and categories have `config_profile` values.
3. Confirm `store_announcements` is RLS-enabled and has the Owner management and public active-read policies.
4. Confirm the bucket `simbaa-store-media` remains public-read and Owner-write with WebP included in allowed MIME types.
5. Confirm `public` remains listed as an exposed Data API schema in Supabase API settings. Grants and RLS are separate controls.

## Website deployment
1. Extract `SIMBAA-Fresh-v18.zip`.
2. Keep `supabase-config.js` on the project's Project URL and Publishable/anon key only. Never put the Secret/service-role key in frontend code.
3. Upload the complete folder to Vercel as a static site. The main entry is `index.html`; the Owner entry remains `/Simbaa.html`.
4. Test `/`, `/layanan.html`, `/promo.html`, `/Simbaa.html` and the Owner login on Android before replacing the production alias.

## Live tests required
Test Owner login, public product reads, product/category CRUD, promotions, announcements, platform updates, image crop/upload, and contextual WhatsApp messages. Do not consider the source production-verified until these live tests pass.
