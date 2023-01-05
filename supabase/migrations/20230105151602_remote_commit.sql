create table "public"."abteilungen" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "name" character varying not null,
    "active" boolean not null default true,
    "logo_url" text
);


alter table "public"."abteilungen" enable row level security;

create table "public"."groups" (
    "id" bigint generated by default as identity not null,
    "created_at" timestamp with time zone default now(),
    "name" character varying not null,
    "active" boolean not null default true,
    "abteilung_id" bigint not null
);


alter table "public"."groups" enable row level security;

CREATE UNIQUE INDEX abteilungen_pkey ON public.abteilungen USING btree (id);

CREATE UNIQUE INDEX groups_pkey ON public.groups USING btree (id);

alter table "public"."abteilungen" add constraint "abteilungen_pkey" PRIMARY KEY using index "abteilungen_pkey";

alter table "public"."groups" add constraint "groups_pkey" PRIMARY KEY using index "groups_pkey";

alter table "public"."groups" add constraint "groups_abteilung_id_fkey" FOREIGN KEY (abteilung_id) REFERENCES abteilungen(id) not valid;

alter table "public"."groups" validate constraint "groups_abteilung_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.install_available_extensions_and_test()
 RETURNS boolean
 LANGUAGE plpgsql
AS $function$
DECLARE extension_name TEXT;
allowed_extentions TEXT[] := string_to_array(current_setting('supautils.privileged_extensions'), ',');
BEGIN 
  FOREACH extension_name IN ARRAY allowed_extentions 
  LOOP
    SELECT trim(extension_name) INTO extension_name;
    /* skip below extensions check for now */
    CONTINUE WHEN extension_name = 'pgroonga' OR  extension_name = 'pgroonga_database' OR extension_name = 'pgsodium';
    CONTINUE WHEN extension_name = 'plpgsql' OR  extension_name = 'plpgsql_check' OR extension_name = 'pgtap';
    CONTINUE WHEN extension_name = 'supabase_vault' OR extension_name = 'wrappers';
    RAISE notice 'START TEST FOR: %', extension_name;
    EXECUTE format('DROP EXTENSION IF EXISTS %s CASCADE', quote_ident(extension_name));
    EXECUTE format('CREATE EXTENSION %s CASCADE', quote_ident(extension_name));
    RAISE notice 'END TEST FOR: %', extension_name;
  END LOOP;
    RAISE notice 'EXTENSION TESTS COMPLETED..';
    return true;
END;
$function$
;

create policy "Enable read access for authenticated users only"
on "public"."abteilungen"
as permissive
for select
to authenticated
using (true);


create policy "Enable inserting for authenticated users which have no group"
on "public"."groups"
as permissive
for insert
to authenticated
with check ((((auth.jwt() -> 'user_metadata'::text) ->> 'group_id'::text) IS NULL));


create policy "Enable reading for authenticated users only"
on "public"."groups"
as permissive
for select
to authenticated
using (true);



set check_function_bodies = off;

CREATE OR REPLACE FUNCTION storage.extension(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
_filename text;
BEGIN
    select string_to_array(name, '/') into _parts;
    select _parts[array_length(_parts,1)] into _filename;
    -- @todo return the last part instead of 2
    return split_part(_filename, '.', 2);
END
$function$
;

CREATE OR REPLACE FUNCTION storage.filename(name text)
 RETURNS text
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[array_length(_parts,1)];
END
$function$
;

CREATE OR REPLACE FUNCTION storage.foldername(name text)
 RETURNS text[]
 LANGUAGE plpgsql
AS $function$
DECLARE
_parts text[];
BEGIN
    select string_to_array(name, '/') into _parts;
    return _parts[1:array_length(_parts,1)-1];
END
$function$
;

