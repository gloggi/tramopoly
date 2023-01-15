create policy "Enable reading own group's proof photos"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'proofPhotos'::text) AND (EXISTS ( SELECT 1
   FROM (profiles u
     LEFT JOIN profiles o ON ((u.group_id = o.group_id)))
  WHERE ((u.id = auth.uid()) AND (o.id = objects.owner))))));


create policy "Enable uploading proof photos for logged in users"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (((bucket_id = 'proofPhotos'::text) AND (owner = auth.uid())));
