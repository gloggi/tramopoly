--
-- PostgreSQL database dump
--

-- Dumped from database version 15.1 (Ubuntu 15.1-1.pgdg20.04+1)
-- Dumped by pg_dump version 15.1 (Debian 15.1-1.pgdg110+1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgsodium; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgsodium" WITH SCHEMA "pgsodium";


--
-- Name: plv8; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "plv8" WITH SCHEMA "pg_catalog";


--
-- Name: pg_graphql; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_graphql" WITH SCHEMA "graphql";


--
-- Name: pg_stat_statements; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pg_stat_statements" WITH SCHEMA "extensions";


--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgcrypto" WITH SCHEMA "extensions";


--
-- Name: pgjwt; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "pgjwt" WITH SCHEMA "extensions";


--
-- Name: supabase_vault; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "supabase_vault" WITH SCHEMA "vault";


--
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA "extensions";


--
-- Name: group_balance_coeffs; Type: TYPE; Schema: public; Owner: postgres
--

CREATE TYPE "public"."group_balance_coeffs" AS (
	"group_id" bigint,
	"real_estate_points" double precision,
	"mr_t_points" bigint,
	"invalid_after" timestamp with time zone,
	"t0" timestamp with time zone,
	"c0" double precision,
	"c1" double precision
);


ALTER TYPE "public"."group_balance_coeffs" OWNER TO "postgres";

SET default_tablespace = '';

SET default_table_access_method = "heap";

--
-- Name: station_visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."station_visits" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "group_id" bigint NOT NULL,
    "station_id" bigint NOT NULL,
    "proof_photo_path" "text",
    "accepted_at" timestamp with time zone,
    "rejected_at" timestamp with time zone,
    "operator_comment" "text",
    "needs_verification" boolean DEFAULT true NOT NULL,
    "verified_at" timestamp with time zone
);


ALTER TABLE "public"."station_visits" OWNER TO "postgres";

--
-- Name: accessible_to("public"."station_visits"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."accessible_to"("public"."station_visits") RETURNS bigint[]
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN ARRAY[$1.group_id] || (SELECT array_agg(our_visit.group_id)
                                  FROM station_visits our_visit
                                  WHERE (our_visit.station_id = $1.station_id)
                                    AND (our_visit.accepted_at IS NOT NULL)
                                    AND (our_visit.rejected_at IS NULL)
                                    AND (our_visit.needs_verification = false)
                                    AND (our_visit.verified_at IS NOT NULL)
                                  GROUP BY our_visit.station_id);
END
$_$;


ALTER FUNCTION "public"."accessible_to"("public"."station_visits") OWNER TO "postgres";

--
-- Name: calculate_balance_coeffs(timestamp with time zone); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."calculate_balance_coeffs"("t0" timestamp with time zone DEFAULT "now"()) RETURNS SETOF "public"."group_balance_coeffs"
    LANGUAGE "plv8"
    AS $_$

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

$_$;


ALTER FUNCTION "public"."calculate_balance_coeffs"("t0" timestamp with time zone) OWNER TO "postgres";

--
-- Name: create_profile_for_new_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."create_profile_for_new_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
INSERT INTO public.profiles (id, phone)
VALUES (new.id, new.phone);
RETURN new;
END;
$$;


ALTER FUNCTION "public"."create_profile_for_new_user"() OWNER TO "postgres";

--
-- Name: delete_profile_for_deleted_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."delete_profile_for_deleted_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
BEGIN
DELETE FROM public.profiles
WHERE id=old.id;
RETURN old;
END;
$$;


ALTER FUNCTION "public"."delete_profile_for_deleted_user"() OWNER TO "postgres";

--
-- Name: grant_joker_bonus("uuid", smallint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint) RETURNS "void"
    LANGUAGE "plv8"
    AS $_$

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

$_$;


ALTER FUNCTION "public"."grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint) OWNER TO "postgres";

--
-- Name: group_id_for("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."group_id_for"("user_id" "uuid") RETURNS bigint
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN(SELECT u.group_id FROM profiles u WHERE u.id=user_id LIMIT 1);
END
$$;


ALTER FUNCTION "public"."group_id_for"("user_id" "uuid") OWNER TO "postgres";

--
-- Name: increment_unseen_counter(bigint, bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."increment_unseen_counter"("chat_id" bigint, "increment" bigint) RETURNS "void"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN

    UPDATE unseen_chat_activity uca SET unseen_activity_count = uca.unseen_activity_count + increment WHERE uca.group_id=chat_id AND uca.profile_id!=auth.uid();

END
$$;


ALTER FUNCTION "public"."increment_unseen_counter"("chat_id" bigint, "increment" bigint) OWNER TO "postgres";

--
-- Name: joker_visits; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."joker_visits" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "group_id" bigint NOT NULL,
    "joker_id" bigint NOT NULL,
    "proof_photo_path" "text",
    "accepted_at" timestamp with time zone,
    "rejected_at" timestamp with time zone,
    "operator_comment" "text",
    "earned_bonus_value" smallint
);


ALTER TABLE "public"."joker_visits" OWNER TO "postgres";

--
-- Name: is_duplicate("public"."joker_visits"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."is_duplicate"("public"."joker_visits") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
    RETURN(SELECT EXISTS(SELECT 1 FROM joker_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.joker_id=$1.joker_id AND other_visit.group_id=$1.group_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL));
END
$_$;


ALTER FUNCTION "public"."is_duplicate"("public"."joker_visits") OWNER TO "postgres";

--
-- Name: is_duplicate("public"."station_visits"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."is_duplicate"("public"."station_visits") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
    RETURN(SELECT EXISTS(SELECT 1 FROM station_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.station_id=$1.station_id AND other_visit.group_id=$1.group_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL AND other_visit.needs_verification=FALSE AND other_visit.verified_at IS NOT NULL));
END
$_$;


ALTER FUNCTION "public"."is_duplicate"("public"."station_visits") OWNER TO "postgres";

--
-- Name: is_purchase("public"."station_visits"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."is_purchase"("public"."station_visits") RETURNS boolean
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $_$
BEGIN
    RETURN(SELECT $1.accepted_at IS NOT NULL AND $1.rejected_at IS NULL AND $1.needs_verification=FALSE AND $1.verified_at IS NOT NULL AND NOT EXISTS(SELECT 1 FROM station_visits other_visit WHERE other_visit.created_at<$1.created_at AND other_visit.station_id=$1.station_id AND other_visit.accepted_at IS NOT NULL AND other_visit.rejected_at IS NULL AND other_visit.needs_verification=FALSE AND other_visit.verified_at IS NOT NULL));
END
$_$;


ALTER FUNCTION "public"."is_purchase"("public"."station_visits") OWNER TO "postgres";

--
-- Name: mr_t_changes; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."mr_t_changes" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "group_id" bigint NOT NULL,
    "vehicle" "text",
    "direction" "text",
    "last_known_location" "text",
    "description" "text",
    "should_call_operator" boolean DEFAULT false NOT NULL,
    "deactivated" boolean DEFAULT false NOT NULL
);


ALTER TABLE "public"."mr_t_changes" OWNER TO "postgres";

--
-- Name: last_change_at("public"."mr_t_changes"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."last_change_at"("public"."mr_t_changes") RETURNS timestamp with time zone
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN(SELECT MIN(change.created_at) FROM mr_t_changes change WHERE change.group_id=$1.group_id AND NOT EXISTS(
        SELECT 1 FROM mr_t_changes other_change WHERE other_change.group_id<>change.group_id AND other_change.created_at > change.created_at AND other_change.created_at <= $1.created_at
    ) GROUP BY (change.group_id, change.deactivated) LIMIT 1);
END
$_$;


ALTER FUNCTION "public"."last_change_at"("public"."mr_t_changes") OWNER TO "postgres";

--
-- Name: last_report_at("public"."mr_t_changes"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."last_report_at"("public"."mr_t_changes") RETURNS timestamp with time zone
    LANGUAGE "plpgsql"
    AS $_$
BEGIN
    RETURN(SELECT change.created_at FROM mr_t_changes change WHERE change.group_id=$1.group_id AND change.created_at <= $1.created_at AND change.deactivated=false AND change.should_call_operator=false AND NOT EXISTS (
        SELECT 1 FROM mr_t_changes other_change WHERE other_change.group_id<>change.group_id AND other_change.created_at > change.created_at AND other_change.created_at <= $1.created_at
    ) ORDER BY change.created_at DESC LIMIT 1);
END
$_$;


ALTER FUNCTION "public"."last_report_at"("public"."mr_t_changes") OWNER TO "postgres";

--
-- Name: on_register(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."on_register"() RETURNS "trigger"
    LANGUAGE "plpgsql"
    SET "search_path" TO 'public'
    AS $$
BEGIN
    IF auth.uid() IS NOT NULL AND new.group_id IS NOT NULL THEN
        INSERT INTO unseen_chat_activity (profile_id, group_id, unseen_activity_count) VALUES (auth.uid(), new.group_id, 1) ON CONFLICT ON CONSTRAINT unseen_chat_activity_profile_id_group_id_key DO NOTHING;
    END IF;
    RETURN new;
END;
$$;


ALTER FUNCTION "public"."on_register"() OWNER TO "postgres";

--
-- Name: operator_id_for("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."operator_id_for"("user_id" "uuid") RETURNS "uuid"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
RETURN(SELECT a.operator_id FROM profiles u INNER JOIN groups g ON u.group_id=g.id INNER JOIN abteilungen a ON g.abteilung_id=a.id WHERE u.id=user_id LIMIT 1);
END
$$;


ALTER FUNCTION "public"."operator_id_for"("user_id" "uuid") OWNER TO "postgres";

--
-- Name: messages; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."messages" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "sender_id" "uuid" NOT NULL,
    "content" "text" NOT NULL,
    "reply_message_id" "uuid",
    "group_id" bigint NOT NULL,
    "reactions" "jsonb" DEFAULT '{}'::"jsonb" NOT NULL
);


ALTER TABLE "public"."messages" OWNER TO "postgres";

--
-- Name: post_message("text", "text"[], "uuid", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint) RETURNS SETOF "public"."messages"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
DECLARE
message_id uuid;
file_path text;
BEGIN
INSERT INTO messages(sender_id, group_id, content, reply_message_id)
VALUES(auth.uid(), CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, content, reply_message_id)
  RETURNING id into message_id;

FOREACH file_path IN ARRAY file_paths
  LOOP
    INSERT INTO message_files(message_id, file_path)
    VALUES(message_id, file_path);
END LOOP;

  PERFORM increment_unseen_counter(group_id, 1);

RETURN QUERY
SELECT *
FROM messages
WHERE id = message_id;
END;
$$;


ALTER FUNCTION "public"."post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint) OWNER TO "postgres";

--
-- Name: post_message_reaction("uuid", "text", "text"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text") RETURNS "void"
    LANGUAGE "plv8" SECURITY DEFINER
    AS $_$

const { user_id, group_id, role, message_group_id, reactions } = plv8.execute('SELECT auth.uid() AS user_id, group_id_for(auth.uid()) AS group_id, role_for(auth.uid()) AS role, m.group_id AS message_group_id, m.reactions as reactions FROM messages m WHERE id=$1 LIMIT 1', [message_id])[0]

if (group_id !== message_group_id && role !== 'operator' && role !== 'admin') return

if (mode === 'remove') {
  reactions[reaction] = (reactions[reaction] || []).filter(u => u !== user_id)
} else {
  reactions[reaction] = (reactions[reaction] || []).concat([user_id])
}

plv8.execute('UPDATE messages SET reactions=$1 WHERE id=$2', [reactions, message_id])

plv8.execute('SELECT increment_unseen_counter($1, 1)', [message_group_id])
$_$;


ALTER FUNCTION "public"."post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text") OWNER TO "postgres";

--
-- Name: rate_joker_visit("uuid", character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying) RETURNS "void"
    LANGUAGE "plv8"
    AS $_$

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

$_$;


ALTER FUNCTION "public"."rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying) OWNER TO "postgres";

--
-- Name: rate_station_visit("uuid", character varying); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."rate_station_visit"("station_visit_id" "uuid", "rating" character varying) RETURNS "void"
    LANGUAGE "plv8"
    AS $_$

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

$_$;


ALTER FUNCTION "public"."rate_station_visit"("station_visit_id" "uuid", "rating" character varying) OWNER TO "postgres";

--
-- Name: reverify_all(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."reverify_all"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
    UPDATE station_visits SET needs_verification=TRUE WHERE 1=1;
    PERFORM verify_all();
    return new;
end;
$$;


ALTER FUNCTION "public"."reverify_all"() OWNER TO "postgres";

--
-- Name: role_for("uuid"); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."role_for"("user_id" "uuid") RETURNS "text"
    LANGUAGE "plpgsql"
    AS $$
BEGIN
RETURN(SELECT u.role FROM profiles u WHERE u.id=user_id LIMIT 1);
END
$$;


ALTER FUNCTION "public"."role_for"("user_id" "uuid") OWNER TO "postgres";

--
-- Name: unseen_activity_count(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."unseen_activity_count"() RETURNS TABLE("group_id" bigint, "unrated_station_visits" bigint, "unrated_joker_visits" bigint, "unseen_chat_activity" bigint)
    LANGUAGE "plpgsql"
    AS $$
BEGIN
    RETURN QUERY
        SELECT
            g.id as group_id,
            COALESCE(station.unrated_station_visits, 0) AS unrated_station_visits,
            COALESCE(joker.unrated_joker_visits, 0) AS unrated_joker_visits,
            COALESCE(unseen.unseen_activity_count, 0) AS unseen_chat_activity
        FROM groups g
                 LEFT JOIN (SELECT sv.group_id, COUNT(sv.id) AS unrated_station_visits FROM station_visits sv WHERE sv.accepted_at IS NULL AND sv.rejected_at IS NULL GROUP BY sv.group_id) station ON g.id=station.group_id
                 LEFT JOIN (SELECT jv.group_id, COUNT(jv.id) AS unrated_joker_visits FROM joker_visits jv WHERE jv.accepted_at IS NULL AND jv.rejected_at IS NULL GROUP BY jv.group_id) joker ON g.id=joker.group_id
                 LEFT JOIN (SELECT uca.group_id, uca.unseen_activity_count AS unseen_activity_count FROM unseen_chat_activity uca) unseen ON g.id=unseen.group_id;
END;
$$;


ALTER FUNCTION "public"."unseen_activity_count"() OWNER TO "postgres";

--
-- Name: update_profile_phone_from_user(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."update_profile_phone_from_user"() RETURNS "trigger"
    LANGUAGE "plpgsql" SECURITY DEFINER
    SET "search_path" TO 'public'
    AS $$
begin
update public.profiles
set phone=new.phone
where profiles.id=new.id;
return new;
end;
$$;


ALTER FUNCTION "public"."update_profile_phone_from_user"() OWNER TO "postgres";

--
-- Name: verify_all(); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."verify_all"() RETURNS "void"
    LANGUAGE "plv8"
    AS $_$

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

$_$;


ALTER FUNCTION "public"."verify_all"() OWNER TO "postgres";

--
-- Name: visit_joker(bigint, "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint) RETURNS SETOF "public"."joker_visits"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
    PERFORM increment_unseen_counter(CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, 1);

    RETURN QUERY
        INSERT INTO joker_visits(joker_id, group_id, proof_photo_path)
            VALUES(joker_id, CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, proof_photo_path)
            RETURNING *;
END;
$$;


ALTER FUNCTION "public"."visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint) OWNER TO "postgres";

--
-- Name: visit_station(bigint, "text", bigint); Type: FUNCTION; Schema: public; Owner: postgres
--

CREATE FUNCTION "public"."visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint) RETURNS SETOF "public"."station_visits"
    LANGUAGE "plpgsql" SECURITY DEFINER
    AS $$
BEGIN
          PERFORM increment_unseen_counter(CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, 1);

RETURN QUERY
    INSERT INTO station_visits(station_id, group_id, proof_photo_path)
          VALUES(station_id, CASE WHEN role_for(auth.uid())='player' THEN (SELECT u.group_id FROM profiles u WHERE u.id=auth.uid() LIMIT 1) ELSE group_id END, proof_photo_path)
          RETURNING *;
END;
  $$;


ALTER FUNCTION "public"."visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint) OWNER TO "postgres";

--
-- Name: abteilungen; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."abteilungen" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" character varying NOT NULL,
    "active" boolean DEFAULT true NOT NULL,
    "logo_url" "text",
    "operator_id" "uuid"
);


ALTER TABLE "public"."abteilungen" OWNER TO "postgres";

--
-- Name: abteilungen_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."abteilungen" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."abteilungen_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: chat_contents; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."chat_contents" AS
 SELECT "messages"."id",
    "messages"."created_at",
    "messages"."group_id",
    ARRAY["messages"."group_id"] AS "accessible_to",
    'message'::"text" AS "type"
   FROM "public"."messages"
UNION ALL
 SELECT "sv"."id",
    "sv"."created_at",
    "sv"."group_id",
    "public"."accessible_to"("sv".*) AS "accessible_to",
    'stationVisit'::"text" AS "type"
   FROM "public"."station_visits" "sv"
UNION ALL
 SELECT "jv"."id",
    "jv"."created_at",
    "jv"."group_id",
    ARRAY["jv"."group_id"] AS "accessible_to",
    'jokerVisit'::"text" AS "type"
   FROM "public"."joker_visits" "jv";


ALTER TABLE "public"."chat_contents" OWNER TO "postgres";

--
-- Name: groups; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."groups" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" character varying NOT NULL,
    "active" boolean DEFAULT true NOT NULL,
    "abteilung_id" bigint NOT NULL
);


ALTER TABLE "public"."groups" OWNER TO "postgres";

--
-- Name: groups_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."groups" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."groups_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: jokers; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."jokers" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" "text" NOT NULL,
    "value" smallint NOT NULL,
    "challenge" "text",
    "bonus_call_value" smallint
);


ALTER TABLE "public"."jokers" OWNER TO "postgres";

--
-- Name: jokers_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."jokers" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."jokers_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: message_files; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."message_files" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "file_path" "text" NOT NULL,
    "message_id" "uuid" NOT NULL
);


ALTER TABLE "public"."message_files" OWNER TO "postgres";

--
-- Name: message_files_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_files" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."message_files_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mr_t_locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."mr_t_locations" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" "text" NOT NULL
);


ALTER TABLE "public"."mr_t_locations" OWNER TO "postgres";

--
-- Name: mr_t_locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."mr_t_locations" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."mr_t_locations_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: mr_t_rewards; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."mr_t_rewards" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "duration" smallint NOT NULL,
    "value" smallint NOT NULL
);


ALTER TABLE "public"."mr_t_rewards" OWNER TO "postgres";

--
-- Name: mr_t_rewards_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."mr_t_rewards" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."mr_t_rewards_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: profiles; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."profiles" (
    "id" "uuid" NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "scout_name" "text",
    "group_id" bigint,
    "phone" "text",
    "preferred_call_method" "text",
    "role" "text" DEFAULT 'player'::"text" NOT NULL,
    "active_caller_id" "uuid"
);


ALTER TABLE "public"."profiles" OWNER TO "postgres";

--
-- Name: operator_callers; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."operator_callers" AS
 SELECT "profiles"."id",
    "profiles"."active_caller_id"
   FROM "public"."profiles"
  WHERE ((("profiles"."id" = "public"."operator_id_for"("auth"."uid"())) AND (("profiles"."active_caller_id" IS NULL) OR ("profiles"."active_caller_id" = "auth"."uid"()))) OR ("profiles"."id" = "auth"."uid"()));


ALTER TABLE "public"."operator_callers" OWNER TO "postgres";

--
-- Name: registerable_profiles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."registerable_profiles" AS
 SELECT 1 AS "row_num",
    "profiles"."scout_name",
    "profiles"."preferred_call_method",
    "profiles"."group_id"
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."group_id" IS NULL));


ALTER TABLE "public"."registerable_profiles" OWNER TO "postgres";

--
-- Name: settings; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."settings" (
    "id" bigint NOT NULL,
    "game_start" timestamp with time zone DEFAULT "now"() NOT NULL,
    "game_end" timestamp with time zone DEFAULT ("now"() + '10:00:00'::interval) NOT NULL,
    "interest_period" smallint DEFAULT '15'::smallint NOT NULL,
    "interest_rate_start" double precision DEFAULT '0.1'::double precision NOT NULL,
    "interest_rate_end" double precision DEFAULT '0.1'::double precision NOT NULL,
    "message_title" "text",
    "message_text" "text",
    "message_type" "text",
    "real_estate_value_ratio" double precision DEFAULT '0.5'::double precision NOT NULL,
    "rent_ratio" double precision DEFAULT '0.2'::double precision NOT NULL,
    "starter_cash" smallint DEFAULT '5000'::smallint NOT NULL,
    "full_real_estate_periods" double precision DEFAULT '5'::double precision NOT NULL,
    "map_url" "text"
);


ALTER TABLE "public"."settings" OWNER TO "postgres";

--
-- Name: settings_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."settings" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."settings_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: stations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."stations" (
    "id" bigint NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"(),
    "name" "text" NOT NULL,
    "value" smallint NOT NULL
);


ALTER TABLE "public"."stations" OWNER TO "postgres";

--
-- Name: stations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

ALTER TABLE "public"."stations" ALTER COLUMN "id" ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME "public"."stations_id_seq"
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- Name: unseen_chat_activity; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE "public"."unseen_chat_activity" (
    "id" "uuid" DEFAULT "gen_random_uuid"() NOT NULL,
    "created_at" timestamp with time zone DEFAULT "now"() NOT NULL,
    "profile_id" "uuid" NOT NULL,
    "group_id" bigint NOT NULL,
    "unseen_activity_count" bigint DEFAULT 0 NOT NULL
);


ALTER TABLE "public"."unseen_chat_activity" OWNER TO "postgres";

--
-- Name: updateable_profiles; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."updateable_profiles" AS
 SELECT "profiles"."id",
    "profiles"."scout_name",
    "profiles"."preferred_call_method",
    "profiles"."active_caller_id"
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."group_id" IS NOT NULL));


ALTER TABLE "public"."updateable_profiles" OWNER TO "postgres";

--
-- Name: visited_stations; Type: VIEW; Schema: public; Owner: postgres
--

CREATE VIEW "public"."visited_stations" AS
 SELECT "sv"."id",
    "sv"."created_at",
    "sv"."group_id",
    "sv"."station_id",
    "sv"."proof_photo_path",
    "sv"."accepted_at",
    "sv"."rejected_at",
    "sv"."needs_verification",
    "sv"."verified_at"
   FROM "public"."station_visits" "sv"
  WHERE ("sv"."group_id" = ( SELECT "profiles"."group_id"
           FROM "public"."profiles"
          WHERE ("profiles"."id" = "auth"."uid"())));


ALTER TABLE "public"."visited_stations" OWNER TO "postgres";

--
-- Name: abteilungen abteilungen_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."abteilungen"
    ADD CONSTRAINT "abteilungen_pkey" PRIMARY KEY ("id");


--
-- Name: groups groups_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_pkey" PRIMARY KEY ("id");


--
-- Name: joker_visits joker_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."joker_visits"
    ADD CONSTRAINT "joker_visits_pkey" PRIMARY KEY ("id");


--
-- Name: jokers jokers_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."jokers"
    ADD CONSTRAINT "jokers_pkey" PRIMARY KEY ("id");


--
-- Name: message_files message_files_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_files"
    ADD CONSTRAINT "message_files_pkey" PRIMARY KEY ("id");


--
-- Name: messages messages_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_pkey" PRIMARY KEY ("id");


--
-- Name: mr_t_changes mr_t_changes_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."mr_t_changes"
    ADD CONSTRAINT "mr_t_changes_pkey" PRIMARY KEY ("id");


--
-- Name: mr_t_locations mr_t_locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."mr_t_locations"
    ADD CONSTRAINT "mr_t_locations_pkey" PRIMARY KEY ("id");


--
-- Name: mr_t_rewards mr_t_rewards_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."mr_t_rewards"
    ADD CONSTRAINT "mr_t_rewards_pkey" PRIMARY KEY ("id");


--
-- Name: profiles profiles_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_pkey" PRIMARY KEY ("id");


--
-- Name: settings settings_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."settings"
    ADD CONSTRAINT "settings_pkey" PRIMARY KEY ("id");


--
-- Name: station_visits station_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."station_visits"
    ADD CONSTRAINT "station_visits_pkey" PRIMARY KEY ("id");


--
-- Name: stations stations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."stations"
    ADD CONSTRAINT "stations_pkey" PRIMARY KEY ("id");


--
-- Name: unseen_chat_activity unseen_chat_activity_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."unseen_chat_activity"
    ADD CONSTRAINT "unseen_chat_activity_pkey" PRIMARY KEY ("id");


--
-- Name: unseen_chat_activity unseen_chat_activity_profile_id_group_id_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."unseen_chat_activity"
    ADD CONSTRAINT "unseen_chat_activity_profile_id_group_id_key" UNIQUE ("profile_id", "group_id");


--
-- Name: profiles on_register; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "on_register" AFTER UPDATE ON "public"."profiles" FOR EACH ROW EXECUTE FUNCTION "public"."on_register"();


--
-- Name: settings on_settings_updated; Type: TRIGGER; Schema: public; Owner: postgres
--

CREATE TRIGGER "on_settings_updated" AFTER UPDATE ON "public"."settings" FOR EACH ROW EXECUTE FUNCTION "public"."reverify_all"();


--
-- Name: abteilungen abteilungen_operator_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."abteilungen"
    ADD CONSTRAINT "abteilungen_operator_id_fkey" FOREIGN KEY ("operator_id") REFERENCES "public"."profiles"("id");


--
-- Name: groups groups_abteilung_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."groups"
    ADD CONSTRAINT "groups_abteilung_id_fkey" FOREIGN KEY ("abteilung_id") REFERENCES "public"."abteilungen"("id");


--
-- Name: joker_visits joker_visits_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."joker_visits"
    ADD CONSTRAINT "joker_visits_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");


--
-- Name: joker_visits joker_visits_joker_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."joker_visits"
    ADD CONSTRAINT "joker_visits_joker_id_fkey" FOREIGN KEY ("joker_id") REFERENCES "public"."jokers"("id");


--
-- Name: message_files message_files_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."message_files"
    ADD CONSTRAINT "message_files_message_id_fkey" FOREIGN KEY ("message_id") REFERENCES "public"."messages"("id");


--
-- Name: messages messages_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");


--
-- Name: messages messages_reply_message_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_reply_message_id_fkey" FOREIGN KEY ("reply_message_id") REFERENCES "public"."messages"("id");


--
-- Name: messages messages_sender_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."messages"
    ADD CONSTRAINT "messages_sender_id_fkey" FOREIGN KEY ("sender_id") REFERENCES "public"."profiles"("id");


--
-- Name: mr_t_changes mr_t_changes_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."mr_t_changes"
    ADD CONSTRAINT "mr_t_changes_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");


--
-- Name: profiles profiles_active_caller_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_active_caller_id_fkey" FOREIGN KEY ("active_caller_id") REFERENCES "public"."profiles"("id");


--
-- Name: profiles profiles_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");


--
-- Name: profiles profiles_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."profiles"
    ADD CONSTRAINT "profiles_id_fkey" FOREIGN KEY ("id") REFERENCES "auth"."users"("id");


--
-- Name: station_visits station_visits_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."station_visits"
    ADD CONSTRAINT "station_visits_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id");


--
-- Name: station_visits station_visits_station_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."station_visits"
    ADD CONSTRAINT "station_visits_station_id_fkey" FOREIGN KEY ("station_id") REFERENCES "public"."stations"("id");


--
-- Name: unseen_chat_activity unseen_chat_activity_group_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."unseen_chat_activity"
    ADD CONSTRAINT "unseen_chat_activity_group_id_fkey" FOREIGN KEY ("group_id") REFERENCES "public"."groups"("id") ON DELETE CASCADE;


--
-- Name: unseen_chat_activity unseen_chat_activity_profile_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY "public"."unseen_chat_activity"
    ADD CONSTRAINT "unseen_chat_activity_profile_id_fkey" FOREIGN KEY ("profile_id") REFERENCES "public"."profiles"("id") ON DELETE CASCADE;


--
-- Name: abteilungen Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."abteilungen" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: groups Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."groups" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: joker_visits Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."joker_visits" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: jokers Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."jokers" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: message_files Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."message_files" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: messages Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."messages" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: mr_t_changes Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."mr_t_changes" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: mr_t_locations Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."mr_t_locations" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: mr_t_rewards Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."mr_t_rewards" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: profiles Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."profiles" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: settings Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."settings" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: station_visits Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."station_visits" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: stations Enable full access for admins; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for admins" ON "public"."stations" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'admin'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'admin'::"text"));


--
-- Name: joker_visits Enable full access for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for operators" ON "public"."joker_visits" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'operator'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: station_visits Enable full access for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access for operators" ON "public"."station_visits" TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'operator'::"text")) WITH CHECK (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: unseen_chat_activity Enable full access to own unseen activity; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable full access to own unseen activity" ON "public"."unseen_chat_activity" TO "authenticated" USING (("profile_id" = "auth"."uid"())) WITH CHECK (("profile_id" = "auth"."uid"()));


--
-- Name: groups Enable inserting for authenticated users which have no group; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable inserting for authenticated users which have no group" ON "public"."groups" FOR INSERT TO "authenticated" WITH CHECK ((EXISTS ( SELECT 1
   FROM "public"."profiles"
  WHERE (("profiles"."id" = "auth"."uid"()) AND ("profiles"."group_id" IS NULL)))));


--
-- Name: mr_t_changes Enable inserting for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable inserting for operators" ON "public"."mr_t_changes" FOR INSERT TO "authenticated" WITH CHECK (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: abteilungen Enable read access for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable read access for authenticated users only" ON "public"."abteilungen" FOR SELECT TO "authenticated" USING (true);


--
-- Name: station_visits Enable reading everywhere the group has been; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading everywhere the group has been" ON "public"."station_visits" FOR SELECT TO "authenticated" USING ((("group_id" = ( SELECT "u"."group_id"
   FROM "public"."profiles" "u"
  WHERE ("u"."id" = "auth"."uid"()))) OR (EXISTS ( SELECT 1
   FROM ("public"."visited_stations" "our_visit"
     JOIN "public"."profiles" "u" ON (("u"."group_id" = "our_visit"."group_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("our_visit"."station_id" = "station_visits"."station_id") AND ("our_visit"."accepted_at" IS NOT NULL) AND ("our_visit"."rejected_at" IS NULL) AND ("our_visit"."needs_verification" = false) AND ("our_visit"."verified_at" IS NOT NULL))))));


--
-- Name: mr_t_changes Enable reading for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users" ON "public"."mr_t_changes" FOR SELECT TO "authenticated" USING (true);


--
-- Name: mr_t_rewards Enable reading for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users" ON "public"."mr_t_rewards" FOR SELECT TO "authenticated" USING (true);


--
-- Name: settings Enable reading for authenticated users; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users" ON "public"."settings" FOR SELECT TO "authenticated" USING (true);


--
-- Name: groups Enable reading for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users only" ON "public"."groups" FOR SELECT TO "authenticated" USING (true);


--
-- Name: jokers Enable reading for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users only" ON "public"."jokers" FOR SELECT TO "authenticated" USING (true);


--
-- Name: stations Enable reading for authenticated users only; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for authenticated users only" ON "public"."stations" FOR SELECT TO "authenticated" USING (true);


--
-- Name: message_files Enable reading for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for operators" ON "public"."message_files" FOR SELECT TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: messages Enable reading for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for operators" ON "public"."messages" FOR SELECT TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: mr_t_locations Enable reading for operators; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading for operators" ON "public"."mr_t_locations" FOR SELECT TO "authenticated" USING (("public"."role_for"("auth"."uid"()) = 'operator'::"text"));


--
-- Name: joker_visits Enable reading own group's joker visits; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own group's joker visits" ON "public"."joker_visits" FOR SELECT TO "authenticated" USING (("group_id" = ( SELECT "u"."group_id"
   FROM "public"."profiles" "u"
  WHERE ("u"."id" = "auth"."uid"()))));


--
-- Name: profiles Enable reading own group's members; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own group's members" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("group_id" = "public"."group_id_for"("auth"."uid"())));


--
-- Name: message_files Enable reading own group's message files; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own group's message files" ON "public"."message_files" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM (("public"."profiles" "u"
     LEFT JOIN "public"."profiles" "o" ON (("u"."group_id" = "o"."group_id")))
     LEFT JOIN "public"."messages" "m" ON (("m"."sender_id" = "o"."id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("m"."id" = "message_files"."message_id")))));


--
-- Name: messages Enable reading own group's messages; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own group's messages" ON "public"."messages" FOR SELECT TO "authenticated" USING ((EXISTS ( SELECT 1
   FROM ("public"."profiles" "u"
     LEFT JOIN "public"."profiles" "o" ON (("u"."group_id" = "o"."group_id")))
  WHERE (("u"."id" = "auth"."uid"()) AND ("o"."id" = "messages"."sender_id")))));


--
-- Name: profiles Enable reading own operator's profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own operator's profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("public"."operator_id_for"("auth"."uid"()) = "id"));


--
-- Name: profiles Enable reading own profile; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Enable reading own profile" ON "public"."profiles" FOR SELECT TO "authenticated" USING (("auth"."uid"() = "id"));


--
-- Name: profiles Temporarily enable reading all profiles; Type: POLICY; Schema: public; Owner: postgres
--

CREATE POLICY "Temporarily enable reading all profiles" ON "public"."profiles" FOR SELECT TO "authenticated" USING (true);


--
-- Name: abteilungen; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."abteilungen" ENABLE ROW LEVEL SECURITY;

--
-- Name: groups; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."groups" ENABLE ROW LEVEL SECURITY;

--
-- Name: joker_visits; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."joker_visits" ENABLE ROW LEVEL SECURITY;

--
-- Name: jokers; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."jokers" ENABLE ROW LEVEL SECURITY;

--
-- Name: message_files; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."message_files" ENABLE ROW LEVEL SECURITY;

--
-- Name: messages; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."messages" ENABLE ROW LEVEL SECURITY;

--
-- Name: mr_t_changes; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."mr_t_changes" ENABLE ROW LEVEL SECURITY;

--
-- Name: mr_t_locations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."mr_t_locations" ENABLE ROW LEVEL SECURITY;

--
-- Name: mr_t_rewards; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."mr_t_rewards" ENABLE ROW LEVEL SECURITY;

--
-- Name: profiles; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."profiles" ENABLE ROW LEVEL SECURITY;

--
-- Name: settings; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."settings" ENABLE ROW LEVEL SECURITY;

--
-- Name: station_visits; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."station_visits" ENABLE ROW LEVEL SECURITY;

--
-- Name: stations; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."stations" ENABLE ROW LEVEL SECURITY;

--
-- Name: unseen_chat_activity; Type: ROW SECURITY; Schema: public; Owner: postgres
--

ALTER TABLE "public"."unseen_chat_activity" ENABLE ROW LEVEL SECURITY;

--
-- Name: SCHEMA "public"; Type: ACL; Schema: -; Owner: pg_database_owner
--

GRANT USAGE ON SCHEMA "public" TO "postgres";
GRANT USAGE ON SCHEMA "public" TO "anon";
GRANT USAGE ON SCHEMA "public" TO "authenticated";
GRANT USAGE ON SCHEMA "public" TO "service_role";


--
-- Name: FUNCTION "algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
--

-- --REVOKE ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") FROM "postgres";
-- --GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- --GRANT ALL ON FUNCTION "extensions"."algorithm_sign"("signables" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "armor"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."armor"("bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "armor"("bytea", "text"[], "text"[]); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."armor"("bytea", "text"[], "text"[]) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "crypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."crypt"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."crypt"("text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "dearmor"("text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."dearmor"("text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."dearmor"("text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."decrypt"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "decrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."decrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "digest"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."digest"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."digest"("bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "digest"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."digest"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."digest"("text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "encrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."encrypt"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "encrypt_iv"("bytea", "bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."encrypt_iv"("bytea", "bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "gen_random_bytes"(integer); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_random_bytes"(integer) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "gen_random_uuid"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."gen_random_uuid"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_random_uuid"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "gen_salt"("text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "gen_salt"("text", integer); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."gen_salt"("text", integer) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."gen_salt"("text", integer) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "hmac"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."hmac"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "hmac"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."hmac"("text", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements"("showtext" boolean, OUT "userid" "oid", OUT "dbid" "oid", OUT "toplevel" boolean, OUT "queryid" bigint, OUT "query" "text", OUT "plans" bigint, OUT "total_plan_time" double precision, OUT "min_plan_time" double precision, OUT "max_plan_time" double precision, OUT "mean_plan_time" double precision, OUT "stddev_plan_time" double precision, OUT "calls" bigint, OUT "total_exec_time" double precision, OUT "min_exec_time" double precision, OUT "max_exec_time" double precision, OUT "mean_exec_time" double precision, OUT "stddev_exec_time" double precision, OUT "rows" bigint, OUT "shared_blks_hit" bigint, OUT "shared_blks_read" bigint, OUT "shared_blks_dirtied" bigint, OUT "shared_blks_written" bigint, OUT "local_blks_hit" bigint, OUT "local_blks_read" bigint, OUT "local_blks_dirtied" bigint, OUT "local_blks_written" bigint, OUT "temp_blks_read" bigint, OUT "temp_blks_written" bigint, OUT "blk_read_time" double precision, OUT "blk_write_time" double precision, OUT "temp_blk_read_time" double precision, OUT "temp_blk_write_time" double precision, OUT "wal_records" bigint, OUT "wal_fpi" bigint, OUT "wal_bytes" numeric, OUT "jit_functions" bigint, OUT "jit_generation_time" double precision, OUT "jit_inlining_count" bigint, OUT "jit_inlining_time" double precision, OUT "jit_optimization_count" bigint, OUT "jit_optimization_time" double precision, OUT "jit_emission_count" bigint, OUT "jit_emission_time" double precision) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_info"(OUT "dealloc" bigint, OUT "stats_reset" timestamp with time zone) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pg_stat_statements_reset"("userid" "oid", "dbid" "oid", "queryid" bigint) TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_armor_headers"("text", OUT "key" "text", OUT "value" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_key_id"("bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_key_id"("bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt"("bytea", "bytea", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_decrypt_bytea"("bytea", "bytea", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_encrypt"("text", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt"("text", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_pub_encrypt_bytea"("bytea", "bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_pub_encrypt_bytea"("bytea", "bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_decrypt"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt"("bytea", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_decrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_decrypt_bytea"("bytea", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_encrypt"("text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_encrypt"("text", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt"("text", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "pgp_sym_encrypt_bytea"("bytea", "text", "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."pgp_sym_encrypt_bytea"("bytea", "text", "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "sign"("payload" "json", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."sign"("payload" "json", "secret" "text", "algorithm" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "try_cast_double"("inp" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."try_cast_double"("inp" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "url_decode"("data" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."url_decode"("data" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."url_decode"("data" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "url_encode"("data" "bytea"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."url_encode"("data" "bytea") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_generate_v1"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_generate_v1mc"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v1mc"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_generate_v3"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v3"("namespace" "uuid", "name" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_generate_v4"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v4"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v4"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_generate_v5"("namespace" "uuid", "name" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_generate_v5"("namespace" "uuid", "name" "text") TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_nil"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_nil"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_nil"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_ns_dns"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_dns"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_dns"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_ns_oid"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_oid"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_oid"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_ns_url"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_url"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_url"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "uuid_ns_x500"(); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."uuid_ns_x500"() FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."uuid_ns_x500"() TO "dashboard_user";
--
--
-- --
-- -- Name: FUNCTION "verify"("token" "text", "secret" "text", "algorithm" "text"); Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") FROM "postgres";
-- GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON FUNCTION "extensions"."verify"("token" "text", "secret" "text", "algorithm" "text") TO "dashboard_user";


--
-- Name: FUNCTION "comment_directive"("comment_" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."comment_directive"("comment_" "text") TO "service_role";


--
-- Name: FUNCTION "exception"("message" "text"); Type: ACL; Schema: graphql; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "anon";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql"."exception"("message" "text") TO "service_role";


--
-- Name: FUNCTION "graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb"); Type: ACL; Schema: graphql_public; Owner: supabase_admin
--

-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "postgres";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "anon";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "authenticated";
-- GRANT ALL ON FUNCTION "graphql_public"."graphql"("operationName" "text", "query" "text", "variables" "jsonb", "extensions" "jsonb") TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_decrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea"); Type: ACL; Schema: pgsodium; Owner: pgsodium_keymaker
--

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_encrypt"("message" "bytea", "additional" "bytea", "key_uuid" "uuid", "nonce" "bytea") TO "service_role";


--
-- Name: FUNCTION "crypto_aead_det_keygen"(); Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON FUNCTION "pgsodium"."crypto_aead_det_keygen"() TO "service_role";


--
-- Name: TABLE "station_visits"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."station_visits" TO "anon";
GRANT ALL ON TABLE "public"."station_visits" TO "authenticated";
GRANT ALL ON TABLE "public"."station_visits" TO "service_role";


--
-- Name: FUNCTION "accessible_to"("public"."station_visits"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."accessible_to"("public"."station_visits") TO "anon";
GRANT ALL ON FUNCTION "public"."accessible_to"("public"."station_visits") TO "authenticated";
GRANT ALL ON FUNCTION "public"."accessible_to"("public"."station_visits") TO "service_role";


--
-- Name: FUNCTION "calculate_balance_coeffs"("t0" timestamp with time zone); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."calculate_balance_coeffs"("t0" timestamp with time zone) TO "anon";
GRANT ALL ON FUNCTION "public"."calculate_balance_coeffs"("t0" timestamp with time zone) TO "authenticated";
GRANT ALL ON FUNCTION "public"."calculate_balance_coeffs"("t0" timestamp with time zone) TO "service_role";


--
-- Name: FUNCTION "create_profile_for_new_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."create_profile_for_new_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."create_profile_for_new_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."create_profile_for_new_user"() TO "service_role";


--
-- Name: FUNCTION "delete_profile_for_deleted_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."delete_profile_for_deleted_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."delete_profile_for_deleted_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."delete_profile_for_deleted_user"() TO "service_role";


--
-- Name: FUNCTION "grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint) TO "anon";
GRANT ALL ON FUNCTION "public"."grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."grant_joker_bonus"("joker_visit_id" "uuid", "earned_bonus_value" smallint) TO "service_role";


--
-- Name: FUNCTION "group_id_for"("user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."group_id_for"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."group_id_for"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."group_id_for"("user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "increment_unseen_counter"("chat_id" bigint, "increment" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."increment_unseen_counter"("chat_id" bigint, "increment" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."increment_unseen_counter"("chat_id" bigint, "increment" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."increment_unseen_counter"("chat_id" bigint, "increment" bigint) TO "service_role";


--
-- Name: TABLE "joker_visits"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."joker_visits" TO "anon";
GRANT ALL ON TABLE "public"."joker_visits" TO "authenticated";
GRANT ALL ON TABLE "public"."joker_visits" TO "service_role";


--
-- Name: FUNCTION "is_duplicate"("public"."joker_visits"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."joker_visits") TO "anon";
GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."joker_visits") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."joker_visits") TO "service_role";


--
-- Name: FUNCTION "is_duplicate"("public"."station_visits"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."station_visits") TO "anon";
GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."station_visits") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_duplicate"("public"."station_visits") TO "service_role";


--
-- Name: FUNCTION "is_purchase"("public"."station_visits"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."is_purchase"("public"."station_visits") TO "anon";
GRANT ALL ON FUNCTION "public"."is_purchase"("public"."station_visits") TO "authenticated";
GRANT ALL ON FUNCTION "public"."is_purchase"("public"."station_visits") TO "service_role";


--
-- Name: TABLE "mr_t_changes"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."mr_t_changes" TO "anon";
GRANT ALL ON TABLE "public"."mr_t_changes" TO "authenticated";
GRANT ALL ON TABLE "public"."mr_t_changes" TO "service_role";


--
-- Name: FUNCTION "last_change_at"("public"."mr_t_changes"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."last_change_at"("public"."mr_t_changes") TO "anon";
GRANT ALL ON FUNCTION "public"."last_change_at"("public"."mr_t_changes") TO "authenticated";
GRANT ALL ON FUNCTION "public"."last_change_at"("public"."mr_t_changes") TO "service_role";


--
-- Name: FUNCTION "last_report_at"("public"."mr_t_changes"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."last_report_at"("public"."mr_t_changes") TO "anon";
GRANT ALL ON FUNCTION "public"."last_report_at"("public"."mr_t_changes") TO "authenticated";
GRANT ALL ON FUNCTION "public"."last_report_at"("public"."mr_t_changes") TO "service_role";


--
-- Name: FUNCTION "on_register"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."on_register"() TO "anon";
GRANT ALL ON FUNCTION "public"."on_register"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."on_register"() TO "service_role";


--
-- Name: FUNCTION "operator_id_for"("user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."operator_id_for"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."operator_id_for"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."operator_id_for"("user_id" "uuid") TO "service_role";


--
-- Name: TABLE "messages"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."messages" TO "anon";
GRANT ALL ON TABLE "public"."messages" TO "authenticated";
GRANT ALL ON TABLE "public"."messages" TO "service_role";


--
-- Name: FUNCTION "post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."post_message"("content" "text", "file_paths" "text"[], "reply_message_id" "uuid", "group_id" bigint) TO "service_role";


--
-- Name: FUNCTION "post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text") TO "anon";
GRANT ALL ON FUNCTION "public"."post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text") TO "authenticated";
GRANT ALL ON FUNCTION "public"."post_message_reaction"("message_id" "uuid", "reaction" "text", "mode" "text") TO "service_role";


--
-- Name: FUNCTION "rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."rate_joker_visit"("joker_visit_id" "uuid", "rating" character varying) TO "service_role";


--
-- Name: FUNCTION "rate_station_visit"("station_visit_id" "uuid", "rating" character varying); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."rate_station_visit"("station_visit_id" "uuid", "rating" character varying) TO "anon";
GRANT ALL ON FUNCTION "public"."rate_station_visit"("station_visit_id" "uuid", "rating" character varying) TO "authenticated";
GRANT ALL ON FUNCTION "public"."rate_station_visit"("station_visit_id" "uuid", "rating" character varying) TO "service_role";


--
-- Name: FUNCTION "reverify_all"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."reverify_all"() TO "anon";
GRANT ALL ON FUNCTION "public"."reverify_all"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."reverify_all"() TO "service_role";


--
-- Name: FUNCTION "role_for"("user_id" "uuid"); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."role_for"("user_id" "uuid") TO "anon";
GRANT ALL ON FUNCTION "public"."role_for"("user_id" "uuid") TO "authenticated";
GRANT ALL ON FUNCTION "public"."role_for"("user_id" "uuid") TO "service_role";


--
-- Name: FUNCTION "unseen_activity_count"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."unseen_activity_count"() TO "anon";
GRANT ALL ON FUNCTION "public"."unseen_activity_count"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."unseen_activity_count"() TO "service_role";


--
-- Name: FUNCTION "update_profile_phone_from_user"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."update_profile_phone_from_user"() TO "anon";
GRANT ALL ON FUNCTION "public"."update_profile_phone_from_user"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."update_profile_phone_from_user"() TO "service_role";


--
-- Name: FUNCTION "verify_all"(); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."verify_all"() TO "anon";
GRANT ALL ON FUNCTION "public"."verify_all"() TO "authenticated";
GRANT ALL ON FUNCTION "public"."verify_all"() TO "service_role";


--
-- Name: FUNCTION "visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."visit_joker"("joker_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "service_role";


--
-- Name: FUNCTION "visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint); Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON FUNCTION "public"."visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "anon";
GRANT ALL ON FUNCTION "public"."visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "authenticated";
GRANT ALL ON FUNCTION "public"."visit_station"("station_id" bigint, "proof_photo_path" "text", "group_id" bigint) TO "service_role";


--
-- Name: TABLE "pg_stat_statements"; Type: ACL; Schema: extensions; Owner: postgres
--

-- REVOKE ALL ON TABLE "extensions"."pg_stat_statements" FROM "postgres";
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements" TO "dashboard_user";
--
--
-- --
-- -- Name: TABLE "pg_stat_statements_info"; Type: ACL; Schema: extensions; Owner: postgres
-- --
--
-- REVOKE ALL ON TABLE "extensions"."pg_stat_statements_info" FROM "postgres";
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "postgres" WITH GRANT OPTION;
-- GRANT ALL ON TABLE "extensions"."pg_stat_statements_info" TO "dashboard_user";


--
-- Name: TABLE "decrypted_key"; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE "pgsodium"."decrypted_key" TO "pgsodium_keyholder";


--
-- Name: TABLE "masking_rule"; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE "pgsodium"."masking_rule" TO "pgsodium_keyholder";


--
-- Name: TABLE "mask_columns"; Type: ACL; Schema: pgsodium; Owner: supabase_admin
--

GRANT ALL ON TABLE "pgsodium"."mask_columns" TO "pgsodium_keyholder";


--
-- Name: TABLE "abteilungen"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."abteilungen" TO "anon";
GRANT ALL ON TABLE "public"."abteilungen" TO "authenticated";
GRANT ALL ON TABLE "public"."abteilungen" TO "service_role";


--
-- Name: SEQUENCE "abteilungen_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."abteilungen_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."abteilungen_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."abteilungen_id_seq" TO "service_role";


--
-- Name: TABLE "chat_contents"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."chat_contents" TO "anon";
GRANT ALL ON TABLE "public"."chat_contents" TO "authenticated";
GRANT ALL ON TABLE "public"."chat_contents" TO "service_role";


--
-- Name: TABLE "groups"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."groups" TO "anon";
GRANT ALL ON TABLE "public"."groups" TO "authenticated";
GRANT ALL ON TABLE "public"."groups" TO "service_role";


--
-- Name: SEQUENCE "groups_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."groups_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."groups_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."groups_id_seq" TO "service_role";


--
-- Name: TABLE "jokers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."jokers" TO "anon";
GRANT ALL ON TABLE "public"."jokers" TO "authenticated";
GRANT ALL ON TABLE "public"."jokers" TO "service_role";


--
-- Name: SEQUENCE "jokers_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."jokers_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."jokers_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."jokers_id_seq" TO "service_role";


--
-- Name: TABLE "message_files"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."message_files" TO "anon";
GRANT ALL ON TABLE "public"."message_files" TO "authenticated";
GRANT ALL ON TABLE "public"."message_files" TO "service_role";


--
-- Name: SEQUENCE "message_files_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."message_files_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."message_files_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."message_files_id_seq" TO "service_role";


--
-- Name: TABLE "mr_t_locations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."mr_t_locations" TO "anon";
GRANT ALL ON TABLE "public"."mr_t_locations" TO "authenticated";
GRANT ALL ON TABLE "public"."mr_t_locations" TO "service_role";


--
-- Name: SEQUENCE "mr_t_locations_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."mr_t_locations_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."mr_t_locations_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."mr_t_locations_id_seq" TO "service_role";


--
-- Name: TABLE "mr_t_rewards"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."mr_t_rewards" TO "anon";
GRANT ALL ON TABLE "public"."mr_t_rewards" TO "authenticated";
GRANT ALL ON TABLE "public"."mr_t_rewards" TO "service_role";


--
-- Name: SEQUENCE "mr_t_rewards_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."mr_t_rewards_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."mr_t_rewards_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."mr_t_rewards_id_seq" TO "service_role";


--
-- Name: TABLE "profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."profiles" TO "anon";
GRANT ALL ON TABLE "public"."profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."profiles" TO "service_role";


--
-- Name: TABLE "operator_callers"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."operator_callers" TO "anon";
GRANT ALL ON TABLE "public"."operator_callers" TO "authenticated";
GRANT ALL ON TABLE "public"."operator_callers" TO "service_role";


--
-- Name: TABLE "registerable_profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."registerable_profiles" TO "anon";
GRANT ALL ON TABLE "public"."registerable_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."registerable_profiles" TO "service_role";


--
-- Name: TABLE "settings"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."settings" TO "anon";
GRANT ALL ON TABLE "public"."settings" TO "authenticated";
GRANT ALL ON TABLE "public"."settings" TO "service_role";


--
-- Name: SEQUENCE "settings_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."settings_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."settings_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."settings_id_seq" TO "service_role";


--
-- Name: TABLE "stations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."stations" TO "anon";
GRANT ALL ON TABLE "public"."stations" TO "authenticated";
GRANT ALL ON TABLE "public"."stations" TO "service_role";


--
-- Name: SEQUENCE "stations_id_seq"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON SEQUENCE "public"."stations_id_seq" TO "anon";
GRANT ALL ON SEQUENCE "public"."stations_id_seq" TO "authenticated";
GRANT ALL ON SEQUENCE "public"."stations_id_seq" TO "service_role";


--
-- Name: TABLE "unseen_chat_activity"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."unseen_chat_activity" TO "anon";
GRANT ALL ON TABLE "public"."unseen_chat_activity" TO "authenticated";
GRANT ALL ON TABLE "public"."unseen_chat_activity" TO "service_role";


--
-- Name: TABLE "updateable_profiles"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."updateable_profiles" TO "anon";
GRANT ALL ON TABLE "public"."updateable_profiles" TO "authenticated";
GRANT ALL ON TABLE "public"."updateable_profiles" TO "service_role";


--
-- Name: TABLE "visited_stations"; Type: ACL; Schema: public; Owner: postgres
--

GRANT ALL ON TABLE "public"."visited_stations" TO "anon";
GRANT ALL ON TABLE "public"."visited_stations" TO "authenticated";
GRANT ALL ON TABLE "public"."visited_stations" TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR SEQUENCES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON SEQUENCES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR FUNCTIONS; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON FUNCTIONS  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: postgres
--

ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
ALTER DEFAULT PRIVILEGES FOR ROLE "postgres" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- Name: DEFAULT PRIVILEGES FOR TABLES; Type: DEFAULT ACL; Schema: public; Owner: supabase_admin
--

-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "postgres";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "anon";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "authenticated";
-- ALTER DEFAULT PRIVILEGES FOR ROLE "supabase_admin" IN SCHEMA "public" GRANT ALL ON TABLES  TO "service_role";


--
-- PostgreSQL database dump complete
--

RESET ALL;
