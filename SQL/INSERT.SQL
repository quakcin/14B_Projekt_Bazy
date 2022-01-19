--Specjalizacje
INSERT INTO Specjalizacje (Nazwa_Specjalizacji,Opis) VALUES ('Kardiolog', 'Lekarz medycyny zajmujący się chorobami serca i układu krążenia.');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Dentysta', 'Lekarz medycyny zajmujący sie chorobami zębów i jamy ustnej');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Okulista', 'Lekarz medycyny zajmujący sie badaniem i leczeniem narządu wzroku oraz korygowaniem jego wad');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Neurolog', 'Lekarz medycyny zajmujący sie zajmujący sie chorobami obwodowego oraz ośrodkowego układu nerwowego');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Urolog', 'Lekarz medycyny zajmujący sie chorobami układu moczowego u mężczyzn, kobiet, a także dzieci');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Psychiatra', 'Lekarz medycyny zajmujący sie diagnozowaniem oraz leczeniem chorób i zaburzę psychicznych');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Pediatra', 'Lekarz medycyny zajmujący sie chorobami dziecięcymi');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Dermatolog', 'Lekarz medycyny zajmujący sie  leczeniem, diagnozowaniem i profilaktyka chorób skóry, włosów i paznokci');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Ginekolog', 'Lekarz medycyny zajmujący sie  profilaktyka i leczeniem chorób żeńskiego układu płciowego');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Alergolog', 'Lekarz medycyny zajmujący sie chorobami wywoływanymi przez alergeny');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Reumatolog', 'Lekarz medycyny zajmujący sie rożnego typu schorzeniami powiązanymi ze stanami zwyrodnieniowymi i zapalnymi tkanki łącznej, kości i stawów');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Hematolog', 'Lekarz medycyny zajmujący sie chorobami krwi i układu krwiotwórczego');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('Lekarz Rodzinny', 'Lekarz medycyny zajmujący sie diagnozowaniem i leczeniem chorób, które występują najczęściej według statystyk, ale nie wymagają konsultacji specjalistycznych');


--Konto ADMINA
INSERT INTO Adresy  VALUES(1, 'Kielce', 'Al. Tysiąclecia Państwa Polskiego', '1', 'D', '25-001');
INSERT INTO Kontakty VALUES (1, NULL, NULL);
INSERT INTO Osoby   VALUES(1, 'Bandura', 'Maciek', TO_DATE('2000-05-16', 'YYYY-MM-DD'), '00000000000', 1, 1);
INSERT INTO Konta   VALUES(1, 'admin', 'qwerty', 'admin', 1);

--Pacjenci
INSERT INTO Pacjenci_view VALUES ('Pac1', 'Dudek', 'Adam', 'Kowalski', sysdate-1000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'kowal@wp.pl', 'Kielce', 'Sandomierska', '74', '10', '25-987', NULL);
INSERT INTO Pacjenci_view VALUES ('Pac2', 'Andrzejek','Andrzej', 'Niewulis', sysdate-1200, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'andrzejek@onet.pl', 'Częstochowa', 'Limanowskiego', '12', NULL, '71-411', NULL);
INSERT INTO Pacjenci_view VALUES ('Pac3', 'luki','Łukasz', 'Źródłowski', sysdate-2500, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'luki2121@wp.pl', 'Kielce', 'Bohaterów Warszawy', '14', '5', '25-200', NULL);
INSERT INTO Pacjenci_view VALUES ('Pac4', 'Firanka','Tomasz', 'Nowakowski', sysdate-2800, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'nowak1452@wp.pl', 'Radom', 'Warszawska', '141', NULL, '85-285', NULL);

--Lekarze
INSERT INTO Lekarze_view VALUES ('Lek1', 'lek1', 'Grzegorz', 'Nowak', sysdate-7000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorNowak@wp.pl', 'Kielce', 'Karczówkowska', '63', NULL, '25-987', 'Kardiolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek2', 'lek2', 'Tomasz', 'Maciaszczyk', sysdate-6500, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorMaciaszczyk@wp.pl', 'Warszawa', 'Skrajna', '63', NULL, '22-287', 'Dentysta', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek3', 'lek3', 'Jacek', 'Stopa', sysdate-8000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorStopa@wp.pl', 'Krakow', 'Duza', '63', NULL, '21-587', 'Kardiolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek4', 'lek4', 'Anna', 'Nowak', sysdate-6000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorANowak@wp.pl', 'Kielce', 'Karczówkowska', '63', NULL, '25-987', 'Dentysta', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek5', 'lek5', 'Adam', 'Witkowski', sysdate-16000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorAWitkowski@wp.pl', 'Kielce', 'Skrajna', '23', NULL, '25-987', 'Okulista', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek6', 'lek6', 'Piotr', 'Woźniak', sysdate-15000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorPWozniak@wp.pl', 'Kielce', 'Sienkiewicza', '41', NULL, '25-987', 'Neurolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek7', 'lek7', 'Agata', 'Dąbrowska', sysdate-14000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorADabrowska@wp.pl', 'Kielce', 'Warszawska', '55', NULL, '25-987', 'Urolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek8', 'lek8', 'Maksymilian', 'Kalinowski', sysdate-9000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorMKalinowski@wp.pl', 'Kielce', 'Jagielonska', '60', NULL, '25-987', 'Psychiatra', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek9', 'lek9', 'Artur', 'Sadowski', sysdate-12000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorSadowski@wp.pl', 'Kielce', 'Lecha', '27', NULL, '25-987', 'Pediatra', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek10', 'lek10', 'Beata', 'Mazurek', sysdate-12500, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorMazurek@wp.pl', 'Nowa Słupia', 'Świetokrzyska', '33', NULL, '25-577', 'Pediatra', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek11', 'lek11', 'Marta', 'Pietrzak', sysdate-8300, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktoPietrzak@wp.pl', 'Kielce', 'Skrajna', '31', NULL, '25-987', 'Dermatolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek12', 'lek12', 'Maciej', 'Sokołowski', sysdate-12310, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorMSoko³owski@wp.pl', 'Bodzentyn', 'Wolnosci', '4', NULL, '25-017', 'Dermatolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek13', 'lek13', 'Monika', 'Sokołowska', sysdate-11000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'Sokol@wp.pl', 'Bodzentyn', 'Wolnosci', '4', NULL, '25-017', 'Ginekolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek14', 'lek14', 'Grzegorz', 'Kubiak', sysdate-9800, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'KubiakKubiak@wp.pl', 'Bodzentyn', 'Licealna', '8', NULL, '25-017', 'Ginekolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek15', 'lek15', 'Mariusz', 'Jaworski', sysdate-9600, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorMJaworski@wp.pl', 'Bodzentyn', 'Wolnosci', '24', NULL, '25-017', 'Alergolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek16', 'lek16', 'Dominika', 'Szulc', sysdate-13600, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'SzulcDok@wp.pl', 'Bodzentyn', 'Wesola', '22', NULL, '25-017', 'Alergolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek17', 'lek17', 'Dominik', 'Kozłowski', sysdate-7700, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'Koz³owski123@wp.pl', 'Nowa S³upia', 'Szkolna', '8', NULL, '25-577', 'Reumatolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek18', 'lek18', 'Julia', 'Duda', sysdate-15500, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorDuda@wp.pl', 'Nowa S³upia', 'Kwiatowa', '13', NULL, '25-577', 'Hematolog', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek19', 'lek19', 'Andrzej', 'Jakubowski', sysdate-12300, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorAJak@wp.pl', 'Nowa S³upia', 'Chemowa', '4', NULL, '25-577', 'Lekarz Rodzinny', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek20', 'lek20', 'Michał', 'Wróblewski', sysdate-14600, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'Wroblewski@wp.pl', 'Kielce', 'Hoza', '25', NULL, '25-987', 'Lekarz Rodzinny', NULL, NULL, NULL);
INSERT INTO Lekarze_view VALUES ('Lek21', 'lek21', 'Szymon', 'Szymczak', sysdate-21370, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorSzymczak@wp.pl', 'Kielce', 'Czestochowska', '46', NULL, '25-987', 'Lekarz Rodzinny', NULL, NULL, NULL);


--Producenci leków
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('USP Zdrowie sp. z o.o.', '02-822', 'Warszawa', 'Poleczki', '35', NULL, 'hurtownia@usp.pl', '225436000');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Mabion S.A.', '95-050', 'Konstantynów Łódzki', 'gen. Mariana Langiewicza', '60', NULL, 'info@mabion.eu', '422077890');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Pelion S.A.', '91-342', 'Łódź', 'Zbąszyńska', '3', NULL, 'hr@pelion.eu', '422007468');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Neuca S.A.', '87-100', 'Toruń', 'Forteczna', '35', '37', 'oferty.farmaceutyczne@neuca.pl', '800804805');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Celon Pharma S.A.', '05-092', 'Łomianki/Kiełpin', 'Ogrodowa', '2a', NULL, 'info@celonpharma.com', '227515933');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Farmacol S.A.', '40-431', 'Katowice', 'Szopienicka', '77', NULL, 'handlowy@farmacol.com.pl', '322080686');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Grupa Adamed S.A.', '05-152', 'Czosnów', 'Mariana Adamkiewicza', '6a', NULL, 'adamed@adamed.com', '227327700');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Aflofarm Farmacja Polska Sp. z o.o.', '95-200', 'Pabianice', 'Partyzancka', '133', '151', 'aflofarm@aflofarm.pl', '422253102');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Toruńskie Zakłady Materiałów Opatrunkowych', '87-100', 'Toruń', 'Żółkiewskiego', '20', '26', 'bok@tzmo-global.com', '566123800');
INSERT INTO Producenci_Lekow_view (nazwa_producenta, kod_pocztowy, miasto, ulica,nr_domu, nr_mieszkania, email,telefon) VALUES ('Zakłady Farmaceutyczne Polpharma S.A.', '83-200', 'Starogard Gdański', 'Pelplińska', '19', NULL, 'iod@polpharma.com', '585631600');


--Godziny wizyt
INSERT INTO dostepne_godz VALUES ('10:00');
INSERT INTO dostepne_godz VALUES ('11:30');
INSERT INTO dostepne_godz VALUES ('13:00');
INSERT INTO dostepne_godz VALUES ('14:30');
INSERT INTO dostepne_godz VALUES ('16:00');
INSERT INTO dostepne_godz VALUES ('17:30');
INSERT INTO dostepne_godz VALUES ('19:00');