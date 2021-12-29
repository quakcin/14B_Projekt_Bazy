-- view do odbierania pacjentow
CREATE OR REPLACE VIEW reqPacjenci AS
SELECT  osoby.imie, osoby.nazwisko, Konta.haslo, TO_CHAR(osoby.data_urodzenia, 'yyyy-MM-dd') as "Data", osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr
        INNER JOIN Pacjenci ON osoby.nr_osoby = pacjenci.osoba_nr;


  -- View do wyszukiwania lekarzy
CREATE OR REPLACE VIEW Pacjent_Wizyty AS
SELECT osoby.imie, osoby.nazwisko, specjalizacje.nazwa_specjalizacji, umawianie.data_wizyty, /*umawianie.opis,*/ umawianie.pacjent_nr FROM UMAWIANIE
INNER JOIN LEKARZE ON umawianie.lekarz_nr = lekarze.nr_lekarza
INNER JOIN Pacjenci ON umawianie.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Specjalizacje ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby;
