drop policy "Enable inserting for authenticated users which have no group" on "public"."groups";

create table "public"."profiles" (
    "id" uuid not null,
    "created_at" timestamp with time zone default now(),
    "scout_name" text,
    "group_id" bigint,
    "phone" text,
    "preferred_call_method" text,
    "role" text not null default 'player'::text
);


alter table "public"."profiles" enable row level security;

CREATE UNIQUE INDEX profiles_pkey ON public.profiles USING btree (id);

alter table "public"."profiles" add constraint "profiles_pkey" PRIMARY KEY using index "profiles_pkey";

alter table "public"."profiles" add constraint "profiles_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) not valid;

alter table "public"."profiles" validate constraint "profiles_group_id_fkey";

alter table "public"."profiles" add constraint "profiles_id_fkey" FOREIGN KEY (id) REFERENCES auth.users(id) not valid;

alter table "public"."profiles" validate constraint "profiles_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.create_profile_for_new_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  INSERT INTO public.profiles (id, phone)
  VALUES (new.id, new.phone);
  RETURN new;
END;
$function$
;

CREATE OR REPLACE FUNCTION public.delete_profile_for_deleted_user()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
BEGIN
  DELETE FROM public.profiles
  WHERE id=old.id;
  RETURN old;
END;
$function$
;

CREATE TRIGGER on_auth_user_created AFTER INSERT ON auth.users FOR EACH ROW EXECUTE FUNCTION create_profile_for_new_user();

CREATE TRIGGER on_auth_user_deleted BEFORE DELETE ON auth.users FOR EACH ROW EXECUTE FUNCTION delete_profile_for_deleted_user();


CREATE POLICY "Enable reading own profile"
on "public"."profiles"
AS PERMISSIVE
FOR SELECT
TO authenticated
USING ((auth.uid() = id));


CREATE POLICY "Enable inserting for authenticated users which have no group"
ON "public"."groups"
AS PERMISSIVE
FOR INSERT
TO authenticated
WITH CHECK ((EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.group_id IS NULL)))));



