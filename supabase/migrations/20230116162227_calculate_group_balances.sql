CREATE EXTENSION plv8;

set check_function_bodies = off;

create type "public"."group_balance_coeffs" as (
    "group_id" bigint,
    "real_estate_points" double precision,
    "mr_t_points" bigint,
    "invalid_after" timestamp with time zone,
    "t0" timestamp with time zone,
    "c0" double precision,
    "c1" double precision
);

CREATE OR REPLACE FUNCTION public.calculate_balance_coeffs(t0 timestamp with time zone DEFAULT now())
 RETURNS SETOF group_balance_coeffs
 LANGUAGE plv8
AS $function$

const groups = plv8.execute('SELECT * FROM groups WHERE active=TRUE')
const settings = plv8.execute('SELECT * FROM settings LIMIT 1')[0]
const jokerVisits = plv8.execute('SELECT jv.*, jokers.value FROM joker_visits jv INNER JOIN jokers ON jv.joker_id=jokers.id WHERE jv.accepted_at IS NOT NULL AND jv.rejected_at IS NULL AND jv.created_at < $1 ORDER BY jv.created_at', [new Date(clamp(t0))])
// Station visits are fetched in reverse order, so that we can more easily calculate the owner of each station
const stationVisits = plv8.execute('SELECT sv.*, stations.value AS value FROM station_visits sv INNER JOIN stations ON sv.station_id=stations.id WHERE sv.accepted_at IS NOT NULL AND sv.rejected_at IS NULL AND sv.needs_verification=FALSE AND sv.verified_at IS NOT NULL AND sv.created_at < $1 ORDER BY sv.created_at DESC', [new Date(clamp(t0))])
const mrTChanges = plv8.execute('SELECT mrt.* FROM mr_t_changes mrt WHERE mrt.created_at < $1 ORDER BY mrt.created_at', [new Date(clamp(t0))])
// Mr. T rewards are fetched in reverse order, so that we can more easily calculate the score of each Mr. T switch
const mrTRewards = plv8.execute('SELECT reward.*, reward.duration * 60 * 1000 as duration FROM mr_t_rewards reward ORDER BY reward.value DESC')

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

/**
 * Calculates the interest rate for a purchase at a given time in the game.
 * In case we have set different interest rates for game start and end, this linearly
 * interpolates between the two values. This is a mechanism we can use to encourage
 * purchases towards the end of the game, when they would otherwise earn the owner
 * comparatively less.
 */
function interestRatePerSecond(buyingTime) {
   const lerpVal = (clamp(buyingTime) - settings.game_start) / (settings.game_end - settings.game_start)
   const interpolated = settings.interest_rate_start + lerpVal * (settings.interest_rate_end - settings.interest_rate_start)
   return interpolated / settings.interest_period / 60
}

/**
 * Calculates the real estate value ratio for a purchase at a given time in the game.
 * Depending on the interest rate (e.g. 10% per 15mins), with a fixed real estate value
 * ratio (e.g. 50%), it is not beneficial at the end of the game (e.g. in the last
 * 50% / 10% * 15mins = 75mins) to buy stations, because stations cost more than they
 * reward the buyer with. During this time (the last 75mins), we can set the real estate
 * value ratio to 100% (i.e. purchases will be "free" except for not having the cash handy)
 * in order to encourage purchases at the end of the game.
 */
function realEstateValueRatio(buyingTime) {
   const start = settings.game_start.valueOf()
   const end = settings.game_end.valueOf()
   const turningPoint = Math.min(Math.max(start, end - (settings.full_real_estate_periods * settings.interest_period * 60 * 1000)), end)
   return (clamp(buyingTime) >= turningPoint) ? 1. : settings.real_estate_value_ratio
}

const { mrTSwitches, invalidAfter } = (() => {
   if (!mrTChanges.length) return { mrTSwitches: [], invalidAfter: null }
   function rewardFor(duration, change) {
      if (change.deactivated) return 0
      return mrTRewards.find(reward => {
         return reward.duration < duration
      })?.value || 0
   }
   const switches = mrTChanges.reduce((switches, change) => {
      if (!switches.length) switches.push(change)
      else if (switches[switches.length - 1].group_id !== change.group_id || switches[switches.length - 1].disabled !== change.disabled) {
         const previousDuration = change.created_at - switches[switches.length - 1].created_at
         switches[switches.length - 1].reward = rewardFor(previousDuration, switches[switches.length - 1])
         switches.push(change)
      }
      return switches
   }, [])
   const lastDuration = clamp(t0) - switches[switches.length - 1].created_at
   switches[switches.length - 1].reward = rewardFor(lastDuration, switches[switches.length - 1])

   let invalidAfter = null
   const nextUnmetReward = mrTRewards.slice().reverse().find(reward => reward.duration > lastDuration)
   if (nextUnmetReward && lastDuration > 0) {
      invalidAfter = new Date(switches[switches.length - 1].created_at.valueOf() + (nextUnmetReward.duration))
      if (invalidAfter > settings.game_end) invalidAfter = null
   }
   // Theoretically, there could be more mr_t_changes after t0 which could affect the validity period of the
   // current scoring. However, this shouldn't be a problem in practice, because t0 will always be ~NOW(), and
   // there shouldn't be any mr_t_changes in the future.
   return { mrTSwitches: switches, invalidAfter }
})()

function clamp(timestamp) {
   return Math.min(Math.max(settings.game_start, timestamp), settings.game_end)
}

function sum(list) {
   return list.reduce((a, b) => a + b, 0)
}

groups.forEach(group => {
   const starterCash = settings.starter_cash

   const jokerIncome = sum(jokerVisits
      .filter(jv => jv.group_id === group.id)
      .map(jv => jv.value + jv.earned_bonus_value))

   const stationExpenses = sum(stationVisits
      .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
      .map(sv => sv.value)
   ) * -1

   const realEstatePoints = sum(stationVisits
     .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
     .map(sv => sv.value * realEstateValueRatio(sv.created_at))
   )

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
         .map(sv => sv.value * interestRatePerSecond(clamp(sv.created_at)) * Math.max(0, clamp(t0) - clamp(sv.created_at)) / 1000)),
      sum(stationVisits
         .filter(sv => sv.group_id === group.id && sv.id === stationPurchases[sv.station_id])
         .map(sv => sv.value * interestRatePerSecond(clamp(sv.created_at))))
   ]

   const mrTPoints = sum(mrTSwitches
      .filter(mrt => mrt.group_id === group.id)
      .map(mrt => mrt.reward)
   )

   plv8.return_next({
      group_id: group.id,
      real_estate_points: realEstatePoints,
      mr_t_points: mrTPoints,
      invalid_after: invalidAfter,
      t0: new Date(clamp(t0)),
      c0: starterCash + jokerIncome + rentIncome + stationExpenses + rentExpenses + interest[0],
      c1: interest[1]
   })
})

$function$
;

