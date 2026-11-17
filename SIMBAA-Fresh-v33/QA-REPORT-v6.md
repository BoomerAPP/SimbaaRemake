# SIMBAA v6 QA Report

## Static checks completed
- `node --check app.js`
- `node --check admin/admin.js`
- HTML parser pass for all five storefront pages and `Simbaa.html`
- Required assets and source files present
- Migration and verification SQL files present
- Owner login Edge Function retained; review submission Edge Function added
- ZIP integrity checked after packaging

## Manual checks still required
1. Supabase v6 migration executes successfully after v5.
2. `simbaa-review-submit` deploys and accepts a valid consented submission.
3. Review intake is not publicly readable; public direct insert is denied.
4. Owner sees pending reviews and can approve/reject them.
5. Approval creates one published testimonial even if the approval action is retried.
6. Product-specific promotion is saved, loaded, and shown only on the intended product.
7. Product images, details, dynamic configuration, and WhatsApp summary work on mobile.
8. Hero and About mascot remain visible in both dark and light modes.
9. Verify contrast, touch targets, modal focus, and bottom navigation on a real Android device.

## Limits
No live Supabase or Vercel deployment was performed from this build environment. Static validation is not a substitute for device/browser and backend integration testing.
