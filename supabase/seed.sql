INSERT INTO storage.buckets (id, name) VALUES ('proofPhotos', 'proofPhotos');
INSERT INTO storage.buckets (id, name) VALUES ('messageFiles', 'messageFiles');
INSERT INTO storage.buckets (id, name, public) VALUES ('abteilungLogos', 'abteilungLogos', TRUE);


INSERT INTO public.settings (game_end) VALUES (now() + interval '10 hours');


INSERT INTO public.mr_t_rewards (duration, value) VALUES (15, 300);
INSERT INTO public.mr_t_rewards (duration, value) VALUES (30, 1000);
INSERT INTO public.mr_t_rewards (duration, value) VALUES (45, 1750);
INSERT INTO public.mr_t_rewards (duration, value) VALUES (60, 3000);
INSERT INTO public.mr_t_rewards (duration, value) VALUES (75, 5000);
INSERT INTO public.mr_t_rewards (duration, value) VALUES (90, 10000);


INSERT INTO public.abteilungen (name, active, logo_url) VALUES ('Zentralä', true, NULL);

SELECT pg_catalog.setval('public.abteilungen_id_seq', 1, true);


INSERT INTO public.groups (name, active, abteilung_id) VALUES ('Zentralä', true, 1);

SELECT pg_catalog.setval('public.groups_id_seq', 1, true);


INSERT INTO public.stations (name, value) VALUES ('Affoltern, Bhf.', 2000);
INSERT INTO public.stations (name, value) VALUES ('Albisgütli', 2000);
INSERT INTO public.stations (name, value) VALUES ('Albisrieden', 1000);
INSERT INTO public.stations (name, value) VALUES ('Albisriederplatz', 2000);
INSERT INTO public.stations (name, value) VALUES ('Altstetten, Bhf.', 1500);
INSERT INTO public.stations (name, value) VALUES ('Auzelg', 1500);
INSERT INTO public.stations (name, value) VALUES ('Bad Allenmoos', 1000);
INSERT INTO public.stations (name, value) VALUES ('Bahnhofplatz / HB', 7000);
INSERT INTO public.stations (name, value) VALUES ('Balgrist', 1000);
INSERT INTO public.stations (name, value) VALUES ('Bellevue', 7000);
INSERT INTO public.stations (name, value) VALUES ('Besenrainstrasse', 1000);
INSERT INTO public.stations (name, value) VALUES ('Bethanien', 1500);
INSERT INTO public.stations (name, value) VALUES ('Brunau', 1000);
INSERT INTO public.stations (name, value) VALUES ('Bucheggplatz', 3000);
INSERT INTO public.stations (name, value) VALUES ('Bürkliplatz', 7000);
INSERT INTO public.stations (name, value) VALUES ('Central', 6000);
INSERT INTO public.stations (name, value) VALUES ('Dolder Bergstation', 2500);
INSERT INTO public.stations (name, value) VALUES ('Elektrowatt', 1500);
INSERT INTO public.stations (name, value) VALUES ('Enge, Bhf.', 2000);
INSERT INTO public.stations (name, value) VALUES ('Escher-Wyss-Platz', 2000);
INSERT INTO public.stations (name, value) VALUES ('ETH / Universitätsspital', 4000);
INSERT INTO public.stations (name, value) VALUES ('ETH Hönggerberg', 2000);
INSERT INTO public.stations (name, value) VALUES ('Farbhof', 1000);
INSERT INTO public.stations (name, value) VALUES ('Feldeggstrasse', 1500);
INSERT INTO public.stations (name, value) VALUES ('Frankental', 1000);
INSERT INTO public.stations (name, value) VALUES ('Goldbrunnenplatz', 3000);
INSERT INTO public.stations (name, value) VALUES ('Hardplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Hardturm', 1000);
INSERT INTO public.stations (name, value) VALUES ('Hegianwandweg', 1200);
INSERT INTO public.stations (name, value) VALUES ('Hegibachplatz', 1500);
INSERT INTO public.stations (name, value) VALUES ('Heuried', 1500);
INSERT INTO public.stations (name, value) VALUES ('Hirzenbach', 1000);
INSERT INTO public.stations (name, value) VALUES ('Im Walder', 1500);
INSERT INTO public.stations (name, value) VALUES ('Irchel', 3000);
INSERT INTO public.stations (name, value) VALUES ('Juchhof', 2000);
INSERT INTO public.stations (name, value) VALUES ('Kappeli', 1000);
INSERT INTO public.stations (name, value) VALUES ('Käshaldenstrasse', 1500);
INSERT INTO public.stations (name, value) VALUES ('Kirche Fluntern', 1000);
INSERT INTO public.stations (name, value) VALUES ('Klusplatz', 3000);
INSERT INTO public.stations (name, value) VALUES ('Kronenstrasse', 2000);
INSERT INTO public.stations (name, value) VALUES ('Limmatplatz', 2000);
INSERT INTO public.stations (name, value) VALUES ('Lochergut', 1000);
INSERT INTO public.stations (name, value) VALUES ('Löwenplatz', 5000);
INSERT INTO public.stations (name, value) VALUES ('Luegisland', 1000);
INSERT INTO public.stations (name, value) VALUES ('Manegg', 3000);
INSERT INTO public.stations (name, value) VALUES ('Meierhofplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Messe / Hallenstadion', 2000);
INSERT INTO public.stations (name, value) VALUES ('Milchbuck', 2000);
INSERT INTO public.stations (name, value) VALUES ('Mötteliweg', 2000);
INSERT INTO public.stations (name, value) VALUES ('Oerlikon, Bhf.', 3000);
INSERT INTO public.stations (name, value) VALUES ('Paradeplatz', 7000);
INSERT INTO public.stations (name, value) VALUES ('Probstei', 1000);
INSERT INTO public.stations (name, value) VALUES ('Rathaus', 1000);
INSERT INTO public.stations (name, value) VALUES ('Rehalp', 2000);
INSERT INTO public.stations (name, value) VALUES ('Riedhofstrasse', 1500);
INSERT INTO public.stations (name, value) VALUES ('Römerhof', 2000);
INSERT INTO public.stations (name, value) VALUES ('Sackzelg', 1000);
INSERT INTO public.stations (name, value) VALUES ('Schaffhauserplatz', 3000);
INSERT INTO public.stations (name, value) VALUES ('Schauenberg', 1500);
INSERT INTO public.stations (name, value) VALUES ('Schlyfi', 1500);
INSERT INTO public.stations (name, value) VALUES ('Schwamendingerplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Seebach', 1000);
INSERT INTO public.stations (name, value) VALUES ('Seilbahn Rigiblick', 2000);
INSERT INTO public.stations (name, value) VALUES ('Selnau SZU, Bhf.', 2000);
INSERT INTO public.stations (name, value) VALUES ('Sonneggstrasse', 2000);
INSERT INTO public.stations (name, value) VALUES ('Stauffacher', 4000);
INSERT INTO public.stations (name, value) VALUES ('Sternen Oerlikon', 3000);
INSERT INTO public.stations (name, value) VALUES ('Stettbach, Bhf.', 1000);
INSERT INTO public.stations (name, value) VALUES ('Stockerstrasse', 3000);
INSERT INTO public.stations (name, value) VALUES ('Sunnau', 2000);
INSERT INTO public.stations (name, value) VALUES ('Tiefenbrunnen, Bhf.', 2000);
INSERT INTO public.stations (name, value) VALUES ('Toblerplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Toni-Areal', 1500);
INSERT INTO public.stations (name, value) VALUES ('Trichtisal', 3300);
INSERT INTO public.stations (name, value) VALUES ('Triemli', 1000);
INSERT INTO public.stations (name, value) VALUES ('Tüffenwies', 1000);
INSERT INTO public.stations (name, value) VALUES ('Waffenplatzstrasse', 2000);
INSERT INTO public.stations (name, value) VALUES ('Waldgarten', 1000);
INSERT INTO public.stations (name, value) VALUES ('Werdhölzli', 1000);
INSERT INTO public.stations (name, value) VALUES ('Wiedikon, Bhf.', 3000);
INSERT INTO public.stations (name, value) VALUES ('Wollishofen, Bhf.', 1500);
INSERT INTO public.stations (name, value) VALUES ('Wollishoferplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Zentrum Witikon', 1500);
INSERT INTO public.stations (name, value) VALUES ('Zoo', 2000);

SELECT pg_catalog.setval('public.stations_id_seq', (SELECT MAX(id) FROM public.stations), true);


INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Albisgütli', 500, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Alte Trotte', 750, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Auzelg Ost', 3000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Binz Center', 1000, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Bleulerstrasse', 3000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Buchzelgstrasse', 2000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Dolder Bergstation', 3000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Gutstrasse', 500, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Helmhaus', 1000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Herbstweg', 1000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Im Hagacker', 1000, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Im Klösterli', 1500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Juchhof', 1500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Kienastenwies', 1000, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Löwenbräu', 1750, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Maillartstrasse', 1000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Manesseplatz', 1000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Micafil', 750, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Mittelleimbach', 3000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Neubühl', 2000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Okenstrasse', 500, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Rütihof', 1000, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('SBB-Werkstätte', 1500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Siemens', 2500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Sportweg', 1000, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Stadtgrenze', 750, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Strickhof', 500, NULL, 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Sunnau', 1750, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Trichtisal', 1500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Waidhof', 2500, NULL, NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Zoo/Forrenweid', 2000, 'Stelläd als Gruppä zämä äs Tiär dar.', 500);

SELECT pg_catalog.setval('public.jokers_id_seq', (SELECT MAX(id) FROM public.jokers), true);
