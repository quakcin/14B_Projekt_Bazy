CREATE OR REPLACE VIEW AdminView_Wizyta AS
SELECT Wizyty.Nr_Wizyty, TO_CHAR(Wizyty.data_wizyty, 'yyyy-MM-dd HH24:MI') as "Data_Wizyty", Wizyty.Opis, Wizyty.czy_odbyta, wizyty.lekarz_nr, 
        "OsobaLekarza".imie AS "Imie lekarza", "OsobaLekarza".Nazwisko AS "Nazwisko lekarza", specjalizacje.nazwa_specjalizacji, 
        wizyty.pacjent_nr, "OsobaPacjenta".imie AS "Imie pacjenta", "OsobaPacjenta".Nazwisko AS "Nazwisko pacjenta" FROM Wizyty
INNER JOIN Lekarze ON wizyty.lekarz_nr = lekarze.nr_lekarza
INNER JOIN Pacjenci ON wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Osoby "OsobaPacjenta" ON "OsobaPacjenta".Nr_Osoby = pacjenci.osoba_nr
INNER JOIN Osoby "OsobaLekarza" ON "OsobaLekarza".Nr_Osoby = Lekarze.osoba_nr
INNER JOIN Specjalizacje ON specjalizacje.nr_specjalizacji = lekarze.specjalizacja_nr;


CREATE OR REPLACE VIEW AdminView_Pacjent AS
SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, pacjenci.nr_karty_pacjenta, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr
        INNER JOIN Pacjenci ON osoby.nr_osoby = pacjenci.osoba_nr;
       
 
CREATE OR REPLACE VIEW AdminView_Admin AS
SELECT  Konta.login, osoby.imie, osoby.nazwisko, kontakty.email, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr 
        WHERE konta.typ_konta = 'admin';

CREATE OR REPLACE VIEW AdminView_Specjalizacje AS
SELECT specjalizacje.nazwa_specjalizacji, specjalizacje.opis, COUNT(Lekarze.nr_lekarza) AS "Ilosc lekarzy" FROM Specjalizacje
INNER JOIN Lekarze ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
GROUP BY specjalizacje.nazwa_specjalizacji, specjalizacje.opis;

SELECT imie, nazwisko, TO_CHAR(data_urodzenia, 'yyyy-MM-dd'), pesel, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy, nazwa_specjalizacji FROM Lekarze_view WHERE Nr_lekarza = 1;
SELECT imie, nazwisko, TO_CHAR(data_urodzenia, 'yyyy-MM-dd'), pesel, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy FROM Pacjenci_view WHERE Nr_osoby = (SELECT Osoba_Nr FROM Pacjenci WHERE Nr_Karty_Pacjenta = 1);
SELECT nazwa_producenta, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy FROM Producenci_Lekow_view WHERE nr_producenta = 1; 
SELECT nazwa_specjalizacji, opis FROM AdminView_Specjalizacje WHERE nazwa_specjalizacji = 'Kardiolog';
SELECT "Data_Wizyty", Opis, czy_odbyta, lekarz_nr, "Imie lekarza", "Nazwisko lekarza", pacjent_nr, "Imie pacjenta", "Nazwisko pacjenta" FROM AdminView_Wizyta WHERE nr_wizyty = 1;

CREATE OR REPLACE PROCEDURE ResetHaslaLekarz(p_id lekarze.nr_lekarza%TYPE, p_haslo konta.haslo%TYPE)
AS
v_osoba osoby.nr_osoby%TYPE;
BEGIN
    SELECT osoba_nr INTO v_osoba FROM Lekarze WHERE nr_lekarza = p_id;
    UPDATE Konta SET haslo = p_haslo WHERE osoba_nr = v_osoba;
END;
/

CREATE OR REPLACE PROCEDURE ResetHaslaPacjent(p_id pacjenci.nr_karty_pacjenta%TYPE, p_haslo konta.haslo%TYPE)
AS
v_osoba osoby.nr_osoby%TYPE;
BEGIN
    SELECT osoba_nr INTO v_osoba FROM Pacjenci WHERE nr_karty_pacjenta = p_id;
    UPDATE Konta SET haslo = p_haslo WHERE osoba_nr = v_osoba;
END;
/