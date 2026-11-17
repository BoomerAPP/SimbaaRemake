-- SIMBAA v14 PRE-DEPLOY PATCH
-- Use this migration for the currently inspected schema.
-- It preserves existing records and does not recreate Owner/Auth accounts.
-- Do NOT run migration-v12-dashboard-settings.sql.

BEGIN;

DO $$
BEGIN
  IF to_regprocedure('private.is_store_owner()') IS NULL THEN
    RAISE EXCEPTION 'private.is_store_owner() tidak ditemukan. Hentikan; periksa migrasi dasar Owner.';
  END IF;
  IF to_regclass('public.store_owners') IS NULL
     OR to_regclass('public.products') IS NULL
     OR to_regclass('public.store_settings') IS NULL
     OR to_regclass('public.store_activity_logs') IS NULL THEN
    RAISE EXCEPTION 'Tabel inti SIMBAA belum lengkap. Tidak ada perubahan yang diterapkan.';
  END IF;
END $$;

-- 1. Preserve the existing key/value store settings schema.
DO $$
BEGIN
  IF NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='store_settings' AND column_name='key'
  ) OR NOT EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='store_settings' AND column_name='value'
  ) THEN
    RAISE EXCEPTION 'store_settings harus memiliki kolom key dan value. Migrasi dibatalkan tanpa mengubah data.';
  END IF;
END $$;

ALTER TABLE public.store_settings ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON TABLE public.store_settings FROM PUBLIC, anon, authenticated;
GRANT SELECT ON public.store_settings TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.store_settings TO authenticated;

DROP POLICY IF EXISTS "public reads store settings" ON public.store_settings;
DROP POLICY IF EXISTS "owner inserts store settings" ON public.store_settings;
DROP POLICY IF EXISTS "owner updates store settings" ON public.store_settings;
DROP POLICY IF EXISTS "owner deletes store settings" ON public.store_settings;
DROP POLICY IF EXISTS "owner manages store settings" ON public.store_settings;

CREATE POLICY "public reads store settings"
  ON public.store_settings FOR SELECT TO anon, authenticated
  USING (key = 'main');

CREATE POLICY "owner inserts store settings"
  ON public.store_settings FOR INSERT TO authenticated
  WITH CHECK ((SELECT private.is_store_owner()) AND key = 'main');

CREATE POLICY "owner updates store settings"
  ON public.store_settings FOR UPDATE TO authenticated
  USING ((SELECT private.is_store_owner()) AND key = 'main')
  WITH CHECK ((SELECT private.is_store_owner()) AND key = 'main');

CREATE POLICY "owner deletes store settings"
  ON public.store_settings FOR DELETE TO authenticated
  USING ((SELECT private.is_store_owner()) AND key = 'main');

INSERT INTO public.store_settings(key, value, updated_at)
VALUES (
  'main',
  jsonb_build_object(
    'brand_name','SIMBAA',
    'tagline','Your Digital Partner',
    'whatsapp_number','6282132043632',
    'contact_email','',
    'website_url','',
    'instagram_url','',
    'tiktok_url','',
    'youtube_url','',
    'price_zero_label','Hubungi untuk penawaran',
    'price_note','Harga yang tampil merupakan harga acuan. Harga akhir dikonfirmasi oleh admin sebelum pembayaran.',
    'order_note','Silakan konfirmasi ruang lingkup, total harga, estimasi, dan ketentuan melalui WhatsApp sebelum pembayaran.'
  ),
  now()
)
ON CONFLICT (key) DO NOTHING;

-- 2. Owner activity history: allow verified Owner to clear old records.
ALTER TABLE public.store_activity_logs ENABLE ROW LEVEL SECURITY;
GRANT SELECT, INSERT, DELETE ON public.store_activity_logs TO authenticated;

DROP POLICY IF EXISTS "owner deletes activity history" ON public.store_activity_logs;
CREATE POLICY "owner deletes activity history"
  ON public.store_activity_logs FOR DELETE TO authenticated
  USING ((SELECT private.is_store_owner()));

-- 3. Keep login rate-limit table server-only.
CREATE TABLE IF NOT EXISTS public.owner_login_attempts (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  ip_hash text NOT NULL,
  attempted_at timestamptz NOT NULL DEFAULT now()
);
CREATE INDEX IF NOT EXISTS owner_login_attempts_ip_time_idx
  ON public.owner_login_attempts(ip_hash, attempted_at DESC);
ALTER TABLE public.owner_login_attempts ENABLE ROW LEVEL SECURITY;
REVOKE ALL ON public.owner_login_attempts FROM PUBLIC, anon, authenticated;
GRANT SELECT, INSERT ON public.owner_login_attempts TO service_role;

-- 4. Ensure Owner username lookup is indexed without changing the current Owner mapping.
CREATE UNIQUE INDEX IF NOT EXISTS store_owners_username_lower_uq
  ON public.store_owners (lower(username))
  WHERE username IS NOT NULL;

COMMIT;
