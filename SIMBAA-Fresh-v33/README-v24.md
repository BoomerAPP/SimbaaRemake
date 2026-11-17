# SIMBAA Fresh v24

## Menjalankan lokal di Acode
1. Ekstrak ZIP dan buka folder `SIMBAA-Fresh-v23` di Acode.
2. Jalankan halaman `index.html` melalui local server/preview Acode (jangan membuka hanya file `Simbaa.html` untuk tampilan publik).
3. Dashboard admin tetap dibuka melalui `Simbaa.html`.
4. Tidak perlu menjalankan SQL baru untuk v24. Pengaturan musik memakai kolom JSONB `store_settings.value` yang sudah ada.

## Mengatur musik
1. Letakkan file MP3/OGG yang dimiliki atau berlisensi di `assets/audio/`, misalnya `simbaa-party-60s.mp3`.
2. Buka Admin → Pengaturan → Pengaturan Toko → Musik website & Dynamic Island.
3. Aktifkan player, isi nama musik, isi path `./assets/audio/simbaa-party-60s.mp3`, atur volume awal, lalu simpan.
4. Alternatif: isi URL HTTPS langsung ke file MP3/OGG yang bisa diakses publik.
5. Pengunjung menekan Play. Pemutaran berhenti setelah maksimal 60 detik.
6. Spotify URL hanya menyediakan tautan buka Spotify. Spotify tidak bisa menjadi sumber audio langsung untuk player kustom atau dikontrol slider volume island.

## Pemeriksaan
- `node --check app.js` dan `node --check admin/admin.js` harus lulus.
- Tes live Supabase, login admin, penyimpanan pengaturan, dan playback perangkat masih perlu dilakukan di perangkat pemilik.
