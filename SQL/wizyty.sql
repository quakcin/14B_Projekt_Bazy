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

CREATE OR REPLACE PROCEDURE lekWizUpdate(p_opis Wizyty.opis%TYPE, p_status Wizyty.czy_odbyta%TYPE, p_wizyta Wizyty.nr_wizyty%TYPE)
IS
BEGIN
UPDATE Wizyty SET Opis = (Opis || ' (Odp: ' || p_opis ||')'), czy_odbyta = p_status WHERE Nr_wizyty = p_wizyta;
END;
/

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
BEGIN
FOR i IN 1..p_ilosc LOOP
    los:=round(dbms_random.VALUE(-60,60));
    SELECT to_char(sysdate + los, 'DD.MM.YYYY') INTO dni FROM dual;
    SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
    data_wizyty := (dni||' '||godziny);
    INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, czy_odbyta) 
    VALUES(round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Lekarza) FROM Lekarze))),round(DBMS_RANDOM.VALUE(1,(SELECT MAX(Nr_Karty_Pacjenta) FROM Pacjenci))), TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'), 'Zaplanowana');
    IF(dbms_random.VALUE(0,100)<80 AND los<0) THEN
        INSERT INTO Recepty (Wizyta_Nr) VALUES ((SELECT MAX(NR_Wizyty) FROM Wizyty));
        prawdopodob:=round(dbms_random.VALUE(1,4));
        FOR i IN 1..prawdopodob LOOP
            INSERT INTO Lek_Na_Recepte VALUES ((SELECT MAX(NR_Recepty) FROM Recepty), (round(dbms_random.VALUE(1,(SELECT MAX(NR_LEKU) FROM LEKI)))));
        END LOOP;
    END IF;
    IF(dbms_random.VALUE(0,100) < 3 AND los<0) THEN
        UPDATE Wizyty SET czy_odbyta = 'Odwołana', Opis = 'Pacjent nie zjawił się na wizycie.' WHERE wizyty.data_wizyty < SYSDATE AND wizyty.czy_odbyta NOT LIKE 'Odbyta' ;
    END IF;
END LOOP;
    UPDATE Wizyty SET czy_odbyta = 'Odbyta' WHERE wizyty.data_wizyty < SYSDATE AND wizyty.czy_odbyta NOT LIKE 'Odwołana';
END;
/
EXECUTE dodaj_wizyte_random(40);
ALTER TRIGGER check_Wizyty_dates_trigger ENABLE;
