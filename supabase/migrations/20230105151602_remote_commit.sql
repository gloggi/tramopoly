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


