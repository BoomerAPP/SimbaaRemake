# QA Report — SIMBAA Fresh v24

## Static checks — PASS
- `node --check app.js` — PASS
- `node --check admin/admin.js` — PASS
- `Simbaa.html` duplicate IDs — none found
- CSS parsing (`style.css`, `admin/admin.css`, `admin/v22-admin.css`) — PASS, no parse errors
- Welcome voice initializer removed; music player initializer is used after settings load.

## Implemented
- Dynamic Island with SIMBAA brand icon, Play/Pause, volume, title, visualizer, optional Spotify open-link.
- Compact icon state after scrolling; tapping the brand icon opens controls.
- Music playback capped at 60 seconds per play.
- Admin settings for enable/disable, title, local path/HTTPS audio URL, default volume, Spotify URL.
- Existing black/charcoal and subtle gold gradient theme retained.
- Existing WhatsApp template implementation left unchanged.

## Not verified in this environment
- Live Supabase login and saving/loading settings.
- Audio playback from the owner's future MP3/OGG file and remote hosting.
- Android browser behavior and actual visual positioning across devices.

## Important
- No new SQL migration is required; settings are stored as extra keys in the existing JSONB value.
- No actual 60-second party track is bundled. The owner must add a licensed MP3/OGG file in `assets/audio/` or enter a direct HTTPS audio-file URL.
- Spotify URLs are external open links only; they are not used as direct audio sources and are not controlled by the island volume slider.
- No product, price, category, order, customer, admin, auth, or RLS data is deleted or modified.
