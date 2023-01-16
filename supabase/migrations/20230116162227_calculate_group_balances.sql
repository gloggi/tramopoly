CREATE EXTENSION plv8;

set check_function_bodies = off;

create type "public"."group_balance_coeffs" as ("group_id" bigint, "t0" timestamp without time zone, "c0" double precision, "c1" double precision);

CREATE OR REPLACE FUNCTION public.calculate_balance_coeffs(t0 timestamp without time zone DEFAULT now())
 RETURNS SETOF group_balance_coeffs
 LANGUAGE plv8
AS $function$

const groups = plv8.execute('SELECT * FROM groups WHERE active=TRUE')
const settings = plv8.execute('SELECT * FROM settings LIMIT 1')[0]
// const jokerVisits = plv8.execute('SELECT * FROM joker_visits ...')
// Station visits are fetched in reverse order, so that we can more easily calculate the owner of each station
const stationVisits = plv8.execute('SELECT sv.*, stations.value AS value FROM station_visits sv INNER JOIN stations ON sv.station_id=stations.id WHERE sv.accepted_at IS NOT NULL AND sv.rejected_at IS NULL AND sv.needs_verification=FALSE AND sv.verified_at IS NOT NULL AND sv.created_at < $1 ORDER BY sv.created_at DESC', [t0])

const stationPurchases = stationVisits.reduce((purchases, visit) => {
   purchases[visit.station_id] = visit.id
   return purchases
}, {})

const stationVisitsById = stationVisits.reduce((visits, visit) => {
   visits[visit.id] = visit
   return visits
}, {})

function stationOwner(station_id) {
   return stationVisitsById[stationPurchases[station_id]].group_id
}

function interestRatePerSecond(buyingTime) {
   const lerpVal = (buyingTime - settings.game_start) / (settings.game_end - settings.game_start)
   const interpolated = settings.interest_rate_start + lerpVal * (settings.interest_rate_end - settings.interest_rate_start)
   return interpolated / settings.interest_period / 60
}

function sum(list) {
   return list.reduce((a, b) => a + b, 0)
}

groups.forEach(group => {
   const starterCash = settings.starter_cash

   const jokerIncome = 0 // TODO sum(...)

   const stationExpenses = sum(stationVisits
      .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
      .map(sv => sv.value)
   ) * -1

   const rentIncome = sum(stationVisits
      .filter(sv => stationOwner(sv.station_id) === group.id && sv.id !== stationPurchases[sv.station_id])
      .map(sv => sv.value)
   ) * settings.rent_ratio

   const rentExpenses = sum(stationVisits
      .filter(sv => stationOwner(sv.station_id) !== group.id && sv.id !== stationPurchases[sv.station_id] && sv.group_id === group.id)
      .map(sv => sv.value)
   ) * -1 * settings.rent_ratio

   const interest = [
      sum(stationVisits
         .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
         .map(sv => sv.value * interestRatePerSecond(sv.created_at) * Math.max(0, t0 - sv.created_at.valueOf()) / 1000)),
      sum(stationVisits
         .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
         .map(sv => sv.value * interestRatePerSecond(sv.created_at)))
   ]

   plv8.return_next({
      group_id: group.id,
      t0: t0,
      c0: starterCash + jokerIncome + rentIncome + stationExpenses + rentExpenses + interest[0],
      c1: interest[1]
   })
})

$function$
;

