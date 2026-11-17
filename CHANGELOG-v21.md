# SIMBAA Fresh v21 — Cinematic Voice & Conversion Polish

## Perubahan utama
- Voice intro tidak lagi memiliki tombol aktif/nonaktif manual.
- Intro hanya mencoba autoplay saat sesi baru dibuka. Jika browser menolak autoplay, audio tidak dipaksa berjalan dan tidak ada retry tersembunyi saat pengunjung menekan layar.
- Audio intro diperbarui menjadi narasi brand berbahasa Indonesia dengan jeda sinematik, ambience sintetis orisinal, logo sting, dan mixing yang lebih terkontrol.
- Visualizer intro hanya muncul ketika audio benar-benar mulai diputar.
- OG image diperbarui ke komposisi hitam-emas 1200×630 dengan ruang teks, maskot SIMBAA, dan latar teknologi sinematik.
- Identitas visual, struktur Supabase, autentikasi, dan data katalog tidak diubah.

## Tetap dipertahankan dari v20
- Sidebar admin vertikal dan drawer hamburger mobile.
- Submenu accordion untuk Katalog, Konten & Promo, dan Pengaturan.
- Form editor terfokus dalam modal/drawer dengan backdrop; editor lain tidak menumpuk.
- Katalog produk berbasis kategori.
- Carousel Pilihan SIMBAA dan Best Seller satu produk per slide, tombol panah dan indikator yang dapat diklik.
- Pengumuman visual dan popup komunitas berbasis sesi.
- Produk beranda hanya mengambil produk aktif yang dipilih admin melalui `show_on_home`.

## Batasan autoplay
Browser modern dapat menolak audio bersuara yang dimulai tanpa gestur pengguna. Pada kondisi tersebut, intro tidak akan diputar; tidak ada cara yang dapat menjamin autoplay bersuara di semua browser. Audio akan berjalan otomatis hanya pada browser/perangkat yang mengizinkannya.

## Database
Tidak ada SQL migration. Tidak ada perubahan schema, RLS, autentikasi, atau data bisnis.
