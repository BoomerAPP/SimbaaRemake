# SIMBAA v8 — Urutan pemasangan database dan login

Jangan reset database dan jangan buat ulang akun Owner.

## 0. Pertahankan konfigurasi yang sudah ada
Pastikan project Supabase yang dipakai adalah project SIMBAA baru yang berisi tabel `products`, `categories`, `store_banners`, `store_owners`, serta bucket `simbaa-store-media`. Pertahankan Owner yang sudah terverifikasi:
- Email Auth: `simbaagorncs@gmail.com`
- Username di `store_owners`: `SimbaaOwner`
- UID: `d75b59dd-de05-4a2a-8a76-a0cd72f0d289`

## 1. Migration v5 (hanya jika belum pernah berhasil dipasang)
Jalankan `migration-v5-experience.sql`, kemudian `verify-v5.sql`.
Migration v5 menyiapkan struktur kategori, banner, promosi, portfolio, FAQ, activity log, dan tabel percobaan login. Jangan jalankan file di `legacy/`.

## 2. Migration v6 (hanya jika belum pernah berhasil dipasang)
Jalankan `migration-v6-portfolio-reviews.sql`, kemudian `verify-v6.sql`.
Nilai `pending_reviews = 0` hanya berarti belum ada ulasan yang menunggu; itu bukan tes login.

## 3. Migration v8 login guard
Jalankan `migration-v8-login-guard.sql`, lalu `verify-v8-login.sql`.
Migration ini additive: menyiapkan kolom/index username, grant dan RLS baca baris Owner sendiri, serta tabel rate limit yang diperlukan Edge Function. Migration ini tidak mengubah password atau membuat akun baru.

## 4. Konfigurasi frontend
Isi `supabase-config.js` dengan Project URL dan Publishable/anon key. Jangan gunakan Secret/service_role key di file frontend.

## 5. Deploy Edge Function untuk login username
File sumber: `functions/simbaa-owner-login/index.ts`.
Nama fungsi harus persis `simbaa-owner-login` dan gateway JWT verification harus dimatikan karena pengguna belum memiliki sesi saat memanggil endpoint login. `config.toml` sudah memuat `verify_jwt = false`.

CLI dari root project:

```bash
supabase functions deploy simbaa-owner-login --no-verify-jwt
```

Edge Function menggunakan environment keys yang disediakan Supabase (`SUPABASE_SECRET_KEYS` dan `SUPABASE_PUBLISHABLE_KEYS`, atau legacy equivalents). Jangan menyalin secret ke frontend.

## 6. Tes login
- Email: langsung melalui Supabase Auth, lalu UID diverifikasi terhadap `store_owners`.
- Username: `SimbaaOwner`, diproses server-side melalui Edge Function, kemudian UID diverifikasi lagi pada frontend dan RLS.
- Akun non-Owner harus ditolak.

Jika username gagal tetapi email berhasil, periksa deploy/status Edge Function dan `config.toml`. Jika email Auth berhasil tetapi Owner check gagal, migration v8 sekarang menyiapkan SELECT policy `owner reads own record`; jalankan `verify-v8-login.sql` dan periksa RLS.
