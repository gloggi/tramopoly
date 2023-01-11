alter table "public"."profiles" add column "active_caller_id" uuid;

alter table "public"."profiles" add constraint "profiles_active_caller_id_fkey" FOREIGN KEY (active_caller_id) REFERENCES profiles(id) not valid;

alter table "public"."profiles" validate constraint "profiles_active_caller_id_fkey";

create or replace view "public"."operator_callers" as  SELECT profiles.id,
    profiles.active_caller_id
   FROM profiles
  WHERE ((profiles.id = operator_id_for(auth.uid())) AND ((profiles.active_caller_id IS NULL) OR (profiles.active_caller_id = auth.uid())));
