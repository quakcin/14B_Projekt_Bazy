--Perspektywa Pacjenta

--Podglad wizyt
CREATE OR REPLACE VIEW Pacjent_Wizyty AS
SELECT Wizyty.nr_wizyty, osoby.imie, osoby.nazwisko, specjalizacje.nazwa_specjalizacji, TO_CHAR(Wizyty.data_wizyty, 'yyyy-MM-dd HH24:MI') as "Data_Wizyty", Wizyty.opis, wizyty.czy_odbyta, Wizyty.pacjent_nr FROM Wizyty
INNER JOIN Lekarze ON Wizyty.lekarz_nr = lekarze.nr_lekarza
INNER JOIN Pacjenci ON Wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Specjalizacje ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby;

SELECT * FROM Pacjent_Wizyty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 2);

--Umowienie wizyty
CREATE OR REPLACE FUNCTION Dostepnosc_Wizyty(p_Numer_Lekarza Lekarze.nr_lekarza%TYPE, p_Data NVARCHAR2)
RETURN NUMBER
IS
v_Nr_Wizyty Wizyty.nr_wizyty%TYPE;
BEGIN
SELECT Nr_Wizyty INTO v_Nr_Wizyty FROM Wizyty WHERE lekarz_nr = p_Numer_Lekarza AND data_wizyty = TO_DATE(p_Data, 'DD.MM.YYYY HH24:MI');
RETURN v_Nr_Wizyty;
END;
/

SELECT Dostepnosc_Wizyty(1, '30.12.2021 10:0') FROM DUAL;

CREATE OR REPLACE PROCEDURE Umow_Wizyte(p_Numer_Lekarza Lekarze.nr_lekarza%TYPE, p_Numer_Osoby Pacjenci.nr_karty_pacjenta%TYPE, p_Data NVARCHAR2, p_Opis Wizyty.Opis%TYPE)
IS
v_Numer_Pacjenta osoby.nr_osoby%TYPE;
BEGIN
SELECT NR_KARTY_PACJENTA INTO v_Numer_Pacjenta FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = p_Numer_Osoby;
INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty, opis) VALUES(p_Numer_Lekarza, v_Numer_Pacjenta, TO_DATE(p_Data, 'DD.MM.YYYY HH24:MI'), p_Opis);
END;
/

--EXECUTE Umow_Wizyte(3,2,'06.01.2022 10:00', 'Opis choroby');


--Perspektywa Lekarza
CREATE OR REPLACE VIEW Lekarz_Wizyty AS
SELECT Wizyty.nr_wizyty, Wizyty.pacjent_nr, osoby.imie, osoby.nazwisko, TO_CHAR(Wizyty.data_wizyty, 'dd.mm.yyyy HH24:MI') as "Data Wizyty", Wizyty.opis, wizyty.czy_odbyta, Wizyty.lekarz_nr FROM Wizyty
INNER JOIN Pacjenci ON Wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Osoby ON Pacjenci.osoba_nr = osoby.nr_osoby;


SELECT Nr_Wizyty, pacjent_nr, Imie, Nazwisko, "Data Wizyty", Opis, czy_odbyta FROM Lekarz_Wizyty WHERE lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 6);


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

EXECUTE lekWizUpdate('abd', 'odbyta', 2);

CREATE OR REPLACE PROCEDURE Odwolaj_Wizyte (p_Nr_Wizyty Wizyty.nr_wizyty%TYPE, p_Nr_Osoby Osoby.nr_osoby%TYPE)
IS
BEGIN
DELETE FROM Wizyty WHERE nr_wizyty =  p_Nr_Wizyty AND pacjent_nr = (SELECT Nr_Karty_Pacjenta  FROM Pacjenci WHERE osoba_nr = p_Nr_Osoby);
END;
/

--EXECUTE Odwolaj_Wizyte(2,2);