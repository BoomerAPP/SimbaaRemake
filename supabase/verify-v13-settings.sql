-- SIMBAA v13 verification
select key, jsonb_typeof(value) as value_type, updated_at
from public.store_settings where key='main';

select column_name, data_type
from information_schema.columns
where table_schema='public' and table_name='store_settings'
order by ordinal_position;

select conname, pg_get_constraintdef(oid) as definition
from pg_constraint
where conrelid='public.promotions'::regclass and contype='c';
