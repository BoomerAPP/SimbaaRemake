# SIMBAA v8.0.0

## Homepage
- Rebuilt the hero as a left-aligned text column beside the official transparent SIMBAA mascot.
- Preserved the exact requested Indonesian copy and clear CTA placement.
- Removed carousel arrow buttons on all public pages; banners remain manually swipeable with snap points and pagination dots.
- Added a privacy-friendly recently viewed section using localStorage only (no customer account or new tracking table).

## Product configuration and WhatsApp
- Shows up to four product-specific configuration fields first; additional fields are tucked into a compact disclosure.
- Buyer name, phone, and notes are optional and collapsed by default.
- Adds an optional product-eligible promotion selector.
- WhatsApp summary includes only values the customer selected/entered, selected promotion, product reference price/status/details, and the requested greeting.

## Owner login
- Email login now uses Supabase Auth directly and then verifies the resulting UID against `store_owners`.
- Username login continues through the `simbaa-owner-login` Edge Function.
- Login errors distinguish a missing/unpublished function, rate limit, and credentials mismatch.
- Edge Function reads current Supabase publishable/secret key maps and tolerates older legacy key environment variables.
- Added an additive login-guard migration and read-only verification query. No Auth account or password is created, deleted, or modified.

## Compatibility
- Existing pages, catalogs, categories, banners, promos, portfolio, reviews, Owner dashboard, dark/light mode, and existing assets are retained.

- Login Owner: migration v8 now explicitly grants authenticated SELECT on `store_owners` with a row policy restricted to `auth.uid()`, resolving a common Owner-verification failure while preserving owner-only visibility.
- Username login Edge Function now returns a specific 503 setup error when Owner mapping/schema lookup fails, instead of incorrectly reporting wrong credentials. Persistent throttling is used when its table is available, with an in-memory fallback if the migration has not yet been applied.
