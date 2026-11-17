# SIMBAA Fresh v23 — Checkout & Voice Settings Polish

## Perubahan
- Checkout modal mendapat header langkah yang jelas, tombol kembali yang konsisten dengan tema, dan transisi halus.
- Konfigurasi pembelian dirapikan menjadi dua kolom pada layar yang cukup lebar; input panjang tetap mengambil lebar penuh dan layar sangat kecil kembali satu kolom.
- Ringkasan produk, promo, dan data tambahan tetap terpisah; field konfigurasi tetap mengikuti produk yang dipilih. Bagian termasuk/tidak termasuk tetap informasi detail, bukan input pembeli.
- Audio welcome sekarang membaca `audio_intro_url` dari pengaturan toko. Admin dapat mengganti URL MP3/OGG melalui Pengaturan Toko; URL kosong memakai audio bawaan.
- Audio mencoba autoplay setelah pengaturan toko dimuat. Jika browser memblokir autoplay, audio mencoba sekali lagi pada interaksi pertama pengguna. Kebijakan browser tetap berlaku.
- Ditambahkan migrasi SQL aman untuk menjelaskan batas free-tier domain/hosting/database pada layanan website tanpa mengubah harga, status, atau data lain.

## Tidak diubah
- Tema utama SIMBAA hitam–emas dan aset yang sudah ada.
- Struktur tabel, autentikasi, RLS, kategori, konfigurasi produk, template WhatsApp, promo, serta data pesanan.
- Harga produk tidak diubah otomatis. Harga layanan custom tetap konsultasi sampai biaya operasional dan margin aktual diverifikasi.
