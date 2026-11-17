# SIMBAA v11 — Simple Owner Workspace

- Admin navigation is simplified into Ringkasan, Katalog, Konten, and Pengaturan with contextual submenus.
- Preserved existing management modules: products, categories, banners, promotions, portfolio, testimonials, incoming reviews, FAQs, and activity history.
- Dashboard metrics now include total products, active products, active Best Sellers, published portfolio, active promotions, and pending reviews.
- Data refresh uses independent table requests: one unavailable table no longer blocks the other admin modules from rendering. Errors are surfaced in the dashboard toast.
- Added Owner-only clear activity history action and additive SQL policy migration `supabase/migration-v11-admin-history.sql`.
- Included the username Owner login Edge Function from v10, with `store_owners` lookup selecting only `user_id, username`.
- Improved mobile navigation, spacing, stat cards, and panel transitions while keeping the black-and-gold SIMBAA direction.

## Important
- Run `migration-v11-admin-history.sql` only after the existing v5 schema migration. It only adds the Owner DELETE policy for activity logs.
- Deploy username login function: `supabase functions deploy simbaa-owner-login --no-verify-jwt`.
- Live Supabase CRUD, RLS, Storage, and browser interactions still require testing against the owner's actual project. Static checks are not a substitute for live verification.
