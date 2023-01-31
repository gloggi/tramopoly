create table "public"."station_visits" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "group_id" bigint not null,
    "station_id" bigint not null,
    "proof_photo_path" text,
    "accepted_at" timestamp with time zone,
    "rejected_at" timestamp with time zone,
    "operator_comment" text,
    "needs_verification" boolean not null default true,
    "verified_at" timestamp with time zone
);


alter table "public"."station_visits" enable row level security;

CREATE UNIQUE INDEX station_visits_pkey ON public.station_visits USING btree (id);

alter table "public"."station_visits" add constraint "station_visits_pkey" PRIMARY KEY using index "station_visits_pkey";

alter table "public"."station_visits" add constraint "station_visits_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) not valid;

alter table "public"."station_visits" validate constraint "station_visits_group_id_fkey";

alter table "public"."station_visits" add constraint "station_visits_station_id_fkey" FOREIGN KEY (station_id) REFERENCES stations(id) not valid;

alter table "public"."station_visits" validate constraint "station_visits_station_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.visit_station(station_id bigint, proof_photo_path text, group_id bigint)
 RETURNS SETOF station_visits
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
      BEGIN
          RETURN QUERY
          INSERT INTO station_visits(station_id, group_id, proof_photo_path)
          VALUES(station_id, CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, proof_photo_path)
          RETURNING *;
      END;
  $function$
;

create policy "Enable reading own group's station visits"
on "public"."station_visits"
as permissive
for select
to authenticated
using ((group_id = ( SELECT u.group_id
   FROM profiles u
  WHERE (u.id = auth.uid()))));

