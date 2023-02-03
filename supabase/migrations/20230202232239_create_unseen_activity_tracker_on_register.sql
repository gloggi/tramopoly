
CREATE OR REPLACE FUNCTION public.on_register()
 RETURNS trigger
 LANGUAGE plpgsql
 SECURITY INVOKER
 SET search_path TO 'public'
AS $function$
BEGIN
  IF auth.uid() IS NOT NULL AND new.group_id IS NOT NULL THEN
    INSERT INTO unseen_chat_activity (profile_id, group_id, unseen_activity_count) VALUES (auth.uid(), new.group_id, 1) ON CONFLICT ON CONSTRAINT unseen_chat_activity_profile_id_group_id_key DO NOTHING;
  END IF;
  RETURN new;
END;
$function$
;

CREATE TRIGGER on_register AFTER UPDATE ON profiles FOR EACH ROW EXECUTE FUNCTION on_register();
