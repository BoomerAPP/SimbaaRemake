-- SIMBAA Fresh v18
-- Safe additive migration for catalog presets, product visibility, and announcements.
-- Keeps existing Owner mapping, products, banners, promotions, and store_settings.key/value.

BEGIN;

DO $$
BEGIN
  IF to_regprocedure('private.is_store_owner()') IS NULL THEN
    RAISE EXCEPTION 'private.is_store_owner() belum tersedia. Pastikan migrasi dasar/Owner SIMBAA sudah dijalankan.';
  END IF;
  IF to_regclass('public.products') IS NULL OR to_regclass('public.categories') IS NULL THEN
    RAISE EXCEPTION 'Tabel products/categories belum tersedia. Jalankan schema dasar SIMBAA terlebih dahulu.';
  END IF;
END $$;

-- Explicit Data API grants are required for public-schema tables in current Supabase projects.
GRANT USAGE ON SCHEMA public TO anon, authenticated;

-- Ensure a default settings row exists without overwriting an existing Owner configuration.
INSERT INTO public.store_settings (key,value)
VALUES ('main', jsonb_build_object(
  'brand_name','SIMBAA',
  'tagline','Your Digital Partner',
  'whatsapp_number','6282132043632',
  'website_url','https://simbaa.my.id',
  'tiktok_url','https://www.tiktok.com/@simbaagorn_',
  'whatsapp_community_group','https://chat.whatsapp.com/GffLq8qIEFCI18blInlOBZ?s=cl&p=a&iam=2',
  'whatsapp_channel','https://whatsapp.com/channel/0029Vb9aebECcW4z3TNt0W3n',
  'platforms','[]'::jsonb
)) ON CONFLICT (key) DO NOTHING;

-- Fill only missing/blank community links. Owner-customized links are preserved.
UPDATE public.store_settings
SET value = jsonb_set(
  jsonb_set(
    value,
    '{whatsapp_community_group}',
    to_jsonb(COALESCE(NULLIF(value->>'whatsapp_community_group',''),'https://chat.whatsapp.com/GffLq8qIEFCI18blInlOBZ?s=cl&p=a&iam=2')),
    true
  ),
  '{whatsapp_channel}',
  to_jsonb(COALESCE(NULLIF(value->>'whatsapp_channel',''),'https://whatsapp.com/channel/0029Vb9aebECcW4z3TNt0W3n')),
  true
), updated_at = now()
WHERE key='main' AND jsonb_typeof(value)='object';

-- Category configuration profile: determines the suggested fields for newly-created products.
ALTER TABLE public.categories
  ADD COLUMN IF NOT EXISTS config_profile text;
ALTER TABLE public.categories DROP CONSTRAINT IF EXISTS categories_config_profile_check;
ALTER TABLE public.categories ADD CONSTRAINT categories_config_profile_check
  CHECK (config_profile IN ('website','application','server','automation','design','digital','custom'));

UPDATE public.categories SET config_profile = CASE
  WHEN slug IN ('development','website','website-development') THEN 'website'
  WHEN slug IN ('application','app','application-development') THEN 'application'
  WHEN slug IN ('server','hosting','vps-hosting') THEN 'server'
  WHEN slug IN ('automation','bot','whatsapp-gateway') THEN 'automation'
  WHEN slug IN ('design','ui-ux') THEN 'design'
  WHEN slug IN ('digital','digital-product','source-code') THEN 'digital'
  ELSE COALESCE(NULLIF(config_profile,''),'custom') END
WHERE config_profile IS NULL;
ALTER TABLE public.categories ALTER COLUMN config_profile SET DEFAULT 'custom';
ALTER TABLE public.categories ALTER COLUMN config_profile SET NOT NULL;

-- Make sure v18 product fields exist. Existing product values are not replaced.
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS price_type text NOT NULL DEFAULT 'fixed',
  ADD COLUMN IF NOT EXISTS benefits_text text,
  ADD COLUMN IF NOT EXISTS configuration_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS show_on_home boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS is_best_seller boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now();
ALTER TABLE public.products DROP CONSTRAINT IF EXISTS products_price_type_check;
ALTER TABLE public.products ADD CONSTRAINT products_price_type_check
  CHECK (price_type IN ('fixed','from','consultation'));
UPDATE public.products SET price_type = CASE WHEN COALESCE(price,0) <= 0 THEN 'consultation' ELSE 'fixed' END
WHERE price_type IS NULL OR price_type = '' OR (price_type = 'fixed' AND COALESCE(price,0) <= 0);
ALTER TABLE public.products ALTER COLUMN price_type SET NOT NULL;

-- Category defaults. Existing custom categories are left intact because conflicts are ignored.
INSERT INTO public.categories (name, slug, description, config_profile, sort_order, is_active)
VALUES
  ('Website Development','development','Landing page, company profile, toko online, portal, dan website custom.','website',1,true),
  ('Application Development','application','Aplikasi web, Android/iOS, dashboard, dan sistem digital.','application',2,true),
  ('VPS & Hosting','server','VPS Linux/Windows, RDP, hosting, game server, dan pengelolaan server.','server',3,true),
  ('Bot & Automation','automation','Bot WhatsApp/Telegram/Discord, integrasi API, dan workflow otomatis.','automation',4,true),
  ('UI/UX Design','design','Riset, wireframe, desain website, aplikasi, dan dashboard.','design',5,true),
  ('Digital Products','digital','Template website, UI kit, source code, dan produk digital.','digital',6,true),
  ('Custom Development','custom','Pembuatan solusi sesuai kebutuhan bisnis atau proyek.','custom',7,true)
ON CONFLICT (slug) DO NOTHING;

-- Product catalog defaults. Only insert missing slugs; never overwrite Owner-edited products.
INSERT INTO public.products
  (category_id, category, name, slug, description, details, benefits_text, turnaround_text,
   includes_text, exclusions_text, terms_text, price, price_type, image_url, icon, tag, status,
   is_active, show_on_home, is_best_seller, configuration_fields, sort_order)
SELECT c.id, v.category, v.name, v.slug, v.description, v.details, v.benefits, v.turnaround,
       v.includes, v.exclusions, v.terms, v.price, v.price_type, v.image_url, v.icon, v.tag,
       'ready', true, v.show_on_home, false, v.config::jsonb, v.sort_order
FROM (VALUES
 ('development','Landing Page','landing-page',
  'Website satu halaman untuk memperkenalkan bisnis, produk, event, atau personal brand. Cocok untuk mulai promosi online dengan alur yang jelas.',
  'Halaman fokus pada satu tujuan: mengenalkan layanan, menampilkan keunggulan, dan mengarahkan pengunjung menghubungi atau melakukan tindakan. Struktur final disepakati melalui brief.',
  'Membuat informasi bisnis lebih mudah ditemukan; tampilan responsif untuk HP; CTA WhatsApp/form; struktur konten lebih terarah.',
  'Estimasi awal 3–7 hari kerja setelah materi lengkap dan ruang lingkup disepakati.',
  'Desain responsif, section sesuai paket, tombol kontak, optimasi dasar, dan revisi sesuai kesepakatan.',
  'Domain, hosting berbayar, email bisnis, copywriting profesional, dan integrasi pihak ketiga kecuali tertulis di penawaran.',
  'Timeline dihitung setelah materi dan akses tersedia. Perubahan ruang lingkup dapat memengaruhi biaya dan estimasi.',0,'consultation','./assets/product-avatars/website.webp','🌐','Website','website',true,
  '[{"label":"Jenis website","type":"select","required":true,"default_value":"Landing Page","options":["Landing Page","Company Profile","Toko Online","Custom Website"]},{"label":"Nama bisnis / brand","type":"text","required":true},{"label":"Tujuan landing page","type":"select","required":true,"options":["Promosi produk","Personal brand","Event","Pengumpulan leads","Lainnya"]},{"label":"Referensi desain","type":"url","required":false},{"label":"Materi sudah tersedia?","type":"select","required":true,"options":["Sudah","Sebagian","Belum"]}]',1),
 ('development','Company Profile','company-profile',
  'Website profil perusahaan atau usaha untuk menjelaskan identitas, layanan, portofolio, dan kontak secara profesional.',
  'Paket disusun berdasarkan jumlah halaman dan kebutuhan konten. Admin membantu menentukan struktur yang sesuai agar pengunjung mudah memahami bisnis.',
  'Meningkatkan kredibilitas online; informasi bisnis tersusun rapi; memudahkan calon pelanggan menghubungi tim.',
  'Estimasi awal 5–10 hari kerja setelah materi lengkap, bergantung jumlah halaman dan fitur.',
  'Halaman profil, layanan, tentang kami, kontak, responsif mobile, dan SEO dasar sesuai kesepakatan.',
  'Biaya domain/hosting, foto profesional, penulisan konten, dan fitur custom yang belum tercantum pada penawaran.',
  'Materi bisnis dan logo disediakan pelanggan atau dimasukkan sebagai pekerjaan tambahan.',0,'consultation','./assets/product-avatars/website.webp','🏢','Website Bisnis','website',true,
  '[{"label":"Jenis website","type":"select","required":true,"default_value":"Company Profile","options":["Landing Page","Company Profile","Toko Online","Custom Website"]},{"label":"Nama perusahaan / usaha","type":"text","required":true},{"label":"Bidang usaha","type":"text","required":true},{"label":"Halaman yang dibutuhkan","type":"select","required":true,"options":["3–5 halaman","6–8 halaman","Lebih dari 8","Belum tahu"]},{"label":"Domain sudah ada?","type":"select","required":true,"options":["Sudah","Belum","Ingin konsultasi"]},{"label":"Fitur tambahan","type":"textarea","required":false}]',2),
 ('development','Toko Online / E-Commerce','toko-online-ecommerce',
  'Website katalog dan toko online untuk menampilkan produk, menerima pertanyaan, dan mengelola pesanan pelanggan.',
  'Fitur seperti katalog, kategori, detail produk, keranjang, checkout, dashboard admin, dan integrasi pembayaran dipilih sesuai paket dan kebutuhan.',
  'Produk tampil lebih teratur; pelanggan mudah melihat informasi; pengelola dapat memperbarui katalog sesuai fitur yang disepakati.',
  'Estimasi awal 10–21 hari kerja bergantung jumlah produk, pembayaran, dan integrasi.',
  'Struktur toko, katalog produk, halaman detail, kontak/pemesanan, dan panel pengelolaan sesuai paket.',
  'Biaya payment gateway, biaya transaksi pihak ketiga, domain/hosting, input produk massal, dan integrasi tambahan kecuali tertulis.',
  'Alur pembayaran dan kebijakan toko harus disetujui sebelum implementasi.',0,'consultation',NULL,'🛒','E-Commerce','website',false,
  '[{"label":"Jenis website","type":"select","required":true,"default_value":"Toko Online","options":["Landing Page","Company Profile","Toko Online","Custom Website"]},{"label":"Jumlah produk awal","type":"select","required":true,"options":["1–20","21–50","51–100","Lebih dari 100"]},{"label":"Metode pemesanan","type":"select","required":true,"options":["WhatsApp","Checkout online","Konsultasi dulu"]},{"label":"Pembayaran online","type":"select","required":true,"options":["Ya","Tidak","Belum tahu"]},{"label":"Fitur penting","type":"textarea","required":true}]',3),
 ('application','Aplikasi Web / Mobile','aplikasi-web-mobile',
  'Pengembangan aplikasi berbasis web atau mobile untuk membantu operasional, layanan pelanggan, atau kebutuhan produk digital.',
  'Pilihan platform, akses pengguna, database, dashboard, integrasi, dan fitur disesuaikan dari brief proyek. Admin membantu memetakan kebutuhan teknis ke bahasa sederhana.',
  'Alur kerja lebih teratur; fitur menyesuaikan proses bisnis; dapat dikembangkan bertahap.',
  'Estimasi ditentukan setelah scope dan prioritas fitur disepakati; proyek menengah umumnya memerlukan beberapa minggu.',
  'Analisis kebutuhan, rancangan alur, implementasi fitur sesuai scope, dan panduan penggunaan dasar.',
  'Biaya akun developer, server, layanan API, lisensi, dan maintenance lanjutan kecuali tercantum.',
  'Fitur dan kriteria selesai ditulis pada penawaran sebelum pengerjaan dimulai.',0,'consultation',NULL,'📱','Aplikasi','application',false,
  '[{"label":"Platform","type":"select","required":true,"options":["Web App","Android","iOS","Web + Android","Belum tahu"]},{"label":"Siapa yang akan menggunakan?","type":"select","required":true,"options":["Pelanggan","Admin / staff","Keduanya","Publik"]},{"label":"Tujuan aplikasi","type":"textarea","required":true},{"label":"Fitur utama","type":"textarea","required":true}]',4),
 ('application','Dashboard Admin & Sistem Custom','dashboard-admin-system',
  'Dashboard dan sistem khusus untuk mengelola data, pengguna, pesanan, laporan, atau proses internal bisnis.',
  'Ruang lingkup dapat mencakup login, role, CRUD, pencarian, filter, laporan, dan integrasi sesuai kebutuhan. Akses serta hak tiap peran disepakati sebelum pembuatan.',
  'Data lebih terstruktur; pekerjaan berulang dapat disederhanakan; pengelolaan terpusat.',
  'Estimasi awal 2–6 minggu setelah alur dan fitur disepakati.',
  'UI dashboard, modul yang disepakati, pengelolaan data, dan dokumentasi singkat.',
  'Server, email/SMS berbayar, layanan API pihak ketiga, dan fitur di luar daftar scope.',
  'Data contoh dan akses uji dibutuhkan saat pengembangan. Data produksi ditangani sesuai kesepakatan.',0,'consultation',NULL,'📊','Dashboard','application',true,
  '[{"label":"Proses yang ingin dikelola","type":"textarea","required":true},{"label":"Jenis pengguna","type":"select","required":true,"options":["Owner dan admin","Admin dan staff","Pelanggan dan admin","Multi-role"]},{"label":"Fitur yang dibutuhkan","type":"textarea","required":true},{"label":"Sudah punya database?","type":"select","required":true,"options":["Ya","Belum","Belum tahu"]}]',5),
 ('server','VPS & Hosting','vps-hosting',
  'VPS dan hosting untuk website, aplikasi, bot, panel game, database, atau kebutuhan server jarak jauh.',
  'Paket VPS mengikuti ketersediaan provider, lokasi, CPU, RAM, storage, bandwidth, sistem operasi, dan masa aktif. Harga acuan yang tersedia mulai Rp19.999 per bulan; spesifikasi dan stok dikonfirmasi admin.',
  'Pilihan server untuk berbagai kebutuhan; dapat memilih OS; cocok untuk proyek pribadi hingga layanan bisnis sesuai spesifikasi.',
  'Aktivasi mengikuti ketersediaan provider dan pembayaran; estimasi diinformasikan sebelum konfirmasi.',
  'Resource sesuai paket, akses server, dan bantuan awal sesuai ketentuan paket.',
  'Lisensi OS/Panel, backup premium, IP tambahan, managed service, dan biaya penggunaan provider tambahan kecuali tercantum.',
  'Ketersediaan, spesifikasi, lokasi, dan harga akhir wajib dikonfirmasi sebelum pembayaran.',19999,'from','./assets/product-avatars/vps.webp','🖥️','VPS & Hosting','server',true,
  '[{"label":"Tujuan penggunaan","type":"select","required":true,"options":["Website","Bot / API","Game server","Panel Pterodactyl","Remote desktop","Lainnya"]},{"label":"Sistem operasi","type":"select","required":true,"options":["Ubuntu","Debian","Windows Server","Belum tahu"]},{"label":"RAM / CPU yang diinginkan","type":"text","required":false},{"label":"Lokasi server","type":"select","required":false,"options":["Indonesia","Singapore","Global","Diskusikan"]},{"label":"Durasi","type":"select","required":true,"options":["1 bulan","3 bulan","6 bulan","12 bulan"]}]',6),
 ('automation','WhatsApp Gateway','whatsapp-gateway',
  'Integrasi WhatsApp untuk notifikasi, autoresponder, pengingat, dan alur komunikasi bisnis.',
  'Skenario integrasi, metode koneksi, jumlah nomor, volume pesan, dan kebutuhan server ditinjau dahulu. SIMBAA tidak menjanjikan fitur yang bergantung pada provider pihak ketiga sebelum diverifikasi.',
  'Membantu komunikasi lebih konsisten; notifikasi lebih cepat; alur pelanggan dapat disederhanakan.',
  'Estimasi awal 2–7 hari kerja untuk setup standar; integrasi khusus dapat lebih lama.',
  'Setup awal, contoh alur, konfigurasi dasar, dan panduan penggunaan sesuai scope.',
  'Biaya provider/API, nomor WhatsApp, server, dan biaya pesan pihak ketiga kecuali tertulis.',
  'Metode resmi dan batasan platform dijelaskan sebelum integrasi. Pelanggan wajib mengikuti kebijakan WhatsApp dan penyedia.',0,'consultation','./assets/product-avatars/whatsapp.webp','💬','WhatsApp Automation','automation',true,
  '[{"label":"Kebutuhan utama","type":"select","required":true,"options":["Auto reply","Notifikasi order","Broadcast berizin","Reminder","Integrasi sistem","Lainnya"]},{"label":"Jumlah nomor","type":"select","required":true,"options":["1","2–3","Lebih dari 3","Belum tahu"]},{"label":"Sistem yang ingin dihubungkan","type":"text","required":false},{"label":"Perkiraan pesan harian","type":"select","required":false,"options":["Di bawah 100","100–500","500–1000","Lebih dari 1000","Belum tahu"]}]',7),
 ('server','Pterodactyl Panel Setup','pterodactyl-panel-setup',
  'Instalasi dan konfigurasi Pterodactyl Panel untuk pengelolaan server game atau aplikasi.',
  'Pemeriksaan mencakup kebutuhan VPS, panel, Wings, node, port, domain, SSL, dan layanan pendukung sesuai kondisi server.',
  'Setup lebih terarah; konfigurasi terdokumentasi; membantu pengelola memahami panel dan kebutuhan server.',
  'Estimasi awal 1–4 hari kerja setelah akses server dan kebutuhan tersedia.',
  'Instalasi/config sesuai pilihan, pengecekan akses, dan panduan dasar.',
  'Biaya VPS, domain, lisensi, tema premium, dan maintenance berkelanjutan kecuali disepakati.',
  'Pelanggan harus memiliki izin dan akses sah ke server yang akan dikonfigurasi.',0,'consultation',NULL,'🦖','Pterodactyl','server',false,
  '[{"label":"Kebutuhan","type":"select","required":true,"options":["Install baru","Perbaikan panel","Setup Wings / Node","Migrasi","Optimasi"]},{"label":"VPS sudah tersedia?","type":"select","required":true,"options":["Sudah","Belum"]},{"label":"Domain panel","type":"text","required":false},{"label":"Keterangan server","type":"textarea","required":false}]',8),
 ('automation','Bot & Automation','bot-automation',
  'Bot dan otomatisasi untuk membantu pekerjaan berulang di WhatsApp, Telegram, Discord, website, atau sistem internal.',
  'Alur bot dibuat berdasarkan pemicu, perintah, respons, integrasi, dan kebutuhan penyimpanan. Fitur final disepakati berdasarkan brief.',
  'Mengurangi pekerjaan manual; respons lebih konsisten; alur dapat disesuaikan dengan kebutuhan.',
  'Estimasi awal 3–10 hari kerja untuk bot sederhana; kompleksitas menentukan waktu.',
  'Script/bot sesuai fitur yang disepakati, konfigurasi awal, dan panduan dasar.',
  'Server, API berbayar, biaya platform, dan pengembangan fitur tambahan kecuali tertulis.',
  'Bot hanya dibuat untuk penggunaan yang sah dan tidak digunakan untuk spam atau penyalahgunaan.',0,'consultation',NULL,'🤖','Automation','automation',false,
  '[{"label":"Platform","type":"select","required":true,"options":["Telegram","Discord","WhatsApp","Website","Multi-platform"]},{"label":"Tujuan bot","type":"textarea","required":true},{"label":"Perintah / fitur utama","type":"textarea","required":true},{"label":"Sudah memiliki server?","type":"select","required":true,"options":["Ya","Belum","Perlu rekomendasi"]}]',9),
 ('design','UI/UX Design','ui-ux-design',
  'Desain pengalaman dan tampilan untuk website, aplikasi, dashboard, atau produk digital.',
  'Pekerjaan dapat meliputi audit ringkas, user flow, wireframe, high-fidelity UI, komponen, dan prototype sesuai paket.',
  'Tampilan lebih konsisten; alur lebih mudah dipahami; developer mendapat acuan visual yang jelas.',
  'Estimasi awal 3–10 hari kerja berdasarkan jumlah layar dan kompleksitas.',
  'File desain dan komponen sesuai kesepakatan, serta prototype bila termasuk paket.',
  'Implementasi coding, ilustrasi berlisensi, dan riset pengguna mendalam kecuali disepakati.',
  'Jumlah layar dan revisi ditetapkan dalam penawaran sebelum pekerjaan dimulai.',0,'consultation',NULL,'🎨','UI/UX Design','design',false,
  '[{"label":"Jenis desain","type":"select","required":true,"options":["Website","Mobile app","Dashboard","Redesign","Design system"]},{"label":"Jumlah layar","type":"select","required":true,"options":["1–5","6–10","11–20","Lebih dari 20","Belum tahu"]},{"label":"Referensi visual","type":"url","required":false},{"label":"Tujuan dan target pengguna","type":"textarea","required":true}]',10),
 ('digital','Website Template','website-template',
  'Template website untuk mempercepat pembuatan halaman bisnis, portofolio, landing page, atau dashboard.',
  'Sebelum pemesanan admin menjelaskan preview, teknologi, lisensi penggunaan, dependensi, dokumentasi, dan dukungan yang tersedia.',
  'Memulai proyek lebih cepat; struktur dasar siap disesuaikan; cocok untuk belajar dan pengembangan lanjutan.',
  'Pengiriman mengikuti ketersediaan produk dan verifikasi lisensi.',
  'File template dan dokumentasi yang tercantum pada produk.',
  'Hosting, domain, aset premium, instalasi custom, dan dukungan berkelanjutan kecuali tercantum.',
  'Lisensi penggunaan harus dibaca dan disetujui sebelum file dikirim.',0,'consultation',NULL,'🧩','Template','digital',false,
  '[{"label":"Jenis template","type":"select","required":true,"options":["Landing page","Company profile","Toko online","Dashboard","Portfolio"]},{"label":"Teknologi pilihan","type":"text","required":false},{"label":"Kebutuhan penyesuaian","type":"textarea","required":false}]',11),
 ('digital','Dashboard UI Kit','dashboard-ui-kit',
  'Kumpulan komponen dan layout UI untuk membantu developer membangun dashboard dengan tampilan konsisten.',
  'Ketersediaan, format file, framework, lisensi, dokumentasi, dan dukungan dijelaskan oleh admin sebelum pembelian.',
  'Menghemat waktu desain awal; komponen lebih konsisten; dapat menjadi fondasi pengembangan dashboard.',
  'Pengiriman digital setelah verifikasi stok dan lisensi.',
  'File UI kit dan daftar komponen sesuai deskripsi produk final.',
  'Implementasi ke proyek, aset premium, dan custom component di luar file produk.',
  'Produk digital mengikuti ketentuan lisensi dan kebijakan pengembalian yang dijelaskan sebelum transaksi.',0,'consultation',NULL,'📐','UI Kit','digital',false,
  '[{"label":"Format yang dibutuhkan","type":"select","required":true,"options":["Figma","HTML/CSS","React","Lainnya"]},{"label":"Framework / referensi","type":"text","required":false},{"label":"Catatan penggunaan","type":"textarea","required":false}]',12),
 ('digital','Source Code Project','source-code-project',
  'Source code untuk dipelajari atau dijadikan dasar proyek. Pembelian selalu melalui konsultasi admin agar lisensi, versi, dan kecocokan kebutuhan jelas.',
  'Admin akan menjelaskan fitur, teknologi, struktur folder, dependensi, dokumentasi, lisensi, dan kemungkinan penyesuaian sebelum memberikan penawaran.',
  'Mempercepat pembelajaran; memberi contoh struktur proyek; dapat menjadi dasar pengembangan dengan memahami lisensinya.',
  'Admin memeriksa ketersediaan dan versi sebelum memberi estimasi pengiriman atau penyesuaian.',
  'File source code dan dokumentasi sesuai listing/penawaran yang disetujui.',
  'Hosting, instalasi, modifikasi, update, dan dukungan teknis tidak termasuk kecuali tertulis.',
  'Konsultasi wajib sebelum transaksi. Tidak ada klaim lisensi atau hak jual kembali tanpa bukti.',0,'consultation',NULL,'</>','Source Code','digital',false,
  '[{"label":"Jenis source code","type":"select","required":true,"options":["Website","Dashboard","Bot","Aplikasi","Lainnya"]},{"label":"Tujuan penggunaan","type":"select","required":true,"options":["Belajar","Proyek pribadi","Bisnis","Pengembangan lanjutan"]},{"label":"Teknologi yang diinginkan","type":"text","required":false},{"label":"Pertanyaan lisensi / penyesuaian","type":"textarea","required":false}]',13),
 ('digital','Pterodactyl Theme Pack','pterodactyl-theme-pack',
  'Tema visual untuk panel Pterodactyl agar tampilan panel lebih sesuai dengan identitas dan preferensi pengelola server.',
  'Preview, kompatibilitas versi panel, lisensi, file pendukung, cara instalasi, dan kebutuhan modifikasi dikonfirmasi sebelum pemesanan.',
  'Panel lebih personal; tampilan lebih konsisten; dapat meningkatkan kenyamanan pengelola.',
  'Pengiriman mengikuti ketersediaan theme pack dan kompatibilitas versi.',
  'File tema dan panduan instalasi sesuai listing final.',
  'Instalasi, custom warna, modifikasi source, dan support jangka panjang kecuali tercantum.',
  'Pastikan versi Pterodactyl kompatibel sebelum menggunakan tema.',0,'consultation',NULL,'🎭','Theme Pack','digital',false,
  '[{"label":"Versi Pterodactyl","type":"text","required":true},{"label":"Jenis tema","type":"select","required":true,"options":["Dark","Light","Custom","Ingin lihat preview"]},{"label":"Perlu bantuan instalasi?","type":"select","required":true,"options":["Ya","Tidak"]}]',14),
 ('custom','Jasa Install & Setup','jasa-install-setup',
  'Bantuan instalasi, setup, konfigurasi, dan pengecekan layanan digital sesuai kebutuhan pelanggan.',
  'Ceritakan software, server, panel, atau sistem yang perlu dipasang. Admin memeriksa kompatibilitas dan akses terlebih dahulu.',
  'Mengurangi langkah teknis yang membingungkan; setup lebih terarah; kebutuhan dijelaskan sebelum pengerjaan.',
  'Estimasi ditentukan dari jenis software, kondisi server, dan akses yang tersedia.',
  'Instalasi dan pengecekan sesuai scope yang disetujui.',
  'Lisensi, VPS, domain, atau software pihak ketiga kecuali tercantum.',
  'Pelanggan wajib memiliki lisensi serta akses sah ke sistem yang akan dikelola.',0,'consultation',NULL,'🛠️','Install & Setup','custom',false,
  '[{"label":"Apa yang ingin di-install?","type":"text","required":true},{"label":"Sistem / server yang digunakan","type":"textarea","required":true},{"label":"Akses sudah siap?","type":"select","required":true,"options":["Ya","Belum","Perlu arahan"]}]',15)
) AS v(category,name,slug,description,details,benefits,turnaround,includes,exclusions,terms,price,price_type,image_url,icon,tag,config_profile,show_on_home,config,sort_order)
JOIN public.categories c ON c.slug = v.category
ON CONFLICT (slug) DO NOTHING;

-- Re-run safe: do not overwrite existing products. Make the catalog order deterministic.
-- Only new rows above are inserted; Owner edits to existing rows remain intact.

-- Announcement center. Public can read only active in-window rows; Owner can manage all rows.
CREATE TABLE IF NOT EXISTS public.store_announcements (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  title text NOT NULL,
  body text NOT NULL,
  announcement_type text NOT NULL DEFAULT 'info',
  cta_label text,
  cta_url text,
  starts_at timestamptz,
  ends_at timestamptz,
  sort_order integer NOT NULL DEFAULT 0,
  is_active boolean NOT NULL DEFAULT false,
  is_pinned boolean NOT NULL DEFAULT false,
  created_at timestamptz NOT NULL DEFAULT now(),
  updated_at timestamptz NOT NULL DEFAULT now(),
  CONSTRAINT store_announcements_type_check CHECK (announcement_type IN ('info','update','promo','maintenance','community')),
  CONSTRAINT store_announcements_window_check CHECK (ends_at IS NULL OR starts_at IS NULL OR ends_at > starts_at)
);
ALTER TABLE public.store_announcements ENABLE ROW LEVEL SECURITY;
DROP POLICY IF EXISTS "owner manages announcements" ON public.store_announcements;
DROP POLICY IF EXISTS "public reads active announcements" ON public.store_announcements;
CREATE POLICY "owner manages announcements" ON public.store_announcements
  FOR ALL TO authenticated
  USING ((SELECT private.is_store_owner()))
  WITH CHECK ((SELECT private.is_store_owner()));
CREATE POLICY "public reads active announcements" ON public.store_announcements
  FOR SELECT TO anon, authenticated
  USING (is_active = true AND (starts_at IS NULL OR starts_at <= now()) AND (ends_at IS NULL OR ends_at >= now()));
CREATE INDEX IF NOT EXISTS idx_store_announcements_window
  ON public.store_announcements (is_active, starts_at, ends_at, sort_order);
CREATE INDEX IF NOT EXISTS idx_products_public_catalog
  ON public.products (is_active, category, sort_order);

-- Explicit grants: RLS continues to enforce which rows each role may access.
GRANT SELECT ON public.products, public.categories, public.store_banners, public.promotions,
  public.portfolio_items, public.testimonials, public.faqs, public.store_settings, public.store_announcements
  TO anon, authenticated;
GRANT INSERT, UPDATE, DELETE ON public.products, public.categories, public.store_banners, public.promotions,
  public.portfolio_items, public.testimonials, public.faqs, public.store_settings, public.store_announcements
  TO authenticated;

COMMIT;

NOTIFY pgrst, 'reload schema';
