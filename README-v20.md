# SIMBAA Fresh v20

Rilis visual upgrade untuk SIMBAA.my.id.

## Isi pembaruan
- Sidebar kiri admin untuk desktop dan drawer hamburger untuk ponsel.
- Submenu navigasi admin yang dinamis untuk Ringkasan, Katalog, Konten & promo, dan Pengaturan.
- Shortcut kategori beranda tetap di bawah search, dengan kontrol slide menggunakan tombol panah.
- Bagian Pilihan SIMBAA memiliki filter kategori, tombol panah, dan indikator posisi; hanya produk yang diaktifkan admin yang ditampilkan.
- Popup pengumuman lebih visual dan panel notifikasi menggunakan gaya SIMBAA Newsroom.
- Voice intro berupa narasi multi-segmen dengan visualizer.
- Fallback untuk gambar produk yang gagal dimuat.
- Social preview Open Graph `assets/og-simbaa.jpg` ukuran 1200×630.

## Cara memasang
1. Backup folder website yang sedang live.
2. Ekstrak arsip ini.
3. Salin isi folder `SIMBAA-Fresh-v20` ke root repository GitHub, jangan membuat folder bertingkat baru.
4. Pertahankan `supabase-config.js` project kamu (Project URL dan Publishable/anon key yang benar).
5. Commit/push ke GitHub lalu deploy di Vercel.

## Database
Tidak ada SQL migration baru pada v20. Rilis ini hanya menyesuaikan frontend dan aset. Jangan menjalankan ulang seluruh migration lama hanya untuk memasang v20.

## Catatan suara
Voice memakai SpeechSynthesis dari browser/perangkat pengunjung. Browser Android dapat memblokir suara otomatis sebelum interaksi pengguna. Situs tetap mencoba otomatis, lalu mencoba lagi pada interaksi pertama. Kualitas suara mengikuti voice Indonesian yang tersedia di perangkat.

## OG image
Metadata `og:image` dan `twitter:image` mengarah ke:
`https://simbaa.my.id/assets/og-simbaa.jpg`
Jika domain berubah, perbarui URL metadata pada `index.html`, `layanan.html`, `promo.html`, `bantuan.html`, dan `tentang.html`.
