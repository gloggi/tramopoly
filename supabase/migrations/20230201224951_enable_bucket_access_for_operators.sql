
create policy "Enable full access for admins 1ddh29c_0"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'messageFiles'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1ddh29c_1"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (((bucket_id = 'messageFiles'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1ddh29c_2"
on "storage"."objects"
as permissive
for update
to authenticated
using (((bucket_id = 'messageFiles'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1ddh29c_3"
on "storage"."objects"
as permissive
for delete
to authenticated
using (((bucket_id = 'messageFiles'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1r1v8px_0"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'proofPhotos'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1r1v8px_1"
on "storage"."objects"
as permissive
for insert
to authenticated
with check (((bucket_id = 'proofPhotos'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1r1v8px_2"
on "storage"."objects"
as permissive
for update
to authenticated
using (((bucket_id = 'proofPhotos'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable full access for admins 1r1v8px_3"
on "storage"."objects"
as permissive
for delete
to authenticated
using (((bucket_id = 'proofPhotos'::text) AND (role_for(auth.uid()) = 'admin'::text)));


create policy "Enable reading message files for operators"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'messageFiles'::text) AND (role_for(auth.uid()) = 'operator'::text)));


create policy "Enable reading proof photos for operators"
on "storage"."objects"
as permissive
for select
to authenticated
using (((bucket_id = 'proofPhotos'::text) AND (role_for(auth.uid()) = 'operator'::text)));

