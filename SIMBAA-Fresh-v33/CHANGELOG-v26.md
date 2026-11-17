# SIMBAA Fresh v26 — Settings Subpages & Music Studio

- Mempertahankan urutan empat menu utama dashboard: Overview, Katalog, Konten & promo, Pengaturan.
- Menambahkan submenu Pengaturan beranda, Pengaturan tampilan, Music Studio, WhatsApp & komunikasi, SEO & Metadata, dan Informasi & kebijakan.
- Memisahkan pengelolaan playlist dari Toko & kontak ke submenu Music Studio tersendiri.
- Mengubah tampilan playlist admin menjadi daftar vertikal responsif dengan urutan naik/turun, preview, default, edit judul/artis/cover, dan hapus.
- Menambahkan upload banyak file audio dengan validasi format serta batas 20 MB per file.
- Menambahkan tautan audio HTTPS langsung dan Spotify Embed untuk track, album, atau playlist.
- Menambahkan tombol import enam pilihan Spotify (deduplikasi berdasarkan ID) tanpa otomatis menimpa playlist yang telah ada.
- Menambahkan pengaturan publik beranda: tampil/sembunyikan, urutan unik, judul/subtitle section, produk unggulan, CTA, dan banner utama.
- Menambahkan pengaturan tampilan, metadata sosial/SEO, template pesan WhatsApp dengan preview, dan ringkasan kebijakan toko.
- Menjaga kompatibilitas playlist/audio lama melalui fallback `audio_intro_url`.
- Tidak mengubah atau menambahkan migration SQL. Tidak menghapus tabel atau data produk, pelanggan, order, promo, autentikasi, maupun admin.
