# Troubleshooting produk tidak muncul — Supabase Data API

Migration v17 memberi `GRANT SELECT` ke `anon` dan `authenticated` serta memastikan RLS aktif dengan policy baca produk aktif. Namun, grant dan RLS saja belum cukup jika Data API dimatikan atau schema `public` tidak diizinkan untuk Data API.

1. Buka Supabase Dashboard → **Integrations → Data API**.
2. Pastikan **Enable Data API** aktif.
3. Pastikan schema `public` termasuk schema yang diekspos.
4. Pastikan tabel `products` tersedia melalui Data API.
5. Jalankan `verify-v17-storefront.sql` dan cek jumlah `active` lebih dari 0.
6. Di browser, buka Developer Tools → Network dan periksa request `/rest/v1/products`. Jika mendapat `42501`, cek grant; jika `PGRST`/schema cache, cek Data API exposure/schema; jika `200` dengan array kosong, cek `is_active` dan policy RLS.

Jangan mengatasi masalah dengan mematikan RLS atau memasukkan `service_role` ke frontend. Frontend hanya memakai Publishable/anon key.
