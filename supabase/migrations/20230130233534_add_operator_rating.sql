set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.is_purchase(station_visits)
 RETURNS boolean
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN
  RETURN(SELECT $1.accepted_at IS NOT NULL AND $1.rejected_at IS NULL AND $1.needs_verification=FALSE AND $1.verified_at IS NOT NULL AND NOT EXISTS(SELECT 1 FROM station_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.station_id=$1.station_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL AND other_visit.needs_verification=FALSE AND other_visit.verified_at IS NOT NULL));
END
$function$
;

CREATE OR REPLACE FUNCTION public.rate_station_visit(station_visit_id uuid, rating character varying)
 RETURNS void
 LANGUAGE plv8
AS $function$

const { role } = plv8.execute('SELECT role_for(auth.uid()) AS role LIMIT 1')[0]
if (role !== 'operator' && role !== 'admin') return

plv8.execute('UPDATE station_visits SET accepted_at=$1, rejected_at=$2 WHERE id=$3', [
  rating === 'accepted' ? new Date() : null,
  rating === 'rejected' ? new Date() : null,
  station_visit_id,
])

// Force re-verification of all station visits after the edited one, because balances might have changed now
plv8.execute('UPDATE station_visits SET needs_verification=TRUE WHERE created_at >= (SELECT created_at FROM station_visits WHERE id=$1)', [station_visit_id])
plv8.execute('SELECT verify_all()')

$function$
;

CREATE OR REPLACE FUNCTION public.rate_joker_visit(joker_visit_id uuid, rating character varying)
 RETURNS void
 LANGUAGE plv8
AS $function$

const { role } = plv8.execute('SELECT role_for(auth.uid()) AS role LIMIT 1')[0]
if (role !== 'operator' && role !== 'admin') return

plv8.execute('UPDATE joker_visits SET accepted_at=$1, rejected_at=$2 WHERE id=$3', [
  rating === 'accepted' ? new Date() : null,
  rating === 'rejected' ? new Date() : null,
  joker_visit_id,
])

// Report the changed joker visit, which is not automatically reported by verify_all
plv8.execute('SELECT increment_unseen_counter((SELECT group_id FROM joker_visits WHERE id=$1), 1)', [joker_visit_id])

// Force re-verification of all station visits after the edited joker visit, because balances might have changed now
plv8.execute('UPDATE station_visits SET needs_verification=TRUE WHERE created_at >= (SELECT created_at FROM joker_visits WHERE id=$1)', [joker_visit_id])
plv8.execute('SELECT verify_all()')

$function$
;

CREATE OR REPLACE FUNCTION public.grant_joker_bonus(joker_visit_id uuid, earned_bonus_value smallint)
    RETURNS void
    LANGUAGE plv8
AS $function$

const { role } = plv8.execute('SELECT role_for(auth.uid()) AS role LIMIT 1')[0]
if (role !== 'operator' && role !== 'admin') return

plv8.execute('UPDATE joker_visits SET earned_bonus_value=$1 WHERE id=$2', [
  earned_bonus_value,
  joker_visit_id,
])

// Report the changed joker visit, which is not automatically reported by verify_all
plv8.execute('SELECT increment_unseen_counter((SELECT group_id FROM joker_visits WHERE id=$1), 1)', [joker_visit_id])

// Force re-verification of all station visits after the edited joker visit, because balances might have changed now
plv8.execute('UPDATE station_visits SET needs_verification=TRUE WHERE created_at >= (SELECT created_at FROM joker_visits WHERE id=$1)', [joker_visit_id])
plv8.execute('SELECT verify_all()')

$function$
;

CREATE OR REPLACE FUNCTION public.verify_all()
 RETURNS void
 LANGUAGE plv8
AS $function$

const stationVisits = plv8.execute('SELECT sv.*, stations.value AS value, is_purchase(sv) AS is_purchase FROM station_visits sv INNER JOIN stations ON sv.station_id=stations.id WHERE (sv.accepted_at IS NOT NULL OR sv.rejected_at IS NOT NULL) AND sv.needs_verification=TRUE ORDER BY sv.created_at ASC')

stationVisits.forEach(stationVisit => {
   const balanceCoeffs = plv8.execute('SELECT * FROM calculate_balance_coeffs($1)', [stationVisit.created_at])
   const groupCoeffs = balanceCoeffs.find(({ group_id }) => group_id === stationVisit.group_id)
   const isValid = groupCoeffs && groupCoeffs.c0 >= stationVisit.value
   plv8.execute('UPDATE station_visits SET needs_verification=FALSE, verified_at=$1 WHERE id=$2', [
      isValid ? new Date() : null,
      stationVisit.id,
   ])
})
const numChangedPerGroup = plv8.execute('SELECT sv.group_id AS group_id, COUNT(sv.id) AS num_changed FROM station_visits sv WHERE (id=ANY($1) AND sv.verified_at IS NULL) OR (id=ANY($2) AND sv.verified_at IS NOT NULL) OR (id=ANY($3) AND is_purchase(sv)=FALSE) OR (id=ANY($4) AND is_purchase(sv)=TRUE) GROUP BY sv.group_id', [
  stationVisits.filter(sv => sv.verified_at !== null).map(sv => sv.id),
  stationVisits.filter(sv => sv.verified_at === null).map(sv => sv.id),
  stationVisits.filter(sv => sv.is_purchase === true).map(sv => sv.id),
  stationVisits.filter(sv => sv.is_purchase === false).map(sv => sv.id),
])
numChangedPerGroup.forEach(({ group_id, num_changed }) => {
  plv8.execute('SELECT increment_unseen_counter($1, $2)', [group_id, num_changed])
})

$function$
;
