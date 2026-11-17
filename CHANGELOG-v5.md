# SIMBAA Fresh v5 — Premium Experience

## Visual and content
- Reworked the home hero so the SIMBAA lion mascot is the first visual element above the copy on mobile, instead of sitting at the card bottom.
- Reworked the Help hero with the mascot above the help headline and CTA.
- Refined typography with Manrope body text and Outfit display headings, increased spacing consistency, premium gold/black surfaces, stronger icon alignment, and improved light-mode contrast.
- Kept the rounded language selector, SVG sun/moon theme toggle, floating five-item bottom navigation, and WhatsApp shortcut.
- Replaced the empty banner state with three honest, editable carousel slides and three factual fallbacks.
- Added service discovery search and visual category shortcuts.
- Added an FAQ preview on the homepage to answer common pre-order questions without forcing visitors to leave the first page.
- Seeded seven standard categories only when missing; category management supports create/edit/activate/delete with safeguards for categories used by existing products.
- Removed the separate “Pilihan SIMBAA” section; homepage features Best Seller only.
- Expanded trust copy around order steps, scope, reference pricing, confirmation, and payment safety.

## Storefront features
- Product cards display avatar, category, status (Ready / Custom / Pre-order), reference price, and details/configuration CTA.
- Added product-level fields for realistic turnaround, included scope, exclusions, and terms so customers can review important details before contacting the team.
- Separated customer name and WhatsApp contact fields; browser validation now checks required and typed configuration inputs before creating the order message.
- Product detail modal builds text, textarea, select, email, number, telephone, and URL inputs from product JSON configuration.
- WhatsApp message includes `Halo Admin SIMBAA 👋✨`, selected product, price reference, status, configuration, buyer contact, notes, and asks for final price/scope/timeline/terms/payment instructions.
- Promo, Portfolio, Testimonials, and FAQ use Supabase data with truthful fallbacks or hidden states. Testimonials are public only with recorded consent.
- Product/service failures show a customer-friendly message rather than raw Postgres error text.

## Owner console and security
- Admin UI accepts username or email in the Username field; the form only displays Username and Password.
- Username login is resolved server-side through the `simbaa-owner-login` Edge Function; it confirms the stored Owner UID and validates the password through Supabase Auth. No public email resolver RPC remains.
- Dashboard panels are hidden until an authenticated Supabase session is confirmed as an Owner.
- Admin workflows cover products (with reference price visible in the table), categories, three banners, promotions, portfolio, consented testimonials, FAQ, and Owner activity history.
- Migration checks the required SIMBAA base tables and exact Owner UID/email mapping before changing policies. It preserves existing data, seeds missing standard categories, replaces legacy policies on v5-managed tables, and restricts writes to the Owner helper. Storage writes are Owner-only.
- Owner login attempt records store HMAC-protected IP identifiers only; add WAF/Turnstile for additional public rate limiting.

## Preserved
- Existing SIMBAA pages and black/gold brand direction.
- Five-item mobile navigation.
- Existing product and owner rows; no password reset and no database wipe.

## Versioning
- v4 source should remain as a separate backup.
- v5 is a new package; future source changes should move to v6 and include a fresh changelog and additive migration when required.


## Final QA refinements
- The homepage search placeholder is translated with the selected language.
- The banner rail always fills exactly three slides: active admin banners first, then factual service/help fallbacks when an admin has not published all slots.
- Added clearer pre-payment safeguards: confirm final price, scope, delivery estimate, revisions/cancellation terms, and official payment instructions before payment; never send OTP/PIN/passwords in the initial order form.
- Percentage discounts are capped at 100% in the dashboard and database.
- Testimonial consent can be revoked when a testimonial is hidden or unpublished.
- Username login rate limiting counts failed attempts only; successful logins do not consume the failure quota.
- RLS policy replacement removes legacy permissive policies from v5-managed tables before adding the v5 policies, preventing old policies from widening access.
- Added a QA report that distinguishes static checks from live deployment checks that still require the owner's Supabase/Vercel project.
