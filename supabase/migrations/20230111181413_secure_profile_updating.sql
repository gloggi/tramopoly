drop policy "Enable updating own profile" on "public"."profiles";

set check_function_bodies = off;

create or replace view "public"."registerable_profiles" as  SELECT 1 AS row_num,
    profiles.scout_name,
    profiles.preferred_call_method,
    profiles.group_id
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.group_id IS NULL));


CREATE OR REPLACE FUNCTION public.update_profile_phone_from_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  update public.profiles
  set phone=new.phone
  where profiles.id=new.id;
  return new;
end;
$function$
;

create or replace view "public"."updateable_profiles" as  SELECT profiles.id,
    profiles.scout_name,
    profiles.preferred_call_method,
    profiles.active_caller_id
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.group_id IS NOT NULL));


CREATE OR REPLACE FUNCTION public.create_profile_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  insert into public.profiles (id, phone)
  values (new.id, new.phone);
  return new;
end;
$function$
;

CREATE TRIGGER on_auth_user_updated AFTER UPDATE ON auth.users FOR EACH ROW EXECUTE FUNCTION update_profile_phone_from_user();

