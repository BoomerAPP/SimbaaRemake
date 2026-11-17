SELECT id,name,public,file_size_limit,allowed_mime_types FROM storage.buckets WHERE id='simbaa-audio';
SELECT policyname,cmd FROM pg_policies WHERE schemaname='storage' AND tablename='objects' AND policyname ILIKE '%simbaa audio%' ORDER BY policyname;
SELECT key, value->>'music_enabled' AS music_enabled, value->>'music_title' AS music_title, jsonb_array_length(COALESCE(value->'music_playlist','[]'::jsonb)) AS playlist_count FROM public.store_settings WHERE key='main';
