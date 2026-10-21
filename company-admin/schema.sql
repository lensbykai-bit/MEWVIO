-- MEWVIO Technologies: private admin membership and role authorization
-- Run ONLY inside your own MEWVIO project SQL Editor.
-- Requires Supabase Auth users to exist before granting founder role.
create table if not exists public.admin_members (
  user_id uuid primary key references auth.users(id) on delete cascade,
  role text not null check (role in ('founder','ceo','manager','staff')),
  is_active boolean not null default true,
  created_at timestamptz not null default now()
);
alter table public.admin_members enable row level security;
revoke all on public.admin_members from anon;
grant select on public.admin_members to authenticated;
-- Any active admin can read membership; no client can assign/edit roles.
drop policy if exists "Active admins can read team" on public.admin_members;
create policy "Active admins can read team" on public.admin_members for select to authenticated
using (exists(select 1 from public.admin_members as mine where mine.user_id=(select auth.uid()) and mine.is_active));
-- CAUTION: the policy above recursively references its own table in Postgres.
-- Replace it with a SECURITY DEFINER membership-check helper before production:
drop policy if exists "Active admins can read team" on public.admin_members;
create or replace function public.is_mewvio_admin()
returns boolean language sql security definer stable
set search_path = '' as $$
  select exists (select 1 from public.admin_members
    where user_id = (select auth.uid()) and is_active = true);
$$;
revoke all on function public.is_mewvio_admin() from public;
grant execute on function public.is_mewvio_admin() to authenticated;
create policy "Active admins can read team" on public.admin_members
for select to authenticated using ((select public.is_mewvio_admin()));
-- No insert/update/delete policies: browser users cannot promote themselves.
-- AFTER you sign up the founder account through Supabase Auth:
-- Find that confirmed user's UUID in Authentication > Users.
-- Then run this line in SQL Editor, substituting the UUID with the verified value:
-- insert into public.admin_members (user_id,role) values ('FOUNDER_AUTH_USER_UUID','founder');
