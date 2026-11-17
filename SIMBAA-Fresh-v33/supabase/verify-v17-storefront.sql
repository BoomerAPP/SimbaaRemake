-- Run after migration-v17-storefront.sql
SELECT 'products' AS item, count(*) AS total,
       count(*) FILTER (WHERE is_active) AS active,
       count(*) FILTER (WHERE is_active AND (is_best_seller OR show_on_home)) AS home_featured
FROM public.products;

SELECT name, slug, category, price, price_type, is_active, is_best_seller, show_on_home, image_url
FROM public.products
ORDER BY sort_order, name;

SELECT policyname, roles, cmd, qual
FROM pg_policies
WHERE schemaname='public' AND tablename='products'
ORDER BY policyname;

SELECT key,
       value->>'website_url' AS website_url,
       value->>'tiktok_url' AS tiktok_url,
       value->>'whatsapp_community_group' AS community_group,
       value->>'whatsapp_channel' AS community_channel,
       jsonb_typeof(value->'platforms') AS platforms_type
FROM public.store_settings
WHERE key='main';
