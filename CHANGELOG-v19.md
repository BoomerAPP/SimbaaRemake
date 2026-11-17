# SIMBAA Fresh v19 — Admin & Storefront Usability Remake

## Admin dashboard
- Reorganized admin navigation into Ringkasan, Katalog, Konten & promo, and Pengaturan. Each group opens its own feature list from a hamburger drawer.
- Added a real dashboard overview with quick actions for products, promotions, portfolio, announcements, and activity history.
- Removed the admin toolbar's website shortcut. The public footer Owner Access links were removed; the private Owner sign-in and UID verification remain intact.
- Added language and dark/light appearance controls at the bottom of the drawer. Admin theme shares the existing `simbaa-theme` preference; the navigation and dashboard tagline follow the language preference.
- Product list now has search, category chips, grouped cards, status controls, and clearer home/Best Seller flags.
- Product, category, promotion, portfolio, testimonial, FAQ, and announcement forms use one focused editor at a time. The background list stays visible but is blocked until the editor is saved or cancelled. Escape closes the active editor.
- Product editor fields use a two-column layout on larger screens and compact responsive columns on mobile. Image upload/crop and all existing CRUD actions are retained.
- Added a session-only internal price calculator: given total cost and target gross margin, it suggests a rounded selling price. Cost input is not saved to the database or sent to visitors.
- Promotion validation rejects a 100% or greater percentage discount, fixed discounts that equal/exceed a linked product price, and fixed global discounts without a minimum order at least as large as the discount.
- Activity history has a clear-all action with confirmation; after clearing, no new “clear history” row is inserted.

## Storefront
- Home selection is controlled only by `show_on_home` and `is_active`. Best Seller remains a visual badge and does not add a product to the home selection by itself.
- Home service shortcuts and selected products use horizontal swipe rails; “Semua layanan” links directly to the full catalog.
- Portfolio is placed immediately after the selected-services section so visitors can see evidence of work earlier. Publish only real projects with permission, and mark demo projects honestly.
- Included/excluded scope, benefits, specifications, delivery estimates, and terms are shown as product information accordions, not buyer form fields.
- All required buyer configuration fields remain visible. Optional fields beyond the first three are placed under a collapsed “Konfigurasi tambahan” section. Buyer name, phone, and notes remain optional and collapsed. Consultation can be sent without completing required purchase configuration, reducing unnecessary friction.
- Product detail information is more compact; the consultation and purchase actions have consistent sizing on the service page.
- Active announcements appear once per browser tab session per announcement, with a dismiss action and optional CTA. The update panel and home announcement strip remain available.
- Added a welcome voice control across public pages. It attempts playback on entry once per browser tab session and retries on first pointer/keyboard interaction if autoplay is blocked; visitors can mute/enable it.
- Existing gold/dark visual identity, typography, art assets, content, and Supabase data conventions are preserved.

## Database and deployment
- No new table or migration is introduced by v19. It reuses the v18 schema and existing `store_settings`, `products`, `categories`, `promotions`, `portfolio_items`, `store_announcements`, and `store_activity_logs` structures.
- Deploy the complete v19 source folder. Keep the frontend Supabase key as Publishable/anon only; never place a service-role/Secret key in browser code.
