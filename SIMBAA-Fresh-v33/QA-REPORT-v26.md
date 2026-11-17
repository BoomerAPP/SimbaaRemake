# QA Report — SIMBAA Fresh v26

## Pemeriksaan yang dilakukan
- `node --check app.js` — lulus.
- `node --check admin/admin.js` — lulus.
- HTML parsing pada `Simbaa.html`, `index.html`, `detail.html`, `layanan.html`, `promo.html`, `tentang.html`, dan `bantuan.html` — lulus.
- Tidak ditemukan ID HTML duplikat di tujuh halaman yang diperiksa.
- Tidak ditemukan form bersarang pada dashboard admin.
- 13 section beranda memiliki kontrol urutan; semua 13 kontrol menggunakan daftar angka 1–13. Validasi saat penyimpanan menolak nomor urutan yang sama.
- Playlist lama berbasis `audio_intro_url` tetap dibaca bila `music_playlist` belum berisi track.
- Pemeriksaan source mengonfirmasi iframe Spotify menggunakan `allow="autoplay; clipboard-write; encrypted-media; fullscreen; picture-in-picture"`.
- Tidak ada file SQL yang diubah atau migration v26 ditambahkan.

## Batas verifikasi
- Uji browser interaktif tidak selesai karena browser pengujian di lingkungan ini diblokir oleh kebijakan akses (`ERR_BLOCKED_BY_ADMINISTRATOR`).
- Tidak dilakukan login ke Supabase project pemilik, upload Storage live, atau pemutaran audio pada perangkat Android fisik.
- Karena itu, laporan ini menyatakan pemeriksaan statis lulus, bukan jaminan bahwa konfigurasi bucket/RLS atau semua sesi Supabase live sudah teruji.

## Checklist setelah deploy
1. Login admin Owner dan buka setiap submenu Pengaturan.
2. Simpan pengaturan beranda, tampilan, SEO, kebijakan, platform, dan template WhatsApp.
3. Pada Music Studio, tekan `Tambahkan 6 lagu`, lalu pastikan keenam track muncul sekali.
4. Upload MP3, preview, set default, ubah urutan, dan hapus satu track uji bila diperlukan.
5. Aktifkan musik dan uji player publik pada halaman beranda serta halaman lain.
6. Pilih Spotify dari daftar dan tekan Play langsung di Spotify Embed.
7. Tes katalog, detail produk, checkout, dan navigasi dashboard untuk memastikan fitur lama tetap berjalan.

**Penting:** simpan backup v25. v26 tidak membutuhkan SQL baru. Jangan menghapus data atau menjalankan ulang migration lama sebagai langkah troubleshooting.
