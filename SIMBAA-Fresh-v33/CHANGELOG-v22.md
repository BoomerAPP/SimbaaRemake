# SIMBAA Fresh v22 — Compact Storefront & Admin Refinement

## Perubahan
- Halaman katalog layanan menggunakan satu banner utama yang menjelaskan cakupan layanan SIMBAA dan mengarahkan pengunjung ke promo.
- Footer dipisahkan menjadi Komunitas SIMBAA (WhatsApp CS, Grup WhatsApp, Channel WhatsApp) dan Platform SIMBAA (TikTok, Facebook, Instagram, YouTube).
- Popup komunitas dan pengumuman entry dinonaktifkan. Panel notifikasi toolbar tetap tersedia untuk pengumuman yang dikelola admin.
- Dynamic Island audio intro dipindah ke bagian atas, dibuat lebih kecil, hanya muncul ketika audio benar-benar mulai diputar, dan memiliki tombol × untuk menghentikan audio serta menyembunyikannya selama sesi berjalan.
- Template pesan pesanan dapat diatur melalui Pengaturan Toko di dashboard. Placeholder didukung: `{nama_produk}`, `{harga}`, `{status}`, `{konfigurasi}`, `{promo}`, `{nama_pemesan}`, `{catatan}`, `{website}`, `{detail}`, `{grup_whatsapp}`, `{channel_whatsapp}`. Konfigurasi tetap bersumber dari layanan yang dipilih.
- Sidebar admin disempurnakan: submenu ditempatkan tepat di bawah kelompok menu aktif, ikon lebih kecil dan rata kiri.
- Ringkasan dashboard dan footer dibuat lebih ringkas; konfigurasi checkout mobile menggunakan layout dua kolom bila memungkinkan.
- Satu banner layanan menggantikan tiga banner terpisah.

## Dipertahankan
- Tema visual dan identitas SIMBAA yang sudah ada.
- Detail produk dan checkout tetap dua tahap terpisah.
- Produk hanya tampil di beranda jika `show_on_home` dipilih admin.
- Sistem promo yang sudah ada, termasuk diskon nominal/persen dan kode promo.
- Supabase, autentikasi, RLS, dan struktur tabel tanpa perubahan.

## Catatan
- Audio autoplay tetap bergantung pada kebijakan browser.
- Facebook hanya tampil jika tautannya disediakan pada pengaturan platform.
- Belum ada migrasi SQL.
