# QA Report — SIMBAA Fresh v20

## Static checks

| Check | Result |
|---|---|
| `node --check app.js` | PASS |
| `node --check admin/admin.js` | PASS |
| Parse 7 HTML documents using lxml | PASS |
| Duplicate HTML IDs | None found |
| Parse `style.css` and `admin/admin.css` using tinycss2 | No parse errors |
| Local `src` / `href` references | No missing local references found |
| OG image | JPEG 1200×630, generated and present |

## Manual / environment-limited checks
- Chromium headless startup timed out in this container, so a reliable visual screenshot or automated click-through test was not completed.
- Supabase login, RLS permissions, database reads/writes, uploads, and live order/WhatsApp flow require the project's live credentials and were not end-to-end tested here.
- Speech voice and autoplay behavior vary by Android/browser voice pack and must be verified on a real phone. The site has an automatic attempt and first-interaction fallback; unmuted autoplay cannot be guaranteed by the website.
- Open Graph preview caching should be refreshed/tested after deployment using the target social platform's preview debugger.

## Notes
No database schema or migration files were modified for v20.
