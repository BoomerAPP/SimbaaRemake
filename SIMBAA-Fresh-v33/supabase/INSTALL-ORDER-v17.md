# SIMBAA v17 — urutan pemasangan

## Sebelum mulai
1. Simpan backup source v15 dan jangan hapus project Supabase yang sedang digunakan.
2. Pastikan `supabase-config.js` mengarah ke project yang benar dan hanya berisi Publishable/anon key.
3. Jangan mengganti `store_owners`, Auth Owner, password, atau policy Owner dari file legacy.

## SQL
Jika migration v5 dan v14 sudah pernah berhasil dipasang pada database yang sama, jalankan **hanya**:

1. `migration-v17-storefront.sql`
2. `verify-v17-storefront.sql`

Jika migration v5 atau v14 belum pernah dipasang, hentikan dulu dan cocokkan schema serta Owner mapping yang sudah ada sebelum menjalankan urutan migrasi. Jangan menjalankan ulang file di `supabase/legacy/`.

Migration v17:
- menambah/menormalkan kolom yang dibutuhkan katalog tanpa menghapus data;
- menambahkan `price_type` jika belum ada;
- menambahkan produk starter hanya jika slug belum ada;
- tidak menimpa produk yang sudah diedit Owner;
- memberi SELECT ke role publik dengan RLS aktif dan hanya baris aktif yang dapat dibaca publik;
- mengisi domain dan TikTok default hanya bila nilai belum diatur.

Jika migration v16 sudah pernah dijalankan, v17 tetap aman dijalankan.

## Data API
Setelah SQL:
1. Buka Supabase Dashboard → Integrations → Data API.
2. Pastikan Data API aktif dan schema `public` diekspos.
3. Periksa `products` dapat dibaca melalui REST/Data API.
4. Jika tabel tidak tersedia, baca `DATA-API-TROUBLESHOOT-v17.md`.

## Source dan deploy
1. Extract `SIMBAA-Fresh-v17.zip`.
2. Periksa `supabase-config.js` sebelum deploy.
3. Jalankan website lokal untuk tes tampilan; localhost hanya alamat development.
4. Di Owner → Pengaturan → Toko & kontak, atur domain produksi `https://simbaa.my.id` (atau domain yang benar-benar digunakan).
5. Di Owner → Pengaturan → Platform, atur grup/channel dan URL sosial.
6. Deploy ke Vercel setelah tes katalog, promo, modal komunitas, tombol WhatsApp, dan dashboard.

Tidak ada migrasi yang mengubah kredensial Auth atau mapping Owner.
