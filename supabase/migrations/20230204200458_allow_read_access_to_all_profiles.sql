
create policy "Temporarily enable reading all profiles"
on "public"."profiles"
as permissive
for select
to authenticated
using (true);



