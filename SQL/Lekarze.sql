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
BEGIN
CASE
WHEN INSERTING THEN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.NEXTVAL, :NEW.Miasto, :NEW.Ulica, :NEW.Nr_Domu, :NEW.Nr_Mieszkania, :NEW.Kod_Pocztowy);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.NEXTVAL, :NEW.Telefon, :NEW.Email);
    INSERT INTO Osoby VALUES (OSOBY_SEQUENCE.NEXTVAL, :NEW.Nazwisko, :NEW.Imie, :NEW.Data_Urodzenia, :NEW.PESEL, ADRESY_SEQUENCE.currval, KONTAKTY_SEQUENCE.currval);
    --INSERT INTO Specjalizacje VALUES(Specjalizacje_sequence.NEXTVAL, :NEW.Nazwa_Specjalizacji, :NEW.Opis); 
    SELECT Nr_Specjalizacji INTO v_Nr_Specjalizacji FROM Specjalizacje WHERE nazwa_specjalizacji=:NEW.nazwa_specjalizacji;
    INSERT INTO Lekarze VALUES (Lekarze_sequence.NEXTVAL, OSOBY_SEQUENCE.currval, v_nr_specjalizacji);
    INSERT INTO Konta VALUES (KONTA_SEQUENCE.NEXTVAL, :NEW.Login, :NEW.Haslo, 'lekarz', OSOBY_SEQUENCE.CURRVAL);
WHEN UPDATING THEN
    UPDATE Adresy SET Miasto = :NEW.Miasto, Ulica = :NEW.Ulica, Nr_Domu = :NEW.Nr_Domu, Nr_Mieszkania = :NEW.Nr_Mieszkania, Kod_Pocztowy = :NEW.Kod_Pocztowy WHERE Nr_Adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby);
    UPDATE Kontakty SET Telefon = :NEW.Telefon, Email = :NEW.Email WHERE Nr_Kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby); 
    UPDATE Osoby SET Nazwisko = :NEW.Nazwisko, Imie = :NEW.Imie, Data_Urodzenia = :NEW.Data_Urodzenia, PESEL = :NEW.PESEL WHERE Nr_Osoby = :NEW.Nr_Osoby;
    SELECT Nr_Specjalizacji INTO v_Nr_Specjalizacji FROM Specjalizacje WHERE nazwa_specjalizacji=:NEW.nazwa_specjalizacji;
    UPDATE Lekarze SET Specjalizacja_Nr = v_Nr_Specjalizacji;
    UPDATE Konta SET Haslo = :NEW.Haslo WHERE Osoba_Nr = :NEW.Nr_Osoby;
WHEN DELETING THEN
    DELETE FROM Lekarze WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Konta WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Sesje WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby; 
    DELETE FROM Adresy WHERE Nr_Adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby);
    DELETE FROM Kontakty WHERE Nr_Kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby);
END CASE;
END;
/

select * from lekarze_view;
delete lekarze_view where nr_osoby=7;