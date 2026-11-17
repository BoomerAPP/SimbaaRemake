# SIMBAA Fresh v28 — Responsive visual refresh

## Dasar pembaruan
Paket dibuat dari SIMBAA Fresh v26. Eksperimen CSS v27 tidak dipakai sebagai dasar karena perubahan breakpoint tunggalnya tidak menyelesaikan perpindahan navigasi pada tablet dan layar landscape.

## Apa yang dibenahi
- Bottom navbar muncul sampai lebar 899px. Menu desktop tampil mulai 900px, sehingga tablet/layar landscape tidak kehilangan navigasi saat header belum cukup lapang.
- Lima item navbar dibuat rata, area tap diperbesar, label tidak dipotong, dan jaraknya mengikuti safe area perangkat.
- WhatsApp floating button tidak menimpa navbar. Konten dan footer mendapat ruang bawah yang sesuai.
- Header dan menu desktop dipadatkan agar tidak saling menekan.
- Hero utama dirapikan agar teks dan maskot tidak saling menimpa di layar kecil.
- Katalog, kartu produk, halaman detail, promo, bantuan, tentang, dan footer menggunakan grid/jarak yang lebih konsisten untuk HP, tablet, laptop, dan desktop.
- Desktop menggunakan area konten yang lebih lebar dan ritme section yang lebih rapat.
- Text marquee hanya dekorasi, tidak menangkap klik. Card hover/press dibuat halus.
- Page transition menggunakan cross-document View Transitions pada browser yang mendukung; fallback hanya menganimasikan area `main`, bukan memaksa reload tambahan. Scroll reveal bersifat opsional dan tidak menyembunyikan konten ketika JavaScript/IntersectionObserver tidak tersedia.
- `prefers-reduced-motion` menonaktifkan marquee dan animasi dekoratif.

## File baru/berubah
- Baru: `design-refresh-v28.css`
- Baru: `site-motion-v28.js`
- Baru: dokumentasi v28
- Berubah: `VERSION` dan enam halaman storefront (`index.html`, `layanan.html`, `detail.html`, `promo.html`, `bantuan.html`, `tentang.html`) untuk menautkan stylesheet/script dan menambahkan ribbon visual.

## File yang sengaja tidak diubah
- `app.js` dan seluruh logika katalog, checkout, order, musik, dan admin.
- `admin/` dan menu Dashboard.
- `supabase-config.js`, folder SQL/migration, tabel, autentikasi, dan data.
- Semua aset produk dan mascot yang sudah ada.

## Cara mencoba di Acode
1. Backup folder project yang sekarang.
2. Ekstrak ZIP v28.
3. Buka folder `SIMBAA-Fresh-v28` di Acode dan jalankan `index.html`.
4. Periksa lebar 320, 360, 390, 430, 768, 900, 1024, 1280, dan 1440px.
5. Tap semua lima item bottom navbar, uji scroll ke footer, tombol WhatsApp, katalog, detail produk, checkout, dan pemutar musik.
6. Jangan jalankan SQL. Tidak perlu hapus produk atau data Supabase.

## Batas uji
Login Supabase live, WhatsApp, upload Storage, dan audio/Spotify tetap perlu dites di perangkat dan project milikmu. Pemeriksaan kode dan render lokal bukan pengganti tes backend tersebut.
