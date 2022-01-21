--Perspektywa Pacjenta

--Podglad wizyt
CREATE OR REPLACE VIEW Pacjent_Wizyty AS
SELECT Wizyty.nr_wizyty, osoby.imie, osoby.nazwisko, specjalizacje.nazwa_specjalizacji, TO_CHAR(Wizyty.data_wizyty, 'yyyy-MM-dd HH24:MI') as "Data_Wizyty", Wizyty.opis, wizyty.czy_odbyta, Wizyty.pacjent_nr FROM Wizyty
INNER JOIN Lekarze ON Wizyty.lekarz_nr = lekarze.nr_lekarza
INNER JOIN Pacjenci ON Wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Specjalizacje ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby;

--SELECT * FROM Pacjent_Wizyty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 2);

--Umowienie wizyty
CREATE OR REPLACE FUNCTION Dostepnosc_Wizyty(p_Numer_Lekarza Lekarze.nr_lekarza%TYPE, p_Data NVARCHAR2)
RETURN NUMBER
IS
v_Nr_Wizyty Wizyty.nr_wizyty%TYPE;
BEGIN
SELECT Nr_Wizyty INTO v_Nr_Wizyty FROM Wizyty WHERE lekarz_nr = p_Numer_Lekarza AND data_wizyty = TO_DATE(p_Data, 'YYYY.MM.DD HH24:MI');
RETURN v_Nr_Wizyty;
END;
/



--SELECT Dostepnosc_Wizyty(1, '30.12.2021 10:0') FROM DUAL;

CREATE OR REPLACE PROCEDURE Umow_Wizyte(p_Numer_Lekarza Lekarze.nr_lekarza%TYPE, p_Numer_Osoby Pacjenci.nr_karty_pacjenta%TYPE, p_Data NVARCHAR2, p_Opis Wizyty.Opis%TYPE)
IS
v_Numer_Pacjenta osoby.nr_osoby%TYPE;
BEGIN
SELECT NR_KARTY_PACJENTA INTO v_Numer_Pacjenta FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = p_Numer_Osoby;
INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, opis) VALUES(p_Numer_Lekarza, v_Numer_Pacjenta, TO_DATE(p_Data, 'YYYY-MM-DD HH24:MI'), p_Opis);
END;
/

--EXECUTE Umow_Wizyte(3,2,'15.01.2022 12:07', 'Opis choroby');


--Perspektywa Lekarza
CREATE OR REPLACE VIEW Lekarz_Wizyty AS
SELECT Wizyty.nr_wizyty, Wizyty.pacjent_nr, osoby.imie, osoby.nazwisko, TO_CHAR(Wizyty.data_wizyty, 'dd.mm.yyyy HH24:MI') as "Data Wizyty", Wizyty.opis, wizyty.czy_odbyta, Wizyty.lekarz_nr FROM Wizyty
INNER JOIN Pacjenci ON Wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Osoby ON Pacjenci.osoba_nr = osoby.nr_osoby;


--SELECT Nr_Wizyty, pacjent_nr, Imie, Nazwisko, "Data Wizyty", Opis, czy_odbyta FROM Lekarz_Wizyty WHERE lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 6);


CREATE OR REPLACE TRIGGER Lekarz_Wizyty_trigger
INSTEAD OF INSERT OR UPDATE OR DELETE ON Lekarz_Wizyty
FOR EACH ROW
BEGIN
CASE
WHEN INSERTING THEN
UPDATE Wizyty SET Opis = :NEW.Opis, czy_odbyta = :NEW.czy_odbyta WHERE nr_wizyty = :NEW.nr_wizyty;
END CASE;
END;
/

CREATE OR REPLACE PROCEDURE lekWizUpdate(p_osoba Osoby.nr_osoby%TYPE, p_opis Wizyty.opis%TYPE, p_status Wizyty.czy_odbyta%TYPE, p_wizyta Wizyty.nr_wizyty%TYPE, p_data wizyty.data_wizyty%TYPE)
IS
v_wizyta Wizyty.Nr_Wizyty%TYPE;
v_Lekarz lekarze.Nr_Lekarza%TYPE;
v_data wizyty.data_wizyty%TYPE;
BEGIN
    SELECT Nr_Lekarza INTO v_Lekarz FROM Lekarze WHERE Osoba_Nr = p_osoba;
    SELECT COUNT(Nr_Wizyty) INTO v_wizyta FROM Wizyty WHERE Lekarz_Nr = v_Lekarz AND Data_Wizyty = p_data AND Nr_Wizyty != p_wizyta;
    IF (v_wizyta = 0) THEN
        UPDATE Wizyty SET Data_Wizyty = p_data, opis = p_opis, czy_odbyta = p_status WHERE nr_wizyty = p_wizyta;
    ELSE
        RAISE_APPLICATION_ERROR( -20004, 'Błędna data wizyty: Taka data wizyty jest już zajęta! Wybierz inną.' );
    END IF;
END;
/
EXECUTE lekWizUpdate(124, 'Stany lękowyyy.', 'Przeniesiona', 1, to_date('2022-04-07 10:00', 'YYYY-MM-DD HH24:mi'));

--EXECUTE lekWizUpdate('abd', 'odbyta', 2);


CREATE OR REPLACE PROCEDURE OdwolajWizytePac (p_Nr_Wizyty Wizyty.nr_wizyty%TYPE, p_Nr_Osoby Osoby.nr_osoby%TYPE)
IS
BEGIN
UPDATE Wizyty SET Opis='(Odp: Pacjent odwołał wizytę)', Czy_Odbyta = 'Odwołana' 
WHERE (nr_wizyty =  p_Nr_Wizyty AND pacjent_nr = (SELECT Nr_Karty_Pacjenta  FROM Pacjenci WHERE osoba_nr = p_Nr_Osoby)) AND (Czy_Odbyta = 'Zaplanowana' OR Czy_Odbyta = 'Przeniesiona');
END;
/

--EXECUTE OdwolajWizytePac(6,5);

CREATE OR REPLACE PROCEDURE OdwolajWizyteLek (p_Nr_Wizyty Wizyty.nr_wizyty%TYPE)
IS
BEGIN
UPDATE Wizyty SET Opis='(Odp: Lekarz odwołał wizytę)', Czy_Odbyta = 'Odwołana' WHERE nr_wizyty =  p_Nr_Wizyty AND (Czy_Odbyta = 'Zaplanowana' OR Czy_Odbyta = 'Przeniesiona');
END;
/

--EXECUTE OdwolajWizyteLek(6);


ALTER TRIGGER check_Wizyty_dates_trigger DISABLE;
CREATE OR REPLACE PROCEDURE dodaj_wizyte_random(p_ilosc NUMBER)
IS
dni NVARCHAR2(80);
godziny NVARCHAR2(80);
data_wizyty NVARCHAR2(80);
los NUMBER;
prawdopodob NUMBER;
type Opisarray IS VARRAY(50) OF VARCHAR2(256); 
ZaplanowaneOpis Opisarray;
OdwolaneOpis Opisarray;
OdbyteOpis Opisarray;
PrzeniesioneOpis Opisarray;
Zalecenia Opisarray;
BEGIN
    ZaplanowaneOpis := Opisarray('Nasilony ból głowy w ostatnich dniach',  'Dziwny wyprysk na wardze',  'Irytujące swędzenie we włosach',  'Ból zęba',  'Ucisk w klatce piersiowej',  'Kołatanie serca',  'Trudności w oddychaniu',  'Przemęczenie studenckie',  'Stany lękowe',  'Chroniczna depresja',  'Coroczna kontrola', '');
    OdwolaneOpis := Opisarray('Pacjent odwołał wizytę',  'Pacjent odwołał wizytę',  'Pacjent odwołał wizytę',  'Pacjent odwołał wizytę',  'Problem sam się rozwiązał',  'Pacjent się nie stawił',  'Lekarz odwołał wizytę',  'Lekarz odwołał wizytę',  'Już się czuje lepiej',  '');
    OdbyteOpis := Opisarray('Pacjent został wyleczony',  'Pacjent zmarł',  'Problem zażegnany',  'Zalecana dalsza hospitalizacja',  'Zalecane zgłoszenie się do szpitala',  '');
    PrzeniesioneOpis := Opisarray('Choroba lekarza',  'Urlop lekarza',  'Brak funduszy z NFZ',  'Kwarantanna Covidowa',  'Brak wolnych miejsc',  '');
    Zalecenia := Opisarray('Zarzywać jak najwięcej',  'Trzy razy dziennie',  'Brać tylko na noc',  'Brać po posiłkach',  'Brać przed posiłkami',  'Dawkować co tydzień');
    FOR i IN 1..p_ilosc LOOP
        prawdopodob:= dbms_random.VALUE(0, 99);
        IF(prawdopodob >= 0 AND prawdopodob < 50) THEN
            los:=round(dbms_random.VALUE(1, 100));
            SELECT to_char(sysdate + los, 'DD.MM.YYYY') INTO dni FROM dual;
            SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
            data_wizyty := (dni||' '||godziny);
            INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, czy_odbyta, Opis) VALUES(round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Lekarza) FROM Lekarze))),round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Karty_Pacjenta) FROM Pacjenci))), TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'), 'Zaplanowana', ZaplanowaneOpis(dbms_random.VALUE(1, 12)));
        ELSIF (prawdopodob >= 50 AND prawdopodob < 90) THEN
            los:=round(dbms_random.VALUE(-360, -1));
            SELECT to_char(sysdate + los, 'DD.MM.YYYY') INTO dni FROM dual;
            SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
            data_wizyty := (dni||' '||godziny);
            INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, czy_odbyta, Opis) VALUES(round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Lekarza) FROM Lekarze))),round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Karty_Pacjenta) FROM Pacjenci))), TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'), 'Odbyta', OdbyteOpis(dbms_random.VALUE(1, 6)));
            IF(dbms_random.VALUE(0, 99) < 75) THEN
                INSERT INTO Recepty (Wizyta_Nr, Zalecenia) VALUES ((SELECT MAX(NR_Wizyty) FROM Wizyty), Zalecenia(dbms_random.VALUE(1, 6)));
                prawdopodob:=round(dbms_random.VALUE(1,4));
                FOR i IN 1..prawdopodob LOOP
                    INSERT INTO Lek_Na_Recepte VALUES ((SELECT MAX(NR_Recepty) FROM Recepty), (round(dbms_random.VALUE(1,(SELECT MAX(NR_LEKU) FROM LEKI)))));
                END LOOP;
            END IF;
        ELSIF (prawdopodob >= 90 AND prawdopodob < 95) THEN
            los:=round(dbms_random.VALUE(-360, -1));
            SELECT to_char(sysdate + los, 'DD.MM.YYYY') INTO dni FROM dual;
            SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
            data_wizyty := (dni||' '||godziny);
            INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, czy_odbyta, Opis) VALUES(round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Lekarza) FROM Lekarze))),round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Karty_Pacjenta) FROM Pacjenci))), TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'), 'Odwołana', OdwolaneOpis(dbms_random.VALUE(1, 10)));
        ELSIF (prawdopodob >= 95 AND prawdopodob < 100) THEN
            los:=round(dbms_random.VALUE(1, 60));
            SELECT to_char(sysdate + los, 'DD.MM.YYYY') INTO dni FROM dual;
            SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
            data_wizyty := (dni||' '||godziny);
            INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, czy_odbyta, Opis) VALUES(round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Lekarza) FROM Lekarze))),round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Karty_Pacjenta) FROM Pacjenci))), TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'), 'Przeniesiona', PrzeniesioneOpis(dbms_random.VALUE(1, 6)));
        END IF;
    END LOOP;
END;
/
SET SERVEROUTPUT ON;
EXECUTE dodaj_wizyte_random(700);
ALTER TRIGGER check_Wizyty_dates_trigger ENABLE;
