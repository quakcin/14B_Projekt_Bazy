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
LEFT JOIN Lekarze ON lekarze.specjalizacja_nr = specjalizacje.nr_specjalizacji
GROUP BY specjalizacje.nazwa_specjalizacji, specjalizacje.opis
ORDER BY specjalizacje.nazwa_specjalizacji;

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

CREATE OR REPLACE PROCEDURE AdminEdytuj_Lekarza(p_idLekarza Lekarze.nr_lekarza%TYPE, p_imie Osoby.imie%TYPE, p_nazwisko Osoby.nazwisko%TYPE, 
                                                p_data Osoby.data_urodzenia%TYPE, p_pesel Osoby.pesel%TYPE, p_telefon Kontakty.telefon%TYPE,
                                                p_mail Kontakty.email%TYPE, p_miasto Adresy.miasto%TYPE, p_ulica Adresy.ulica%TYPE, p_dom Adresy.nr_domu%TYPE,
                                                p_mieszk adresy.nr_mieszkania%TYPE, p_kod Adresy.Kod_Pocztowy%TYPE, p_specjalizacja Specjalizacje.nazwa_specjalizacji%TYPE)
AS
v_osoba osoby.nr_osoby%TYPE;
BEGIN
    SELECT Osoba_Nr INTO v_osoba FROM Lekarze WHERE Nr_Lekarza = p_idLekarza;
    UPDATE Lekarze_view SET imie = p_imie, nazwisko = p_nazwisko, data_urodzenia = p_data, pesel = p_pesel, telefon = p_telefon, 
                            email = p_mail, miasto = p_miasto, ulica = p_ulica, nr_domu = p_dom, nr_mieszkania = p_mieszk, 
                            kod_pocztowy = p_kod, nazwa_specjalizacji = p_specjalizacja  
    WHERE Nr_Osoby = v_osoba;
END;
/

--EXECUTE AdminEdytuj_Lekarza(1, 'Piotr' , 'Nowak', sysdate-8000, '74125896325', '412541254', 'doktornowak@wp.pl', 'Kielce', 'Prosta', '34', '45', '25-265', 'Dentysta');

CREATE OR REPLACE PROCEDURE AdminEdytuj_Pacjenta(p_idPacjenta pacjenci.nr_karty_pacjenta%TYPE, p_imie Osoby.imie%TYPE, p_nazwisko Osoby.nazwisko%TYPE, 
                                                p_data Osoby.data_urodzenia%TYPE, p_pesel Osoby.pesel%TYPE, p_telefon Kontakty.telefon%TYPE,
                                                p_mail Kontakty.email%TYPE, p_miasto Adresy.miasto%TYPE, p_ulica Adresy.ulica%TYPE, p_dom Adresy.nr_domu%TYPE,
                                                p_mieszk adresy.nr_mieszkania%TYPE, p_kod Adresy.Kod_Pocztowy%TYPE)
AS
v_osoba osoby.nr_osoby%TYPE;
BEGIN
    SELECT Osoba_Nr INTO v_osoba FROM Pacjenci WHERE nr_karty_pacjenta = p_idPacjenta;
    UPDATE Pacjenci_view SET imie = p_imie, nazwisko = p_nazwisko, data_urodzenia = p_data, pesel = p_pesel, telefon = p_telefon, 
                            email = p_mail, miasto = p_miasto, ulica = p_ulica, nr_domu = p_dom, nr_mieszkania = p_mieszk, 
                            kod_pocztowy = p_kod  
    WHERE Nr_Osoby = v_osoba;
END;
/

--EXECUTE AdminEdytuj_Pacjenta (1, 'Adam', 'Niezgódka', sysdate-8541, '96325874125', NULL, NULL, 'Warszawa', 'Al. Jerozolimskie', '369a', '94', '01-256');

CREATE OR REPLACE PROCEDURE AdminEdytuj_Producenta(p_idProcucenta Producenci_Lekow.nr_producenta%TYPE, p_nazwa Producenci_Lekow.Nazwa_Producenta%TYPE, 
                                                    p_telefon Kontakty.telefon%TYPE, p_mail Kontakty.email%TYPE, p_miasto Adresy.miasto%TYPE, 
                                                    p_ulica Adresy.ulica%TYPE, p_dom Adresy.nr_domu%TYPE,
                                                    p_mieszk adresy.nr_mieszkania%TYPE, p_kod Adresy.Kod_Pocztowy%TYPE)
AS
BEGIN
    UPDATE producenci_lekow SET nazwa_producenta = p_nazwa 
    WHERE nr_producenta = p_idProcucenta;
    
    UPDATE Adresy SET miasto = p_miasto, ulica = p_ulica, nr_domu = p_dom, nr_mieszkania = p_mieszk, kod_pocztowy = p_kod 
    WHERE nr_adresu = (SELECT Adres_Nr FROM Producenci_Lekow WHERE Nr_Producenta = p_idProcucenta);
    
    UPDATE Kontakty SET email = p_mail, telefon = p_telefon 
    WHERE nr_kontaktu = (SELECT Kontakt_Nr FROM Producenci_Lekow WHERE Nr_Producenta = p_idProcucenta);
END;
/

--EXECUTE AdminEdytuj_Producenta (1, 'upsik', '412874587', 'UDR@WP.PL', 'AD', 'SS', '15', null, '25-001');

--UPDATE specjalizacje SET nazwa_specjalizacji = 'coś', opis = 'cos2' WHERE nr_specjalizacji = 1

CREATE OR REPLACE PROCEDURE AdminEdytuj_Wizyte(p_idWizyty Wizyty.nr_wizyty%TYPE, p_data Wizyty.Data_Wizyty%TYPE, 
                                                p_opis Wizyty.opis%TYPE, p_status Wizyty.czy_odbyta%TYPE, 
                                                p_lekarz Wizyty.lekarz_nr%TYPE, p_pacjent Wizyty.pacjent_nr%TYPE)
AS
BEGIN
    UPDATE Wizyty SET Data_Wizyty = p_data, opis = p_opis, czy_odbyta = p_status, lekarz_nr = p_lekarz, pacjent_nr = p_pacjent WHERE nr_wizyty = p_idWizyty;
END;
/

--EXECUTE AdminEdytuj_Wizyte(1, to_date('25.02.2022 15:10', 'DD.MM.YYYY HH24:mi'), '  ', 'Zaplanowana', 20, 4);

CREATE OR REPLACE PROCEDURE AdminUsun_admina(p_id osoby.nr_osoby%TYPE)
AS
BEGIN
    IF(p_id = 1) THEN
     RAISE_APPLICATION_ERROR( -20005, 
          'Nie można usunąć konta głównego administratora numer 1!' );
    END IF;
    DELETE FROM Konta WHERE osoba_nr = p_id;
    DELETE FROM Kontakty WHERE nr_kontaktu = 37;
    DELETE FROM Osoby WHERE Nr_Osoby = p_id;
END;
/

--EXECUTE AdminUsun_admina(27);

CREATE OR REPLACE PROCEDURE AdminUsun_pacjenta(p_id osoby.nr_osoby%TYPE)
AS
v_osoba Osoby.nr_osoby%TYPE;
BEGIN
    
END;
/