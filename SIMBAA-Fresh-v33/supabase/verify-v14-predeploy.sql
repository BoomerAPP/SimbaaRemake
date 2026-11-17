-- SIMBAA v14 READ-ONLY VERIFICATION
-- Run after migration-v14-predeploy.sql and Edge Function deployment.

-- A. Owner mapping: must return the expected existing UID, username and true.
SELECT so.user_id, so.username, (u.id IS NOT NULL) AS auth_user_exists
FROM public.store_owners so
LEFT JOIN auth.users u ON u.id=so.user_id
WHERE so.user_id='d75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid;

-- B. Required tables and RLS.
SELECT c.relname AS table_name, c.relrowsecurity AS rls_enabled
FROM pg_class c
JOIN pg_namespace n ON n.oid=c.relnamespace
WHERE n.nspname='public'
  AND c.relname IN (
    'store_owners','products','categories','promotions','store_settings',
    'store_banners','portfolio_items','testimonials','testimonial_submissions',
    'faqs','store_activity_logs','owner_login_attempts'
  )
ORDER BY c.relname;

-- C. Owner/public policies for critical tables.
SELECT tablename, policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname='public'
  AND tablename IN (
    'store_owners','products','categories','promotions','store_settings',
    'store_banners','portfolio_items','testimonials','testimonial_submissions',
    'faqs','store_activity_logs'
  )
ORDER BY tablename, policyname;

-- D. Store settings must be key/value, not id-based.
SELECT column_name, data_type
FROM information_schema.columns
WHERE table_schema='public' AND table_name='store_settings'
ORDER BY ordinal_position;

SELECT key, value, updated_at
FROM public.store_settings
WHERE key='main';

-- E. Storage bucket and policies.
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id='simbaa-store-media';

SELECT policyname, roles, cmd, qual, with_check
FROM pg_policies
WHERE schemaname='storage' AND tablename='objects'
  AND (coalesce(qual,'') ILIKE '%simbaa-store-media%'
    OR coalesce(with_check,'') ILIKE '%simbaa-store-media%')
ORDER BY policyname;

-- F. Current content counts. Zero is acceptable for not-yet-created content.
SELECT 'products' AS table_name, count(*) AS total FROM public.products
UNION ALL SELECT 'categories', count(*) FROM public.categories
UNION ALL SELECT 'promotions', count(*) FROM public.promotions
UNION ALL SELECT 'banners', count(*) FROM public.store_banners
UNION ALL SELECT 'portfolio', count(*) FROM public.portfolio_items
UNION ALL SELECT 'testimonials', count(*) FROM public.testimonials
UNION ALL SELECT 'testimonial_submissions', count(*) FROM public.testimonial_submissions
UNION ALL SELECT 'faqs', count(*) FROM public.faqs;
