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
INSERT INTO public.stations (name, value) VALUES ('Polyterasse', 3000);
INSERT INTO public.stations (name, value) VALUES ('Probstei', 1000);
INSERT INTO public.stations (name, value) VALUES ('Rathaus', 1000);
INSERT INTO public.stations (name, value) VALUES ('Rehalp', 2000);
INSERT INTO public.stations (name, value) VALUES ('Riedhofstrasse', 1500);
INSERT INTO public.stations (name, value) VALUES ('Rigiblick', 1500);
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
INSERT INTO public.stations (name, value) VALUES ('Tiefenbrunnen, Bhf.', 2000);
INSERT INTO public.stations (name, value) VALUES ('Toblerplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Toni-Areal', 1500);
INSERT INTO public.stations (name, value) VALUES ('Friedhof Witikon', 2000);
INSERT INTO public.stations (name, value) VALUES ('Triemli', 1000);
INSERT INTO public.stations (name, value) VALUES ('Tüffenwies', 1000);
INSERT INTO public.stations (name, value) VALUES ('Ueberlandpark', 1000);
INSERT INTO public.stations (name, value) VALUES ('Universität Irchel', 3000);
INSERT INTO public.stations (name, value) VALUES ('Waffenplatzstrasse', 2000);
INSERT INTO public.stations (name, value) VALUES ('Werdhölzli', 1000);
INSERT INTO public.stations (name, value) VALUES ('Wiedikon, Bhf.', 3000);
INSERT INTO public.stations (name, value) VALUES ('Wollishofen, Bhf./Staubstr.', 1500);
INSERT INTO public.stations (name, value) VALUES ('Wollishoferplatz', 1000);
INSERT INTO public.stations (name, value) VALUES ('Zentrum Witikon', 1500);
INSERT INTO public.stations (name, value) VALUES ('Zoo', 2000);


INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Albisgütli', 750, 'Machäd äs Fotti wo alli dä Bodä nümä berüähräd.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Alte Trotte', 750, 'Stönd vor dä Station und posiäräd uf äm Fotti wiä alti Lüüt.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Auzelg Ost', 3000, 'Suächäd ä Münzä mit äm gliichä Jahrgang wiä öppär vo oi und machäd äs Fotti vor dä Station.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Binz Center', 1000, 'Filmäd än churzä Wättärbricht a dä Station.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Bleulerstrasse', 3000, 'Zäigäd uf äm Fotti äs Papierschiffli wo im Brunnä uf dä andere Strassäsiitä schwümmt.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Buchzelgstrasse', 1750, 'Machäd die längscht möglich Polonaise mit mindästäns 5 fremdä Personä und filmäds.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Dolder Bergstation', 3000, 'Stönd Spalier (Tunnel mit de Ärm) für 5 fremdi Personä und filmä.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Gutstrasse', 750, 'Machäd alli ä Yoga-Posä uf äm Fotti.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Helmhaus', 750, 'Machäd zämä en grossä gordischä Chnopf und föttäläds.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Herbstweg', 1000, 'Versteckäd oi "gaaanz unuffällig" hindär dä Bäum und machäd äs Föttäli wiä mär oi "fast nöd" entdeckt.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Im Hagacker', 1000, 'Machäd en Hochziitsatrag und föttäläds.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Im Klösterli', 1000, 'Machäd mit äm Füürhydrant äs Föttäli.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Juchhof', 1000, 'Schriibäd s Wort Juchhof mit mänschlichä Buächstabä und föttäläds.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Kienastenwies', 1000, 'Machäd ä mänschlichi Pyramidä und föttäläds.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Löwenbräu', 1500, 'Stelläd uf ämä Fotti vor äm Stationsschild än Loi naa.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Maillartstrasse', 1500, 'Gönd ufd Brugg näbe dä Haltestell und posiäräd deet druf i oiärä coolstä Posä.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Manesseplatz', 750, 'Machäd äs Fotti mit ärä brülläträgändä Person.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Micafil', 1000, 'Machäd 3 verschiedäni Kunststückli und tüänd die föttälä oder filmä.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Mittelleimbach', 2750, 'Machäd äs Fotti mit ämä Busfahrär oder öppäräm im Bus (BITTE um Erlaubnis frägä).', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Neubühl', 1750, 'Findäd ä fremdi Person mit mindästäns Schuägrössi 42.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Okenstrasse', 750, 'Föttäläd än Uswiis mit äm Jahrgang 2005.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Rütihof', 1500, 'Posäd ufämä Föttäli mit dä Schachfigurä wo uf äm Platz vor äm Coop stönd.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('SBB-Werkstätte', 1500, 'Versuächäd ä Person zum singä z bringä und filmäds.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Siemens', 1000, 'Machäd äs professionells Fotti mit äm Siemens-Logo.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Sportweg', 750, 'Machäd äs Fotti mit 3 Lüüt wo zämä 50 Jahr alt sind (oder so näch wiä möglich).', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Stadtgrenze', 1000, 'Laufäd us Züri usä und machäd äs Fotti mit äm Ortsschild.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Strickhof', 500, 'Schickäd än guätä Flachwitz ad Zentralä.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Sunnau', 2000, 'Trojanischs Pferd: Uf äm Fotti sind 4 Bei, 5 Ärm und 2 Chöpf.', 500);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Trichtisal', 1500, 'Spieläd alli dä James Bond und "spioniäräd, und föttäläd das.', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Waidhof', 2500, 'Erfindäd ä churzi Fotolovestory und föttäläd sie (chasch au mee Fottis no im Chat naaschickä).', NULL);
INSERT INTO public.jokers (name, value, challenge, bonus_call_value) VALUES ('Zoo/Forrenweid', 2000, 'Bringäd dä Krawattächnopf ärä fremdä Person bii und föttäläds.', 500);


INSERT INTO public.mr_t_locations (name) VALUES ('Aargauerstrasse'), ('Albisgütli'), ('Albisrank'), ('Albisrieden'), ('Albisriederdörfli'), ('Albisriederplatz'), ('Alte Trotte'), ('Altenhofstrasse'), ('Altes Krematorium'), ('Althoos'), ('Altried'), ('Am Börtli'), ('Am Suteracher'), ('Appenzellerstrasse'), ('Arnikahof'), ('Aspholz'), ('Aubrücke'), ('Ausserdorfstrasse'), ('Auzelg'), ('Auzelg Ost'), ('Bachmattstrasse'), ('Bäckeranlage'), ('Bad Allenmoos'), ('Bahnhof Affoltern'), ('Bahnhof Altstetten'), ('Bahnhof Altstetten N'), ('Bahnhof Enge'), ('Bahnhof Enge/Bederstr.'), ('Bahnhof Hardbrücke'), ('Bahnhof Leimbach'), ('Bahnhof Oerlikon'), ('Bahnhof Oerlikon Nord'), ('Bahnhof Oerlikon Ost'), ('Bahnhof Selnau'), ('Bahnhof Stadelhofen'), ('Bahnhof Stettbach'), ('Bahnhof Tiefenbrunnen'), ('Bahnhof Wiedikon'), ('Bahnhof Wipkingen'), ('Bahnhof Wollishofen'), ('Bahnhofplatz/HB'), ('Bahnhofquai/HB'), ('Bahnhofstrasse/HB'), ('Balgrist'), ('Balgrist Ost'), ('Bändliweg'), ('Baslerstrasse'), ('Beckenhof'), ('Bellevue'), ('Berghaldenstrasse'), ('Bergstation Dolderbahn'), ('Berninaplatz'), ('Bernoulli-Häuser'), ('Bertastrasse'), ('Berufswahlschule'), ('Besenrainstrasse'), ('Besenrainweg'), ('Bethanien'), ('Bezirksgebäude'), ('Bhf Enge Pausenplatz'), ('Bhf. Wollishofen/Werft'), ('Billoweg'), ('Binz'), ('Binz Center'), ('Birch-/Glatttalstrasse'), ('Birchdörfli'), ('Bircher-Benner'), ('Birchstrasse'), ('Bleulerstrasse'), ('Blumenfeldstrasse'), ('Bollingerweg'), ('Botanischer Garten'), ('Bristenstrasse'), ('Brunau/Mutschellenstr.'), ('Brunaustrasse'), ('Brunnenhof'), ('Bucheggplatz'), ('Buchholz'), ('Buchzelgstrasse'), ('Buhnstrasse'), ('Burgwies'), ('Bürkliplatz'), ('Butzenstrasse'), ('Central'), ('Central Polybahn'), ('Chaletweg'), ('Chinagarten'), ('Dangelstrasse'), ('Dorflinde'), ('Dreispitz'), ('Dreiwiesen'), ('Drusbergstrasse'), ('Dunkelhölzli'), ('Einfangstrasse'), ('Elektrowatt'), ('Englischviertelstrasse'), ('EPI-Klinik'), ('Escher-Wyss-Platz'), ('Eschergutweg'), ('ETH Hönggerberg'), ('ETH/Universitätsspital'), ('Ettenfeld'), ('Farbhof'), ('Feldeggstrasse'), ('Fellenbergstrasse'), ('Felsenrainstrasse'), ('Fernsehstudio'), ('Feusisbergli'), ('Fischerweg'), ('Flobotstrasse'), ('Flühgasse'), ('Flurstrasse'), ('Förrlibuckstrasse'), ('Frankental'), ('Freiestrasse'), ('Freihofstrasse'), ('Friedackerstrasse'), ('Friedhof Eichbühl'), ('Friedhof Enzenbühl'), ('Friedhof Hönggerberg'), ('Friedhof Schwandenholz'), ('Friedhof Sihlfeld'), ('Friedhof Uetliberg'), ('Friedhof Witikon'), ('Friedrichstrasse'), ('Friesenberg'), ('Friesenberghalde'), ('Friesenbergstrasse'), ('Frohburg'), ('Fröhlichstrasse'), ('Fronwald'), ('Frymannstrasse'), ('Geeringstrasse'), ('Genossenschaftsstrasse'), ('Germaniastrasse'), ('Giblenstrasse'), ('Glattwiesen'), ('Glaubtenstrasse'), ('Glaubtenstrasse Nord'), ('Glaubtenstrasse Süd'), ('Glockenacker'), ('Goldackerweg'), ('Goldauerstrasse'), ('Goldbrunnenplatz'), ('Grimselstrasse'), ('Grubenstrasse'), ('Grünaustrasse'), ('Grünwald'), ('Guggachstrasse'), ('Güterbahnhof'), ('Gutstrasse'), ('Hadlaubstrasse'), ('Hagenholz'), ('Haldenbach'), ('Haldenegg'), ('Hallenbad Oerlikon'), ('Hardhof'), ('Hardplatz'), ('Hardturm'), ('Hedwigsteig'), ('Heerenwiesen'), ('Hegianwandweg'), ('Hegibachplatz'), ('Heizenholz'), ('Helmhaus'), ('Helvetiaplatz'), ('Herbstweg'), ('Herdernstrasse'), ('Hermetschloo'), ('Hertensteinstrasse'), ('Hertersteg'), ('Herzogenmühlestrasse'), ('Heubeeriweg'), ('Heuried'), ('Himmeri'), ('Hinterbergstrasse'), ('Hirschwiesenstrasse'), ('Hirzenbach'), ('Höfliweg'), ('Hofstrasse'), ('Hohenklingensteig'), ('Hölderlinsteig'), ('Hölderlinstrasse'), ('Holzerhurd'), ('Hönggerberg'), ('Höschgasse'), ('Hottingerplatz'), ('Hubertus'), ('Hügelstrasse'), ('Hungerbergstrasse'), ('Hürstholz'), ('Im Ebnet'), ('Im Gut'), ('Im Hagacker'), ('Im Hüsli'), ('Im Klösterli'), ('Im Walder'), ('Im Wingert'), ('In der Ey'), ('Juchhof'), ('Jugendherberge'), ('Kalchbühlweg'), ('Kalkbreite/Bhf.Wiedikon'), ('Kanonengasse'), ('Kantonalbank'), ('Kantonsschule'), ('Kantonsschule Enge'), ('Kapfstrasse'), ('Kappeli'), ('Kappenbühlweg'), ('Käshaldenstrasse'), ('Kempfhofsteig'), ('Kernstrasse'), ('Kienastenwies'), ('Kindersp. (ab 10/2024)'), ('Kinkelstrasse'), ('Kirche Fluntern'), ('Klinik Hirslanden'), ('Klosbach'), ('Klusplatz'), ('Köschenrüti'), ('Krematorium Nordheim'), ('Kreuzplatz'), ('Kreuzstrasse'), ('Kronenstrasse'), ('Krönleinstrasse'), ('Kunsthaus'), ('Lägernstrasse'), ('Landiwiese'), ('Langensteinenstrasse'), ('Langgrütstrasse'), ('Langmauerstrasse'), ('Laubegg'), ('Laubiweg'), ('Lehenstrasse'), ('Leimgrübelstrasse'), ('Lerchenhalde'), ('Lerchenrain'), ('Lettenstrasse'), ('Letzibach'), ('Letzigrund'), ('Letzipark'), ('Letzipark West'), ('Letzistrasse'), ('Leutschenbach'), ('Leutschenpark'), ('Limmatplatz'), ('Lindenplatz'), ('Lochergut'), ('Loogarten'), ('Loorenstrasse'), ('Löwenbräu'), ('Löwenplatz'), ('Luchswiesen'), ('Luegisland'), ('Maienweg'), ('Maillartstrasse'), ('Manegg'), ('Manesseplatz'), ('Marbachweg'), ('Mattenhof'), ('Max-Bill-Platz'), ('Meierhofplatz'), ('Messe/Hallenstadion'), ('Micafil'), ('Michelstrasse'), ('Milchbuck'), ('Militär-/Langstrasse'), ('Mittelleimbach'), ('Morgental'), ('Mötteliweg'), ('Mühlacker'), ('Museum für Gestaltung'), ('Museum Rietberg'), ('Neeserweg'), ('Neuaffoltern'), ('Neubühl'), ('Neumarkt'), ('Neunbrunnen'), ('Nordheimstrasse'), ('Nordstrasse'), ('Nürenbergstrasse'), ('Obere Hornhalde'), ('Oberwiesenstrasse'), ('Oerlikerhus'), ('Okenstrasse'), ('Opernhaus'), ('Orionstrasse'), ('Ottikerstrasse'), ('Paradeplatz'), ('Pflegezentr. Käferberg'), ('Platte'), ('Polyterrasse ETH'), ('Probstei'), ('Quellenstrasse'), ('Räffelstrasse'), ('Rathaus'), ('Rautihalde'), ('Rautistrasse'), ('Rebbergsteig'), ('Regensbergbrücke'), ('Rehalp'), ('Renggerstrasse'), ('Rennweg'), ('Rentenanstalt'), ('Riedbach'), ('Riedgraben'), ('Riedhofstrasse'), ('Rigiblick'), ('Römerhof'), ('Röntgenstrasse'), ('Rosengartenstrasse'), ('Röslistrasse'), ('Roswiesen'), ('Rotbuchstrasse'), ('Rote Fabrik'), ('Rudolf-Brun-Brücke'), ('Rütihof'), ('Saalsporthalle'), ('Saatlenstrasse'), ('Sackzelg'), ('Sädlenweg'), ('Salersteig'), ('Salzweg'), ('SBB-Werkstätte'), ('Schaffhauserplatz'), ('Schanzackerstrasse'), ('Schäppiweg'), ('Schauenberg'), ('Schaufelbergerstrasse'), ('Scheuchzerstrasse'), ('Schiffbau'), ('Schlyfi'), ('Schmiede Wiedikon'), ('Schönauring'), ('Schulhaus Altweg'), ('Schulhaus Buchlern'), ('Schumacherweg'), ('Schürgistrasse'), ('Schützenhaus Höngg'), ('Schwamendingerplatz'), ('Schwandenholz'), ('Schweighof'), ('Schweizer Rück'), ('Schwert'), ('Seebach'), ('Seebacherplatz'), ('Seerose'), ('Segantinistrasse'), ('Segeten'), ('Seidelhof'), ('Seilbahn Rigiblick'), ('Siemens'), ('Signaustrasse'), ('Sihlcity'), ('Sihlcity Nord'), ('Sihlpost / HB'), ('Sihlquai/HB'), ('Sihlstrasse'), ('Sihlweidstrasse'), ('Singlistrasse'), ('Solidapark'), ('Sonneggstrasse'), ('Sportweg'), ('Sprecherstrasse'), ('Spyriplatz'), ('Spyristeig'), ('Stadtgrenze'), ('Stampfenbachplatz'), ('Staudenbühl'), ('Stauffacher'), ('Sternen Oerlikon'), ('Stettbach'), ('Stierenried'), ('Stockerstrasse'), ('Stodolastrasse'), ('Strassenverkehrsamt'), ('Strickhof'), ('Sukkulentensammlung'), ('Susenbergstrasse'), ('Talwiesenstrasse'), ('Technopark'), ('Thujastrasse'), ('Tierspital'), ('Titlisstrasse'), ('Tobelhof'), ('Toblerplatz'), ('Toni-Areal'), ('Trichtenhausenfussweg'), ('Trichtisal'), ('Triemli'), ('Triemlispital'), ('Tüffenwies'), ('Tulpenstrasse'), ('Tunnelstrasse'), ('Ueberlandpark'), ('Uetlihof'), ('Universität Irchel'), ('Unteraffoltern'), ('Untermoosstrasse'), ('Verenastrasse'), ('Vogelsangstrasse'), ('Voltastrasse'), ('Vulkanstrasse'), ('Waffenplatz-/Bederstr.'), ('Waffenplatzstrasse'), ('Waidbadstrasse'), ('Waidfussweg'), ('Waidhof'), ('Waidspital'), ('Waldgarten'), ('Waldhaus Dolder'), ('Wartau'), ('Waserstrasse'), ('Weihersteig'), ('Werd'), ('Werdhölzli'), ('Wetlistrasse'), ('Widmerstrasse'), ('Wieslergasse'), ('Wiesliacher'), ('Wildbachstrasse'), ('Winkelriedstrasse'), ('Winzerhalde'), ('Winzerstrasse'), ('Winzerstrasse Süd'), ('Wipkingerplatz'), ('Wollishoferplatz'), ('Wonnebergstrasse'), ('Würzgraben'), ('Zch, Bhf.Wollishofen/Staubstr.'), ('Zehntenhausplatz'), ('Zentrum Witikon'), ('Zielweg'), ('Zoo'), ('Zoo/Forrenweid'), ('Zürich Affoltern'), ('Zürich Altstetten'), ('Zürich Bellevue (See)'), ('Zürich Binz'), ('Zürich Brunau'), ('Zürich Bürkliplatz (See)'), ('Zürich Enge'), ('Zürich Enge (See)'), ('Zürich Friesenberg'), ('Zürich Giesshübel'), ('Zürich Hardbrücke'), ('Zürich HB'), ('Zürich HB Museum'), ('Zürich HB Sihlpost'), ('Zürich HB SZU'), ('Zürich Landesmuseum (See)'), ('Zürich Leimbach'), ('Zürich Limmatquai'), ('Zürich Manegg'), ('Zürich Oerlikon'), ('Zürich Saalsporthalle'), ('Zürich Schweighof'), ('Zürich Seebach'), ('Zürich Selnau'), ('Zürich Stadelhofen'), ('Zürich Storchen'), ('Zürich Tiefenbrunnen'), ('Zürich Tiefenbrunnen (See)'), ('Zürich Triemli'), ('Zürich Wiedikon'), ('Zürich Wipkingen'), ('Zürich Wollishofen'), ('Zürich Wollishofen (See)'), ('Zürichbergstrasse'), ('Zürichhorn (See)'), ('Zweiackerstrasse'), ('Zwielplatz'), ('Zwinglihaus'), ('Zypressenstrasse');

