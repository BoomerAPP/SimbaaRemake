-- =============================================================
-- SIMBAA FRESH v4 MIGRATION
-- Schema alignment + secure Owner username login + promotions
-- Run once in Supabase SQL Editor. Additive; does not delete products.
-- =============================================================
begin;

-- Product fields consumed by v4 frontend/admin.
alter table public.products
  add column if not exists category text,
  add column if not exists name_en text,
  add column if not exists description_en text,
  add column if not exists show_on_home boolean not null default false,
  add column if not exists is_best_seller boolean not null default false,
  add column if not exists configuration_fields jsonb not null default '[]'::jsonb,
  add column if not exists image_url text,
  add column if not exists status text not null default 'ready',
  add column if not exists sort_order integer not null default 0;

-- Backfill category labels from relation when possible, then fallback.
update public.products p set category=c.slug
from public.categories c where p.category_id=c.id and (p.category is null or btrim(p.category)='');
update public.products set category='development' where category is null or btrim(category)='';

alter table public.store_owners add column if not exists username text;
create unique index if not exists store_owners_username_lower_uq
  on public.store_owners (lower(username)) where username is not null;

-- Set the known owner username only for the verified Auth UID.
update public.store_owners
set username='SimbaaOwner'
where user_id='d75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid
  and exists (select 1 from auth.users u where u.id=store_owners.user_id and lower(u.email)=lower('simbaagorncs@gmail.com'));

-- Username -> email resolver. It reveals only the email mapped to the exact owner username
-- so Supabase Auth can perform its normal password verification. No password is stored here.
create or replace function public.simbaa_owner_email(p_username text)
returns text
language sql
stable
security definer
set search_path = pg_catalog, public, auth
as $$
  select u.email::text
  from public.store_owners o
  join auth.users u on u.id=o.user_id
  where lower(o.username)=lower(btrim(p_username))
  limit 1;
$$;
revoke all on function public.simbaa_owner_email(text) from public;
grant execute on function public.simbaa_owner_email(text) to anon, authenticated;

-- Banner compatibility for the existing storefront/admin.
alter table public.store_banners
  add column if not exists label text not null default 'SIMBAA UPDATE',
  add column if not exists label_en text,
  add column if not exists title_en text,
  add column if not exists description text not null default '',
  add column if not exists description_en text,
  add column if not exists target_url text;
update public.store_banners
set description=coalesce(nullif(description,''),subtitle,''),
    target_url=coalesce(nullif(target_url,''),link_url)
where description='' or target_url is null;

-- Ensure the editor has three initial banner slots; existing slots/content are preserved.
insert into public.store_banners (title, subtitle, description, label, sort_order, is_active)
select v.title, v.subtitle, v.description, v.label, v.sort_order, false
from (values
  ('Solusi digital untuk kebutuhanmu','Diskusikan ide dan kebutuhan bersama SIMBAA.','Diskusikan ide dan kebutuhan bersama SIMBAA.','SIMBAA INTRO',1),
  ('Layanan fleksibel, proses terarah','Pilih layanan dan tentukan konfigurasi yang kamu butuhkan.','Pilih layanan dan tentukan konfigurasi yang kamu butuhkan.','OUR SERVICES',2),
  ('Butuh bantuan memilih layanan?','Tim SIMBAA siap membantu melalui WhatsApp.','Tim SIMBAA siap membantu melalui WhatsApp.','WE ARE HERE',3)
) as v(title,subtitle,description,label,sort_order)
where not exists (select 1 from public.store_banners b where b.sort_order=v.sort_order);

-- Promotions used by the public Promo page and admin panel.
create table if not exists public.promotions (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  code text unique,
  promo_type text not null default 'percent' check (promo_type in ('fixed','percent')),
  discount_value numeric(12,2) not null default 0 check (discount_value>=0),
  minimum_order numeric(14,2) not null default 0 check (minimum_order>=0),
  terms text not null default '',
  starts_at timestamptz, ends_at timestamptz,
  is_active boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);
alter table public.promotions enable row level security;
grant select on public.promotions to anon, authenticated;
grant insert, update, delete on public.promotions to authenticated;
drop policy if exists "public reads active promotions" on public.promotions;
drop policy if exists "owner manages promotions" on public.promotions;
create policy "public reads active promotions" on public.promotions
  for select to anon, authenticated using (is_active=true and (starts_at is null or starts_at<=now()) and (ends_at is null or ends_at>=now()));
create policy "owner manages promotions" on public.promotions
  for all to authenticated using ((select private.is_store_owner())) with check ((select private.is_store_owner()));

-- Public catalog can read active rows; owner permissions continue to rely on existing owner RLS.
commit;

-- Verify after migration:
-- select u.email,o.username,o.user_id from public.store_owners o join auth.users u on u.id=o.user_id;
-- select public.simbaa_owner_email('SimbaaOwner');
