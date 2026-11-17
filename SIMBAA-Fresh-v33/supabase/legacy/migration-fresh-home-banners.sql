-- SIMBAA Fresh v1: home curation, product configuration fields, bilingual content, and 3 swipeable banners.
-- Run once in Supabase SQL Editor AFTER the existing SIMBAA schema.sql has been installed.
begin;

alter table public.products
  add column if not exists show_on_home boolean not null default false,
  add column if not exists configuration_fields jsonb not null default '[]'::jsonb,
  add column if not exists name_en text,
  add column if not exists description_en text;

create table if not exists public.store_banners (
  id uuid primary key default gen_random_uuid(),
  label text not null default 'SIMBAA UPDATE',
  label_en text,
  title text not null,
  title_en text,
  description text not null default '',
  description_en text,
  image_url text,
  target_url text,
  sort_order integer not null default 1 check (sort_order between 1 and 3),
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint store_banners_sort_order_unique unique(sort_order)
);

alter table public.store_banners enable row level security;
drop policy if exists "owner manages store banners" on public.store_banners;
drop policy if exists "public reads active store banners" on public.store_banners;
create policy "owner manages store banners" on public.store_banners
  for all to authenticated
  using (public.is_simbaagorn_owner())
  with check (public.is_simbaagorn_owner());
create policy "public reads active store banners" on public.store_banners
  for select to anon, authenticated
  using (is_active = true);

grant select on public.store_banners to anon, authenticated;
grant select, insert, update, delete on public.store_banners to authenticated;

-- Exactly three editable banner slots. Existing rows are not overwritten on re-run.
insert into public.store_banners(label,label_en,title,title_en,description,description_en,sort_order,is_active)
select v.label,v.label_en,v.title,v.title_en,v.description,v.description_en,v.sort_order,true
from (values
 ('SIMBAA DIGITAL SERVICE','SIMBAA DIGITAL SERVICE','Semua kebutuhan digital, satu tempat.','All your digital needs, in one place.','Temukan website, aplikasi, server, dan solusi digital dalam satu tempat.','Explore websites, apps, servers, and digital solutions in one place.',1),
 ('WEBSITE DEVELOPMENT','WEBSITE DEVELOPMENT','Wujudkan website impianmu.','Bring your website idea to life.','Mulai dari company profile hingga website bisnis yang responsif.','From company profiles to responsive business websites.',2),
 ('KONSULTASI GRATIS','FREE CONSULTATION','Masih bingung memilih layanan?','Need help choosing a service?','Ceritakan kebutuhanmu dan konsultasikan langsung melalui WhatsApp.','Tell us what you need and consult directly on WhatsApp.',3)
) as v(label,label_en,title,title_en,description,description_en,sort_order)
where not exists (select 1 from public.store_banners b where b.sort_order=v.sort_order);

-- Public image delivery; uploads and deletes remain Owner-only through Storage RLS.
insert into storage.buckets(id,name,public,file_size_limit,allowed_mime_types)
values('simbaa-store-media','simbaa-store-media',true,5242880,array['image/jpeg','image/png','image/webp','image/avif'])
on conflict(id) do update set public=true,file_size_limit=5242880,allowed_mime_types=array['image/jpeg','image/png','image/webp','image/avif'];

drop policy if exists "simbaa media owner uploads" on storage.objects;
drop policy if exists "simbaa media owner deletes" on storage.objects;
create policy "simbaa media owner uploads" on storage.objects
  for insert to authenticated
  with check (bucket_id='simbaa-store-media' and public.is_simbaagorn_owner());
create policy "simbaa media owner deletes" on storage.objects
  for delete to authenticated
  using (bucket_id='simbaa-store-media' and public.is_simbaagorn_owner());

commit;
