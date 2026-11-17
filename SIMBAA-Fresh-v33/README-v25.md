# SIMBAA Fresh v25

## Update dari v24
- Playlist musik dapat dikelola langsung dari Admin Dashboard → Pengaturan → Toko & kontak → Musik website & Dynamic Island.
- Upload MP3/M4A/AAC/WAV/OGG/WebM hingga 20 MB, tambah URL audio HTTPS langsung, rename, delete, dan pilih default.
- Playlist disimpan pada `store_settings.value` (JSONB). File upload disimpan di Supabase Storage bucket `simbaa-audio`.

## Instalasi SQL
1. Backup database dan simpan ZIP v24.
2. Buka Supabase → SQL Editor.
3. Jalankan **hanya** `supabase/migration-v25-audio-playlist.sql` satu kali.
4. Jalankan `supabase/verify-v25-audio-playlist.sql` untuk memeriksa bucket dan policy.
5. Jangan menjalankan ulang migrasi v5/v12/v13/v14/v17/v18/v23.

## Penggunaan Admin
1. Login sebagai Owner.
2. Buka Pengaturan → Toko & kontak.
3. Upload audio atau tambahkan URL HTTPS langsung.
4. Pilih lagu default, ubah nama, atau hapus lagu.
5. Atur aktif/nonaktif, volume awal, mode urut/acak, dan batas 60 detik.
6. Simpan pengaturan toko.

## Catatan
- Link Spotify hanya menjadi pintasan untuk membuka Spotify, bukan audio sumber player.
- Volume player hanya mengatur volume audio website, bukan volume fisik Android.
- Browser memerlukan interaksi pengguna untuk memulai audio.
- Tes login Owner, upload, delete, playback Android, dan simpan pengaturan harus dilakukan pada project Supabase pemilik.
