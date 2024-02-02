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


INSERT INTO public.stations (name, value, x, y) VALUES ('Affoltern, Bhf.', 2000, 443, 216);
INSERT INTO public.stations (name, value, x, y) VALUES ('Albisgütli', 2000, 224, 1159);
INSERT INTO public.stations (name, value, x, y) VALUES ('Albisrieden', 1000, 101, 831);
INSERT INTO public.stations (name, value, x, y) VALUES ('Albisriederplatz', 2000, 296, 769);
INSERT INTO public.stations (name, value, x, y) VALUES ('Altstetten, Bhf.', 1500, 237, 608);
INSERT INTO public.stations (name, value, x, y) VALUES ('Auzelg', 1500, 918, 296);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bad Allenmoos', 1000, 614, 439);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bahnhofplatz / HB', 7000, 523, 805);
INSERT INTO public.stations (name, value, x, y) VALUES ('Balgrist', 1000, 917, 1065);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bellevue', 7000, 630, 955);
INSERT INTO public.stations (name, value, x, y) VALUES ('Besenrainstrasse', 1000, 404, 1193);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bethanien', 1500, 805, 718);
INSERT INTO public.stations (name, value, x, y) VALUES ('Brunau', 1000, 381, 1134);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bucheggplatz', 3000, 526, 521);
INSERT INTO public.stations (name, value, x, y) VALUES ('Bürkliplatz', 7000, 580, 970);
INSERT INTO public.stations (name, value, x, y) VALUES ('Central', 6000, 604, 795);
INSERT INTO public.stations (name, value, x, y) VALUES ('Elektrowatt', 1500, 707, 1092);
INSERT INTO public.stations (name, value, x, y) VALUES ('Enge, Bhf.', 2000, 485, 1004);
INSERT INTO public.stations (name, value, x, y) VALUES ('Escher-Wyss-Platz', 2000, 407, 634);
INSERT INTO public.stations (name, value, x, y) VALUES ('ETH / Universitätsspital', 4000, 729, 778);
INSERT INTO public.stations (name, value, x, y) VALUES ('ETH Hönggerberg', 2000, 439, 379);
INSERT INTO public.stations (name, value, x, y) VALUES ('Farbhof', 1000, 128, 591);
INSERT INTO public.stations (name, value, x, y) VALUES ('Feldeggstrasse', 1500, 722, 1052);
INSERT INTO public.stations (name, value, x, y) VALUES ('Frankental', 1000, 271, 392);
INSERT INTO public.stations (name, value, x, y) VALUES ('Goldbrunnenplatz', 3000, 302, 909);
INSERT INTO public.stations (name, value, x, y) VALUES ('Hardplatz', 1000, 358, 704);
INSERT INTO public.stations (name, value, x, y) VALUES ('Hardturm', 1000, 353, 572);
INSERT INTO public.stations (name, value, x, y) VALUES ('Hegianwandweg', 1200, 217, 1099);
INSERT INTO public.stations (name, value, x, y) VALUES ('Hegibachplatz', 1500, 787, 1017);
INSERT INTO public.stations (name, value, x, y) VALUES ('Heuried', 1500, 237, 892);
INSERT INTO public.stations (name, value, x, y) VALUES ('Hirzenbach', 1000, 960, 450);
INSERT INTO public.stations (name, value, x, y) VALUES ('Im Walder', 1500, 862, 1136);
INSERT INTO public.stations (name, value, x, y) VALUES ('Juchhof', 2000, 185, 467);
INSERT INTO public.stations (name, value, x, y) VALUES ('Kappeli', 1000, 198, 693);
INSERT INTO public.stations (name, value, x, y) VALUES ('Käshaldenstrasse', 1500, 668, 110);
INSERT INTO public.stations (name, value, x, y) VALUES ('Kirche Fluntern', 1000, 798, 796);
INSERT INTO public.stations (name, value, x, y) VALUES ('Klusplatz', 3000, 858, 931);
INSERT INTO public.stations (name, value, x, y) VALUES ('Kronenstrasse', 2000, 622, 649);
INSERT INTO public.stations (name, value, x, y) VALUES ('Limmatplatz', 2000, 494, 689);
INSERT INTO public.stations (name, value, x, y) VALUES ('Lochergut', 1000, 241, 710);
INSERT INTO public.stations (name, value, x, y) VALUES ('Löwenplatz', 5000, 373, 706);
INSERT INTO public.stations (name, value, x, y) VALUES ('Luegisland', 1000, 700, 414);
INSERT INTO public.stations (name, value, x, y) VALUES ('Manegg', 3000, 215, 1029);
INSERT INTO public.stations (name, value, x, y) VALUES ('Meierhofplatz', 1000, 397, 453);
INSERT INTO public.stations (name, value, x, y) VALUES ('Messe / Hallenstadion', 2000, 754, 375);
INSERT INTO public.stations (name, value, x, y) VALUES ('Milchbuck', 2000, 619, 536);
INSERT INTO public.stations (name, value, x, y) VALUES ('Mötteliweg', 2000, 555, 257);
INSERT INTO public.stations (name, value, x, y) VALUES ('Oerlikon, Bhf.', 3000, 681, 350);
INSERT INTO public.stations (name, value, x, y) VALUES ('Paradeplatz', 7000, 551, 913);
INSERT INTO public.stations (name, value, x, y) VALUES ('Polyterasse', 3000, 698, 801);
INSERT INTO public.stations (name, value, x, y) VALUES ('Probstei', 1000, 945, 485);
INSERT INTO public.stations (name, value, x, y) VALUES ('Rathaus', 1000, 617, 884);
INSERT INTO public.stations (name, value, x, y) VALUES ('Rehalp', 2000, 959, 1114);
INSERT INTO public.stations (name, value, x, y) VALUES ('Riedhofstrasse', 1500, 255, 342);
INSERT INTO public.stations (name, value, x, y) VALUES ('Rigiblick', 1500, 816, 607);
INSERT INTO public.stations (name, value, x, y) VALUES ('Römerhof', 2000, 802, 887);
INSERT INTO public.stations (name, value, x, y) VALUES ('Sackzelg', 1000, 159, 829);
INSERT INTO public.stations (name, value, x, y) VALUES ('Schaffhauserplatz', 3000, 608, 593);
INSERT INTO public.stations (name, value, x, y) VALUES ('Schauenberg', 1500, 419, 281);
INSERT INTO public.stations (name, value, x, y) VALUES ('Schlyfi', 1500, 895, 950);
INSERT INTO public.stations (name, value, x, y) VALUES ('Schwamendingerplatz', 1000, 881, 426);
INSERT INTO public.stations (name, value, x, y) VALUES ('Seebach', 1000, 770, 186);
INSERT INTO public.stations (name, value, x, y) VALUES ('Seilbahn Rigiblick', 2000, 741, 652);
INSERT INTO public.stations (name, value, x, y) VALUES ('Selnau SZU, Bhf.', 2000, 457, 897);
INSERT INTO public.stations (name, value, x, y) VALUES ('Sonneggstrasse', 2000, 676, 685);
INSERT INTO public.stations (name, value, x, y) VALUES ('Stauffacher', 4000, 436, 836);
INSERT INTO public.stations (name, value, x, y) VALUES ('Sternen Oerlikon', 3000, 717, 368);
INSERT INTO public.stations (name, value, x, y) VALUES ('Stettbach, Bhf.', 1000, 982, 540);
INSERT INTO public.stations (name, value, x, y) VALUES ('Stockerstrasse', 3000, 501, 931);
INSERT INTO public.stations (name, value, x, y) VALUES ('Tiefenbrunnen, Bhf.', 2000, 800, 1164);
INSERT INTO public.stations (name, value, x, y) VALUES ('Toblerplatz', 1000, 832, 759);
INSERT INTO public.stations (name, value, x, y) VALUES ('Toni-Areal', 1500, 330, 635);
INSERT INTO public.stations (name, value, x, y) VALUES ('Friedhof Witikon', 2000, 1023, 933);
INSERT INTO public.stations (name, value, x, y) VALUES ('Triemli', 1000, 162, 966);
INSERT INTO public.stations (name, value, x, y) VALUES ('Tüffenwies', 1000, 317, 537);
INSERT INTO public.stations (name, value, x, y) VALUES ('Ueberlandpark', 1000, 837, 433);
INSERT INTO public.stations (name, value, x, y) VALUES ('Universität Irchel', 3000, 688, 548);
INSERT INTO public.stations (name, value, x, y) VALUES ('Waffenplatzstrasse', 2000, 420, 997);
INSERT INTO public.stations (name, value, x, y) VALUES ('Werdhölzli', 1000, 213, 482);
INSERT INTO public.stations (name, value, x, y) VALUES ('Wiedikon, Bhf.', 3000, 408, 889);
INSERT INTO public.stations (name, value, x, y) VALUES ('Wollishofen, Bhf./Staubstr.', 1500, 493, 1165);
INSERT INTO public.stations (name, value, x, y) VALUES ('Wollishoferplatz', 1000, 389, 1264);
INSERT INTO public.stations (name, value, x, y) VALUES ('Zentrum Witikon', 1500, 963, 934);
INSERT INTO public.stations (name, value, x, y) VALUES ('Zoo', 2000, 929, 695);


INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Albisgütli', 750, 225, 1158, 'Machäd äs Fotti wo alli dä Bodä nümä berüähräd.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Alte Trotte', 750, 415, 503, 'Stönd vor dä Station und posiäräd uf äm Fotti wiä alti Lüüt.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Auzelg Ost', 3000, 926, 317, 'Suächäd ä Münzä mit äm gliichä Jahrgang wiä öppär vo oi und machäd äs Fotti vor dä Station.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Binz Center', 1000, 288, 1045, 'Filmäd än churzä Wättärbricht a dä Station.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Bleulerstrasse', 3000, 855, 1143, 'Zäigäd uf äm Fotti äs Papierschiffli wo im Brunnä uf dä andere Strassäsiitä schwümmt.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Buchzelgstrasse', 1750, 956, 895, 'Machäd die längscht möglich Polonaise mit mindästäns 5 fremdä Personä und filmäds.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Dolder Bergstation', 3000, 920, 835, 'Stönd Spalier (Tunnel mit de Ärm) für 5 fremdi Personä und filmä.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Gutstrasse', 750, 260, 846, 'Machäd alli ä Yoga-Posä uf äm Fotti.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Helmhaus', 750, 618, 911, 'Machäd zämä en grossä gordischä Chnopf und föttäläds.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Herbstweg', 1000, 832, 396, 'Versteckäd oi "gaaanz unuffällig" hindär dä Bäum und machäd äs Föttäli wiä mär oi "fast nöd" entdeckt.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Im Hagacker', 1000, 204, 1062, 'Machäd en Hochziitsatrag und föttäläds.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Im Klösterli', 1000, 958, 661, 'Machäd mit äm Füürhydrant äs Föttäli.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Juchhof', 1000, 186, 467, 'Schriibäd s Wort Juchhof mit mänschlichä Buächstabä und föttäläds.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Kienastenwies', 1000, 1031, 1012, 'Machäd ä mänschlichi Pyramidä und föttäläds.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Löwenbräu', 1500, 451, 653, 'Stelläd uf ämä Fotti vor äm Stationsschild än Loi naa.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Maillartstrasse', 1500, 601, 250, 'Gönd ufd Brugg näbe dä Haltestell und posiäräd deet druf i oiärä coolstä Posä.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Manesseplatz', 750, 348, 970, 'Machäd äs Fotti mit ärä brülläträgändä Person.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Micafil', 1000, 102, 558, 'Machäd 3 verschiedäni Kunststückli und tüänd die föttälä oder filmä.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Mittelleimbach', 2750, 233, 1372, 'Machäd äs Fotti mit ämä Busfahrär oder öppäräm im Bus (BITTE um Erlaubnis frägä).', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Neubühl', 1750, 448, 1299, 'Findäd ä fremdi Person mit mindästäns Schuägrössi 42.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Okenstrasse', 750, 517, 640, 'Föttäläd än Uswiis mit äm Jahrgang 2005.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Rütihof', 1500, 245, 275, 'Posäd ufämä Föttäli mit dä Schachfigurä wo uf äm Platz vor äm Coop stönd.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('SBB-Werkstätte', 290, 678, 1500, 'Versuächäd ä Person zum singä z bringä und filmäds.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Siemens', 1000, 168, 772, 'Machäd äs professionells Fotti mit äm Siemens-Logo.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Sportweg', 750, 322, 627, 'Machäd äs Fotti mit 3 Lüüt wo zämä 50 Jahr alt sind (oder so näch wiä möglich).', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Stadtgrenze', 1000, 543, 1268, 'Laufäd us Züri usä und machäd äs Fotti mit äm Ortsschild.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Strickhof', 500, 724, 542, 'Schickäd än guätä Flachwitz ad Zentralä.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Sunnau', 2000, 361, 1371, 'Trojanischs Pferd: Uf äm Fotti sind 4 Bei, 5 Ärm und 2 Chöpf.', 500);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Trichtisal', 1500, 1022, 1045, 'Spieläd alli dä James Bond und "spioniäräd, und föttäläd das.', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Waidhof', 2500, 543, 160, 'Erfindäd ä churzi Fotolovestory und föttäläd sie (chasch au mee Fottis no im Chat naaschickä).', NULL);
INSERT INTO public.jokers (name, value, x, y, challenge, bonus_call_value) VALUES ('Zoo/Forrenweid', 2000, 994, 734, 'Bringäd dä Krawattächnopf ärä fremdä Person bii und föttäläds.', 500);


INSERT INTO public.mr_t_locations (name) VALUES ('Aargauerstrasse'), ('Albisgütli'), ('Albisrank'), ('Albisrieden'), ('Albisriederdörfli'), ('Albisriederplatz'), ('Alte Trotte'), ('Altenhofstrasse'), ('Altes Krematorium'), ('Althoos'), ('Altried'), ('Am Börtli'), ('Am Suteracher'), ('Appenzellerstrasse'), ('Arnikahof'), ('Aspholz'), ('Aubrücke'), ('Ausserdorfstrasse'), ('Auzelg'), ('Auzelg Ost'), ('Bachmattstrasse'), ('Bäckeranlage'), ('Bad Allenmoos'), ('Bahnhof Affoltern'), ('Bahnhof Altstetten'), ('Bahnhof Altstetten N'), ('Bahnhof Enge'), ('Bahnhof Enge/Bederstr.'), ('Bahnhof Hardbrücke'), ('Bahnhof Leimbach'), ('Bahnhof Oerlikon'), ('Bahnhof Oerlikon Nord'), ('Bahnhof Oerlikon Ost'), ('Bahnhof Selnau'), ('Bahnhof Stadelhofen'), ('Bahnhof Stettbach'), ('Bahnhof Tiefenbrunnen'), ('Bahnhof Wiedikon'), ('Bahnhof Wipkingen'), ('Bahnhof Wollishofen'), ('Bahnhofplatz/HB'), ('Bahnhofquai/HB'), ('Bahnhofstrasse/HB'), ('Balgrist'), ('Balgrist Ost'), ('Bändliweg'), ('Baslerstrasse'), ('Beckenhof'), ('Bellevue'), ('Berghaldenstrasse'), ('Bergstation Dolderbahn'), ('Berninaplatz'), ('Bernoulli-Häuser'), ('Bertastrasse'), ('Berufswahlschule'), ('Besenrainstrasse'), ('Besenrainweg'), ('Bethanien'), ('Bezirksgebäude'), ('Bhf Enge Pausenplatz'), ('Bhf. Wollishofen/Werft'), ('Billoweg'), ('Binz'), ('Binz Center'), ('Birch-/Glatttalstrasse'), ('Birchdörfli'), ('Bircher-Benner'), ('Birchstrasse'), ('Bleulerstrasse'), ('Blumenfeldstrasse'), ('Bollingerweg'), ('Botanischer Garten'), ('Bristenstrasse'), ('Brunau/Mutschellenstr.'), ('Brunaustrasse'), ('Brunnenhof'), ('Bucheggplatz'), ('Buchholz'), ('Buchzelgstrasse'), ('Buhnstrasse'), ('Burgwies'), ('Bürkliplatz'), ('Butzenstrasse'), ('Central'), ('Central Polybahn'), ('Chaletweg'), ('Chinagarten'), ('Dangelstrasse'), ('Dorflinde'), ('Dreispitz'), ('Dreiwiesen'), ('Drusbergstrasse'), ('Dunkelhölzli'), ('Einfangstrasse'), ('Elektrowatt'), ('Englischviertelstrasse'), ('EPI-Klinik'), ('Escher-Wyss-Platz'), ('Eschergutweg'), ('ETH Hönggerberg'), ('ETH/Universitätsspital'), ('Ettenfeld'), ('Farbhof'), ('Feldeggstrasse'), ('Fellenbergstrasse'), ('Felsenrainstrasse'), ('Fernsehstudio'), ('Feusisbergli'), ('Fischerweg'), ('Flobotstrasse'), ('Flühgasse'), ('Flurstrasse'), ('Förrlibuckstrasse'), ('Frankental'), ('Freiestrasse'), ('Freihofstrasse'), ('Friedackerstrasse'), ('Friedhof Eichbühl'), ('Friedhof Enzenbühl'), ('Friedhof Hönggerberg'), ('Friedhof Schwandenholz'), ('Friedhof Sihlfeld'), ('Friedhof Uetliberg'), ('Friedhof Witikon'), ('Friedrichstrasse'), ('Friesenberg'), ('Friesenberghalde'), ('Friesenbergstrasse'), ('Frohburg'), ('Fröhlichstrasse'), ('Fronwald'), ('Frymannstrasse'), ('Geeringstrasse'), ('Genossenschaftsstrasse'), ('Germaniastrasse'), ('Giblenstrasse'), ('Glattwiesen'), ('Glaubtenstrasse'), ('Glaubtenstrasse Nord'), ('Glaubtenstrasse Süd'), ('Glockenacker'), ('Goldackerweg'), ('Goldauerstrasse'), ('Goldbrunnenplatz'), ('Grimselstrasse'), ('Grubenstrasse'), ('Grünaustrasse'), ('Grünwald'), ('Guggachstrasse'), ('Güterbahnhof'), ('Gutstrasse'), ('Hadlaubstrasse'), ('Hagenholz'), ('Haldenbach'), ('Haldenegg'), ('Hallenbad Oerlikon'), ('Hardhof'), ('Hardplatz'), ('Hardturm'), ('Hedwigsteig'), ('Heerenwiesen'), ('Hegianwandweg'), ('Hegibachplatz'), ('Heizenholz'), ('Helmhaus'), ('Helvetiaplatz'), ('Herbstweg'), ('Herdernstrasse'), ('Hermetschloo'), ('Hertensteinstrasse'), ('Hertersteg'), ('Herzogenmühlestrasse'), ('Heubeeriweg'), ('Heuried'), ('Himmeri'), ('Hinterbergstrasse'), ('Hirschwiesenstrasse'), ('Hirzenbach'), ('Höfliweg'), ('Hofstrasse'), ('Hohenklingensteig'), ('Hölderlinsteig'), ('Hölderlinstrasse'), ('Holzerhurd'), ('Hönggerberg'), ('Höschgasse'), ('Hottingerplatz'), ('Hubertus'), ('Hügelstrasse'), ('Hungerbergstrasse'), ('Hürstholz'), ('Im Ebnet'), ('Im Gut'), ('Im Hagacker'), ('Im Hüsli'), ('Im Klösterli'), ('Im Walder'), ('Im Wingert'), ('In der Ey'), ('Juchhof'), ('Jugendherberge'), ('Kalchbühlweg'), ('Kalkbreite/Bhf.Wiedikon'), ('Kanonengasse'), ('Kantonalbank'), ('Kantonsschule'), ('Kantonsschule Enge'), ('Kapfstrasse'), ('Kappeli'), ('Kappenbühlweg'), ('Käshaldenstrasse'), ('Kempfhofsteig'), ('Kernstrasse'), ('Kienastenwies'), ('Kindersp. (ab 10/2024)'), ('Kinkelstrasse'), ('Kirche Fluntern'), ('Klinik Hirslanden'), ('Klosbach'), ('Klusplatz'), ('Köschenrüti'), ('Krematorium Nordheim'), ('Kreuzplatz'), ('Kreuzstrasse'), ('Kronenstrasse'), ('Krönleinstrasse'), ('Kunsthaus'), ('Lägernstrasse'), ('Landiwiese'), ('Langensteinenstrasse'), ('Langgrütstrasse'), ('Langmauerstrasse'), ('Laubegg'), ('Laubiweg'), ('Lehenstrasse'), ('Leimgrübelstrasse'), ('Lerchenhalde'), ('Lerchenrain'), ('Lettenstrasse'), ('Letzibach'), ('Letzigrund'), ('Letzipark'), ('Letzipark West'), ('Letzistrasse'), ('Leutschenbach'), ('Leutschenpark'), ('Limmatplatz'), ('Lindenplatz'), ('Lochergut'), ('Loogarten'), ('Loorenstrasse'), ('Löwenbräu'), ('Löwenplatz'), ('Luchswiesen'), ('Luegisland'), ('Maienweg'), ('Maillartstrasse'), ('Manegg'), ('Manesseplatz'), ('Marbachweg'), ('Mattenhof'), ('Max-Bill-Platz'), ('Meierhofplatz'), ('Messe/Hallenstadion'), ('Micafil'), ('Michelstrasse'), ('Milchbuck'), ('Militär-/Langstrasse'), ('Mittelleimbach'), ('Morgental'), ('Mötteliweg'), ('Mühlacker'), ('Museum für Gestaltung'), ('Museum Rietberg'), ('Neeserweg'), ('Neuaffoltern'), ('Neubühl'), ('Neumarkt'), ('Neunbrunnen'), ('Nordheimstrasse'), ('Nordstrasse'), ('Nürenbergstrasse'), ('Obere Hornhalde'), ('Oberwiesenstrasse'), ('Oerlikerhus'), ('Okenstrasse'), ('Opernhaus'), ('Orionstrasse'), ('Ottikerstrasse'), ('Paradeplatz'), ('Pflegezentr. Käferberg'), ('Platte'), ('Polyterrasse ETH'), ('Probstei'), ('Quellenstrasse'), ('Räffelstrasse'), ('Rathaus'), ('Rautihalde'), ('Rautistrasse'), ('Rebbergsteig'), ('Regensbergbrücke'), ('Rehalp'), ('Renggerstrasse'), ('Rennweg'), ('Rentenanstalt'), ('Riedbach'), ('Riedgraben'), ('Riedhofstrasse'), ('Rigiblick'), ('Römerhof'), ('Röntgenstrasse'), ('Rosengartenstrasse'), ('Röslistrasse'), ('Roswiesen'), ('Rotbuchstrasse'), ('Rote Fabrik'), ('Rudolf-Brun-Brücke'), ('Rütihof'), ('Saalsporthalle'), ('Saatlenstrasse'), ('Sackzelg'), ('Sädlenweg'), ('Salersteig'), ('Salzweg'), ('SBB-Werkstätte'), ('Schaffhauserplatz'), ('Schanzackerstrasse'), ('Schäppiweg'), ('Schauenberg'), ('Schaufelbergerstrasse'), ('Scheuchzerstrasse'), ('Schiffbau'), ('Schlyfi'), ('Schmiede Wiedikon'), ('Schönauring'), ('Schulhaus Altweg'), ('Schulhaus Buchlern'), ('Schumacherweg'), ('Schürgistrasse'), ('Schützenhaus Höngg'), ('Schwamendingerplatz'), ('Schwandenholz'), ('Schweighof'), ('Schweizer Rück'), ('Schwert'), ('Seebach'), ('Seebacherplatz'), ('Seerose'), ('Segantinistrasse'), ('Segeten'), ('Seidelhof'), ('Seilbahn Rigiblick'), ('Siemens'), ('Signaustrasse'), ('Sihlcity'), ('Sihlcity Nord'), ('Sihlpost / HB'), ('Sihlquai/HB'), ('Sihlstrasse'), ('Sihlweidstrasse'), ('Singlistrasse'), ('Solidapark'), ('Sonneggstrasse'), ('Sportweg'), ('Sprecherstrasse'), ('Spyriplatz'), ('Spyristeig'), ('Stadtgrenze'), ('Stampfenbachplatz'), ('Staudenbühl'), ('Stauffacher'), ('Sternen Oerlikon'), ('Stettbach'), ('Stierenried'), ('Stockerstrasse'), ('Stodolastrasse'), ('Strassenverkehrsamt'), ('Strickhof'), ('Sukkulentensammlung'), ('Susenbergstrasse'), ('Talwiesenstrasse'), ('Technopark'), ('Thujastrasse'), ('Tierspital'), ('Titlisstrasse'), ('Tobelhof'), ('Toblerplatz'), ('Toni-Areal'), ('Trichtenhausenfussweg'), ('Trichtisal'), ('Triemli'), ('Triemlispital'), ('Tüffenwies'), ('Tulpenstrasse'), ('Tunnelstrasse'), ('Ueberlandpark'), ('Uetlihof'), ('Universität Irchel'), ('Unteraffoltern'), ('Untermoosstrasse'), ('Verenastrasse'), ('Vogelsangstrasse'), ('Voltastrasse'), ('Vulkanstrasse'), ('Waffenplatz-/Bederstr.'), ('Waffenplatzstrasse'), ('Waidbadstrasse'), ('Waidfussweg'), ('Waidhof'), ('Waidspital'), ('Waldgarten'), ('Waldhaus Dolder'), ('Wartau'), ('Waserstrasse'), ('Weihersteig'), ('Werd'), ('Werdhölzli'), ('Wetlistrasse'), ('Widmerstrasse'), ('Wieslergasse'), ('Wiesliacher'), ('Wildbachstrasse'), ('Winkelriedstrasse'), ('Winzerhalde'), ('Winzerstrasse'), ('Winzerstrasse Süd'), ('Wipkingerplatz'), ('Wollishoferplatz'), ('Wonnebergstrasse'), ('Würzgraben'), ('Zch, Bhf.Wollishofen/Staubstr.'), ('Zehntenhausplatz'), ('Zentrum Witikon'), ('Zielweg'), ('Zoo'), ('Zoo/Forrenweid'), ('Zürich Affoltern'), ('Zürich Altstetten'), ('Zürich Bellevue (See)'), ('Zürich Binz'), ('Zürich Brunau'), ('Zürich Bürkliplatz (See)'), ('Zürich Enge'), ('Zürich Enge (See)'), ('Zürich Friesenberg'), ('Zürich Giesshübel'), ('Zürich Hardbrücke'), ('Zürich HB'), ('Zürich HB Museum'), ('Zürich HB Sihlpost'), ('Zürich HB SZU'), ('Zürich Landesmuseum (See)'), ('Zürich Leimbach'), ('Zürich Limmatquai'), ('Zürich Manegg'), ('Zürich Oerlikon'), ('Zürich Saalsporthalle'), ('Zürich Schweighof'), ('Zürich Seebach'), ('Zürich Selnau'), ('Zürich Stadelhofen'), ('Zürich Storchen'), ('Zürich Tiefenbrunnen'), ('Zürich Tiefenbrunnen (See)'), ('Zürich Triemli'), ('Zürich Wiedikon'), ('Zürich Wipkingen'), ('Zürich Wollishofen'), ('Zürich Wollishofen (See)'), ('Zürichbergstrasse'), ('Zürichhorn (See)'), ('Zweiackerstrasse'), ('Zwielplatz'), ('Zwinglihaus'), ('Zypressenstrasse');

