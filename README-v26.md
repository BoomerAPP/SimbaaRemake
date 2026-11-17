# SIMBAA Fresh v26

## Ringkasan
v26 dibangun dari paket v25. Pembaruan berfokus pada Music Studio dan pengelompokan submenu Pengaturan, tanpa mengganti struktur data katalog atau pesanan.

## Struktur dashboard
Urutan menu utama tetap: **Overview → Katalog → Konten & promo → Pengaturan**.

Di dalam Pengaturan tersedia:
1. Pengaturan beranda — tampil/sembunyikan section, urutan, judul/subtitle, produk unggulan, CTA, dan banner utama.
2. Pengaturan tampilan — warna utama/aksen, latar charcoal/gradient, logo, ikon SIMBAA, favicon, dan tema gelap/terang.
3. Music Studio — upload audio banyak file, URL audio langsung, Spotify Embed, edit judul/artis/cover, preview, hapus, urutkan, musik default, volume awal MP3, batas durasi, dan mode acak.
4. Toko & kontak — identitas toko, domain, email publik, informasi harga.
5. WhatsApp & komunikasi — nomor CS, grup, channel, serta tautan sosial.
6. Template pesan — template konsultasi dan pemesanan per jenis layanan dengan preview.
7. SEO & Metadata — judul website, meta description, gambar preview sosial, favicon (disinkronkan dengan Pengaturan tampilan), dan template metadata halaman produk.
8. Informasi & kebijakan — syarat dan ketentuan, privasi, garansi, estimasi, dan pembayaran.
9. Riwayat aktivitas.

## Instalasi / pembaruan
1. Simpan backup source v25 dan backup database Supabase sebelum mengganti file.
2. Ekstrak ZIP v26, lalu salin isi folder `SIMBAA-Fresh-v26` ke root repository yang sama. Jangan menaruh folder rilis sebagai subfolder kedua.
3. Pertahankan `supabase-config.js` milik project kamu. Jangan mengganti URL Supabase atau anon/publishable key dengan nilai contoh.
4. Jangan menghapus folder `assets`, `supabase`, atau file konfigurasi lama.
5. v26 tidak menambahkan migration SQL dan tidak membutuhkan SQL baru. Migration audio v25 tetap tersedia dan tidak perlu dijalankan ulang bila bucket `simbaa-audio` sudah terpasang.
6. Commit dan deploy seperti proses project kamu sebelumnya.

## Mengaktifkan playlist
1. Login ke admin sebagai Owner.
2. Buka **Pengaturan → Music Studio**.
3. Tekan **Tambahkan 6 lagu** untuk memasukkan rekomendasi Spotify ke playlist yang sudah ada. Tindakan ini menambahkan lagu yang belum ada saja dan tidak menggandakan ID Spotify yang sama.
4. Untuk MP3, pilih satu atau beberapa file lalu tekan **Upload lagu**. Batas ukuran 20 MB per file mengikuti bucket audio v25.
5. Untuk Spotify lain, tempel tautan `open.spotify.com/track/...`, `/album/...`, atau `/playlist/...`, lalu tekan **Tambah Spotify**.
6. Atur urutan, default, judul/artis/cover, lalu tekan **Simpan pengaturan musik** untuk menyimpan status aktif, volume, mode, dan batas durasi.
7. Pastikan opsi **Aktifkan pemutar musik website** dicentang. Pengunjung membuka pulau musik dan menekan Play. Untuk Spotify, pengunjung menekan Play di dalam Spotify Embed.

## Catatan pemutaran
- MP3 dan URL file audio langsung diputar melalui HTML Audio. Volume awal, mode acak/urut, dan batas durasi berlaku untuk audio MP3/URL di player SIMBAA.
- Spotify diputar melalui iframe Embed resmi. Kontrol play/pause dan volume Spotify dikendalikan oleh player Spotify, bukan slider volume MP3 SIMBAA.
- Pemutaran tidak dipaksa autoplay. Browser membutuhkan interaksi pengguna; ketersediaan penuh lagu dapat mengikuti akun, wilayah, dan kebijakan Spotify. Spotify Embed memakai kontrol Spotify sendiri.
- Jika MP3 tidak dapat diputar, periksa file/URL, bucket `simbaa-audio`, dan policy Owner dari migration v25. Jangan menghapus playlist atau file Storage untuk memperbaiki audio.
- Jika v25 belum pernah memasang bucket audio, periksa statusnya dengan `supabase/verify-v25-audio-playlist.sql`; jalankan `supabase/migration-v25-audio-playlist.sql` satu kali hanya bila bucket/policy memang belum terpasang. Jangan jalankan ulang jika sudah ada.
- Volume player website tidak mengubah volume sistem Android.

## Catatan SEO / preview tautan
- Pengaturan judul dan meta diterapkan ketika JavaScript website memuat pengaturan dari Supabase. Crawler atau aplikasi chat yang hanya membaca HTML awal dan tidak menjalankan JavaScript dapat memakai metadata statis bawaan, bukan nilai dinamis dari dashboard. Verifikasi preview tautan setelah deploy; preview dinamis penuh memerlukan metadata yang dirender pada server/build atau HTML statis per halaman.

## Penyimpanan dan kompatibilitas
- Seluruh submenu baru menyimpan pengaturan dalam kolom JSONB `store_settings.value` pada key `main`.
- Playlist tetap disimpan pada `music_playlist`; file upload berada di bucket Storage `simbaa-audio`.
- Fallback `audio_intro_url` versi lama tetap dibaca bila playlist baru belum memiliki daftar lagu. Data audio lama tidak dihapus saat membuka Music Studio.
- Tidak ada perubahan SQL pada v26. Tidak ada operasi hapus/replace terhadap produk, kategori, promo, order, pelanggan, akun admin, atau tabel lain.

## Verifikasi yang masih perlu dilakukan pada project pemilik
Setelah deploy, lakukan test di Android: login Owner, import enam track, upload satu MP3 kecil, preview dari admin, aktifkan player, pilih MP3 dan Spotify dari pulau musik, tes Play/Pause, volume MP3, mode shuffle, lalu cek halaman beranda, katalog, detail, checkout, dan admin. Tes akhir Supabase perlu memakai project pemilik karena kredensial dan sesi live tidak tersedia di lingkungan build.
