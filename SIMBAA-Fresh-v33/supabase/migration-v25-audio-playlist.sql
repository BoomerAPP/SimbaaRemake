-- SIMBAA v25: dedicated public-read / Owner-write audio bucket for playlist uploads.
-- Additive only. Does not alter existing media bucket, catalog, orders, auth, or settings.
BEGIN;
DO $$ BEGIN
  IF to_regprocedure('private.is_store_owner()') IS NULL THEN
    RAISE EXCEPTION 'private.is_store_owner() tidak ditemukan. Jangan lanjutkan sebelum fungsi Owner tersedia.';
  END IF;
END $$;
INSERT INTO storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
VALUES (
  'simbaa-audio','simbaa-audio',true,20971520,
  ARRAY['audio/mpeg','audio/mp3','audio/mp4','audio/aac','audio/wav','audio/x-wav','audio/ogg','audio/webm']
)
ON CONFLICT(id) DO UPDATE SET
  public=true,
  file_size_limit=20971520,
  allowed_mime_types=EXCLUDED.allowed_mime_types;
DROP POLICY IF EXISTS "public reads simbaa audio" ON storage.objects;
DROP POLICY IF EXISTS "owner uploads simbaa audio" ON storage.objects;
DROP POLICY IF EXISTS "owner deletes simbaa audio" ON storage.objects;
DROP POLICY IF EXISTS "owner updates simbaa audio" ON storage.objects;
CREATE POLICY "public reads simbaa audio" ON storage.objects
  FOR SELECT TO anon, authenticated USING (bucket_id='simbaa-audio');
CREATE POLICY "owner uploads simbaa audio" ON storage.objects
  FOR INSERT TO authenticated WITH CHECK (bucket_id='simbaa-audio' AND (SELECT private.is_store_owner()));
CREATE POLICY "owner updates simbaa audio" ON storage.objects
  FOR UPDATE TO authenticated USING (bucket_id='simbaa-audio' AND (SELECT private.is_store_owner()))
  WITH CHECK (bucket_id='simbaa-audio' AND (SELECT private.is_store_owner()));
CREATE POLICY "owner deletes simbaa audio" ON storage.objects
  FOR DELETE TO authenticated USING (bucket_id='simbaa-audio' AND (SELECT private.is_store_owner()));
COMMIT;
-- Verify bucket and policies:
SELECT id,name,public,file_size_limit,allowed_mime_types FROM storage.buckets WHERE id='simbaa-audio';
SELECT policyname,cmd FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname ILIKE '%simbaa audio%';
