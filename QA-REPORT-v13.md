# QA v13

- `admin/admin.js`: JavaScript syntax checked.
- Settings read path statically verified against `key,value` schema.
- Settings write path statically verified with `onConflict: key`.
- Migration is additive and preserves existing settings rows.
- Live Supabase/RLS/Storage CRUD is not verified; it requires execution in the user's project.
