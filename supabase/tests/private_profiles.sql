-- Run as the migration owner. Fixtures and all changes are rolled back.
begin;
select set_config('mewvio_test.owner', gen_random_uuid()::text, true);
select set_config('mewvio_test.other', gen_random_uuid()::text, true);
insert into auth.users (id, email, created_at, updated_at, raw_app_meta_data, raw_user_meta_data)
select value::uuid, 'mewvio-rls-' || value || '@example.invalid', now(), now(), '{}'::jsonb, '{}'::jsonb
from (values (current_setting('mewvio_test.owner')), (current_setting('mewvio_test.other'))) as fixtures(value);

set local role authenticated;
select set_config('request.jwt.claim.sub', current_setting('mewvio_test.owner'), true);
select set_config('request.jwt.claims', json_build_object('sub', current_setting('mewvio_test.owner'), 'role', 'authenticated')::text, true);

do $$
declare visible_count integer;
begin
  insert into public.profiles (id, display_name, username, bio)
  values (auth.uid(), 'RLS owner', 'rls_' || substr(replace(auth.uid()::text, '-', ''), 1, 16), 'Private test');
  select count(*) into visible_count from public.profiles;
  if visible_count <> 1 then raise exception 'Owner cannot read exactly their own profile'; end if;
  update public.profiles set display_name = 'Updated owner' where id = auth.uid();
  if not found then raise exception 'Owner update failed'; end if;
  if not exists (select 1 from public.profiles where id = auth.uid() and display_name = 'Updated owner')
    then raise exception 'Saved profile was not persisted'; end if;

  begin
    insert into public.profiles (id, display_name) values (current_setting('mewvio_test.other')::uuid, 'Forged');
    raise exception 'Cross-user insert was accepted';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.profiles set id = current_setting('mewvio_test.other')::uuid where id = auth.uid();
    raise exception 'Profile owner can be reassigned';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.profiles set created_at = now() where id = auth.uid();
    raise exception 'Client can change server timestamps';
  exception when insufficient_privilege then null;
  end;
  begin
    delete from public.profiles where id = auth.uid();
    raise exception 'Client can delete profiles';
  exception when insufficient_privilege then null;
  end;
  begin
    update public.profiles set username = 'Invalid Username!' where id = auth.uid();
    raise exception 'Invalid username was accepted';
  exception when check_violation then null;
  end;
  if exists (select 1 from public.admin_members) then raise exception 'A normal user can read company membership'; end if;
  begin
    update public.admin_members set role = 'founder' where user_id = auth.uid();
    raise exception 'A normal user can alter company membership';
  exception when insufficient_privilege then null;
  end;
end;
$$;

select set_config('request.jwt.claim.sub', current_setting('mewvio_test.other'), true);
select set_config('request.jwt.claims', json_build_object('sub', current_setting('mewvio_test.other'), 'role', 'authenticated')::text, true);
do $$
begin
  if exists (select 1 from public.profiles) then raise exception 'Another user can read the owner profile'; end if;
  update public.profiles set bio = 'Tampered' where id = current_setting('mewvio_test.owner')::uuid;
  if found then raise exception 'Another user can update the owner profile'; end if;
end;
$$;

set local role anon;
do $$
begin
  begin
    perform 1 from public.profiles;
    raise exception 'Anonymous users can read profiles';
  exception when insufficient_privilege then null;
  end;
  begin
    insert into public.profiles (id, display_name) values (current_setting('mewvio_test.other')::uuid, 'Anonymous');
    raise exception 'Anonymous users can create profiles';
  exception when insufficient_privilege then null;
  end;
end;
$$;
reset role;
select 'PASS: owner CRUD restrictions, cross-user isolation, anonymous denial, company admin isolation' as result;
rollback;
