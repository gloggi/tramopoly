set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_duplicate(joker_visits)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN(SELECT EXISTS(SELECT 1 FROM joker_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.joker_id=$1.joker_id AND other_visit.group_id=$1.group_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL));
END
$function$
;

CREATE OR REPLACE FUNCTION public.is_duplicate(station_visits)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN(SELECT EXISTS(SELECT 1 FROM station_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.station_id=$1.station_id AND other_visit.group_id=$1.group_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL AND other_visit.needs_verification=FALSE AND other_visit.verified_at IS NOT NULL));
END
$function$
;

