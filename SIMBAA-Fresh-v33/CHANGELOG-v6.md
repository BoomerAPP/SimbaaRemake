# SIMBAA Fresh v6 — Premium Store Experience

## Based on v5, preserved
- Existing five-page storefront and five-item bottom navigation.
- Supabase Auth Owner login through the `simbaa-owner-login` Edge Function.
- Product/category/banner/promotion/portfolio/testimonial/FAQ management.
- Three-slide swipeable homepage banner rail and Best Seller section.
- Dynamic product configuration fields and WhatsApp order summary.
- Dark/light theme and Indonesian/English switch.
- Existing storage bucket and media upload path.

## v6 improvements
- Re-composed homepage hero: mascot sits inside a circular visual beside and behind the headline, with the text layer kept above it.
- Removed `mix-blend-mode: screen` from mascot artwork. The About mascot now uses a dedicated dark circular stage, so it remains visible in light mode.
- Updated discovery copy and service shortcut cards; two-column shortcut layout with aligned SVG icons.
- Product catalog is a two-column mobile-first grid with product avatars, status, reference price, Best Seller badge, and separate “Beli Sekarang” / “Detail Produk” actions.
- Product details show the dynamic configuration form, scope, turnaround, inclusions/exclusions, terms, and matching active promotion details.
- Promotions can be linked to a specific product from the Owner dashboard; unlinked promotions remain store-wide.
- About page keeps Owner-managed portfolio items and adds a customer review submission form.
- Customer reviews are submitted through a server-side Edge Function, rate-limited using HMAC-hashed network identifiers, held privately for moderation, and only published after Owner approval.
- Owner dashboard adds an incoming review queue; approval is idempotent to avoid duplicate published reviews if an action is retried.
- Additional light-mode contrast refinements for controls, secondary text, chips, and promo notes.

## Notes
- `supabase/migration-v6-portfolio-reviews.sql` is additive and must run after v5 migration.
- `supabase/functions/simbaa-review-submit/index.ts` must be deployed as `simbaa-review-submit` with JWT verification disabled, as configured in `supabase/config.toml`. The function performs validation and rate limiting itself and uses server-only Supabase Secret keys.
- No Supabase SQL or Edge Function has been run against the user's live project from this workspace.
