alter table "public"."abteilungen" add column "operator_id" uuid;

alter table "public"."abteilungen" add constraint "abteilungen_operator_id_fkey" FOREIGN KEY (operator_id) REFERENCES profiles(id) not valid;

alter table "public"."abteilungen" validate constraint "abteilungen_operator_id_fkey";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.operator_id_for(user_id uuid)
 RETURNS uuid
 LANGUAGE plpgsql
AS $function$
BEGIN
   RETURN(SELECT a.operator_id FROM profiles u INNER JOIN groups g ON u.group_id=g.id INNER JOIN abteilungen a ON g.abteilung_id=a.id WHERE u.id=user_id LIMIT 1);
END
$function$
;

create policy "Enable reading own operator's profile"
on "public"."profiles"
as permissive
for select
to authenticated
using ((operator_id_for(auth.uid()) = id));
