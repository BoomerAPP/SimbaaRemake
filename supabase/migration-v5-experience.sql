-- =============================================================
-- SIMBAA FRESH v5 — EXPERIENCE + SECURITY MIGRATION
-- Apply after the SIMBAA base SQL and Owner mapping have been installed.
-- Additive: preserves existing product, owner, banner and promo rows.
-- Do NOT run legacy SQL files after this migration.
-- =============================================================
begin;

-- The owner helper is created by the original SIMBAA base schema.
-- It must live in the non-exposed private schema and check auth.uid().
do $$ begin
  if to_regprocedure('private.is_store_owner()') is null then
    raise exception 'private.is_store_owner() is missing. Run the SIMBAA base SQL first; do not continue with v5 migration.';
  end if;
  if to_regclass('public.store_owners') is null
     or to_regclass('public.categories') is null
     or to_regclass('public.products') is null
     or to_regclass('public.store_banners') is null then
    raise exception 'SIMBAA base tables are missing. Run the SIMBAA base SQL first.';
  end if;
end $$;
grant usage on schema private to authenticated;
grant execute on function private.is_store_owner() to authenticated;

-- 0) Seed the seven standard service categories without overwriting Owner edits.
insert into public.categories (name,slug,description,sort_order,is_active) values
 ('Website Development','development','Website company profile, landing page, toko online, dan sistem web.',1,true),
 ('Application Development','application','Aplikasi mobile, web app, dashboard, dan integrasi sistem.',2,true),
 ('VPS & Hosting','server','VPS, RDP, hosting, server, dan pengelolaan infrastruktur.',3,true),
 ('Bot & Automation','automation','Bot WhatsApp, integrasi API, dan otomatisasi workflow.',4,true),
 ('UI/UX Design','design','Riset pengalaman pengguna, wireframe, dan desain antarmuka.',5,true),
 ('Source Code & Digital Product','digital','Source code, template, dan produk digital siap pakai.',6,true),
 ('Custom Development','custom','Pengembangan khusus mengikuti kebutuhan dan ruang lingkup project.',7,true)
on conflict (slug) do nothing;

-- 1) Product schema consumed by v5 storefront/admin.
alter table public.products
  add column if not exists category text,
  add column if not exists name_en text,
  add column if not exists description_en text,
  add column if not exists details text,
  add column if not exists turnaround_text text,
  add column if not exists includes_text text,
  add column if not exists exclusions_text text,
  add column if not exists terms_text text,
  add column if not exists tag text,
  add column if not exists icon text,
  add column if not exists is_best_seller boolean not null default false,
  add column if not exists configuration_fields jsonb not null default '[]'::jsonb,
  add column if not exists image_url text,
  add column if not exists status text not null default 'ready',
  add column if not exists sort_order integer not null default 0,
  add column if not exists updated_at timestamptz not null default now();
update public.products p
set category = c.slug,
    updated_at = coalesce(p.updated_at, now())
from public.categories c
where p.category_id = c.id;
update public.products p
set category = c.slug, category_id = c.id
from public.categories c
where p.category_id is null
  and lower(btrim(coalesce(p.category,''))) in (lower(c.slug), lower(c.name));
update public.products set category='development' where category is null or btrim(category)='';
update public.products set configuration_fields='[]'::jsonb where configuration_fields is null;
update public.products set status='ready' where status is null or btrim(status)='';
update public.products p set category_id=c.id from public.categories c where p.category_id is null and p.category=c.slug;

-- 2) Three editable swipe banners. Existing custom text/images are retained.
alter table public.store_banners
  add column if not exists label text not null default 'SIMBAA HIGHLIGHT',
  add column if not exists label_en text,
  add column if not exists title_en text,
  add column if not exists description text not null default '',
  add column if not exists description_en text,
  add column if not exists target_url text,
  add column if not exists cta text,
  add column if not exists theme text,
  add column if not exists sort_order integer not null default 0,
  add column if not exists is_active boolean not null default false,
  add column if not exists updated_at timestamptz not null default now();
update public.store_banners
set description = coalesce(nullif(description,''), subtitle, ''),
    target_url = coalesce(nullif(target_url,''), link_url)
where description='' or target_url is null;
-- Activate only the three known inactive starter slides from the earlier migration.
update public.store_banners
set label='MULAI DARI KEBUTUHANMU', label_en='START WITH YOUR NEEDS',
    title='Temukan layanan digital yang tepat', title_en='Find the right digital service',
    description='Jelajahi website, aplikasi, server, desain, dan otomatisasi dalam satu katalog.',
    description_en='Explore websites, applications, servers, design, and automation in one catalog.',
    target_url='./layanan.html', cta='Jelajahi layanan', theme='banner-blue', is_active=true
where sort_order=1 and is_active=false and title in ('Solusi digital untuk kebutuhanmu','SIMBAA Service','');
update public.store_banners
set label='JELAS SEBELUM SEPAKAT', label_en='CLEAR BEFORE YOU DECIDE',
    title='Pahami detail dan harga acuan', title_en='Understand details and reference pricing',
    description='Lihat spesifikasi, status layanan, dan konfigurasi sebelum berdiskusi dengan admin.',
    description_en='Review specifications, service status, and configuration before speaking with the admin.',
    target_url='./layanan.html', cta='Lihat katalog', theme='banner-gold', is_active=true
where sort_order=2 and is_active=false and title in ('Layanan fleksibel, proses terarah','Layanan SIMBAA','');
update public.store_banners
set label='BUTUH YANG LEBIH SPESIFIK?', label_en='NEED SOMETHING CUSTOM?',
    title='Ceritakan ide custom-mu', title_en='Tell us about your custom idea',
    description='Diskusikan ruang lingkup, kebutuhan teknis, dan estimasi bersama tim SIMBAA.',
    description_en='Discuss scope, technical needs, and estimates with the SIMBAA team.',
    target_url='./bantuan.html', cta='Minta arahan', theme='banner-violet', is_active=true
where sort_order=3 and is_active=false and title in ('Butuh bantuan memilih layanan?','We are here to help','');
insert into public.store_banners (label,label_en,title,title_en,description,description_en,target_url,cta,theme,sort_order,is_active)
select v.label,v.label_en,v.title,v.title_en,v.description,v.description_en,v.target_url,v.cta,v.theme,v.sort_order,true
from (values
 ('MULAI DARI KEBUTUHANMU','START WITH YOUR NEEDS','Temukan layanan digital yang tepat','Find the right digital service','Jelajahi website, aplikasi, server, desain, dan otomatisasi dalam satu katalog.','Explore websites, applications, servers, design, and automation in one catalog.','./layanan.html','Jelajahi layanan','banner-blue',1),
 ('JELAS SEBELUM SEPAKAT','CLEAR BEFORE YOU DECIDE','Pahami detail dan harga acuan','Understand details and reference pricing','Lihat spesifikasi, status layanan, dan konfigurasi sebelum berdiskusi dengan admin.','Review specifications, service status, and configuration before speaking with the admin.','./layanan.html','Lihat katalog','banner-gold',2),
 ('BUTUH YANG LEBIH SPESIFIK?','NEED SOMETHING CUSTOM?','Ceritakan ide custom-mu','Tell us about your custom idea','Diskusikan ruang lingkup, kebutuhan teknis, dan estimasi bersama tim SIMBAA.','Discuss scope, technical needs, and estimates with the SIMBAA team.','./bantuan.html','Minta arahan','banner-violet',3)
) as v(label,label_en,title,title_en,description,description_en,target_url,cta,theme,sort_order)
where not exists (select 1 from public.store_banners b where b.sort_order=v.sort_order);

-- 3) Promotions: retain existing table/data, add ordering and expiry support.
create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(), name text not null, code text,
  promo_type text not null default 'percent' check (promo_type in ('fixed','percent')),
  discount_value numeric(12,2) not null default 0 check (discount_value>=0 and (promo_type <> 'percent' or discount_value<=100)),
  minimum_order numeric(14,2) not null default 0 check (minimum_order>=0),
  terms text not null default '', starts_at timestamptz, ends_at timestamptz,
  is_active boolean not null default false, sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.promotions add column if not exists sort_order integer not null default 0;
alter table public.promotions add column if not exists updated_at timestamptz not null default now();
do $$ begin
  if not exists (select 1 from pg_constraint where conrelid='public.promotions'::regclass and conname='promotions_percent_value_cap') then
    alter table public.promotions add constraint promotions_percent_value_cap check (promo_type <> 'percent' or discount_value <= 100);
  end if;
end $$;

-- 4) Portfolio. Public visibility is only for items explicitly activated by Owner.
create table if not exists public.portfolio_items (
  id uuid primary key default gen_random_uuid(), title text not null, title_en text,
  category text, summary text not null, summary_en text, project_url text, image_url text,
  is_active boolean not null default false, sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- 5) Testimonials: publication requires explicit permission.
create table if not exists public.testimonials (
  id uuid primary key default gen_random_uuid(), customer_name text not null,
  customer_title text, message text not null, rating integer not null default 5 check (rating between 1 and 5),
  avatar_url text, consent_confirmed boolean not null default false,
  is_active boolean not null default false, sort_order integer not null default 0,
  created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);
alter table public.testimonials add column if not exists consent_confirmed boolean not null default false;

-- 6) FAQ managed by the dashboard.
create table if not exists public.faqs (
  id uuid primary key default gen_random_uuid(), question text not null, question_en text,
  answer text not null, answer_en text, is_active boolean not null default true,
  sort_order integer not null default 0, created_at timestamptz not null default now(), updated_at timestamptz not null default now()
);

-- 7) Owner activity log. No customer credentials or message contents are logged.
create table if not exists public.store_activity_logs (
  id uuid primary key default gen_random_uuid(), actor_user_id uuid references auth.users(id) on delete set null,
  action text not null, entity text not null, entity_id text,
  summary text not null default '', created_at timestamptz not null default now()
);

-- 8) Persistent hashed-IP rate limit data for username login Edge Function.
-- No raw IP, username, email, or password is stored in this table.
create table if not exists public.owner_login_attempts (
  id uuid primary key default gen_random_uuid(),
  ip_hash text not null,
  attempted_at timestamptz not null default now()
);
create index if not exists owner_login_attempts_ip_time_idx
  on public.owner_login_attempts(ip_hash, attempted_at desc);
alter table public.owner_login_attempts enable row level security;
revoke all on public.owner_login_attempts from anon, authenticated;

-- 9) Owner username mapping. Do not modify auth.users or password.
alter table public.store_owners add column if not exists username text;
create unique index if not exists store_owners_username_lower_uq
  on public.store_owners(lower(username)) where username is not null;
update public.store_owners
set username='SimbaaOwner'
where user_id='d75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid
  and exists (select 1 from auth.users u where u.id=store_owners.user_id and lower(u.email)=lower('simbaagorncs@gmail.com'));
do $$ begin
  if not exists (
    select 1 from public.store_owners o
    join auth.users u on u.id=o.user_id
    where o.user_id='d75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid
      and lower(u.email)=lower('simbaagorncs@gmail.com')
      and lower(o.username)=lower('SimbaaOwner')
  ) then
    raise exception 'Owner verification failed for the expected SIMBAA account. Check the Owner UID and email before applying this migration.';
  end if;
end $$;
-- Remove v4 public email resolver. Username login is handled by the Edge Function only.
drop function if exists public.simbaa_owner_email(text);

-- 9) RLS grants and strict replacement of legacy policies.
grant select on public.categories, public.products, public.store_banners, public.promotions, public.portfolio_items, public.testimonials, public.faqs to anon, authenticated;
grant insert, update, delete on public.categories, public.products, public.store_banners, public.promotions, public.portfolio_items, public.testimonials, public.faqs to authenticated;
grant select, insert on public.store_activity_logs to authenticated;

alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.store_banners enable row level security;
alter table public.promotions enable row level security;
alter table public.portfolio_items enable row level security;
alter table public.testimonials enable row level security;
alter table public.faqs enable row level security;
alter table public.store_activity_logs enable row level security;

-- Drop policies on managed tables first: permissive legacy policies otherwise OR together.
do $$
declare r record;
begin
  for r in select schemaname, tablename, policyname from pg_policies
    where schemaname='public' and tablename in ('categories','products','store_banners','promotions','portfolio_items','testimonials','faqs','store_activity_logs')
  loop
    execute format('drop policy if exists %I on %I.%I',r.policyname,r.schemaname,r.tablename);
  end loop;
end $$;

create policy "public reads active categories" on public.categories for select to anon, authenticated using (is_active=true);
create policy "owner manages categories" on public.categories for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads active products" on public.products for select to anon, authenticated using (is_active=true);
create policy "owner manages products" on public.products for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads active banners" on public.store_banners for select to anon, authenticated using (is_active=true);
create policy "owner manages banners" on public.store_banners for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads active promotions" on public.promotions for select to anon, authenticated using (is_active=true and (starts_at is null or starts_at<=now()) and (ends_at is null or ends_at>=now()));
create policy "owner manages promotions" on public.promotions for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads active portfolio" on public.portfolio_items for select to anon, authenticated using (is_active=true);
create policy "owner manages portfolio" on public.portfolio_items for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads approved testimonials" on public.testimonials for select to anon, authenticated using (is_active=true and consent_confirmed=true);
create policy "owner manages testimonials" on public.testimonials for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "public reads active faqs" on public.faqs for select to anon, authenticated using (is_active=true);
create policy "owner manages faqs" on public.faqs for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));
create policy "owner reads activity" on public.store_activity_logs for select to authenticated using ((select private.is_store_owner()));
create policy "owner writes activity" on public.store_activity_logs for insert to authenticated with check ((select private.is_store_owner()) and actor_user_id=(select auth.uid()));

-- 10) Public media reads; only verified Owner can write/update/delete this bucket.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('simbaa-store-media','simbaa-store-media',true,5242880,array['image/jpeg','image/png','image/webp','image/avif'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=excluded.allowed_mime_types;
do $$
declare r record;
begin
  for r in select policyname from pg_policies where schemaname='storage' and tablename='objects'
    and (coalesce(qual,'') ilike '%simbaa-store-media%' or coalesce(with_check,'') ilike '%simbaa-store-media%')
  loop execute format('drop policy if exists %I on storage.objects',r.policyname); end loop;
end $$;
create policy "public reads simbaa media" on storage.objects for select to anon, authenticated using (bucket_id='simbaa-store-media');
create policy "owner uploads simbaa media" on storage.objects for insert to authenticated with check (bucket_id='simbaa-store-media' and (select private.is_store_owner()));
create policy "owner updates simbaa media" on storage.objects for update to authenticated using (bucket_id='simbaa-store-media' and (select private.is_store_owner())) with check (bucket_id='simbaa-store-media' and (select private.is_store_owner()));
create policy "owner deletes simbaa media" on storage.objects for delete to authenticated using (bucket_id='simbaa-store-media' and (select private.is_store_owner()));

commit;

-- Verify manually after running:
-- select u.email,o.username,o.user_id from public.store_owners o join auth.users u on u.id=o.user_id;
-- select column_name from information_schema.columns where table_schema='public' and table_name='products' order by ordinal_position;
-- select count(*) as active_banners from public.store_banners where is_active=true;
-- select tablename,policyname,cmd from pg_policies where schemaname='public' and tablename in ('categories','products','store_banners','promotions','portfolio_items','testimonials','faqs','store_activity_logs');
