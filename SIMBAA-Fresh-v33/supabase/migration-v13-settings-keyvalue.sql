-- SIMBAA v13: compatibility migration for existing key/value store_settings.
-- Run after the previously supplied base migrations. This does not drop or reset data.
begin;

-- Ensure store_settings uses the existing key/value contract. If the table is absent,
-- create it in that same format; never introduce the incompatible `id` schema.
create table if not exists public.store_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now()
);

-- Keep any existing settings rows intact; add the default main document only if absent.
insert into public.store_settings(key,value)
values ('main', jsonb_build_object(
  'brand_name','SIMBAA',
  'tagline','Your Digital Partner',
  'whatsapp_number','6282132043632',
  'contact_email','',
  'website_url','',
  'instagram_url','',
  'tiktok_url','',
  'youtube_url','',
  'price_zero_label','Hubungi untuk penawaran',
  'price_note','Harga yang tampil merupakan harga acuan. Harga akhir dikonfirmasi oleh admin sebelum pembayaran.',
  'order_note','Silakan konfirmasi total harga, ruang lingkup, estimasi, dan ketentuan melalui WhatsApp sebelum melakukan pembayaran.'
)) on conflict (key) do nothing;

alter table public.store_settings enable row level security;
revoke all on table public.store_settings from anon, authenticated;
grant select on table public.store_settings to anon, authenticated;
grant insert, update, delete on table public.store_settings to authenticated;

drop policy if exists "public reads store settings" on public.store_settings;
drop policy if exists "owner inserts store settings" on public.store_settings;
drop policy if exists "owner updates store settings" on public.store_settings;
drop policy if exists "owner deletes store settings" on public.store_settings;
create policy "public reads store settings" on public.store_settings
  for select to anon, authenticated using (key = 'main');
create policy "owner inserts store settings" on public.store_settings
  for insert to authenticated with check ((select private.is_store_owner()) and key = 'main');
create policy "owner updates store settings" on public.store_settings
  for update to authenticated using ((select private.is_store_owner()) and key = 'main')
  with check ((select private.is_store_owner()) and key = 'main');
create policy "owner deletes store settings" on public.store_settings
  for delete to authenticated using ((select private.is_store_owner()) and key = 'main');

-- Price is numeric in the user's current schema. Remove legacy arbitrary caps only.
alter table public.promotions drop constraint if exists promotions_discount_value_check;
do $$ begin
  if not exists (select 1 from pg_constraint where conrelid='public.promotions'::regclass and conname='promotions_discount_value_nonnegative') then
    alter table public.promotions add constraint promotions_discount_value_nonnegative check (discount_value >= 0);
  end if;
end $$;

commit;

-- Verify: select key, value from public.store_settings where key='main';
