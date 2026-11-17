# SIMBAA v29

Perbaikan dari v28:
- Area sentuh tombol utama, toolbar, filter dan panah minimum 44px. Tombol produk tidak lagi memakai teks sangat kecil; aksi membungkus sesuai ruang.
- Status navigasi desktop/mobile menggunakan halaman yang sama dan aria-current.
- Carousel menghitung posisi relatif layar, bukan offset parent yang dapat berbeda. ResizeObserver memperbarui kontrol saat breakpoint berubah.
- Dua sistem reveal section lama diganti satu sistem reveal teks dari bawah ke atas. Teks dinamis ikut diamati; animasi berulang saat teks masuk kembali dari bawah viewport.
- Transisi halaman native dengan fallback keluar singkat dan animasi masuk. Modifier klik, unduh, tab baru dan link eksternal tetap normal.
- Tampilan laptop: hero, ukuran heading, panjang paragraf dan jarak section diperbaiki. Fokus keyboard, titik carousel dan preferensi reduced-motion diperhatikan.

Buka index.html lewat local server/Acode. Seluruh folder perlu diunggah bersama. Tidak membutuhkan migrasi SQL.

Validasi: sintaks kedua JS yang berubah, referensi file lokal pada enam halaman storefront, serta pemasangan tepat satu controller animasi lolos. Browser Chromium tidak dapat berjalan karena pembatasan socket lingkungan; render visual, sentuhan perangkat, backend, WhatsApp, checkout dan admin live belum diuji. Uji perangkat pada 320, 390, 768, 899, 900, 1024 dan 1440px, termasuk pindah halaman, back/forward, geser carousel dan resize.
