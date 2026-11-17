-- SIMBAA v6 additive migration
-- Run AFTER migration-v5-experience.sql. Does not reset products, Owner, passwords, or existing content.
begin;

-- Allow a promotion to be scoped to one product. NULL means it applies store-wide.
alter table public.promotions add column if not exists product_id uuid;
do $$ begin
  if not exists (
    select 1 from pg_constraint
    where conrelid='public.promotions'::regclass and conname='promotions_product_id_fkey'
  ) then
    alter table public.promotions
      add constraint promotions_product_id_fkey
      foreign key (product_id) references public.products(id) on delete set null;
  end if;
end $$;
create index if not exists promotions_product_active_idx on public.promotions(product_id,is_active);

-- Server-only rate-limit ledger for the public testimonial submission Edge Function.
create table if not exists public.review_submission_attempts (
  id uuid primary key default gen_random_uuid(),
  ip_hash text not null,
  attempted_at timestamptz not null default now()
);
create index if not exists review_submission_attempts_ip_time_idx on public.review_submission_attempts(ip_hash,attempted_at desc);
alter table public.review_submission_attempts enable row level security;
revoke all on public.review_submission_attempts from anon, authenticated;
grant all on public.review_submission_attempts to service_role;

-- Public review submissions are private until Owner reviews them.
create table if not exists public.testimonial_submissions (
  id uuid primary key default gen_random_uuid(),
  customer_name text not null check (char_length(btrim(customer_name)) between 2 and 80),
  customer_title text,
  message text not null check (char_length(btrim(message)) between 12 and 500),
  rating integer not null default 5 check (rating between 1 and 5),
  consent_confirmed boolean not null default false,
  status text not null default 'pending' check (status in ('pending','approved','rejected')),
  created_at timestamptz not null default now(),
  reviewed_at timestamptz
);

-- Keep approval idempotent so retrying an interrupted admin action cannot duplicate a testimonial.
alter table public.testimonials add column if not exists source_submission_id uuid;
do $$ begin
  if not exists (select 1 from pg_constraint where conrelid='public.testimonials'::regclass and conname='testimonials_source_submission_id_fkey') then
    alter table public.testimonials add constraint testimonials_source_submission_id_fkey
      foreign key (source_submission_id) references public.testimonial_submissions(id) on delete set null;
  end if;
end $$;
create unique index if not exists testimonials_source_submission_id_uq
  on public.testimonials(source_submission_id) where source_submission_id is not null;

alter table public.testimonial_submissions enable row level security;
revoke all on public.testimonial_submissions from anon, authenticated;
grant select, update on public.testimonial_submissions to authenticated;
grant all on public.testimonial_submissions to service_role;

drop policy if exists "public submits review for moderation" on public.testimonial_submissions;
drop policy if exists "owner reviews submissions" on public.testimonial_submissions;
create policy "owner reviews submissions"
  on public.testimonial_submissions for all to authenticated
  using ((select private.is_store_owner()))
  with check ((select private.is_store_owner()));
-- Public submissions go through simbaa-review-submit Edge Function only.
-- Its server-side Secret key is never shipped to the browser and enforces rate limits.

commit;

-- Read-only verification:
-- select column_name,data_type from information_schema.columns
-- where table_schema='public' and table_name='promotions' and column_name='product_id';
-- select count(*) from public.testimonial_submissions;
-- select count(*) from public.review_submission_attempts;
-- select tablename,policyname,cmd,roles from pg_policies
-- where schemaname='public' and tablename='testimonial_submissions';
