-- SIMBAA v23: safe product-detail clarification and configurable welcome audio.
-- Run after the existing v18 storefront migration. This script does NOT change prices,
-- product status, categories, auth, RLS policies, or delete any records.

BEGIN;

DO $$
BEGIN
  IF to_regclass('public.products') IS NULL THEN
    RAISE EXCEPTION 'Tabel public.products tidak ditemukan. Jalankan migrasi storefront yang sudah digunakan project terlebih dahulu.';
  END IF;
  IF to_regclass('public.store_settings') IS NULL THEN
    RAISE EXCEPTION 'Tabel public.store_settings tidak ditemukan.';
  END IF;
END $$;

-- Clarify that free domain/hosting/database options are limited free tiers,
-- not an unlimited or guaranteed production package. Append only once.
UPDATE public.products
SET details = concat_ws(E'\n\n', NULLIF(BTRIM(details), ''),
  'Opsi biaya hemat: jika tersedia, proyek dapat memakai subdomain gratis serta free-tier hosting/database dari provider. Paket gratis memiliki batas resource, kuota, performa, dan kebijakan provider; tidak dijamin cocok untuk trafik produksi. Domain sendiri, resource tambahan, backup, dan upgrade dapat menimbulkan biaya terpisah. Ketersediaan akan dikonfirmasi sebelum pengerjaan.')
WHERE slug IN ('landing-page','company-profile','toko-online-ecommerce','dashboard-admin-system')
  AND COALESCE(details,'') NOT ILIKE '%free-tier hosting/database%';

-- Keep the current key/value settings model. The website and admin can now
-- read/write audio_intro_url inside the existing JSON value without a new column.
UPDATE public.store_settings
SET value = jsonb_set(COALESCE(value, '{}'::jsonb), '{audio_intro_url}', 'null'::jsonb, true),
    updated_at = now()
WHERE key = 'main'
  AND NOT (COALESCE(value, '{}'::jsonb) ? 'audio_intro_url');

COMMIT;

-- Verification: existing product prices are intentionally not modified.
SELECT slug, name, price, price_type,
       (details ILIKE '%free-tier hosting/database%') AS free_tier_terms_explained
FROM public.products
WHERE slug IN ('landing-page','company-profile','toko-online-ecommerce','dashboard-admin-system')
ORDER BY sort_order;

SELECT key, value->>'audio_intro_url' AS audio_intro_url
FROM public.store_settings
WHERE key = 'main';
