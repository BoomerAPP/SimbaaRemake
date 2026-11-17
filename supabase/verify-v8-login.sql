-- Read-only verification for SIMBAA v8 Owner login.
select u.id as user_id, u.email, o.username,
       case when o.user_id is not null then 'OWNER' else 'NOT OWNER' end as owner_status
from auth.users u
left join public.store_owners o on o.user_id = u.id
where lower(u.email) = lower('simbaagorncs@gmail.com');

select to_regclass('public.owner_login_attempts') as rate_limit_table;

select indexname
from pg_indexes
where schemaname = 'public'
  and tablename = 'store_owners'
  and indexname = 'store_owners_username_lower_uq';
