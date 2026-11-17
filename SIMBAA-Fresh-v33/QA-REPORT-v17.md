# SIMBAA Fresh v17 — QA Report

## Static checks
- `node --check app.js`: PASS
- `node --check admin/admin.js`: PASS
- HTML parse untuk halaman publik dan dashboard: PASS (hasil script QA)
- Cek duplicate ID pada tiap halaman: PASS (hasil script QA)
- Cek referensi file lokal dari HTML: PASS (hasil script QA)
- ZIP integrity: PASS (diverifikasi setelah packaging)
- Seed SQL row/column shape: PASS (9 rows, 22 columns each)

## Implemented
- Baseline source berasal dari v15; halaman publik dan modul admin v15 tetap disertakan.
- Query produk menggunakan `select('*')`, normalisasi harga legacy, dan tabel dimuat independen.
- Harga `fixed`, `from`, `consultation`; form admin memvalidasi harga sesuai model.
- Sembilan produk starter untuk Website Landing Page, Company Profile, Toko Online, VPS & Hosting, WhatsApp Gateway, Web App & Dashboard, Source Code & Lisensi, UI/UX Design, serta Bot & Workflow Automation.
- Detail produk dengan ringkasan, estimasi, termasuk/belum termasuk, ketentuan, konfigurasi dan CTA WhatsApp.
- Tipe website otomatis terpilih berdasarkan paket website yang dibuka.
- Banner highlight di slider beranda, banner layanan di halaman katalog, avatar produk dari crop gambar unggahan, serta visual komunitas.
- Community popup sekali per browser, pembaruan/notifikasi, footer platform SVG dan admin tab Platform.
- Admin drawer/sidebar dan status produk ringkas.

## Not run / requires user environment
- Live Supabase migration execution and rollback test.
- Supabase Data API exposure, live RLS behavior, Auth Owner login, Storage upload, and live CRUD.
- Real WhatsApp handoff on a phone.
- Production domain / Vercel deployment.

Headless visual browser screenshot did not complete in this environment; mobile/desktop visual acceptance still needs a real browser check. No claim of live Supabase success is made. Run `migration-v17-storefront.sql`, then `verify-v17-storefront.sql`. If products still fail to load, use `DATA-API-TROUBLESHOOT-v17.md`. Supabase Data API exposure must also be enabled for `public`; SQL grants and RLS do not make a table reachable if Data API is disabled or the schema is not exposed.
