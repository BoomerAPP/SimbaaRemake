-- SIMBAA Fresh v5 — read-only verification queries
-- Run after migration-v5-experience.sql has completed successfully.

-- 1) Confirm the expected Owner mapping.
select u.email, o.username, o.user_id
from public.store_owners o
join auth.users u on u.id = o.user_id
where o.user_id = 'd75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid;

-- 2) Confirm key product fields consumed by the storefront/admin.
select column_name, data_type, is_nullable
from information_schema.columns
where table_schema = 'public'
  and table_name = 'products'
  and column_name in (
    'category', 'category_id', 'name_en', 'description_en', 'price',
    'details', 'turnaround_text', 'includes_text', 'exclusions_text',
    'terms_text', 'configuration_fields', 'is_best_seller', 'status'
  )
order by column_name;

-- 3) Confirm at least three banner slots are available.
select id, sort_order, title, is_active
from public.store_banners
order by sort_order
limit 3;

-- 4) Review public/Owner policies applied by v5.
select tablename, policyname, cmd, roles
from pg_policies
where schemaname = 'public'
  and tablename in (
    'categories', 'products', 'store_banners', 'promotions',
    'portfolio_items', 'testimonials', 'faqs', 'store_activity_logs'
  )
order by tablename, policyname;

-- 5) Confirm the media bucket exists.
select id, name, public, file_size_limit
from storage.buckets
where id = 'simbaa-store-media';
