# SIMBAA v5 — Customer Experience Diagnosis

## Scope and confidence
This diagnosis is based on the screenshots supplied in this conversation and a static review of the SIMBAA source. It is a heuristic review—not a measured bounce-rate audit, customer interview, or live production test. Conversion or bounce-rate improvements must be validated with real usage data.

## Friction likely to make visitors leave

1. **Mascot/hero composition feels detached.** In the screenshots, the mascot sits low, nearly touches the card edge, and competes with the text. v5 moves the mascot to the top of the mobile hero before the headline and gives it a defined visual stage.
2. **The first screen does not make the next step obvious enough.** Visitors need a visible primary action, a simple search, and service shortcuts. v5 keeps the first actions prominent and places three swipeable information banners immediately after the hero.
3. **A broken or empty banner/catalog looks abandoned.** If the database has no active banners, v5 shows three truthful fallback slides. Product failures show a plain helpful message instead of raw database errors.
4. **Visitors may not know which service fits them.** Search, category shortcuts, labels, and a direct consultation route reduce the amount of guessing.
5. **Price ambiguity creates distrust.** The storefront labels values as reference prices where applicable and the WhatsApp handoff requests final price, scope, availability, timeline, terms, and official payment details before the customer agrees.
6. **Service status is not self-explanatory.** Every product can show Ready, Custom, or Pre-order with a clear label.
7. **Configuration forms can feel intimidating.** Only the fields defined by the Owner for that product are displayed. Required and typed inputs are validated before opening WhatsApp. The form also separates buyer name and WhatsApp contact. Product details can show turnaround, included work, exclusions, and service terms before the customer sends a request.
8. **WhatsApp messages that omit configuration cause repeated questions.** v5 sends the selected product and field values plus contact and notes, starting with “Halo Admin SIMBAA 👋✨”.
9. **Unsupported claims can damage the brand.** Fake reviews, unearned “Best Seller” claims, invented usage numbers, uptime guarantees, fake discounts, or unapproved portfolio items must not be published. The CMS requires explicit consent before testimonial publication; the Owner must still enter truthful content.
10. **Poor mobile nav or light-mode contrast can feel broken.** v5 keeps five main destinations, fixed safe-area spacing, explicit text colors, and theme-aware controls.

## Content and UI improvements included
- Hero mascot positioned at the top of the visual stack on mobile; heading and copy follow it.
- Three horizontal carousel slides with swipe, dots, counter, and arrow controls. Default slides explain service discovery, reference details, and custom consultation rather than claiming an unsupported discount.
- Service search and visual shortcuts.
- Best Seller section only; no duplicate “Pilihan SIMBAA” section.
- Product card details: category, description, reference price, status, and detail action.
- Dynamic configuration form and contextual WhatsApp handoff.
- Clear order steps, payment-safety reminder, FAQs on both home and help pages, optional portfolio/testimonials, and support CTA with mascot above the copy.
- Owner dashboard for products, banners, promotions, portfolio, testimonials, FAQ, and activity log.

## Additional recommendations before public marketing

- Publish concise Service Terms, Privacy Notice, Refund/Revision policy, and an official payment policy. Keep the actual terms consistent with how SIMBAA operates.
- Add product-level turnaround ranges and explicit exclusions only when the team can meet them consistently.
- Offer a written quotation or order summary in WhatsApp before taking payment.
- Add a status/incident notice for hosting/server services if SIMBAA can maintain it reliably.
- Use compressed WebP/AVIF banners and lazy-load non-hero images.
- Add Cloudflare/WAF or Turnstile for login rate limiting and bot mitigation.
- Keep backups before migrations and use a staging Supabase/Vercel deployment for future changes.
- Measure aggregate events such as catalog search, product detail open, banner click, and WhatsApp click only with a clear privacy notice. Do not log password, private chat text, or sensitive form values. Do not claim lower bounce rates until actual analytics show it.
