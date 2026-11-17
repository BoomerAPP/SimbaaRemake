# SIMBAA Fresh v24 — Dynamic Island Music

## Perubahan
- Menghapus perilaku welcome voice/autoplay. Tidak ada lagi audio yang otomatis diputar.
- Mengganti welcome stage dengan pemutar musik Dynamic Island menggunakan ikon/logo SIMBAA yang sudah tersedia.
- Island menampilkan kontrol Play/Pause, nama musik, visualizer, volume pengunjung, dan tautan Spotify opsional.
- Saat halaman discroll lebih dari 100px, island mengecil menjadi ikon SIMBAA. Ketuk ikon untuk membuka kontrol kembali.
- Musik dibatasi maksimal 60 detik per pemutaran; track yang lebih pendek tetap mengikuti durasi aslinya.
- Dashboard Pengaturan Toko dapat mengaktifkan player, mengatur judul, path file lokal di `assets/audio/` atau URL HTTPS langsung, volume awal, dan tautan Spotify.
- Tema background charcoal/black dengan gradient emas halus dipertahankan; tidak diganti wallpaper gambar.
- Template WhatsApp kategori dan sistem pengisian variabel yang sudah ada dipertahankan.

## Batasan penting
- Spotify URL bukan file audio langsung. Link Spotify hanya ditampilkan sebagai tautan untuk membuka Spotify; kontrol volume island tidak dapat mengendalikan Spotify.
- Untuk kontrol Play/Pause dan volume di island, gunakan file MP3/OGG milik sendiri/berlisensi melalui path lokal atau URL file audio HTTPS langsung.
- Tidak ada file musik party baru yang disertakan. Admin perlu memasukkan file musik 60 detik ke `assets/audio/` atau mengisi URL audio yang sah.
- Tidak ada SQL migration baru. Pengaturan disimpan sebagai properti tambahan di `store_settings.value` (JSONB) yang sudah digunakan v23.
- Autoplay tidak dipaksakan; pengunjung harus menekan Play.

## Data safety
- Tidak ada produk, kategori, harga, promo, pesanan, pelanggan, akun admin, atau kebijakan RLS yang dihapus/diubah.
- WhatsApp templates dan konfigurasi pembelian tetap dipertahankan.
