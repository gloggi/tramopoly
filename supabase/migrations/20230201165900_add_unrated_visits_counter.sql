
CREATE OR REPLACE FUNCTION public.unrated_visits_count()
 RETURNS TABLE(group_id bigint, unrated_station_visits bigint, unrated_joker_visits bigint)
 LANGUAGE plpgsql
AS $function$
BEGIN
  RETURN QUERY
  SELECT
    g.id as group_id,
    COALESCE(station.unrated_station_visits, 0) AS unrated_station_visits,
    COALESCE(joker.unrated_joker_visits, 0) AS unrated_joker_visits
  FROM groups g
  LEFT JOIN (SELECT sv.group_id, COUNT(sv.id) AS unrated_station_visits FROM station_visits sv WHERE sv.accepted_at IS NULL AND sv.rejected_at IS NULL GROUP BY sv.group_id) station ON g.id=station.group_id
  LEFT JOIN (SELECT jv.group_id, COUNT(jv.id) AS unrated_joker_visits FROM joker_visits jv WHERE jv.accepted_at IS NULL AND jv.rejected_at IS NULL GROUP BY jv.group_id) joker ON g.id=joker.group_id;
END;
$function$
;


