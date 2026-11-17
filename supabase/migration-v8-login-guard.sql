-- SIMBAA v8 — Owner login guard
-- Apply after the original base schema. Additive only: does not modify Auth passwords,
-- does not create/delete accounts, and does not expose a public username-to-email resolver.

begin;

alter table public.store_owners add column if not exists username text;
alter table public.store_owners enable row level security;
grant select on public.store_owners to authenticated, service_role;
drop policy if exists "owner reads own record" on public.store_owners;
create policy "owner reads own record" on public.store_owners
  for select to authenticated
  using (user_id = (select auth.uid()));
create unique index if not exists store_owners_username_lower_uq
  on public.store_owners (lower(username)) where username is not null;

-- Ensure the rate-limit table exists even if an earlier v5 migration was skipped.
create table if not exists public.owner_login_attempts (
  id uuid primary key default gen_random_uuid(),
  ip_hash text not null,
  attempted_at timestamptz not null default now()
);
create index if not exists owner_login_attempts_ip_time_idx
  on public.owner_login_attempts (ip_hash, attempted_at desc);
alter table public.owner_login_attempts enable row level security;
revoke all on public.owner_login_attempts from public, anon, authenticated;
grant select, insert on public.owner_login_attempts to service_role;
grant select on public.store_owners to service_role;

-- Confirm the mapped Owner account; deliberately do not overwrite any other Owner.
do $$
begin
  if not exists (
    select 1
    from public.store_owners o
    join auth.users u on u.id = o.user_id
    where o.user_id = 'd75b59dd-de05-4a2a-8a76-a0cd72f0d289'::uuid
      and lower(u.email) = lower('simbaagorncs@gmail.com')
      and lower(o.username) = lower('SimbaaOwner')
  ) then
    raise exception 'SIMBAA Owner mapping was not found. Expected the existing Auth UID, email, and username SimbaaOwner. No account or password was changed.';
  end if;
end $$;

-- The older public email resolver is not needed; username resolution stays server-side.
drop function if exists public.simbaa_owner_email(text);

commit;
