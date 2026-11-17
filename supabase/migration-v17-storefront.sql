-- SIMBAA Fresh v17 — additive storefront repair and starter catalog
-- Run after the existing SIMBAA base schema + migration-v5-experience.sql.
-- Safe to re-run: no existing product is overwritten or deleted.
BEGIN;

DO $$
BEGIN
  IF to_regclass('public.products') IS NULL THEN
    RAISE EXCEPTION 'public.products belum ada. Jalankan schema dasar SIMBAA dan migration v5 terlebih dahulu.';
  END IF;
  IF to_regclass('public.categories') IS NULL THEN
    RAISE EXCEPTION 'public.categories belum ada. Jalankan schema dasar SIMBAA dan migration v5 terlebih dahulu.';
  END IF;
END $$;

-- Normalize columns consumed by v15/v17 storefront and Owner dashboard.
ALTER TABLE public.products
  ADD COLUMN IF NOT EXISTS price bigint NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS category text,
  ADD COLUMN IF NOT EXISTS name_en text,
  ADD COLUMN IF NOT EXISTS description_en text,
  ADD COLUMN IF NOT EXISTS details text,
  ADD COLUMN IF NOT EXISTS benefits_text text,
  ADD COLUMN IF NOT EXISTS turnaround_text text,
  ADD COLUMN IF NOT EXISTS includes_text text,
  ADD COLUMN IF NOT EXISTS exclusions_text text,
  ADD COLUMN IF NOT EXISTS terms_text text,
  ADD COLUMN IF NOT EXISTS tag text,
  ADD COLUMN IF NOT EXISTS icon text,
  ADD COLUMN IF NOT EXISTS is_active boolean NOT NULL DEFAULT true,
  ADD COLUMN IF NOT EXISTS is_best_seller boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS show_on_home boolean NOT NULL DEFAULT false,
  ADD COLUMN IF NOT EXISTS configuration_fields jsonb NOT NULL DEFAULT '[]'::jsonb,
  ADD COLUMN IF NOT EXISTS image_url text,
  ADD COLUMN IF NOT EXISTS status text NOT NULL DEFAULT 'ready',
  ADD COLUMN IF NOT EXISTS sort_order integer NOT NULL DEFAULT 0,
  ADD COLUMN IF NOT EXISTS updated_at timestamptz NOT NULL DEFAULT now(),
  ADD COLUMN IF NOT EXISTS price_type text DEFAULT 'consultation';

-- If an older deployment used starting_price, preserve it when the v15 price field is empty.
DO $$
BEGIN
  IF EXISTS (
    SELECT 1 FROM information_schema.columns
    WHERE table_schema='public' AND table_name='products' AND column_name='starting_price'
  ) THEN
    EXECUTE 'UPDATE public.products SET price = starting_price WHERE coalesce(price,0)=0 AND coalesce(starting_price,0)>0';
  END IF;
END $$;

UPDATE public.products
SET price_type = CASE WHEN coalesce(price,0)>0 THEN 'fixed' ELSE 'consultation' END
WHERE price_type IS NULL OR price_type NOT IN ('fixed','from','consultation');
ALTER TABLE public.products ALTER COLUMN price_type SET DEFAULT 'consultation';
ALTER TABLE public.products ALTER COLUMN price_type SET NOT NULL;
ALTER TABLE public.products DROP CONSTRAINT IF EXISTS products_price_type_check;
ALTER TABLE public.products ADD CONSTRAINT products_price_type_check
  CHECK (price_type IN ('fixed','from','consultation'));

-- Ensure the basic categories exist without replacing Owner edits.
INSERT INTO public.categories(name,slug,description,sort_order,is_active) VALUES
 ('Website Development','development','Landing page, company profile, toko online, dan website custom.',1,true),
 ('VPS & Hosting','server','VPS Linux/Windows, RDP, hosting, dan server.',2,true),
 ('Source Code & Produk Digital','digital','Source code, template, dan konsultasi lisensi produk digital.',3,true)
ON CONFLICT (slug) DO NOTHING;

-- Starter catalog. All entries are editable/deletable from Owner dashboard.
-- Only the VPS starting price is taken from the supplied banner (Rp19.999/bulan).
INSERT INTO public.products
(name,slug,category,description,details,benefits_text,price,price_type,tag,icon,image_url,status,is_active,is_best_seller,show_on_home,configuration_fields,turnaround_text,includes_text,exclusions_text,terms_text,sort_order,updated_at)
VALUES
(
 'Website Landing Page','website-landing-page','development',
 'Landing page profesional untuk promosi bisnis, produk, jasa, event, atau personal brand. Cocok untuk mulai hadir secara online tanpa membuat website terasa rumit.',
 'Website satu halaman dengan struktur yang fokus pada tujuan pengunjung: mengenal layanan, melihat keunggulan, lalu menghubungi pemilik bisnis. Tampilan responsif untuk HP dan desktop.',
 'Membantu bisnis terlihat lebih profesional, menjelaskan penawaran dalam satu halaman, dan memudahkan calon pelanggan menghubungi pemilik bisnis.',
 0,'consultation','Website Development','🌐','./assets/product-avatars/website.webp','ready',true,true,true,
 '[{"label":"Jenis website","type":"select","required":true,"default_value":"Landing Page","options":["Landing Page","Company Profile","Toko Online","Portfolio","Custom Website"]},{"label":"Tujuan landing page","type":"select","required":true,"options":["Promosi bisnis","Jual produk/jasa","Personal brand","Event / pendaftaran","Lainnya" ]},{"label":"Nama brand / bisnis","type":"text","required":true},{"label":"Domain","type":"select","required":true,"options":["Sudah punya domain","Butuh rekomendasi domain","Belum tahu"]},{"label":"Referensi desain atau website","type":"url","required":false},{"label":"Konten dan foto sudah siap?","type":"select","required":true,"options":["Sudah","Sebagian","Belum"]}]'::jsonb,
 'Estimasi dibahas setelah brief, materi, dan ruang lingkup disepakati. Waktu pengerjaan mulai dihitung setelah bahan utama diterima.',
 'Desain responsif, struktur halaman sesuai brief, tombol kontak/WhatsApp, pengaturan dasar SEO on-page, dan panduan penggunaan saat serah terima.',
 'Domain, hosting berbayar, layanan pihak ketiga, penulisan konten profesional, foto berlisensi, dan fitur tambahan di luar ruang lingkup awal kecuali disepakati.',
 'Harga akhir dan jumlah revisi disepakati tertulis melalui WhatsApp sebelum pengerjaan dimulai. Jangan melakukan pembayaran sebelum menerima konfirmasi resmi.',10,now()
),
(
 'Website Company Profile','website-company-profile','development',
 'Website profil perusahaan atau organisasi untuk memperkenalkan identitas, layanan, portofolio, informasi kontak, dan meningkatkan kepercayaan calon pelanggan.',
 'Struktur halaman dapat mencakup Beranda, Tentang, Layanan, Portfolio, FAQ, dan Kontak. Susunan akhir mengikuti kebutuhan bisnis dan materi yang tersedia.',
 'Meningkatkan kepercayaan, membuat informasi perusahaan mudah ditemukan, dan menjadi pusat informasi resmi yang dapat dibagikan ke calon klien.',
 0,'consultation','Company Profile','🏢','./assets/product-avatars/website.webp','custom',true,true,true,
 '[{"label":"Jenis website","type":"select","required":true,"default_value":"Company Profile","options":["Landing Page","Company Profile","Toko Online","Portfolio","Custom Website"]},{"label":"Nama perusahaan / organisasi","type":"text","required":true},{"label":"Bidang usaha","type":"text","required":true},{"label":"Halaman yang dibutuhkan","type":"textarea","required":true},{"label":"Domain sudah tersedia?","type":"select","required":true,"options":["Sudah","Belum","Butuh saran"]},{"label":"Referensi website","type":"url","required":false}]'::jsonb,
 'Estimasi ditentukan dari jumlah halaman, kesiapan konten, dan kebutuhan integrasi.',
 'Perencanaan struktur, desain responsif, halaman sesuai kesepakatan, formulir/kontak, dan pengujian sebelum serah terima.',
 'Biaya domain/hosting, email bisnis, layanan eksternal, copywriting, foto premium, dan integrasi kompleks jika tidak tercantum dalam penawaran.',
 'Ruang lingkup, jadwal, revisi, dan biaya final dikonfirmasi oleh admin sebelum project dimulai.',20,now()
),
(
 'Website Toko Online','website-online-store','development',
 'Toko online untuk menampilkan katalog produk, informasi harga, detail produk, dan jalur pemesanan agar pelanggan lebih mudah berbelanja.',
 'Dapat mencakup halaman katalog, kategori, detail produk, informasi toko, dan tombol pemesanan. Pembayaran otomatis atau integrasi kurir hanya jika masuk ruang lingkup yang disepakati.',
 'Membantu katalog produk lebih rapi, pelanggan memahami pilihan sebelum bertanya, dan pemilik toko mengarahkan calon pembeli ke proses pemesanan.',
 0,'consultation','Online Store','🛍️','./assets/product-avatars/website.webp','custom',true,false,false,
 '[{"label":"Jenis website","type":"select","required":true,"default_value":"Toko Online","options":["Landing Page","Company Profile","Toko Online","Portfolio","Custom Website"]},{"label":"Jumlah produk awal","type":"number","required":true},{"label":"Metode pemesanan","type":"select","required":true,"options":["WhatsApp","Checkout website","Konsultasi dulu"]},{"label":"Metode pembayaran","type":"select","required":true,"options":["Transfer manual","Payment gateway","Belum ditentukan"]},{"label":"Butuh panel admin?","type":"select","required":true,"options":["Ya","Tidak","Minta rekomendasi"]}]'::jsonb,
 'Estimasi bergantung pada jumlah produk, panel admin, dan integrasi yang diperlukan.',
 'Struktur katalog, detail produk, kategori, tampilan mobile, dan panduan pengelolaan sesuai paket yang disepakati.',
 'Biaya payment gateway, biaya transaksi, layanan kurir, domain/hosting, dan integrasi eksternal di luar ruang lingkup.',
 'Fitur checkout dan pembayaran harus diuji serta disepakati terpisah. Harga final diberikan setelah analisis kebutuhan.',30,now()
),
(
 'VPS & Hosting Starter','vps-hosting-starter','server',
 'Server virtual untuk menjalankan website, aplikasi, bot, panel, atau kebutuhan digital lainnya. Pilih spesifikasi sesuai beban penggunaan.',
 'Paket awal mengacu pada harga mulai Rp19.999 per bulan sebagaimana materi banner. Spesifikasi, lokasi, sistem operasi, dan ketersediaan dikonfirmasi sebelum aktivasi.',
 'Menjadi lingkungan terpisah untuk menjalankan website, bot, panel, atau aplikasi dengan resource yang dapat disesuaikan menurut kebutuhan.',
 19999,'from','VPS & Hosting','🖥️','./assets/product-avatars/vps.webp','ready',true,true,true,
 '[{"label":"Sistem operasi","type":"select","required":true,"options":["Ubuntu","Debian","Windows Server","Lainnya / minta saran"]},{"label":"Kebutuhan server","type":"select","required":true,"options":["Website","Bot / automation","Game server","Panel / aplikasi","Remote desktop","Lainnya"]},{"label":"RAM / CPU yang diinginkan","type":"text","required":false},{"label":"Durasi","type":"select","required":true,"options":["1 Bulan","3 Bulan","6 Bulan","12 Bulan"]},{"label":"Lokasi server","type":"text","required":false}]'::jsonb,
 'Aktivasi mengikuti ketersediaan stok dan verifikasi konfigurasi. Estimasi dikonfirmasi admin sebelum pembayaran.',
 'Provisioning VPS sesuai paket yang disetujui, akses server, dan informasi dasar untuk mulai menggunakan server.',
 'Pengelolaan server berkelanjutan, lisensi berbayar, backup tambahan, migrasi data, dan konfigurasi khusus kecuali tercantum pada paket.',
 'Harga Rp19.999/bulan adalah harga mulai dari, bukan jaminan untuk semua spesifikasi. Spesifikasi final dan ketersediaan wajib dikonfirmasi admin.',40,now()
),
(
 'WhatsApp Gateway','whatsapp-gateway-setup','automation',
 'Integrasi WhatsApp untuk membantu bisnis mengelola chat, notifikasi, dan alur komunikasi pelanggan secara lebih terstruktur.',
 'Ruang lingkup dapat meliputi setup gateway, koneksi API, webhook, auto reply, notifikasi, atau integrasi sistem lain sesuai platform dan metode yang disepakati.',
 'Mengurangi pekerjaan berulang, membantu notifikasi lebih konsisten, dan menyambungkan percakapan WhatsApp dengan proses bisnis yang disepakati.',
 0,'consultation','WhatsApp Gateway','💬','./assets/product-avatars/whatsapp.webp','custom',true,true,true,
 '[{"label":"Tujuan penggunaan","type":"select","required":true,"options":["Notifikasi transaksi","Auto reply","Customer service","Integrasi website / aplikasi","Kampanye pesan dengan persetujuan","Lainnya"]},{"label":"Sudah punya server?","type":"select","required":true,"options":["Sudah","Belum","Minta rekomendasi"]},{"label":"Estimasi pesan per hari","type":"number","required":false},{"label":"Sistem yang ingin diintegrasikan","type":"textarea","required":false}]'::jsonb,
 'Estimasi ditentukan setelah metode integrasi, infrastruktur, dan kebutuhan fitur diketahui.',
 'Analisis kebutuhan, setup dasar sesuai kesepakatan, pengujian koneksi, dan panduan penggunaan.',
 'Biaya nomor/akun pihak ketiga, server, provider API, biaya percakapan resmi, serta fitur tambahan di luar brief.',
 'Penggunaan harus mematuhi kebijakan platform dan aturan persetujuan penerima. Tidak menjanjikan pengiriman massal tanpa batas.',50,now()
),
(
 'Aplikasi Web & Dashboard','web-app-dashboard','application',
 'Pembuatan aplikasi berbasis web untuk mengelola data, anggota, transaksi, laporan, atau proses operasional bisnis.',
 'Dapat mencakup autentikasi, role pengguna, dashboard, formulir, tabel data, dan integrasi API. Fitur final mengikuti analisis kebutuhan.',
 'Merapikan proses kerja, mengurangi pencatatan manual, dan menyajikan informasi operasional dalam satu aplikasi sesuai alur bisnis.',
 0,'consultation','Application Development','📊','./assets/product-avatars/website.webp','custom',true,false,false,
 '[{"label":"Tujuan aplikasi","type":"textarea","required":true},{"label":"Siapa saja penggunanya?","type":"text","required":true},{"label":"Fitur wajib","type":"textarea","required":true},{"label":"Perlu login dan role?","type":"select","required":true,"options":["Ya","Tidak","Belum tahu"]},{"label":"Referensi","type":"url","required":false}]'::jsonb,
 'Estimasi dibuat setelah alur kerja, modul, dan prioritas fitur disepakati.',
 'Analisis awal, rancangan modul, implementasi fitur yang disepakati, pengujian, dan dokumentasi dasar.',
 'Biaya layanan cloud pihak ketiga, lisensi, domain/hosting, dan modul tambahan di luar dokumen ruang lingkup.',
 'Project dimulai setelah kebutuhan dan milestone disetujui. Perubahan fitur dapat mengubah biaya dan jadwal.',60,now()
),
(
 'Source Code & Lisensi','source-code-consultation','digital',
 'Butuh source code, template, atau lisensi project tertentu? Konsultasikan kebutuhan dan tujuan penggunaan terlebih dahulu dengan admin SIMBAA.',
 'Admin akan membantu memeriksa ketersediaan, kompatibilitas, dokumentasi, hak penggunaan, dan kebutuhan penyesuaian. Tidak semua source code tersedia untuk dijual.',
 'Membantu memastikan teknologi, lisensi, dan dukungan sesuai kebutuhan sebelum pembelian; opsi instalasi atau penyesuaian dapat dibahas bila tersedia.',
 0,'consultation','Source Code','⌘','./assets/simbaa-mascot.png','custom',true,false,false,
 '[{"label":"Jenis source code / produk","type":"text","required":true},{"label":"Teknologi yang diinginkan","type":"text","required":false},{"label":"Tujuan penggunaan","type":"textarea","required":true},{"label":"Butuh instalasi atau custom?","type":"select","required":true,"options":["Hanya source code","Source code + instalasi","Source code + custom","Konsultasi dulu"]}]'::jsonb,
 'Ketersediaan dan estimasi disampaikan setelah admin memeriksa produk serta lisensinya.',
 'Pemeriksaan kebutuhan, informasi kompatibilitas, penjelasan lisensi, dan opsi bantuan instalasi/custom jika tersedia.',
 'Source code yang tidak tersedia, hak cipta pihak lain, lisensi komersial pihak ketiga, dan pengembangan tambahan yang belum disepakati.',
 'Kepemilikan, lisensi, batas distribusi, dan dukungan harus jelas sebelum transaksi. Pemesanan melalui konsultasi admin.',70,now()
),
(
 'UI/UX Design & Prototype','ui-ux-design-prototype','design',
 'Perancangan tampilan website atau aplikasi agar lebih mudah dipahami, nyaman digunakan, dan konsisten dengan identitas produk.',
 'Proses dapat meliputi pemahaman kebutuhan pengguna, struktur halaman, wireframe, desain antarmuka, dan prototype interaktif sesuai ruang lingkup.',
 'Membantu tim melihat alur produk sebelum development, mengurangi kebingungan pengguna, dan menjaga konsistensi tampilan antarlayar.',
 0,'consultation','UI/UX Design','🎨','./assets/product-avatars/website.webp','custom',true,false,false,
 '[{"label":"Platform desain","type":"select","required":true,"options":["Website","Mobile App","Dashboard","Website + Mobile"]},{"label":"Jumlah halaman / layar","type":"number","required":true},{"label":"Brand guideline sudah ada?","type":"select","required":true,"options":["Sudah","Belum","Perlu dibuat"]},{"label":"Referensi visual","type":"url","required":false},{"label":"Brief dan target pengguna","type":"textarea","required":true}]'::jsonb,
 'Estimasi mengikuti jumlah layar, tingkat kompleksitas, dan kesiapan brief.',
 'Rancangan alur, wireframe, desain antarmuka, dan prototype sesuai paket yang disetujui.',
 'Development frontend/backend, aset premium, riset pengguna berskala besar, dan revisi di luar kesepakatan.',
 'File final, format serah terima, hak penggunaan, dan jumlah revisi dikonfirmasi sebelum project dimulai.',80,now()
),
(
 'Bot & Workflow Automation','bot-workflow-automation','automation',
 'Otomatisasi tugas berulang dan bot untuk membantu proses operasional, notifikasi, atau layanan pelanggan di platform yang didukung.',
 'Dapat mencakup bot Telegram/WhatsApp sesuai metode yang tersedia, integrasi webhook/API, command, auto reply, dan alur kerja sederhana hingga custom.',
 'Menghemat waktu untuk proses berulang, menjaga alur kerja lebih konsisten, dan menghubungkan beberapa layanan sesuai kebutuhan.',
 0,'consultation','Bot & Automation','🤖','./assets/product-avatars/whatsapp.webp','custom',true,false,false,
 '[{"label":"Platform bot","type":"select","required":true,"options":["Telegram","WhatsApp","Website","Multi-platform"]},{"label":"Fungsi utama bot","type":"textarea","required":true},{"label":"Integrasi API / layanan","type":"text","required":false},{"label":"Server sudah tersedia?","type":"select","required":true,"options":["Sudah","Belum","Butuh rekomendasi"]},{"label":"Contoh alur atau referensi","type":"textarea","required":false}]'::jsonb,
 'Estimasi dibuat setelah alur otomatisasi, platform, dan integrasi disepakati.',
 'Analisis alur, implementasi bot sesuai fitur yang disetujui, pengujian, dan panduan dasar.',
 'Biaya API pihak ketiga, server, akun platform, dan integrasi eksternal berbayar jika tidak tercantum.',
 'Bot dan otomatisasi harus mematuhi ketentuan platform. Hindari spam, scraping tanpa izin, atau penyalahgunaan akun.',90,now()
)
ON CONFLICT (slug) DO NOTHING;

-- Set public starter banner images only where no custom image is already configured.
UPDATE public.store_banners SET image_url='./assets/banners/highlight-01.webp' WHERE sort_order=1 AND (image_url IS NULL OR btrim(image_url)='');
UPDATE public.store_banners SET image_url='./assets/banners/highlight-02.webp' WHERE sort_order=2 AND (image_url IS NULL OR btrim(image_url)='');
UPDATE public.store_banners SET image_url='./assets/banners/highlight-03.webp' WHERE sort_order=3 AND (image_url IS NULL OR btrim(image_url)='');

-- Public Data API access is granted, while RLS still limits public reads to active products.
ALTER TABLE public.products ENABLE ROW LEVEL SECURITY;
GRANT SELECT ON TABLE public.products TO anon, authenticated;
DO $$
BEGIN
  IF NOT EXISTS (SELECT 1 FROM pg_policies WHERE schemaname='public' AND tablename='products' AND policyname='public reads active products') THEN
    CREATE POLICY "public reads active products" ON public.products FOR SELECT TO anon, authenticated USING (is_active=true);
  END IF;
END $$;

-- Ensure the public catalog's supporting content can be read without exposing private review submissions.
DO $$
DECLARE
  item record;
BEGIN
  FOR item IN
    SELECT * FROM (VALUES
      ('categories','public reads active categories','is_active = true'),
      ('store_banners','public reads active banners','is_active = true'),
      ('promotions','public reads active promotions','is_active = true AND (starts_at IS NULL OR starts_at <= now()) AND (ends_at IS NULL OR ends_at >= now())'),
      ('portfolio_items','public reads active portfolio','is_active = true'),
      ('testimonials','public reads approved testimonials','is_active = true AND consent_confirmed = true'),
      ('faqs','public reads active faqs','is_active = true')
    ) AS t(table_name, policy_name, policy_expression)
  LOOP
    IF to_regclass(format('public.%I', item.table_name)) IS NOT NULL THEN
      EXECUTE format('ALTER TABLE public.%I ENABLE ROW LEVEL SECURITY', item.table_name);
      EXECUTE format('GRANT SELECT ON TABLE public.%I TO anon, authenticated', item.table_name);
      IF NOT EXISTS (
        SELECT 1 FROM pg_policies
        WHERE schemaname='public' AND tablename=item.table_name AND policyname=item.policy_name
      ) THEN
        EXECUTE format('CREATE POLICY %I ON public.%I FOR SELECT TO anon, authenticated USING (%s)', item.policy_name, item.table_name, item.policy_expression);
      END IF;
    END IF;
  END LOOP;
END $$;

-- Preserve existing store settings and fill only missing defaults.
DO $$
BEGIN
  IF to_regclass('public.store_settings') IS NOT NULL THEN
    UPDATE public.store_settings
    SET value = coalesce(value,'{}'::jsonb)
      || jsonb_build_object(
        'website_url', coalesce(nullif(value->>'website_url',''),'https://simbaa.my.id'),
        'tiktok_url', coalesce(nullif(value->>'tiktok_url',''),'https://www.tiktok.com/@simbaagorn_'),
        'price_zero_label', coalesce(nullif(value->>'price_zero_label',''),'Konsultasi Admin')
      ),
      updated_at=now()
    WHERE key='main';
  END IF;
END $$;

COMMIT;
