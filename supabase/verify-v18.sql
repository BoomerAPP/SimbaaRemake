-- SIMBAA v18 read-only verification. Run after migration-v18-admin-storefront.sql.
SELECT 'products' AS table_name, count(*) AS total, count(*) FILTER (WHERE is_active) AS active FROM public.products
UNION ALL SELECT 'categories', count(*), count(*) FILTER (WHERE is_active) FROM public.categories
UNION ALL SELECT 'announcements', count(*), count(*) FILTER (WHERE is_active) FROM public.store_announcements;

SELECT name, slug, config_profile, is_active FROM public.categories ORDER BY sort_order;
SELECT name, slug, category, price_type, price, is_active, show_on_home FROM public.products ORDER BY sort_order;
SELECT policyname, roles, cmd, qual, with_check FROM pg_policies WHERE schemaname='public' AND tablename='store_announcements';
SELECT grantee, table_name, privilege_type FROM information_schema.role_table_grants WHERE table_schema='public' AND table_name IN ('products','categories','store_announcements') AND grantee IN ('anon','authenticated') ORDER BY table_name, grantee, privilege_type;

SELECT c.relname AS table_name, c.relrowsecurity AS rls_enabled
FROM pg_class c JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public' AND c.relname IN ('products','categories','store_announcements') ORDER BY c.relname;

SELECT conname, pg_get_constraintdef(oid) AS definition
FROM pg_constraint WHERE conrelid='public.products'::regclass AND conname='products_price_type_check';
