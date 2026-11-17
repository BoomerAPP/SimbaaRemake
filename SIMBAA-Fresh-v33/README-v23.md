# SIMBAA Fresh v23

Basis: SIMBAA Fresh v22. Tema, Supabase project binding, public key config, authentication, existing tables, RLS, and business data are retained.

## Deploy
1. Backup project/database and keep the current deployment ZIP.
2. Upload the complete contents of this folder to the same Vercel project. Do not upload only `Simbaa.html`; include `admin/`, `assets/`, `supabase-config.js`, CSS, and JS files.
3. In Supabase SQL Editor, run `supabase/migration-v23-product-copy-and-audio.sql` once. It does not change prices, auth, RLS, or delete records.
4. Open `/Simbaa.html` → Pengaturan Toko → URL audio intro. Paste a publicly accessible HTTPS MP3/OGG URL and save. Leave blank to use `assets/audio/simbaa-intro-v22.mp3`.
5. Test checkout and WhatsApp on mobile and desktop.

## Important behavior
- Audible autoplay is controlled by the browser. The website attempts autoplay and retries on the first user interaction if blocked; it cannot force sound before browser permission.
- Free subdomain/hosting/database options are explicitly described as limited provider free-tiers. They are not promised as unlimited production infrastructure.
- Product prices are deliberately not bulk-overwritten. VPS remains at the existing seed reference price; custom development remains consultation until real provider costs, API/license costs, labor, support, and target margin are confirmed.

## QA boundary
Static syntax, markup, CSS parsing, duplicate IDs, and local relative assets were checked. Live Supabase RLS/CRUD/storage, production audio hosting, and device-specific autoplay still require testing in the owner's environment.
