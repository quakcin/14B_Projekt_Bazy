CREATE OR REPLACE PROCEDURE dane_osoby_proc (p_osoba_nr Osoby.Nr_Osoby%type)
AS
  dane SYS_REFCURSOR;

BEGIN
   OPEN dane FOR
   SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby=Konta.Osoba_Nr
        WHERE osoby.nr_osoby=p_osoba_nr;

   DBMS_SQL.RETURN_RESULT(dane);
END;
/

execute dane_osoby_proc(1);
