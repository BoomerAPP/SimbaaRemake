# SIMBAA Fresh v19 — QA Report

## Static checks completed
- `node --check app.js`: PASS
- `node --check admin/admin.js`: PASS
- All project JavaScript files checked with Node syntax validation: see the final QA run noted below.
- All HTML files parsed: PASS
- Duplicate static HTML IDs: none found
- Local `src` / `href` references in HTML: no missing files found
- CSS parser (`tinycss2`) on all project CSS files: no top-level parse errors
- Admin overview, editor, sidebar, and storefront feature selectors were checked against the markup.
- Public HTML footers contain no `Owner access` links. The private Owner login panel is intentionally retained.
- No `Lihat website` shortcut remains in the admin toolbar.
- The v19 patch does not add a database migration or replace existing RLS/Owner authentication.

## Important runtime tests still required
These tests require the deployed Supabase project, a valid Owner session, and a real browser/device:
- Owner login, UID verification, session refresh, and logout.
- CRUD and storage uploads for each admin module with the existing project RLS policies.
- Product home selection, category filters, and promo rules against real database rows.
- The welcome voice behavior on the user's target Android browser. Browser autoplay policy can block sound until the first tap/key interaction; v19 retries on first interaction and offers a mute/enable control.
- Announcement display and per-session dismissal across pages.
- WhatsApp order/consultation links, product configuration, and mobile viewport behavior.

## Environment limitation
- Headless Chromium could not initialize reliably in this container and timed out even on `about:blank`; therefore no visual browser automation or end-to-end click test is claimed.
- No live SQL or Supabase API call was performed. Do not treat static checks as proof that hosted CRUD, RLS, Storage, Owner login, or WhatsApp flows work in production.
- The price helper is a gross-margin estimator, not an accounting system. It cannot know taxes, payment fees, refunds, server utilization, support time, or supplier cost unless those are included in the cost entered by the Owner. The cost itself is session-only and is not persisted.
- Promotion validation reduces obvious zero-price cases but cannot guarantee profitability without actual cost/margin data for every eligible product and bundle.
