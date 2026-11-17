# QA Report — SIMBAA Fresh v22

## Static checks (completed)
| Check | Result |
|---|---|
| `node --check app.js` | PASS |
| `node --check admin/admin.js` | PASS |
| Parse 7 HTML documents with lxml | PASS |
| Duplicate HTML IDs | None found |
| Parse `style.css`, `v22.css`, `admin/admin.css`, and `admin/v22-admin.css` with tinycss2 | PASS — no CSS parse errors |
| Relative local HTML asset references | PASS — no missing local references |
| Database migrations | None added |

## Implemented
- One compact service catalog banner.
- Pilihan SIMBAA and Best Seller use one visible product per slide with previous/next controls beside the card; swipe remains available.
- Footer separated into Community and Platform sections, with requested order.
- Entry announcement and community popups disabled; toolbar notification drawer and admin announcement CRUD remain.
- Audio island compact and positioned above the toolbar; its × control stops playback. Audio playback remains subject to browser autoplay permission.
- WhatsApp order template setting added to Store Settings, with placeholders and product configuration sourced from the selected product.
- Admin accordion submenu is moved directly under its selected group; icons and overview cards are compacted.
- Mobile checkout configuration fields use two columns where possible.
- Existing detail and checkout stages remain separate.

## Not verified in this environment
- Live Supabase login, RLS, CRUD, storage upload, and persistence.
- Real WhatsApp deep links on the user's device.
- Audio autoplay on every browser/device.
- Visual behavior on physical Android screen sizes.
- Facebook link is only displayed after an admin URL is configured.

## Data safety
No SQL migration, schema change, RLS change, auth change, or data deletion was made.
