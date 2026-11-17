# SIMBAA Fresh v20 — Visual Upgrade

## Fokus rilis
Penyempurnaan visual dan navigasi berdasarkan tangkapan layar mobile, tanpa mengganti identitas visual hitam-emas SIMBAA atau mengubah schema Supabase.

## Perubahan

### Admin dashboard
- Sidebar admin sekarang menjadi navigasi vertikal di sisi kiri pada desktop.
- Di layar ponsel, sidebar menjadi drawer dari sisi kiri dengan backdrop dan tombol hamburger.
- Menu utama Ringkasan, Katalog, Konten & promo, dan Pengaturan mengaktifkan submenu yang relevan.
- Label submenu disembunyikan saat grup tidak memiliki submenu, sehingga tidak muncul area "FITUR MENU" kosong.
- Preferensi bahasa dan tema tetap di bagian bawah sidebar; tema admin mengikuti `simbaa-theme` yang sama dengan website.

### Beranda
- Shortcut kategori tetap berada tepat di bawah pencarian seperti layout awal.
- Ditambahkan tombol panah untuk menggeser kategori melalui klik, selain dukungan scroll sentuh.
- Produk pilihan admin diberi filter kategori, tombol panah sebelumnya/berikutnya, dan indikator posisi.
- Produk yang masuk bagian Pilihan SIMBAA tetap hanya produk aktif dengan `show_on_home=true`.

### Pengumuman
- Popup pengumuman entry memiliki visual header maskot, label broadcast, aksen glow, animasi masuk, dan action yang lebih jelas.
- Panel notifikasi ditingkatkan menjadi SIMBAA Newsroom dengan header visual.
- Popup komunitas tidak lagi langsung muncul menimpa popup pengumuman aktif.
- Pengumuman aktif tetap memakai data `store_announcements`; tidak ada perubahan tabel.

### Voice intro
- Sambutan diubah menjadi narasi beberapa segmen dengan jeda, tempo berbeda, dan visualizer.
- Intro menampilkan maskot dan identitas SIMBAA tanpa menutupi konten utama.
- Tombol suara tetap tersedia untuk mengaktifkan atau menonaktifkan voice.
- Browser tetap dapat membatasi autoplay; sistem mencoba otomatis dan memiliki fallback saat interaksi pertama.
- Suara menggunakan SpeechSynthesis/browser voice, bukan rekaman voice actor atau MP3 studio.

### Gambar dan social preview
- Ditambahkan `assets/og-simbaa.jpg`, gambar Open Graph 1200×630 dengan maskot SIMBAA dan branding yang sudah dirender langsung.
- Halaman publik utama menerima metadata Open Graph dan Twitter Large Image Card.
- Gambar produk diberi fallback lokal ketika URL gambar eksternal gagal dimuat.

## Database dan deployment
- Tidak ada SQL migration baru.
- Tidak ada perubahan schema, RLS, autentikasi, atau data produk.
- Pertahankan `supabase-config.js` milik project saat mengganti file website.
