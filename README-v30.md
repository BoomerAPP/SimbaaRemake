# SIMBAA Fresh v30

Perbaikan berfokus pada mobile, memakai struktur/aset v26 sebagai referensi dan melanjutkan perubahan v29.

## Yang diperbaiki
- Navbar mobile ditambatkan langsung ke sisi kiri dan kanan viewport. Lima item tetap sama lebar, dengan ruang safe area di bawah. Desktop mulai 900px menggunakan menu atas.
- Music island pindah ke baris khusus di bawah toolbar, tetap berada dalam sticky header. Tidak lagi menimpa logo atau menu. Panel playlist memiliki batas tinggi sesuai ruang layar.
- Toolbar dan notifikasi menggunakan satu pengendali panel: hanya satu terbuka, backdrop menutup panel, Escape bekerja, Tab dibatasi dalam dialog, fokus kembali ke pemicu. Panel yang tertutup dibuat inert.
- Tinggi header diukur ulang ketika music island berubah dan saat resize. Posisi panel mengikuti tinggi aktual, bukan angka top yang tetap.
- Tombol musik memakai selector ID yang benar. Play/Pause, status audio gagal, dan volume yang dipilih tidak kembali ke nilai lama setiap pembaruan UI.
- Autoplay dicoba sekali ketika musik diaktifkan admin dan tersedia lagu MP3/URL, kecuali pengunjung sudah menekan Pause dalam sesi ini atau music_autoplay disetel false. Browser tetap menentukan izin. Jika diblokir, ada pesan dan tombol Play. Spotify memakai tombol player resminya.
- Listener musik tidak lagi membangun ulang playlist pada setiap scroll.
- Modal pemesanan memiliki lapisan di atas navbar/header.
- Laptop: hero dua kolom, ruang gambar stabil, lebar bagian banner/produk diselaraskan, kartu produk lebih lapang. Mobile: pencarian tidak melebar keluar, kartu unggulan bertumpuk, ukuran tombol tidak ditimpa aturan kecil v22.
- Animasi scroll dan transisi halaman v29 tetap aktif, dengan dukungan reduced-motion.

## Cara memakai
Ekstrak seluruh folder SIMBAA-Fresh-v30, lalu buka index.html melalui server lokal/Acode. Untuk mengganti proyek, unggah seluruh isi folder bersama file baru, jangan hanya app.js. Refresh halaman setelah penggantian. Tidak perlu menjalankan SQL.

## Validasi dan batas
Lihat QA-REPORT-v30.md. Pengujian pengendali UI menggunakan DOM/audio tiruan. Sintaks, referensi file dan keutuhan admin/SQL sudah diperiksa. Render visual browser serta integrasi Supabase/WhatsApp/audio nyata belum dapat diverifikasi di lingkungan ini; perlu uji perangkat sebelum produksi.
