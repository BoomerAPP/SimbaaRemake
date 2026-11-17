# SIMBAA Fresh v12 — Working Owner Dashboard

- Fixed the admin navigation and banner-save crash: the dashboard referenced `$$` for query-all selection without defining it.
- Kept the four simple top-level groups: Ringkasan, Katalog, Konten, and Pengaturan.
- Added a visual product-configuration builder. Owner can add fields, choose text / paragraph / dropdown / email / number / phone / URL, set required status, and list dropdown choices without manually writing a pipe-delimited format.
- Simplified product price entry: accepts `25000`, `25.000`, `Rp 25.000`, etc.; removes grouping punctuation and saves the Rupiah amount. No arbitrary product price cap is hard-coded in the dashboard.
- Updated fixed-promo amount and minimum-order inputs to accept Indonesian Rupiah separators.
- Added a Store Settings page for brand name, tagline, WhatsApp number, public email, website, Instagram, TikTok, YouTube, zero-price label, price note, and order confirmation note.
- Added `supabase/migration-v12-dashboard-settings.sql` with a public-readable / Owner-writable settings row, explicit Data API grants, and RLS policies.
- Removed the legacy fixed-promotion ceiling constraint when it uses the known generated constraint name, while keeping non-negative amounts and the 100% percentage cap.
- Public storefront now reads the saved WhatsApp number, brand name, tagline, zero-price label, and order notes from Supabase settings; optional email, website, and social links appear in the public footer.

## Installation
- Run `migration-v12-dashboard-settings.sql` after the previous SIMBAA migrations. Do not rerun the base schema or reset Owner data.
- Verify with `verify-v12.sql`.
- Existing login and Owner UID verification are unchanged.

## Verification boundary
- Static JavaScript syntax, HTML IDs, price-parser test cases, form/button wiring, and ZIP integrity are checked in this release.
- Live Supabase Auth, RLS, storage, and CRUD still require testing on the user's project; this environment does not have access to their Supabase database.

- Compatibility repair: add canonical `products.price` for older schemas that stored `starting_price`; copy existing data and keep the two values synchronized. Remove the legacy fixed-category check so Owner-managed categories can be selected.
