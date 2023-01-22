create or replace view "public"."chat_contents" as  SELECT messages.id,
    messages.created_at,
    messages.group_id
   FROM messages
UNION ALL
 SELECT sv.id,
    sv.created_at,
    sv.group_id
   FROM station_visits sv;

