create policy "Enable uploading abteilungLogos files for admins"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (((bucket_id = 'abteilungLogos'::text) AND (owner = auth.uid()) AND (EXISTS ( SELECT 1
   FROM profiles
  WHERE ((profiles.id = auth.uid()) AND (profiles.role = 'admin'::text))))));



