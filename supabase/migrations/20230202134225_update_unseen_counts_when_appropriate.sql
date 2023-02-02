
set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.reverify_all()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY DEFINER
 SET search_path TO 'public'
AS $function$
begin
  UPDATE station_visits SET needs_verification=TRUE WHERE 1=1;
  PERFORM verify_all();
  return new;
end;
$function$
;

create policy "Enable full access to own unseen activity"
on "public"."unseen_chat_activity"
as permissive
for all
to authenticated
using ((profile_id = auth.uid()))
with check ((profile_id = auth.uid()));


CREATE TRIGGER on_settings_updated AFTER UPDATE ON public.settings FOR EACH ROW EXECUTE FUNCTION reverify_all();


