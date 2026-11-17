-- SIMBAA v11: allow the verified Owner to clear old activity history.
-- Additive policy only. Run after the existing v5/v6 schema migrations.
begin;

DO $$
BEGIN
  IF to_regclass('public.store_activity_logs') IS NULL THEN
    RAISE EXCEPTION 'public.store_activity_logs belum ada. Jalankan migration v5 terlebih dahulu.';
  END IF;
END $$;

DROP POLICY IF EXISTS "owner deletes activity history" ON public.store_activity_logs;
CREATE POLICY "owner deletes activity history"
  ON public.store_activity_logs
  FOR DELETE TO authenticated
  USING ((SELECT private.is_store_owner()));

GRANT DELETE ON public.store_activity_logs TO authenticated;

commit;
