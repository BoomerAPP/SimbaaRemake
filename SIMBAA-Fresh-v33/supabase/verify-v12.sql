-- SIMBAA v12 read-only verification
select id,brand_name,tagline,whatsapp_number,updated_at
from public.store_settings where id='main';

select conname,pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid='public.promotions'::regclass and contype='c'
order by conname;

select tablename,policyname,cmd,roles
from pg_policies
where schemaname='public' and tablename='store_settings'
order by policyname;

select grantee,privilege_type
from information_schema.role_table_grants
where table_schema='public' and table_name='store_settings'
order by grantee,privilege_type;


-- Confirm the canonical price field, preserved legacy column (when present), and compatibility trigger.
select column_name,data_type,is_nullable,column_default
from information_schema.columns
where table_schema='public' and table_name='products'
  and column_name in ('price','starting_price')
order by column_name;

select trigger_name,event_manipulation,action_timing
from information_schema.triggers
where event_object_schema='public' and event_object_table='products'
  and trigger_name='sync_simbaa_product_price_compat';

select conname,pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid='public.products'::regclass
  and conname in ('simbaa_products_price_nonnegative','products_category_check');
