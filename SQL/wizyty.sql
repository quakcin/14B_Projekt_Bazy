--Perspektywa Pacjenta
CREATE OR REPLACE VIEW Pacjent_Wizyty AS
SELECT Wizyty.nr_wizyty, osoby.imie, osoby.nazwisko, specjalizacje.nazwa_specjalizacji, TO_CHAR(Wizyty.data_wizyty, 'yyyy-MM-dd') as "Data_Wizyty", Wizyty.opis, wizyty.czy_odbyta, Wizyty.pacjent_nr FROM Wizyty
INNER JOIN Lekarze ON Wizyty.lekarz_nr = lekarze.nr_lekarza
INNER JOIN Pacjenci ON Wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Specjalizacje ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby;

--SELECT * FROM Pacjent_Wizyty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 2);
/*
--Perspektywa Lekarza
CREATE OR REPLACE VIEW Lekarz_Wizyty AS
SELECT umawianie.nr_wizyty, osoby.imie, osoby.nazwisko, umawianie.data_wizyty, umawianie.opis, umawianie.lekarz_nr FROM UMAWIANIE
INNER JOIN Pacjenci ON umawianie.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Osoby ON Pacjenci.osoba_nr = osoby.nr_osoby;

SELECT * FROM Lekarz_Wizyty WHERE lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 5);

CREATE OR REPLACE PROCEDURE Odwolaj_Wizyte (p_Nr_Wizyty Umawianie.nr_wizyty%TYPE, p_Nr_Osoby Osoby.nr_osoby%TYPE)
IS
BEGIN
DELETE FROM Umawianie WHERE nr_wizyty =  p_Nr_Wizyty AND pacjent_nr = (SELECT Nr_Karty_Pacjenta  FROM Pacjenci WHERE osoba_nr = p_Nr_Osoby);
END;
/
*/
--EXECUTE Odwolaj_Wizyte(2,2);