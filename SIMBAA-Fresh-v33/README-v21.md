# SIMBAA Fresh v21

Pembaruan narasi intro sinematik, OG image, dan penyempurnaan pengalaman storefront berdasarkan v20.

## Instalasi
1. Backup repository dan website aktif.
2. Salin isi folder ini ke root repository GitHub (jangan membuat folder bertingkat).
3. Pertahankan `supabase-config.js` milik project kamu beserta Project URL dan Publishable/anon key yang benar.
4. Commit dan push ke GitHub, lalu deploy ulang di Vercel.

## File utama
- `app.js`, `style.css`: voice intro, storefront, dan interaksi publik.
- `assets/audio/simbaa-intro.mp3`: narasi intro dengan ambience sinematik.
- `assets/og-simbaa.jpg`: social preview 1200×630.
- `admin/`: dashboard admin (fitur dan struktur v20 tetap dipertahankan).

## Voice intro
Tidak ada tombol suara manual dan tidak ada pemaksaan autoplay. Situs hanya mencoba memutar audio ketika sesi baru dimulai. Bila browser menolak autoplay, intro dilewati. Kebijakan browser tidak memungkinkan situs menjamin autoplay bersuara di semua perangkat.

## Database
Tidak ada migration SQL baru. Jangan menjalankan ulang migration lama hanya untuk memasang v21.
