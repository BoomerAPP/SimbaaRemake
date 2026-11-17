# QA v31

## Reproduksi sebelum perbaikan
Browser Chromium, iframe viewport 390px dengan tinggi 780px, v30 dan data storefront termuat: scrollWidth dokumen 1086px. Discovery section dan rail kategori berukuran 1070px. Navbar sendiri terukur di dalam viewport; halaman yang melebar menjelaskan mengapa mengubah posisi navbar saja tidak menyelesaikan masalah pada browser mobile.

## Browser setelah perbaikan
Beranda diuji pada lebar 320, 360, 390, 430, 768, 899, 900, 1024, 1280, 1440px. Semua menunjukkan scrollWidth sama dengan clientWidth dan tidak ada elemen bocor keluar viewport di luar rail yang memang menggulir. Scrollbar desktop iframe memakai 15px sehingga clientWidth = lebar iframe - 15px.

- 320–899px: menu desktop none, navbar bawah grid, kelima item muat dengan lebar sama.
- 900–1440px: menu desktop flex, navbar bawah none.
- Pada 390px: navbar x=12, lebar=351, kanan=363 dalam clientWidth 375. Lebar setiap item sekitar 66px.
- Enam halaman index, layanan, detail, promo, bantuan, tentang diperiksa pada 390px. Setelah pemuatan/transisi selesai, scrollWidth = clientWidth 375px.
- Footer beranda diperiksa secara visual pada tema gelap dan terang: kelima menu terlihat penuh, tidak bergeser ke luar layar.
- Panel preferensi dibuka, tema diganti lewat kontrol, panel ditutup; interaksi berhasil.
- Musik teramati menampilkan fallback autoplay diblokir dan pada sesi yang mengizinkan menampilkan Sedang diputar.

Pengujian ini menggunakan ukuran viewport browser/iframe, bukan perangkat Android fisik. Pembayaran/pengiriman WhatsApp dan perubahan admin live tidak dijalankan.

## Regresi fitur
node tests/interaction-regression.cjs: PASS untuk autoplay allowed/blocked, manual pause/resume, session pause, musik nonaktif, Spotify, volume, init idempotent, panel eksklusif, pemulihan fokus/inert, dan pengukuran header/navbar.

Perbandingan byte: app.js, chrome-layout-v30.js, site-motion-v29.js, supabase-config.js, seluruh admin/, supabase/ dan assets/ identik dengan v30. Seluruh tautan aset lokal pada enam halaman storefront valid.
