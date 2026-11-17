# QA SIMBAA v30

## Bukti dan diagnosis
Screenshot pengguna menunjukkan navbar keluar batas kanan, pencarian melebar, music island menimpa area navigasi, serta layout laptop dengan bagian konten yang tidak seimbang. v26 diperiksa sebagai referensi struktur mobile; style.css dan v22.css sama dengan dasar v29.

Penyebab terkonfirmasi di kode:
1. Music island fixed top 7–9px, left 50% menempati area header yang sama dengan logo/menu.
2. Drawer menggunakan top tetap 67/76px, sementara tinggi toolbar dan area musik berubah; navbar v28 z-index 190 berada di atas modal produk z-index 100.
3. updateMusicIsland memanggil $(id) tanpa '#', padahal helper menggunakan querySelector. Tombol Play/Pause tidak ditemukan.
4. initMusicPlayer tidak pernah mencoba autoplay.
5. Nilai slider volume ditimpa music_volume lama setiap update; handler input tidak memperbarui nilai settings lokal.
6. Handler scroll membangun ulang kontrol/playlist dan menutup playlist setiap scroll.
7. Aturan !important v22 masih memaksa tombol produk unggulan setinggi 31–36px meski v29 mencoba memperbesarnya.

Penyebab persis overflow navbar pada browser screenshot belum direproduksi dalam renderer. Perbaikannya menggunakan opposing fixed insets dan lebar auto agar tidak mengandalkan lebar persentase atau pemusatan transform, sekaligus mengunci lima kolom minmax(0,1fr).

## Pengujian yang dijalankan
- node --check app.js, site-motion-v29.js dan chrome-layout-v30.js: PASS.
- node tests/interaction-regression.cjs: PASS.
  - autoplay berhasil serta penolakan NotAllowedError;
  - Play/Pause dan label status;
  - Pause dalam sesi mencegah autoplay pada halaman berikut;
  - musik nonaktif/Spotify tidak memanggil Audio.play;
  - volume tetap tersimpan setelah update;
  - init ulang tidak menggandakan listener;
  - drawer saling eksklusif, fokus awal/pemulihan dan inert dipulihkan;
  - pengukuran tinggi header dan clearance navbar mobile/laptop.
- Uji regresi terhadap app.js v29 gagal pada autoplay count 0 vs expected 1, sesuai bug yang diperbaiki.
- Enam halaman storefront: referensi file lokal, satu navbar, satu viewport dan pemasangan script/CSS baru: PASS.
- admin/, supabase/ dan supabase-config.js identik byte terhadap paket v29: PASS.
- Keseimbangan kurung CSS: PASS (bukan pemeriksaan render atau parser CSS penuh).

## Belum diverifikasi
Browser headless tidak dapat berjalan karena pembatasan socket. Browser desktop dapat diluncurkan, tetapi kontrol/aksesibilitasnya tidak tersedia sehingga inspeksi halaman tidak berhasil. Tidak ada klaim pengujian screenshot/visual pada ukuran layar tertentu.

Supabase live, WhatsApp, audio nyata, izin autoplay browser pengguna, dan Spotify embed memerlukan uji perangkat. Autoplay bersuara tidak dapat dijamin oleh kode website; browser yang menolak akan menampilkan tombol Play.

## Uji perangkat yang perlu dilakukan
320/360/390/430px: kelima item navbar terlihat, tidak ada scroll horizontal halaman, toolbar dan musik terpisah. Buka notifikasi/preferensi lalu tutup via backdrop/Escape. Buka playlist, atur volume, Play/Pause. Scroll ke footer, buka produk dan checkout. Uji keyboard perangkat pada input. Uji juga 768/899/900/1024/1280/1440px serta rotasi dan browser Back/Forward. Uji autoplay baik pada browser yang mengizinkan maupun yang memblokirnya.
