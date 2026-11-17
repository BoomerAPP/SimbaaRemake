# QA Report — SIMBAA Fresh v28

## Sumber dan batas perubahan
- Sumber kerja: `SIMBAA-Fresh-v26.zip` dari pengguna.
- File patch responsif v27 tidak dipakai sebagai dasar.
- Perubahan hanya pada CSS presentasi, helper animasi, dan markup enam halaman storefront.
- `app.js`, admin, Supabase config, SQL/migration, autentikasi, produk, dan data tidak diubah.

## Pemeriksaan yang dilakukan
- Integritas ZIP sumber v26 diverifikasi sebelum ekstraksi.
- Struktur navigasi dan breakpoint diperiksa pada enam halaman storefront.
- Validasi HTML parser dan pemeriksaan ID duplikat pada enam halaman.
- Pemeriksaan syntax JavaScript dengan `node --check` untuk `app.js` dan `site-motion-v28.js`.
- Render statis Chromium pada enam halaman di beberapa ukuran layar, termasuk 320, 390, 768, 900, 1024, dan 1440 px.
- Uji tambahan header dengan tombol header dinamis pada lebar 900–1200 px.
- Tidak ditemukan horizontal overflow pada ukuran layar yang diuji; bottom navbar tetap tampil sampai 899 px dan menu desktop digunakan mulai 900 px.
- Uji preferensi reduced-motion untuk memastikan animasi dekoratif dapat dinonaktifkan.
- Integritas ZIP v28 diperiksa setelah pengemasan.

## Batas pengujian
Render Chromium dilakukan sebagai pemeriksaan layout statis; skrip aplikasi dan layanan eksternal tidak dijalankan dalam pengujian visual. Karena itu, hasil ini bukan pengganti tes pada HP Android dan bukan bukti bahwa login Supabase, baca/tulis database, Storage, pembayaran/WhatsApp, atau audio/Spotify sudah diuji live. Tes akhir tetap dilakukan di Acode sebelum deploy.
