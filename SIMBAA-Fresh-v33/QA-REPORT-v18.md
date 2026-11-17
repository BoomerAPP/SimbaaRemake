# SIMBAA Fresh v18 — QA Report

## Static checks completed
- `node --check app.js`: PASS
- `node --check admin/admin.js`: PASS
- All 6 root HTML pages parsed successfully: PASS
- Duplicate static HTML IDs: none found
- Admin static DOM ID references: 146 checked, none missing
- CSS parsing (`style.css`, `admin/admin.css`): no top-level parse errors
- Local `src` / `href` asset references in HTML: no missing files found
- Product seed shape: 15 starter products, 19 fields per seed row
- SQL re-run behavior reviewed: categories/products use `ON CONFLICT (slug) DO NOTHING`; announcement table creation/policies and indexes are repeatable; existing settings links are filled only when blank
- Active source contains no hardcoded `localhost` or `127.0.0.1` URLs
- Existing image assets reused; no new image generation and no OG image

## Important runtime tests still required
These tests cannot be completed without the user's deployed Supabase project and Owner session:
- Run v18 migration in the target database and inspect `verify-v18.sql` output.
- Confirm public Data API reads products, categories, banners, promotions, portfolio, testimonials, FAQs, and announcements with RLS enabled.
- Confirm Owner create/edit/delete operations for products, categories, promotions, banners, portfolio, FAQs, platforms, and announcements.
- Confirm Storage uploads and WebP crop outputs in `simbaa-store-media`.
- Confirm the current Owner username login and session behavior remain valid.
- Confirm WhatsApp links open the configured admin number and append both community links.
- Confirm mobile interactions on the user's Android browser and current Vercel domain.

## Limitations
- No live SQL was executed against the user's Supabase project.
- No production login, RLS, CRUD, Storage, or WhatsApp runtime result is claimed.
- Browser visual automation was not completed in this environment; static checks are not a substitute for a live mobile test.
- Existing unknown product rows are preserved. Review and remove any accidental test products from Admin after deployment rather than deleting user data automatically.
