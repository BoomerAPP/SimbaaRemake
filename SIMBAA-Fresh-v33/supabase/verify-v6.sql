-- SIMBAA v6 read-only verification
select 'promotions.product_id' as check_name,
       exists(select 1 from information_schema.columns where table_schema='public' and table_name='promotions' and column_name='product_id') as passed;
select 'testimonial_submissions table' as check_name,
       to_regclass('public.testimonial_submissions') is not null as passed;
select 'testimonial_submissions RLS' as check_name,
       coalesce((select relrowsecurity from pg_class where oid='public.testimonial_submissions'::regclass),false) as passed;
select policyname,cmd,roles from pg_policies
where schemaname='public' and tablename='testimonial_submissions'
order by policyname;
select count(*) as pending_reviews from public.testimonial_submissions where status='pending';
