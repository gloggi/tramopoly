
create policy "Enable full access for operators"
on "public"."joker_visits"
as permissive
for all
to authenticated
using ((role_for(auth.uid()) = 'operator'::text))
with check ((role_for(auth.uid()) = 'operator'::text));


create policy "Enable reading for operators"
on "public"."message_files"
as permissive
for select
to authenticated
using ((role_for(auth.uid()) = 'operator'::text));


create policy "Enable reading for operators"
on "public"."messages"
as permissive
for select
to authenticated
using ((role_for(auth.uid()) = 'operator'::text));


create policy "Enable inserting for operators"
on "public"."mr_t_changes"
as permissive
for insert
to authenticated
with check ((role_for(auth.uid()) = 'operator'::text));


create policy "Enable full access for operators"
on "public"."station_visits"
as permissive
for all
to authenticated
using ((role_for(auth.uid()) = 'operator'::text))
with check ((role_for(auth.uid()) = 'operator'::text));


