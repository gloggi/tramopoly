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


INSERT INTO public.groups (name, active, abteilung_id) VALUES ('Zentralä', true, 1);


INSERT INTO public.mr_t_changes(group_id) VALUES ((SELECT MAX(id) FROM public.groups));


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


INSERT INTO public.mr_t_locations (name) VALUES ('Aargauerstrasse'), ('Albisgütli'), ('Albisrank'), ('Albisrieden'), ('Albisriederdörfli'), ('Albisriederplatz'), ('Alte Trotte'), ('Altenhofstrasse'), ('Altes Krematorium'), ('Althoos'), ('Altried'), ('Am Börtli'), ('Am Suteracher'), ('Appenzellerstrasse'), ('Aspholz'), ('Aubrücke'), ('Ausserdorfstrasse'), ('Auzelg'), ('Auzelg Ost'), ('Bachmattstrasse'), ('Bäckeranlage'), ('Bad Allenmoos'), ('Bahnhof Affoltern'), ('Bahnhof Altstetten'), ('Bahnhof Altstetten Nord'), ('Bahnhof Enge'), ('Bahnhof Enge/Bederstr.'), ('Bahnhof Hardbrücke'), ('Bahnhof Leimbach'), ('Bahnhof Oerlikon'), ('Bahnhof Oerlikon Nord'), ('Bahnhof Oerlikon Ost'), ('Bahnhof Selnau'), ('Bahnhof Stadelhofen'), ('Bahnhof Stettbach'), ('Bahnhof Tiefenbrunnen'), ('Bahnhof Wiedikon'), ('Bahnhof Wipkingen'), ('Bahnhof Wollishofen'), ('Bahnhofplatz/HB'), ('Bahnhofquai/HB'), ('Bahnhofstrasse/HB'), ('Balgrist'), ('Bändliweg'), ('Baslerstrasse'), ('Beckenhof'), ('Bellevue'), ('Berghaldenstrasse'), ('Bergstation Dolderbahn'), ('Berninaplatz'), ('Bernoulli-Häuser'), ('Bertastrasse'), ('Berufswahlschule'), ('Besenrainstrasse'), ('Bethanien'), ('Bezirksgebäude'), ('Bhf. Wollishofen/Staubstr.'), ('Bhf. Wollishofen/Werft'), ('Billoweg'), ('Binz'), ('Binz Center'), ('Birch-/Glatttalstrasse'), ('Birchdörfli'), ('Bircher-Benner'), ('Birchstrasse'), ('Bleulerstrasse'), ('Blumenfeldstrasse'), ('Bocklerstrasse'), ('Bollingerweg'), ('Botanischer Garten'), ('Bristenstrasse'), ('Brunau/Mutschellenstr.'), ('Brunaustrasse'), ('Bucheggplatz'), ('Buchholz'), ('Buchzelgstrasse'), ('Buhnstrasse'), ('Burgwies'), ('Bürkliplatz'), ('Butzenstrasse'), ('Central'), ('Central Polybahn'), ('Chaletweg'), ('Chinagarten'), ('Dangelstrasse'), ('Dorflinde'), ('Dreispitz'), ('Dreiwiesen'), ('Drusbergstrasse'), ('Dunkelhölzli'), ('Einfangstrasse'), ('Elektrowatt'), ('Englischviertelstrasse'), ('EPI-Klinik'), ('Eschergutweg'), ('Escher-Wyss-Platz'), ('ETH Hönggerberg'), ('ETH/Universitätsspital'), ('Ettenfeld'), ('Farbhof'), ('Feldeggstrasse'), ('Fellenbergstrasse'), ('Felsenrainstrasse'), ('Fernsehstudio'), ('Feusisbergli'), ('Fischerweg'), ('Flobotstrasse'), ('Flühgasse'), ('Flurstrasse'), ('Förrlibuckstrasse'), ('Frankental'), ('Freiestrasse'), ('Freihofstrasse'), ('Friedackerstrasse'), ('Friedhof Eichbühl'), ('Friedhof Enzenbühl'), ('Friedhof Hönggerberg'), ('Friedhof Schwandenholz'), ('Friedhof Sihlfeld'), ('Friedhof Uetliberg'), ('Friedhof Witikon'), ('Friedrichstrasse'), ('Friesenberg'), ('Friesenberghalde'), ('Friesenbergstrasse'), ('Frohburg'), ('Fröhlichstrasse'), ('Fronwald'), ('Frymannstrasse'), ('Geeringstrasse'), ('Genossenschaftsstrasse'), ('Germaniastrasse'), ('Giblenstrasse'), ('Glatt'), ('Glattpark'), ('Glattwiesen'), ('Glaubtenstrasse'), ('Glaubtenstrasse Nord'), ('Glaubtenstrasse Süd'), ('Glockenacker'), ('Goldackerweg'), ('Goldauerstrasse'), ('Goldbrunnenplatz'), ('Grimselstrasse'), ('Grubenstrasse'), ('Grünaustrasse'), ('Grünwald'), ('Guggachstrasse'), ('Güterbahnhof'), ('Gutstrasse'), ('Hadlaubstrasse'), ('Hagenholz'), ('Haldenbach'), ('Haldenegg'), ('Hallenbad Oerlikon'), ('Hardhof'), ('Hardplatz'), ('Hardturm'), ('Hedwigsteig'), ('Heerenwiesen'), ('Hegianwandweg'), ('Hegibachplatz'), ('Heizenholz'), ('Helmhaus'), ('Helvetiaplatz'), ('Herbstweg'), ('Herdernstrasse'), ('Hermetschloo'), ('Hertensteinstrasse'), ('Herzogenmühlestrasse'), ('Heubeeriweg'), ('Heuried'), ('Himmeri'), ('Hinterbergstrasse'), ('Hirschwiesenstrasse'), ('Hirzenbach'), ('Höfliweg'), ('Hofstrasse'), ('Hohenklingensteig'), ('Hölderlinsteig'), ('Hölderlinstrasse'), ('Holzerhurd'), ('Hönggerberg'), ('Höschgasse'), ('Hottingerplatz'), ('Hubertus'), ('Hügelstrasse'), ('Hungerbergstrasse'), ('Hürstholz'), ('Im Ebnet'), ('Im Gut'), ('Im Hagacker'), ('Im Hüsli'), ('Im Klösterli'), ('Im Walder'), ('Im Wingert'), ('In der Ey'), ('Juchhof'), ('Jugendherberge'), ('Kalchbühlweg'), ('Kalkbreite/Bhf.Wiedikon'), ('Kanonengasse'), ('Kantonalbank'), ('Kantonsschule'), ('Kantonsschule Enge'), ('Kapfstrasse'), ('Kappeli'), ('Kappenbühlweg'), ('Käshaldenstrasse'), ('Kempfhofsteig'), ('Kernstrasse'), ('Kienastenwies'), ('Kinkelstrasse'), ('Kirche Fluntern'), ('Klosbach'), ('Klusplatz'), ('Köschenrüti'), ('Krematorium Nordheim'), ('Kreuzplatz'), ('Kreuzstrasse'), ('Kronenstrasse'), ('Krönleinstrasse'), ('Kunsthaus'), ('Lägernstrasse'), ('Landiwiese'), ('Langensteinenstrasse'), ('Langgrütstrasse'), ('Langmauerstrasse'), ('Laubegg'), ('Laubiweg'), ('Lehenstrasse'), ('Leimgrübelstrasse'), ('Lerchenhalde'), ('Lerchenrain'), ('Lettenstrasse'), ('Letzibach'), ('Letzigrund'), ('Letzipark'), ('Letzipark West'), ('Letzistrasse'), ('Leutschenbach'), ('Limmatplatz'), ('Lindenplatz'), ('Lochergut'), ('Loogarten'), ('Loorenstrasse'), ('Löwenbräu'), ('Löwenplatz'), ('Luchswiesen'), ('Luegisland'), ('Maienweg'), ('Maillartstrasse'), ('Manegg'), ('Manesseplatz'), ('Marbachweg'), ('Mattenhof'), ('Max-Bill-Platz'), ('Meierhofplatz'), ('Messe/Hallenstadion'), ('Micafil'), ('Michelstrasse'), ('Milchbuck'), ('Militär-/Langstrasse'), ('Mittelleimbach'), ('Morgental'), ('Mötteliweg'), ('Mühlacker'), ('Museum für Gestaltung'), ('Museum Rietberg'), ('Neeserweg'), ('Neuaffoltern'), ('Neubühl'), ('Neumarkt'), ('Neunbrunnen'), ('Nordheimstrasse'), ('Nordstrasse'), ('Nürenbergstrasse'), ('Oberwiesenstrasse'), ('Oerlikerhus'), ('Okenstrasse'), ('Opernhaus'), ('Orionstrasse'), ('Ottikerstrasse'), ('Paradeplatz'), ('Pflegezentr. Käferberg'), ('Platte'), ('Polyterrasse ETH'), ('Post Wollishofen'), ('Probstei'), ('Quellenstrasse'), ('Radiostudio'), ('Räffelstrasse'), ('Rathaus'), ('Rautihalde'), ('Rautistrasse'), ('Rebbergsteig'), ('Regensbergbrücke'), ('Rehalp'), ('Rennweg'), ('Rentenanstalt'), ('Riedbach'), ('Riedgraben'), ('Riedhofstrasse'), ('Rigiblick'), ('Römerhof'), ('Röntgenstrasse'), ('Rosengartenstrasse'), ('Röslistrasse'), ('Roswiesen'), ('Rotbuchstrasse'), ('Rote Fabrik'), ('Rudolf-Brun-Brücke'), ('Rütihof'), ('Saalsporthalle'), ('Saatlenstrasse'), ('Sackzelg'), ('Sädlenweg'), ('Salersteig'), ('Salzweg'), ('SBB-Werkstätte'), ('Schaffhauserplatz'), ('Schanzackerstrasse'), ('Schäppiweg'), ('Schauenberg'), ('Schaufelbergerstrasse'), ('Scheuchzerstrasse'), ('Schiffbau'), ('Schiffstation'), ('Schiffstation'), ('Schiffstation'), ('Schiffstation'), ('Schiffstation'), ('Schiffstation'), ('Schiffstation'), ('Schlyfi'), ('Schmiede Wiedikon'), ('Schönauring'), ('Schörlistrasse'), ('Schulhaus Altweg'), ('Schulhaus Buchlern'), ('Schumacherweg'), ('Schürgistrasse'), ('Schützenhaus Höngg'), ('Schwamendingerplatz'), ('Schwandenholz'), ('Schweighof'), ('Schweizer Rück'), ('Schwert'), ('Seebach'), ('Seebacherplatz'), ('Seerose'), ('Segantinistrasse'), ('Segeten'), ('Seidelhof'), ('Seilbahn Rigiblick'), ('Siemens'), ('Signaustrasse'), ('Sihlcity'), ('Sihlcity Nord'), ('Sihlpost / HB'), ('Sihlquai/HB'), ('Sihlstrasse'), ('Sihlweidstrasse'), ('Singlistrasse'), ('Solidapark'), ('Sonneggstrasse'), ('Sportweg'), ('Sprecherstrasse'), ('Spyriplatz'), ('Spyristeig'), ('Stadtgrenze'), ('Stampfenbachplatz'), ('Staudenbühl'), ('Stauffacher'), ('Sternen Oerlikon'), ('Stettbach'), ('Stierenried'), ('Stockerstrasse'), ('Stodolastrasse'), ('Strassenverkehrsamt'), ('Strickhof'), ('Sukkulentensammlung'), ('Sunnau'), ('Susenbergstrasse'), ('Talwiesenstrasse'), ('Technopark'), ('Thujastrasse'), ('Tierspital'), ('Titlisstrasse'), ('Tobelhof'), ('Toblerplatz'), ('Toni-Areal'), ('Trichtenhausenfussweg'), ('Trichtisal'), ('Triemli'), ('Triemlispital'), ('Tüffenwies'), ('Tulpenstrasse'), ('Tunnelstrasse'), ('Uetlihof'), ('Universität Irchel'), ('Unteraffoltern'), ('Untermoosstrasse'), ('Verenastrasse'), ('Vogelsangstrasse'), ('Voltastrasse'), ('Vulkanstrasse'), ('Waffenplatz-/Bederstr.'), ('Waffenplatzstrasse'), ('Waidbadstrasse'), ('Waidfussweg'), ('Waidhof'), ('Waidspital'), ('Waldgarten'), ('Waldhaus Dolder'), ('Wartau'), ('Waserstrasse'), ('Weihersteig'), ('Werd'), ('Werdhölzli'), ('Wetlistrasse'), ('Widmerstrasse'), ('Wieslergasse'), ('Wiesliacher'), ('Wildbachstrasse'), ('Winkelriedstrasse'), ('Winzerhalde'), ('Winzerstrasse'), ('Winzerstrasse Süd'), ('Wipkingerplatz'), ('Wollishoferplatz'), ('Wonnebergstrasse'), ('Würzgraben'), ('Zehntenhausplatz'), ('Zentrum Witikon'), ('Zielweg'), ('Zoo'), ('Zoo/Forrenweid'), ('Zürich Affoltern'), ('Zürich Altstetten'), ('Zürich Balgrist'), ('Zürich Bellevue (See)'), ('Zürich Binz'), ('Zürich Brunau'), ('Zürich Enge'), ('Zürich Friesenberg'), ('Zürich Giesshübel'), ('Zürich Hardbrücke'), ('Zürich HB'), ('Zürich HB Museum'), ('Zürich HB Sihlpost'), ('Zürich HB SZU'), ('Zürich Hegibachplatz'), ('Zürich Kreuzplatz'), ('Zürich Leimbach'), ('Zürich Manegg'), ('Zürich Oerlikon'), ('Zürich Rehalp'), ('Zürich Saalsporthalle'), ('Zürich Schweighof'), ('Zürich Seebach'), ('Zürich Selnau'), ('Zürich Stadelhofen'), ('Zürich Tiefenbrunnen'), ('Zürich Tiefenbrunnen (See)'), ('Zürich Triemli'), ('Zürich Wiedikon'), ('Zürich Wipkingen'), ('Zürich Wollishofen'), ('Zürichbergstrasse'), ('Zweiackerstrasse'), ('Zwielplatz'), ('Zwinglihaus'), ('Zypressenstrasse');

