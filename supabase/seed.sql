INSERT INTO public.abteilungen (id, created_at, name, active, logo_url) VALUES (1, '2023-01-01 00:00:00.000000+00', 'Gloggi', true, NULL);

SELECT pg_catalog.setval('public.abteilungen_id_seq', 1, true);


INSERT INTO public.groups (id, created_at, name, active, abteilung_id) VALUES (1, '2023-01-01 00:00:00.000000+00', 'Gloggi', true, 1);

SELECT pg_catalog.setval('public.groups_id_seq', 1, true);
