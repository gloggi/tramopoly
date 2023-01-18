drop policy "Enable reading own group's station visits" on "public"."station_visits";

create or replace view "public"."visited_stations" as  SELECT sv.id,
    sv.created_at,
    sv.group_id,
    sv.station_id,
    sv.proof_photo_path,
    sv.accepted_at,
    sv.rejected_at,
    sv.needs_verification,
    sv.verified_at
   FROM station_visits sv
  WHERE (sv.group_id = ( SELECT profiles.group_id
           FROM profiles
          WHERE (profiles.id = auth.uid())));


create policy "Enable reading everywhere the group has been"
on "public"."station_visits"
as permissive
for select
to authenticated
using (((group_id = ( SELECT u.group_id
   FROM profiles u
  WHERE (u.id = auth.uid()))) OR (EXISTS ( SELECT 1
   FROM (visited_stations our_visit
     JOIN profiles u ON ((u.group_id = our_visit.group_id)))
  WHERE ((u.id = auth.uid()) AND (our_visit.station_id = station_visits.station_id) AND (our_visit.accepted_at IS NOT NULL) AND (our_visit.rejected_at IS NULL) AND (our_visit.needs_verification = false) AND (our_visit.verified_at IS NOT NULL))))));


