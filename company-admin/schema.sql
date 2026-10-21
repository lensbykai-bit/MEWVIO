-- MEWVIO Private Admin: schema applied to Supabase project swbsevzhudttiwwlcdwl
-- Kept as reference. Database was provisioned directly via Supabase migration.
create table if not exists public.admin_members (
 user_id uuid primary key references auth.users(id) on delete cascade,
 role text not null check (role in ('founder','ceo','manager','staff')),
 is_active boolean not null default true,
 created_at timestamptz not null default now()
);
alter table public.admin_members enable row level security;
revoke all on public.admin_members from anon;
revoke all on public.admin_members from authenticated;
grant select on public.admin_members to authenticated;
drop policy if exists "Members can read only their own role" on public.admin_members;
create policy "Members can read only their own role" on public.admin_members
for select to authenticated using (user_id = (select auth.uid()));
-- No browser-side role editing. Founder role is granted only to a verified
-- Supabase Auth user through a trusted administrative workflow.
-- Do not insert founder membership based on an unverified email.
