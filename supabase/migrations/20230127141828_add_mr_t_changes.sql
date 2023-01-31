
create table "public"."mr_t_changes" (
    "id" uuid not null default gen_random_uuid(),
    "created_at" timestamp with time zone not null default now(),
    "group_id" bigint not null,
    "vehicle" text,
    "direction" text,
    "last_known_location" text,
    "description" text,
    "should_call_operator" boolean not null default false,
    "deactivated" boolean not null default false
);


alter table "public"."mr_t_changes" enable row level security;

CREATE UNIQUE INDEX mr_t_changes_pkey ON public.mr_t_changes USING btree (id);

alter table "public"."mr_t_changes" add constraint "mr_t_changes_pkey" PRIMARY KEY using index "mr_t_changes_pkey";

alter table "public"."mr_t_changes" add constraint "mr_t_changes_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) not valid;

alter table "public"."mr_t_changes" validate constraint "mr_t_changes_group_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.last_change_at(mr_t_changes)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN(SELECT MIN(change.created_at) FROM mr_t_changes change WHERE change.group_id=$1.group_id AND NOT EXISTS(
    SELECT 1 FROM mr_t_changes other_change WHERE other_change.group_id<>change.group_id AND other_change.created_at > change.created_at AND other_change.created_at <= $1.created_at
  ) GROUP BY (change.group_id, change.deactivated) LIMIT 1);
END
$function$
;

CREATE OR REPLACE FUNCTION public.last_report_at(mr_t_changes)
 RETURNS timestamp with time zone
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN(SELECT change.created_at FROM mr_t_changes change WHERE change.group_id=$1.group_id AND change.created_at <= $1.created_at AND change.deactivated=false AND change.should_call_operator=false AND NOT EXISTS (
    SELECT 1 FROM mr_t_changes other_change WHERE other_change.group_id<>change.group_id AND other_change.created_at > change.created_at AND other_change.created_at <= $1.created_at
) ORDER BY change.created_at DESC LIMIT 1);
END
$function$
;

create policy "Enable full access for admins"
on "public"."mr_t_changes"
as permissive
for all
to authenticated
using ((role_for(auth.uid()) = 'admin'::text))
with check ((role_for(auth.uid()) = 'admin'::text));


create policy "Enable reading for authenticated users"
on "public"."mr_t_changes"
as permissive
for select
to authenticated
using (true);

