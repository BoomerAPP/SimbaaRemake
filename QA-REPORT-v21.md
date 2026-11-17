# QA Report — SIMBAA Fresh v21

## Static checks

| Check | Result |
|---|---|
| `node --check app.js` | PASS |
| `node --check admin/admin.js` | PASS |
| Parse 7 HTML documents with lxml | PASS |
| Duplicate HTML IDs | None found after removing stale duplicate product-modal markup from `index.html` and `layanan.html` |
| Local `src` / `href` references | No missing local references |
| Parse `style.css` and `admin/admin.css` with tinycss2 | No parse errors |
| OG image | JPEG 1200×630 |
| Intro audio | MP3 generated, approx. 46.9 seconds |

## Fix found during diagnosis
- `index.html` and `layanan.html` contained an obsolete duplicate fragment of the product modal after the current modal was already closed. This created duplicate IDs for `configFields`, `consultWhatsApp`, `modalDetails`, `modalPrice`, `modalStatus`, and `sendWhatsApp`. The stale fragment was removed; the current two-stage detail/checkout modal remains.

## Manual / environment-limited checks
- Supabase login, RLS, database reads/writes, storage uploads, order data, and WhatsApp deep links require the owner's live Supabase project and must be tested after deployment.
- Browser audio autoplay policy varies by browser/device. v21 attempts autoplay once per new session and deliberately does not retry after a user gesture. If the browser blocks sound, no voice will play in that session.
- Visual interaction testing on a physical Android device remains recommended.

## Database
No SQL migration or schema change.
