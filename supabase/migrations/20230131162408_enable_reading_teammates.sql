
CREATE OR REPLACE FUNCTION public.group_id_for(user_id uuid)
 RETURNS bigint
 LANGUAGE plpgsql
AS $function$
BEGIN
   RETURN(SELECT u.group_id FROM profiles u WHERE u.id=user_id LIMIT 1);
END
$function$
;

create policy "Enable reading own group's members"
on "public"."profiles"
as permissive
for select
to authenticated
using ((group_id = group_id_for(auth.uid())));

