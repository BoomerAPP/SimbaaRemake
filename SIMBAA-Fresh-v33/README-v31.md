# SIMBAA Fresh v31 — mobile width regression fix

Buka index.html dari folder hasil ekstraksi. Ganti seluruh isi paket saat memasang agar experience-v31.css ikut dimuat. Query versi pada CSS/JS storefront diperbarui untuk menghindari cache aset lama. Tidak perlu migrasi SQL.

## Perubahan
Penyebab halaman melebar telah direproduksi dalam browser: pada iframe mobile 390px, dokumen v30 memiliki scrollWidth 1086px. Setelah pengaturan admin menjadikan main sebagai flex column, margin-inline:auto pada section memungkinkan bagian discovery mengikuti lebar intrinsik seluruh kategori. Perbaikan sebelumnya hanya mengatur navbar, bukan sumber overflow ini.

v31 membatasi setiap anak langsung main pada 100% lebar kontainer dengan min-width:0. Bagian kategori dan banner tetap dapat digeser di dalam rail masing-masing; dokumen tidak ikut melebar. Navbar mobile memakai lima kolom sama lebar. Menu desktop tampil mulai 900px. Hero dan kartu unggulan kembali memakai susunan ringkas dua kolom yang mengacu pada v26; panah carousel mobile berada di bawah kartu dengan target sentuh 44px.

## Fitur tetap tersedia
app.js, chrome-layout-v30.js dan site-motion-v29.js identik byte dengan v30. Musik/autoplay sesuai izin browser, Play/Pause, volume, playlist/Spotify, notifikasi, preferensi tema/bahasa, checkout, pengurutan section admin, reveal teks dan transisi halaman tetap dipertahankan. Admin, SQL, konfigurasi Supabase dan aset juga identik.

## Hasil uji
Lihat QA-REPORT-v31.md. Kali ini browser preview berhasil dijalankan dan overflow direproduksi sebelum perbaikan, kemudian diukur setelah perbaikan.
