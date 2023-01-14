INSERT INTO storage.buckets (id, name) VALUES ('proofPhotos', 'proofPhotos');


INSERT INTO public.abteilungen (id, created_at, name, active, logo_url) VALUES (1, now(), 'Gloggi', true, NULL);

SELECT pg_catalog.setval('public.abteilungen_id_seq', 1, true);


INSERT INTO public.groups (id, created_at, name, active, abteilung_id) VALUES (1, now(), 'Gloggi', true, 1);

SELECT pg_catalog.setval('public.groups_id_seq', 1, true);


INSERT INTO public.stations (id, created_at, name, value) VALUES (1, now(), 'Affoltern, Bhf.', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (2, now(), 'Albisgütli', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (3, now(), 'Albisrieden', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (4, now(), 'Albisriederplatz', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (5, now(), 'Altstetten, Bhf.', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (6, now(), 'Auzelg', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (7, now(), 'Bad Allenmoos', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (8, now(), 'Bahnhofplatz / HB', 7000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (9, now(), 'Balgrist', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (10, now(), 'Bellevue', 7000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (11, now(), 'Besenrainstrasse', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (12, now(), 'Bethanien', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (13, now(), 'Brunau', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (14, now(), 'Bucheggplatz', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (15, now(), 'Bürkliplatz', 7000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (16, now(), 'Central', 6000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (17, now(), 'Dolder Bergstation', 2500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (18, now(), 'Elektrowatt', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (19, now(), 'Enge, Bhf.', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (20, now(), 'Escher-Wyss-Platz', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (21, now(), 'ETH / Universitätsspital', 4000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (22, now(), 'Farbhof', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (23, now(), 'Feldeggstrasse', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (24, now(), 'Frankental', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (25, now(), 'Goldbrunnenplatz', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (26, now(), 'Hardplatz', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (27, now(), 'Hardturm', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (28, now(), 'Hegianwandweg', 1200);
INSERT INTO public.stations (id, created_at, name, value) VALUES (29, now(), 'Hegibachplatz', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (30, now(), 'Heuried', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (31, now(), 'Hirzenbach', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (32, now(), 'Im Walder', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (33, now(), 'Irchel', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (34, now(), 'Juchhof', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (35, now(), 'Käshaldenstrasse', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (36, now(), 'Kappeli', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (37, now(), 'Kirche Fluntern', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (38, now(), 'Klusplatz', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (39, now(), 'Kronenstrasse', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (40, now(), 'Limmatplatz', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (41, now(), 'Lochergut', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (42, now(), 'Löwenplatz', 5000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (43, now(), 'Luegisland', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (44, now(), 'Manegg', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (45, now(), 'Meierhofplatz', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (46, now(), 'Messe / Hallenstadion', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (47, now(), 'Milchbuck', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (48, now(), 'Mötteliweg', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (49, now(), 'Oerlikon, Bhf.', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (50, now(), 'Paradeplatz', 7000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (51, now(), 'Probstei', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (52, now(), 'Rathaus', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (53, now(), 'Rehalp', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (54, now(), 'Riedhofstrasse', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (55, now(), 'Römerhof', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (56, now(), 'Sackzelg', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (57, now(), 'Schaffhauserplatz', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (58, now(), 'Schauenberg', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (59, now(), 'Schlyfi', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (60, now(), 'Schwamendingerplatz', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (61, now(), 'Seebach', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (62, now(), 'Seilbahn Rigiblick', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (63, now(), 'Selnau SZU, Bhf.', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (64, now(), 'Sonneggstrasse', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (65, now(), 'Stauffacher', 4000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (66, now(), 'Sternen Oerlikon', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (67, now(), 'Stettbach, Bhf.', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (68, now(), 'Stockerstrasse', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (69, now(), 'Sunnau', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (70, now(), 'Tiefenbrunnen, Bhf.', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (71, now(), 'Toblerplatz', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (72, now(), 'Toni-Areal', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (73, now(), 'Trichtisal', 3300);
INSERT INTO public.stations (id, created_at, name, value) VALUES (74, now(), 'Triemli', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (75, now(), 'Tüffenwies', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (76, now(), 'Waffenplatzstrasse', 2000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (77, now(), 'Waldgarten', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (78, now(), 'Werdhölzli', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (79, now(), 'Wiedikon, Bhf.', 3000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (80, now(), 'Wollishofen, Bhf.', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (81, now(), 'Wollishoferplatz', 1000);
INSERT INTO public.stations (id, created_at, name, value) VALUES (82, now(), 'Zentrum Witikon', 1500);
INSERT INTO public.stations (id, created_at, name, value) VALUES (83, now(), 'Zoo', 2000);

SELECT pg_catalog.setval('public.stations_id_seq', 83, true);
