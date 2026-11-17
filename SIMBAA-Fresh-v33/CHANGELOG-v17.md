# SIMBAA Fresh v17

## Fondasi dan kompatibilitas
- Source v15 dipakai sebagai baseline; halaman, modul, dan konfigurasi Owner tetap dipertahankan.
- Mengambil perbaikan harga dan aset banner yang telah diproses di v16 secara selektif.
- Query produk memakai `select('*')`, normalisasi harga legacy, dan pemuatan tabel independen agar kegagalan satu tabel tidak menghentikan promo/kategori.

## Storefront
- Produk aktif ditampilkan di katalog; produk yang ditandai Best Seller / Tampilkan di Beranda tampil di beranda.
- Detail produk lebih kaya, gambar kontekstual, harga fixed/from/consultation, konfigurasi awal otomatis, ringkasan dan estimasi.
- Semua CTA pemesanan tetap menuju WhatsApp admin, tanpa mencampurkan link grup/channel.
- Banner dari gambar yang diunggah ditempatkan pada slider beranda; highlight komunitas dipakai pada modal komunitas.
- Tambah skeleton loading dan ikon SVG platform di footer.
- Modal komunitas sekali per browser dan tombol pembaruan/notifikasi; link kosong tidak lagi menampilkan `undefined` atau link grup/channel palsu.

## Admin
- Navigasi admin dijadikan drawer sidebar ringkas.
- Tambah tab Platform untuk mengelola nama, URL, dan ikon SVG.
- Status produk dibuat ringkas; validasi model harga diperbaiki.

## Database
- Migration v17 idempotent: memastikan kolom price_type dan menambah produk starter tanpa menimpa produk yang sudah ada.
- Verification SQL disediakan. Jalankan setelah migration v5 dan v14; bila migration v16 sudah dijalankan, migration v17 tetap aman.
