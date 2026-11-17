-- SIMBAA Fresh v12: simple Owner settings and unrestricted reference pricing.
-- Run AFTER the existing SIMBAA base schema + v5 + v6 + v8 + v11 migration.
-- Additive migration: does not reset products, users, Owner mapping, or existing content.

begin;

-- Normalize the product price field used by the current dashboard and storefront.
-- Some older SIMBAA base schemas stored this value as `starting_price`; the current
-- frontend reads/writes `price`. Add the canonical column without deleting old data.
do $$
declare
  has_price boolean;
  has_starting_price boolean;
begin
  select exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='products' and column_name='price'
  ) into has_price;
  select exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='products' and column_name='starting_price'
  ) into has_starting_price;

  if not has_price then
    alter table public.products add column price bigint not null default 0;
    if has_starting_price then
      execute 'update public.products set price = starting_price';
    end if;
  end if;
end $$;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid='public.products'::regclass
      and conname='simbaa_products_price_nonnegative'
  ) then
    alter table public.products
      add constraint simbaa_products_price_nonnegative check (price >= 0);
  end if;
end $$;

-- Keep old integrations that still write `starting_price` compatible, while making
-- the dashboard's `price` field canonical for new changes.
do $$
begin
  if exists (
    select 1 from information_schema.columns
    where table_schema='public' and table_name='products' and column_name='starting_price'
  ) then
    execute $fn$
      create or replace function public.sync_simbaa_product_price_compat()
      returns trigger
      language plpgsql
      set search_path = public
      as $body$
      begin
        if tg_op = 'INSERT' then
          if coalesce(new.price,0)=0 and coalesce(new.starting_price,0)>0 then
            new.price := new.starting_price;
          else
            new.starting_price := new.price;
          end if;
        elsif new.price is distinct from old.price then
          new.starting_price := new.price;
        elsif new.starting_price is distinct from old.starting_price then
          new.price := new.starting_price;
        end if;
        return new;
      end;
      $body$;
    $fn$;
    execute 'drop trigger if exists sync_simbaa_product_price_compat on public.products';
    execute 'create trigger sync_simbaa_product_price_compat before insert or update on public.products for each row execute function public.sync_simbaa_product_price_compat()';
    execute 'revoke all on function public.sync_simbaa_product_price_compat() from public, anon, authenticated';
  end if;
end $$;

-- Categories are Owner-managed and may be added later; remove the legacy fixed
-- three-value category check if the old base schema still has it.
alter table public.products drop constraint if exists products_category_check;

-- General storefront settings. Only non-secret, public-facing values belong here.
create table if not exists public.store_settings (
  id text primary key default 'main' check (id = 'main'),
  brand_name text not null default 'SIMBAA',
  tagline text not null default 'Your Digital Partner',
  whatsapp_number text not null default '6282132043632',
  contact_email text,
  website_url text,
  instagram_url text,
  tiktok_url text,
  youtube_url text,
  price_zero_label text not null default 'Hubungi untuk penawaran',
  price_note text not null default 'Harga yang tampil merupakan harga acuan. Harga akhir dikonfirmasi oleh admin sebelum pembayaran.',
  order_note text not null default 'Silakan konfirmasi total harga, ruang lingkup, estimasi, dan ketentuan melalui WhatsApp sebelum melakukan pembayaran.',
  updated_at timestamptz not null default now()
);

insert into public.store_settings (id,brand_name,tagline,whatsapp_number)
values ('main','SIMBAA','Your Digital Partner','6282132043632')
on conflict (id) do nothing;

alter table public.store_settings enable row level security;
revoke all on table public.store_settings from anon, authenticated;
grant select on table public.store_settings to anon, authenticated;
grant insert, update, delete on table public.store_settings to authenticated;

drop policy if exists "public reads store settings" on public.store_settings;
drop policy if exists "owner inserts store settings" on public.store_settings;
drop policy if exists "owner updates store settings" on public.store_settings;
drop policy if exists "owner deletes store settings" on public.store_settings;

create policy "public reads store settings"
  on public.store_settings for select to anon, authenticated
  using (id = 'main');

create policy "owner inserts store settings"
  on public.store_settings for insert to authenticated
  with check ((select private.is_store_owner()) and id = 'main');

create policy "owner updates store settings"
  on public.store_settings for update to authenticated
  using ((select private.is_store_owner()) and id = 'main')
  with check ((select private.is_store_owner()) and id = 'main');

create policy "owner deletes store settings"
  on public.store_settings for delete to authenticated
  using ((select private.is_store_owner()) and id = 'main');

-- Older installations may have inherited a starter-promo fixed-discount ceiling.
-- Remove only the legacy generated constraint, then retain non-negative values and
-- the legitimate 0–100 range for percentage discounts. Fixed discounts have no
-- arbitrary 7,999 / 400,000 style cap in the application migration.
alter table public.promotions
  drop constraint if exists promotions_discount_value_check;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conrelid = 'public.promotions'::regclass
      and conname = 'promotions_discount_value_nonnegative'
  ) then
    alter table public.promotions
      add constraint promotions_discount_value_nonnegative check (discount_value >= 0);
  end if;
end $$;

-- Ensure the currently used public fields remain explicitly exposed to the Data API.
-- RLS policies above still restrict public access to the single safe settings row.
grant select on public.store_settings to anon, authenticated;
grant insert, update, delete on public.store_settings to authenticated;

commit;

-- Verification:
-- select * from public.store_settings where id='main';
-- select conname, pg_get_constraintdef(oid) from pg_constraint
-- where conrelid='public.promotions'::regclass and contype='c';
-- select tablename,policyname,cmd,roles from pg_policies
-- where schemaname='public' and tablename='store_settings';
