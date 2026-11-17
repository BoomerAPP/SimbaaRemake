# SIMBAA v7 QA report

## Static checks
- All six public/admin HTML documents parsed successfully.
- `app.js` and `admin/admin.js` passed Node syntax checks.
- CSS parsed with zero parser errors.
- No missing local `src`/`href` asset references were found.
- New mascot cutout is RGBA with alpha range 0–255.
- ZIP integrity verified after packaging.

## Not yet tested
- Live Supabase connectivity or SQL execution.
- Supabase Edge Function deployment and public review submission.
- Owner login against the user's project.
- Actual WhatsApp order handoff.
- Visual testing on the user's Android phone in both themes.

## Release recommendation
Deploy to Vercel Preview first. Validate home layout, swipe carousel, 2-column service grid, all mascot placements, footer, catalog modal/configuration, Owner login, and light/dark contrast before production.
