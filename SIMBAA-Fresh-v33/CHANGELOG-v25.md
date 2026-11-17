# SIMBAA Fresh v25 — Admin Music Playlist

- Admin dapat upload audio ke Supabase Storage bucket `simbaa-audio` (maksimum 20 MB per file).
- Admin dapat menambah URL audio HTTPS langsung, mengganti nama, memilih musik default, dan menghapus lagu.
- Playlist tersimpan di `store_settings.value` JSONB; `audio_intro_url` dan `music_title` tetap disinkronkan untuk kompatibilitas versi lama.
- Website menampilkan island kecil berikon SIMBAA; panel musik berisi playlist, Play/Pause, sebelumnya/berikutnya, dan volume.
- Mode playlist urut/acak, durasi maksimal 60 detik atau sesuai durasi file.
- Musik tetap membutuhkan interaksi Play dari pengunjung; volume player tidak mengubah volume sistem HP.
- Ditambahkan migrasi SQL bucket audio terpisah dengan public read dan Owner-only upload/update/delete.
- Tidak menghapus atau mengubah data produk, kategori, promo, pesanan, pelanggan, akun admin, atau template WhatsApp.
