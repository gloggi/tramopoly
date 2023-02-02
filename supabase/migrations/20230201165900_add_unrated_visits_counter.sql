
create table "public"."unseen_chat_activity" (
                                                 "id" uuid not null default gen_random_uuid(),
                                                 "created_at" timestamp with time zone not null default now(),
                                                 "profile_id" uuid not null,
                                                 "group_id" bigint not null,
                                                 "unseen_activity_count" bigint not null default 0
);


alter table "public"."unseen_chat_activity" enable row level security;

CREATE UNIQUE INDEX unseen_chat_activity_pkey ON public.unseen_chat_activity USING btree (id);

CREATE UNIQUE INDEX unseen_chat_activity_profile_id_group_id_key ON public.unseen_chat_activity USING btree (profile_id, group_id);

alter table "public"."unseen_chat_activity" add constraint "unseen_chat_activity_pkey" PRIMARY KEY using index "unseen_chat_activity_pkey";

alter table "public"."unseen_chat_activity" add constraint "unseen_chat_activity_group_id_fkey" FOREIGN KEY (group_id) REFERENCES groups(id) ON DELETE CASCADE not valid;

alter table "public"."unseen_chat_activity" validate constraint "unseen_chat_activity_group_id_fkey";

alter table "public"."unseen_chat_activity" add constraint "unseen_chat_activity_profile_id_fkey" FOREIGN KEY (profile_id) REFERENCES profiles(id) ON DELETE CASCADE not valid;

alter table "public"."unseen_chat_activity" validate constraint "unseen_chat_activity_profile_id_fkey";

alter table "public"."unseen_chat_activity" add constraint "unseen_chat_activity_profile_id_group_id_key" UNIQUE using index "unseen_chat_activity_profile_id_group_id_key";

set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.increment_unseen_counter(chat_id bigint, increment bigint)
 RETURNS void
 LANGUAGE plpgsql
 SECURITY DEFINER
AS $function$
BEGIN

UPDATE unseen_chat_activity uca SET unseen_activity_count = uca.unseen_activity_count + increment WHERE uca.group_id=chat_id AND uca.profile_id!=auth.uid();

END
$function$
;

CREATE OR REPLACE FUNCTION public.unseen_activity_count()
 RETURNS TABLE(group_id bigint, unrated_station_visits bigint, unrated_joker_visits bigint, unseen_chat_activity bigint)
 LANGUAGE plpgsql
AS $function$
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
$function$
;


