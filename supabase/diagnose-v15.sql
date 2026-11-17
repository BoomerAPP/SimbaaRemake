-- SIMBAA v15: READ-ONLY CONTENT / PROMOTION DIAGNOSTICS
-- Does not modify records.

-- 1) Why the promotion may not appear on the public Promo page.
SELECT
  id,
  name,
  code,
  promo_type,
  discount_value,
  minimum_order,
  product_id,
  is_active,
  starts_at,
  ends_at,
  (is_active = true
    AND (starts_at IS NULL OR starts_at <= now())
    AND (ends_at IS NULL OR ends_at >= now())) AS should_appear_publicly,
  now() AS database_now
FROM public.promotions
ORDER BY created_at DESC;

-- 2) Product home visibility and active flags.
SELECT id, name, price, is_active, is_best_seller, show_on_home, status
FROM public.products
ORDER BY sort_order, created_at DESC;

-- 3) Banner targets: each active banner CTA should have a destination.
SELECT id, label, title, is_active, image_url, target_url, cta, sort_order
FROM public.store_banners
ORDER BY sort_order;

-- 4) Current public business settings are stored inside JSONB value.
SELECT key, value
FROM public.store_settings
WHERE key = 'main';

-- 5) Confirm the moderation tables and columns exist.
SELECT table_name, column_name, data_type, is_nullable
FROM information_schema.columns
WHERE table_schema='public'
  AND table_name IN ('testimonials','testimonial_submissions')
ORDER BY table_name, ordinal_position;

-- 6) Storage bucket existence (image uploads).
SELECT id, name, public, file_size_limit, allowed_mime_types
FROM storage.buckets
WHERE id='simbaa-store-media';
