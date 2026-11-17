# SIMBAA Fresh v13

- Fixed admin settings compatibility with the existing Supabase `store_settings(key, value, updated_at)` schema.
- Admin now loads the `main` JSONB document and saves it with `upsert(..., onConflict: 'key')`.
- Added additive migration `supabase/migration-v13-settings-keyvalue.sql`; it preserves existing key/value rows and never adds the incompatible `id`-based settings layout.
- Added `supabase/verify-v13-settings.sql` for post-migration checks.

Run the v13 migration after the existing base migrations. Do not run the v12 dashboard-settings migration on a database that already has the key/value `store_settings` table; use v13 instead.
