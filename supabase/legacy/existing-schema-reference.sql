-- SimbaaGorn V4.2 | Supabase PostgreSQL schema — WhatsApp-first, no public checkout
-- Run in Supabase SQL Editor. Never expose service_role key in browser files.
begin;

create extension if not exists pgcrypto with schema extensions;

create table if not exists public.user_roles (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('owner')),
  created_at timestamptz not null default now()
);
create unique index if not exists one_simbaagorn_owner on public.user_roles(role) where role='owner';

create or replace function public.is_simbaagorn_owner()
returns boolean language sql stable security definer set search_path=public
as $$ select exists(select 1 from public.user_roles where user_id=auth.uid() and role='owner'); $$;
revoke all on function public.is_simbaagorn_owner() from public;
grant execute on function public.is_simbaagorn_owner() to authenticated;

-- Exact single-owner allowlist. A second account can never receive owner role.
create or replace function public.assign_simbaagorn_owner()
returns trigger language plpgsql security definer set search_path=public,auth
as $$
begin
  if lower(coalesce(new.email,''))='whinoosiel@gmail.com' then
    insert into public.user_roles(user_id,role) values(new.id,'owner')
    on conflict(user_id) do update set role='owner';
  end if;
  return new;
end; $$;
revoke all on function public.assign_simbaagorn_owner() from public;
drop trigger if exists on_auth_user_created_simbaagorn_owner on auth.users;
create trigger on_auth_user_created_simbaagorn_owner after insert on auth.users
for each row execute procedure public.assign_simbaagorn_owner();

create table if not exists public.products (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  slug text not null unique,
  category text not null check(category in ('development','server','digital')),
  description text not null default '',
  details text not null default '',
  starting_price bigint not null default 0 check(starting_price>=0),
  tag text not null default 'Jasa',
  image_url text,
  is_active boolean not null default true,
  is_best_seller boolean not null default false,
  sort_order integer not null default 0,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists products_public_order on public.products(is_active,sort_order,created_at);

create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique,
  promo_type text not null check(promo_type in ('fixed','percent')),
  discount_value numeric(12,2) not null check(discount_value>=0 and ((promo_type='fixed' and discount_value<=7999) or (promo_type='percent' and discount_value<=100))),
  minimum_order bigint not null default 0 check(minimum_order>=0),
  starts_at timestamptz,
  ends_at timestamptz,
  terms text not null default '',
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.purchase_bonuses (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  bonus_type text not null check(bonus_type in ('product','order_total','campaign')),
  rule_value text not null,
  description text not null default '',
  is_active boolean not null default false,
  created_at timestamptz not null default now()
);

create table if not exists public.orders (
  id uuid primary key default gen_random_uuid(),
  order_code text not null unique,
  product_id uuid references public.products(id) on delete set null,
  product_name text not null,
  product_category text,
  customer_name text not null,
  customer_contact text not null,
  requirements jsonb not null default '{}'::jsonb,
  promo_code text,
  final_price bigint check(final_price is null or final_price>=0),
  status text not null default 'Menunggu konfirmasi' check(status in ('Menunggu konfirmasi','Menunggu pembayaran','Pembayaran diverifikasi','Pengerjaan','Selesai','Dibatalkan')),
  admin_note text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
create index if not exists orders_created_idx on public.orders(created_at desc);
create index if not exists orders_code_idx on public.orders(order_code);

-- New transactions are recorded by the Owner after WhatsApp consultation.
-- There is deliberately no public checkout, order-creation RPC, tracking code, or public purchase lookup.

alter table public.user_roles enable row level security;
alter table public.products enable row level security;
alter table public.promotions enable row level security;
alter table public.purchase_bonuses enable row level security;
alter table public.orders enable row level security;

drop policy if exists "owner reads own role" on public.user_roles;
create policy "owner reads own role" on public.user_roles for select to authenticated using(user_id=auth.uid());
drop policy if exists "owner manages products" on public.products;
create policy "owner manages products" on public.products for all to authenticated using(public.is_simbaagorn_owner()) with check(public.is_simbaagorn_owner());
drop policy if exists "public reads active products" on public.products;
create policy "public reads active products" on public.products for select to anon,authenticated using(is_active=true);
drop policy if exists "owner manages promotions" on public.promotions;
create policy "owner manages promotions" on public.promotions for all to authenticated using(public.is_simbaagorn_owner()) with check(public.is_simbaagorn_owner());
drop policy if exists "public reads current promotions" on public.promotions;
create policy "public reads current promotions" on public.promotions for select to anon,authenticated using(is_active=true and (starts_at is null or starts_at<=now()) and (ends_at is null or ends_at>=now()));
drop policy if exists "owner manages bonuses" on public.purchase_bonuses;
create policy "owner manages bonuses" on public.purchase_bonuses for all to authenticated using(public.is_simbaagorn_owner()) with check(public.is_simbaagorn_owner());
drop policy if exists "public reads active bonuses" on public.purchase_bonuses;
create policy "public reads active bonuses" on public.purchase_bonuses for select to anon,authenticated using(is_active=true);
-- Drop every pre-existing orders policy before installing the single Owner-only policy.
-- This prevents permissive policies from older versions being OR-combined with this one.
do $$
declare old_policy record;
begin
  for old_policy in
    select policyname from pg_policies where schemaname='public' and tablename='orders'
  loop
    execute format('drop policy if exists %I on public.orders', old_policy.policyname);
  end loop;
end $$;
create policy "owner manages orders" on public.orders for all to authenticated using(public.is_simbaagorn_owner()) with check(public.is_simbaagorn_owner());

-- Explicit grants; RLS remains the actual row-level security boundary.
grant select on public.products, public.promotions, public.purchase_bonuses to anon, authenticated;
grant select on public.user_roles to authenticated;
grant select, insert, update, delete on public.products, public.promotions, public.purchase_bonuses to authenticated;
revoke all on table public.orders from public, anon;
grant select, insert, update, delete on public.orders to authenticated;

-- Seed catalogue with V3.1 reference prices. Admin must confirm active prices before publishing.
insert into public.products(name,slug,category,description,starting_price,tag,is_active,is_best_seller,sort_order,details) values
('Website Development','website-development','development','Website bisnis, portfolio, landing page, dan toko online.',24999,'Jasa',true,true,1,'Struktur halaman responsif, UI sesuai brand, integrasi dan SEO dasar sesuai scope.'),
('Application Development','application-development','development','Aplikasi dan web app sesuai kebutuhan project.',49999,'Jasa',true,false,2,'Perencanaan fitur, frontend, backend/API dan database sesuai scope.'),
('Dashboard & Custom System','dashboard-custom-system','development','Dashboard admin, panel manajemen, dan sistem khusus.',79999,'Custom',true,false,3,'Role-based dashboard, tabel, pencarian, integrasi API dan database.'),
('WhatsApp Gateway','whatsapp-gateway','server','Integrasi bot, notifikasi, dan otomasi WhatsApp.',19999,'Jasa',true,false,4,'Otomasi pesan dan integrasi API sesuai kebijakan platform.'),
('Pterodactyl Panel','pterodactyl-panel','server','Instalasi, konfigurasi, tema, dan optimasi panel.',29999,'Setup',true,true,5,'Panel, Wings/node, egg, allocation, SSL dan tema sesuai kebutuhan.'),
('VPS & Hosting','vps-hosting','server','Server virtual untuk website, API, bot, game server dan remote desktop.',14999,'Server',true,false,6,'Paket, vCPU, RAM, storage, bandwidth, IP, lokasi, OS, lisensi dan masa aktif wajib dikonfirmasi admin.'),
('Website Template','website-template','digital','Template website siap disesuaikan untuk brand.',9999,'Produk',true,false,7,'Preview, halaman, dependensi, lisensi dan panduan instalasi.'),
('Dashboard UI Kit','dashboard-ui-kit','digital','Komponen UI untuk membangun dashboard.',14999,'Produk',true,false,8,'Komponen layout, navigasi, tabel dan form sesuai paket.'),
('Source Code Project','source-code-project','digital','Source code project dengan struktur yang dapat ditinjau.',39999,'Produk',true,false,9,'Bahasa, framework, versi dependensi, lisensi dan dokumentasi.'),
('Pterodactyl Theme Pack','pterodactyl-theme-pack','digital','Tema panel untuk tampilan server yang lebih personal.',19999,'Produk',true,false,10,'Kompatibilitas versi panel, panduan instalasi dan lisensi.')
on conflict(slug) do nothing;

-- Initial first-purchase campaign. Exact eligibility and amount are confirmed manually by the Owner.
insert into public.promotions(name,code,promo_type,discount_value,minimum_order,terms,is_active)
values('Promo Pembeli Baru','FIRSTBUY','fixed',2999,0,'Potongan khusus pembelian pertama dalam rentang Rp2.999–Rp7.999. Admin menetapkan nilai yang berlaku, memeriksa riwayat pembelian, periode, minimum transaksi, dan syarat sebelum mengonfirmasi. Tidak otomatis diterapkan sebelum persetujuan admin.',true)
on conflict(code) do nothing;

-- If the Owner user already exists before this schema was installed, assign role once:
insert into public.user_roles(user_id,role)
select id,'owner' from auth.users where lower(email)='whinoosiel@gmail.com'
on conflict(user_id) do update set role='owner';

commit;
