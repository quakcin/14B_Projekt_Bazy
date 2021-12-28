
INSERT INTO Specjalizacje (Nazwa_Specjalizacji) VALUES ('Kardiolog');
INSERT INTO Specjalizacje (Nazwa_Specjalizacji) VALUES ('Dentysta');

--Konto ADMINA
INSERT INTO Adresy  VALUES(1, 'Daleszyce', 'Xyz', '1', NULL, '26-021');
INSERT INTO Kontakty VALUES (1, NULL, NULL);
INSERT INTO Osoby   VALUES(1, 'Bandura', 'Maciek', TO_DATE('2000-05-16', 'YYYY-MM-DD'), '00000000000', 1, 1);
INSERT INTO Konta   VALUES(1, 'admin', 'qwerty', 'admin', 1);

--Pacjenci
INSERT INTO Pacjenci_view VALUES ('Pac1', 'Dudek', 'Adam', 'Kowalski', sysdate-1000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'kowal@wp.pl', 'Kielce', 'Sandomierska', '74', '10', '25-987', NULL);
INSERT INTO Pacjenci_view VALUES ('Pac2', 'Andrzejek','Andrzej', 'Niewulis', sysdate-1200, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'andrzejek@onet.pl', 'Częstochowa', 'Limanowskiego', '12', NULL, '71-411', NULL);
INSERT INTO Pacjenci_view VALUES ('Pac3', 'luki','Łukasz', 'Źródłdowski', sysdate-2500, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'luki2121@wp.pl', 'Kielce', 'Bohaterów Warszawy', '14', '5', '25-200', NULL);

--Lekarze
INSERT INTO Lekarze_view VALUES ('Lek1', 'lek1', 'Grzegorz', 'Nowak', sysdate-7000, TO_CHAR(round(dbms_random.value(00000000001,99999999999))), TO_CHAR(round(dbms_random.value(500000000,999999999))), 'doktorNowak@wp.pl', 'Kielce', 'Karczówkowska', '63', NULL, '25-987', 'Kardiolog', NULL, NULL);

--Producenci leków
INSERT INTO Producenci_Lekow_view VALUES ('USP Zdrowie sp. z o.o.', '02-822', 'Warszawa', 'Poleczki', '35', NULL, 'hurtownia@usp.pl', '225436000');
INSERT INTO Producenci_Lekow_view VALUES ('Mabion S.A.', '95-050', 'Konstantynów Łódzki', 'gen. Mariana Langiewicza', '60', NULL, 'info@mabion.eu', '422077890');
INSERT INTO Producenci_Lekow_view VALUES ('Pelion S.A.', '91-342', 'Łódź', 'Zbąszyńska', '3', NULL, 'hr@pelion.eu', '422007468');
INSERT INTO Producenci_Lekow_view VALUES ('Neuca S.A.', '87-100', 'Toruń', 'Forteczna', '35', '37', 'oferty.farmaceutyczne@neuca.pl', '800804805');
INSERT INTO Producenci_Lekow_view VALUES ('Celon Pharma S.A.', '05-092', 'Łomianki/Kiełpin', 'Ogrodowa', '2a', NULL, 'info@celonpharma.com', '227515933');
INSERT INTO Producenci_Lekow_view VALUES ('Farmacol S.A.', '40-431', 'Katowice', 'Szopienicka', '77', NULL, 'handlowy@farmacol.com.pl', '322080686');
INSERT INTO Producenci_Lekow_view VALUES ('Grupa Adamed S.A.', '05-152', 'Czosnów', 'Mariana Adamkiewicza', '6a', NULL, 'adamed@adamed.com', '227327700');
INSERT INTO Producenci_Lekow_view VALUES ('Aflofarm Farmacja Polska Sp. z o.o.', '95-200', 'Pabianice', 'Partyzancka', '133', '151', 'aflofarm@aflofarm.pl', '422253102');
INSERT INTO Producenci_Lekow_view VALUES ('Toruńskie Zakłady Materiałów Opatrunkowych', '87-100', 'Toruń', 'Żółkiewskiego', '20', '26', 'bok@tzmo-global.com', '566123800');
INSERT INTO Producenci_Lekow_view VALUES ('Zakłady Farmaceutyczne Polpharma S.A.', '83-200', 'Starogard Gdański', 'Pelplińska', '19', NULL, 'iod@polpharma.com', '585631600');

--Leki
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Apap',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Ibuprom',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Gripex',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Stoperan',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Verdin',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Xenna',1);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Florcontrol',3);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witamina D3 2000',3);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witamina A+E',3);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witamina C',3);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Magnez+B6',3);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Krem do rak z oliwa z oliwek',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Woda morksa',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Krem do stop z macznikiem',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Multi flora',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('AquaAPTEO',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witamina D 2000 Forte',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witaminy dla niej',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Witaminy dla niego',4);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Donepex',5);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Ketrel',5);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Lazivir',5);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Salmex',5);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Valzek',5);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Maximum total',6);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Artresan',6);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Koenzym Q10',6);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Protefix',6);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Kerdex',7);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Hitaxa Fast',7);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Anesteloc',7);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Recigar',7);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Ibupar Forte',7);
INSERT INTO leki (Nazwa_Leku, Producent_Nr) VALUES ('Nervomix',7);