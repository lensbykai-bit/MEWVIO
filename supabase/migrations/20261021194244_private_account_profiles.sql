-- Additive mobile account storage. Company admin membership is unchanged.
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  display_name text not null default 'MEWVIO Friend'
    check (display_name = btrim(display_name) and char_length(display_name) between 1 and 60),
  username text unique
    check (username is null or username ~ '^[a-z0-9_]{3,24}$'),
  bio text not null default '' check (char_length(bio) <= 280),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

comment on table public.profiles is
  'Private MEWVIO mobile profiles. Accessible only by their authenticated owner.';

alter table public.profiles enable row level security;

revoke all on public.profiles from public, anon, authenticated;
grant select on public.profiles to authenticated;
grant insert (id, display_name, username, bio) on public.profiles to authenticated;
grant update (display_name, username, bio) on public.profiles to authenticated;

create policy profiles_select_own on public.profiles
  for select to authenticated using (id = (select auth.uid()));
create policy profiles_insert_own on public.profiles
  for insert to authenticated with check (id = (select auth.uid()));
create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = (select auth.uid())) with check (id = (select auth.uid()));

-- Timestamp maintenance is not an exposed Data API function and bypasses no RLS.
create schema if not exists mewvio_private;
revoke all on schema mewvio_private from public, anon, authenticated;
create function mewvio_private.touch_profile_updated_at()
returns trigger language plpgsql security invoker set search_path = '' as $$
begin
  new.updated_at = pg_catalog.now();
  return new;
end;
$$;
revoke all on function mewvio_private.touch_profile_updated_at()
  from public, anon, authenticated;
create trigger profiles_updated_at
  before update on public.profiles for each row
  execute function mewvio_private.touch_profile_updated_at();
