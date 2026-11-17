# SIMBAA Fresh v4 — Premium Black & Gold

- Refined premium visual system while retaining the existing black/gold identity.
- Removed the separate “Pilihan SIMBAA” homepage section; Best Seller remains.
- Repositioned brand emblem and introduced SVG theme control plus circular language selector.
- Added a mascot-led Help hero and improved support messaging.
- Improved light-mode contrast and mobile spacing.
- Updated storefront product query to the actual `products.price` schema.
- Updated admin product writes to `price`, `category`, `status`, and existing product columns.
- Replaced hard-coded legacy owner email/user_roles verification with `store_owners` UID verification.
- Login accepts username or email; username is resolved by a narrowly scoped SQL function, then Supabase Auth validates the password.
- Added v4 SQL migration under `supabase/`.

## Notes
Run `supabase/migration-v4-premium-owner-login.sql` before deploying this source. Confirm `supabase-config.js` points to the correct Supabase project and uses only the publishable/anon key.
