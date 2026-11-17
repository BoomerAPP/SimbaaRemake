# SIMBAA Fresh v14

- Bound `supabase/config.toml` to the existing Supabase project ref.
- Fixed username login CORS preflight by allowing the `authorization` header required by browser Supabase client invocation.
- Added a consolidated additive migration for the existing key/value `store_settings` schema, Owner-only activity DELETE, login rate-limit table privileges, and username lookup index.
- Added read-only verification for Owner mapping, RLS, settings, media bucket, policies, and content counts.
- Added deployment and end-to-end test instructions.
- No Auth password, Owner mapping, product, category, banner, or other content rows are reset.
