CREATE OR REPLACE VIEW Lekarze_view AS
SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, specjalizacje.nazwa_specjalizacji, specjalizacje.opis, lekarze.nr_lekarza, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr
        INNER JOIN Lekarze ON osoby.nr_osoby = lekarze.osoba_Nr
        INNER JOIN Specjalizacje ON lekarze.Specjalizacja_Nr = specjalizacje.nr_specjalizacji;
        
        
CREATE OR REPLACE TRIGGER Lekarz_add_trigger
INSTEAD OF INSERT OR UPDATE OR DELETE ON Lekarze_view
FOR EACH ROW
DECLARE
    v_Nr_Specjalizacji specjalizacje.nr_specjalizacji%TYPE;
    adres NUMBER;
    kontakt NUMBER;
BEGIN
CASE
WHEN INSERTING THEN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.NEXTVAL, :NEW.Miasto, :NEW.Ulica, :NEW.Nr_Domu, :NEW.Nr_Mieszkania, :NEW.Kod_Pocztowy);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.NEXTVAL, :NEW.Telefon, :NEW.Email);
    INSERT INTO Osoby VALUES (OSOBY_SEQUENCE.NEXTVAL, :NEW.Nazwisko, :NEW.Imie, :NEW.Data_Urodzenia, :NEW.PESEL, ADRESY_SEQUENCE.currval, KONTAKTY_SEQUENCE.currval);
    SELECT Nr_Specjalizacji INTO v_Nr_Specjalizacji FROM Specjalizacje WHERE nazwa_specjalizacji=:NEW.nazwa_specjalizacji;
    INSERT INTO Lekarze VALUES (Lekarze_sequence.NEXTVAL, OSOBY_SEQUENCE.currval, v_nr_specjalizacji, NULL);
    INSERT INTO Konta VALUES (KONTA_SEQUENCE.NEXTVAL, :NEW.Login, :NEW.Haslo, 'lekarz', OSOBY_SEQUENCE.CURRVAL);
WHEN UPDATING THEN
    UPDATE Adresy SET Miasto = :NEW.Miasto, Ulica = :NEW.Ulica, Nr_Domu = :NEW.Nr_Domu, Nr_Mieszkania = :NEW.Nr_Mieszkania, Kod_Pocztowy = :NEW.Kod_Pocztowy WHERE Nr_Adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby);
    UPDATE Kontakty SET Telefon = :NEW.Telefon, Email = :NEW.Email WHERE Nr_Kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby); 
    UPDATE Osoby SET Nazwisko = :NEW.Nazwisko, Imie = :NEW.Imie, Data_Urodzenia = :NEW.Data_Urodzenia, PESEL = :NEW.PESEL WHERE Nr_Osoby = :NEW.Nr_Osoby;
    SELECT Nr_Specjalizacji INTO v_Nr_Specjalizacji FROM Specjalizacje WHERE nazwa_specjalizacji=:NEW.nazwa_specjalizacji;
    UPDATE Lekarze SET Specjalizacja_Nr = v_Nr_Specjalizacji WHERE Osoba_Nr = :NEW.Nr_Osoby;
    UPDATE Konta SET Haslo = :NEW.Haslo WHERE Osoba_Nr = :NEW.Nr_Osoby;
WHEN DELETING THEN
    SELECT Adres_Nr INTO adres FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby;
    SELECT Kontakt_Nr INTO kontakt FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby;
    DELETE FROM Lekarze WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Konta WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Sesje WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby;
    DELETE FROM Adresy WHERE Nr_Adresu = adres;
    DELETE FROM Kontakty WHERE Nr_Kontaktu = kontakt; 
END CASE;
END;
/

CREATE OR REPLACE PROCEDURE uptInfo(    p_imie osoby.imie%TYPE, p_nazwisko osoby.nazwisko%TYPE, p_haslo konta.haslo%TYPE, 
                                        p_data NVARCHAR2, p_pesel osoby.pesel%TYPE, p_telefon kontakty.telefon%TYPE,
                                        p_mail kontakty.email%TYPE, p_miasto adresy.miasto%TYPE, p_ulica adresy.ulica%TYPE,
                                        p_dom adresy.nr_domu%TYPE, p_mieszk adresy.nr_mieszkania%TYPE, p_poczt adresy.kod_pocztowy%TYPE, p_osoba osoby.nr_osoby%TYPE)
IS
BEGIN
    UPDATE Kontakty SET Telefon = p_telefon, Email = p_mail WHERE nr_kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = p_osoba);
    UPDATE Adresy SET Miasto = p_miasto, Ulica = p_ulica, Nr_domu = p_dom, nr_mieszkania = p_mieszk, kod_pocztowy = p_poczt 
    WHERE nr_adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = p_osoba);
    UPDATE Osoby SET Nazwisko = p_nazwisko, Imie = p_imie, Data_Urodzenia = TO_DATE(p_data, 'YYYY-MM-DD'), PESEL = p_pesel WHERE nr_osoby = p_osoba;
    UPDATE Konta SET haslo = p_haslo WHERE Osoba_Nr = p_osoba;
END;
/

--EXECUTE uptInfo('Grzegorzz', 'Nowakk', 'lek3454', '1979-10-21', '15943770171', '997018017', 'doktorRafal@wpp.pl', 'Rubbin', 'Kwiatowa', '1', '5', '78-417', 6);


CREATE OR REPLACE VIEW pacjentLekarzaInfo AS
SELECT pacjenci.nr_karty_pacjenta, osoby.imie, osoby.nazwisko, osoby.data_urodzenia,"tab"."Ostatnia", wizyty.lekarz_nr from Wizyty
INNER JOIN pacjenci on wizyty.pacjent_nr = pacjenci.nr_karty_pacjenta
INNER JOIN Osoby ON pacjenci.osoba_nr=osoby.nr_osoby
INNER JOIN (SELECT pacjent_Nr, MAX(data_wizyty) as "Ostatnia" FROM Wizyty WHERE CZY_ODBYTA = 'Odbyta' GROUP BY pacjent_Nr) "tab" ON wizyty.pacjent_nr = "tab".pacjent_Nr
GROUP BY pacjenci.nr_karty_pacjenta, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, "tab"."Ostatnia", wizyty.lekarz_nr;

--SELECT nr_karty_pacjenta, imie, nazwisko, TO_CHAR(data_urodzenia, 'dd.mm.yyyy'), TO_CHAR("Ostatnia", 'dd.mm.yyyy HH24:mi') FROM pacjentLekarzaInfo WHERE lekarz_nr = 2;


CREATE OR REPLACE PROCEDURE ZaznaczRecepte(p_lekarz wizyty.lekarz_nr%TYPE, p_Wizyta wizyty.nr_wizyty%TYPE)
IS
v_recepta recepty.nr_recepty%TYPE;
BEGIN
    SELECT Nr_Recepty INTO v_recepta FROM Recepty WHERE wizyta_nr = p_wizyta;
    UPDATE Lekarze SET Ostatnia_Recepta = v_recepta WHERE Osoba_Nr = p_lekarz;
END;
/

CREATE OR REPLACE PROCEDURE DodajRecepte_z_Wizyty(p_lekarz wizyty.lekarz_nr%TYPE, p_wizyta wizyty.nr_wizyty%TYPE, p_DataWystawienia recepty.data_wystawienia%TYPE, p_DataWaznosci recepty.data_waznosci%TYPE, p_Zalecenia recepty.zalecenia%type)
IS
v_recepta recepty.nr_recepty%TYPE;
BEGIN
    INSERT INTO Recepty (Wizyta_Nr, Data_Wystawienia, Data_Waznosci, Zalecenia) VALUES (p_wizyta, p_DataWystawienia, p_DataWaznosci, p_Zalecenia);
    SELECT Nr_Recepty INTO v_recepta FROM Recepty WHERE wizyta_nr = p_wizyta;
    UPDATE Lekarze SET Ostatnia_Recepta = v_recepta WHERE Osoba_Nr = p_lekarz;
END;
/