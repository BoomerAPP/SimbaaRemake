# SIMBAA Fresh v18 — Changelog

## Admin workspace
- Moved the Admin Dashboard entry into the top toolbar. The tool menu opens as a compact top popover with grouped destinations instead of a full-height left rail.
- Replaced the wide product table with image-led product cards. Cards keep status, pricing mode, featured flags, edit and delete actions visible.
- Kept the product editor field-based; configuration items are collapsible, capped at eight, and shorter to scan.
- Added category `config_profile` so a newly created category can recommend relevant product configuration fields.
- Added image crop dialog with zoom and horizontal/vertical positioning for product, banner, portfolio, and testimonial images.

## Storefront
- Catalog shows category groups, each with a two-column product grid that remains two columns on mobile.
- Homepage shows active items selected by Owner using `show_on_home` and/or Best Seller.
- Product cards use “Beli Sekarang” and “Konsultasi”. Both open the product detail/configuration flow; Source Code remains consultation-first.
- Product detail shows summary, benefits, estimated turnaround, included/excluded scope, terms, and the category/package-specific configuration.
- Website package defaults preselect Landing Page, Company Profile, or Toko Online where appropriate.
- Removed the extra floating WhatsApp shortcut; contextual product and consultation CTAs remain.

## Notifications and platform settings
- Added Owner-managed announcement CRUD using `public.store_announcements`.
- Added a small one-line announcement strip below the homepage header and kept full announcements inside the notification bell panel.
- Moved Language and Dark/Light Theme into one compact preferences drawer.
- Centralized WhatsApp number, social URLs, WhatsApp Group and Channel links under Platform. Updating the WhatsApp number updates all WhatsApp CTAs; social links update footer icons.
- All WhatsApp messages append SIMBAA Group and Channel invitations at the end, as requested in the latest brief.

## Supabase
- Added `supabase/migration-v18-admin-storefront.sql`.
- Seeds seven service categories and fifteen starter products only when the slug is missing. Existing Owner-edited products are not overwritten.
- Adds explicit Data API grants while preserving RLS as the row-level control.
- Adds a public-read/Owner-manage policy pair for announcements.
- Preserves `store_settings.key/value`, existing Owner mapping, product data, banners, promotions, and media bucket.

## Assets
- Uses the previously supplied SIMBAA images already included in `assets/`.
- No new images were generated in v18.
- OG image remains deferred.
