# SIMBAA v6 — Visitor Journey Diagnosis

This is a heuristic checklist based on the existing v5 source and user-provided mobile screenshots, not measured analytics.

## Likely friction points addressed
- Mascot competing with content or becoming visually faint in light mode: circular stage, normal blend mode, clear text layer.
- Unclear first action: three swipeable “Jelajahi” banners plus service search and category shortcuts.
- Catalog feels like a wall of products: two-column cards, avatar, category, availability, reference price, and two clear actions.
- Customers cannot judge the offer: product detail adds specifications, configuration, timeline, inclusions, exclusions, terms, and applicable promotion.
- Promotion ambiguity: optional product association, active dates, minimum order, and terms.
- Trust gap: Owner-managed portfolio and customer-submitted reviews held for moderation.
- Review spam / privacy: review submissions are not directly readable or insertable from the public browser; Edge Function validates consent and applies a short-window rate limit.

## Measurement plan after launch
Track only aggregate events with an appropriate privacy notice: banner interaction, service search with zero results, category selection, product detail open, required-field validation failures, WhatsApp handoff clicks, FAQ opens, and review form submissions. Do not collect passwords, message contents, or unnecessary personal data. Compare by page/device over a sufficient period before claiming a conversion or bounce-rate improvement.

## Further recommendations
1. Add Cloudflare Turnstile to public forms if spam appears despite rate limiting.
2. Add an image focal-point field for product and portfolio media so mobile crops remain consistent.
3. Add a quote validity period and scope revision note to manual WhatsApp quotations.
4. Create a lightweight project status update flow only if SIMBAA will maintain it operationally.
5. Add a service comparison feature after there are enough real packages to compare.
