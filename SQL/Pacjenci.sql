CREATE OR REPLACE VIEW Pacjenci_view AS
SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr
        INNER JOIN Pacjenci ON osoby.nr_osoby = pacjenci.osoba_nr;
        

CREATE OR REPLACE TRIGGER Pacjent_trigger
INSTEAD OF INSERT OR UPDATE OR DELETE ON Pacjenci_view
FOR EACH ROW
BEGIN
CASE
WHEN INSERTING THEN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.nextval, :NEW.Miasto, :NEW.Ulica, :NEW.Nr_Domu, :NEW.Nr_Mieszkania, :NEW.Kod_Pocztowy);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.nextval, :NEW.Telefon, :NEW.Email);
    INSERT INTO Osoby VALUES (OSOBY_SEQUENCE.nextval, :NEW.Nazwisko, :NEW.Imie, :NEW.Data_Urodzenia, :NEW.PESEL, ADRESY_SEQUENCE.currval, KONTAKTY_SEQUENCE.currval);
    INSERT INTO Pacjenci VALUES (PACJENCI_SEQUENCE.nextval, OSOBY_SEQUENCE.currval);
    INSERT INTO Konta VALUES (KONTA_SEQUENCE.nextval, :NEW.Login, :NEW.Haslo, 'pacjent', OSOBY_SEQUENCE.currval);
WHEN UPDATING THEN
    UPDATE Adresy SET Miasto = :NEW.Miasto, Ulica = :NEW.Ulica, Nr_Domu = :NEW.Nr_Domu, Nr_Mieszkania = :NEW.Nr_Mieszkania, Kod_Pocztowy = :NEW.Kod_Pocztowy WHERE Nr_Adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby);
    UPDATE Kontakty SET Telefon = :NEW.Telefon, Email = :NEW.Email WHERE Nr_Kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = :NEW.Nr_Osoby); 
    UPDATE Osoby SET Nazwisko = :NEW.Nazwisko, Imie = :NEW.Imie, Data_Urodzenia = :NEW.Data_Urodzenia, PESEL = :NEW.PESEL WHERE Nr_Osoby = :NEW.Nr_Osoby;
    UPDATE Konta SET Haslo = :NEW.Haslo WHERE Osoba_Nr = :NEW.Nr_Osoby;
WHEN DELETING THEN
    DELETE FROM Pacjenci WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Konta WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Sesje WHERE Osoba_Nr = :OLD.Nr_Osoby;
    DELETE FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby; 
    DELETE FROM Adresy WHERE Nr_Adresu = (SELECT Adres_Nr FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby);
    DELETE FROM Kontakty WHERE Nr_Kontaktu = (SELECT Kontakt_Nr FROM Osoby WHERE Nr_Osoby = :OLD.Nr_Osoby); 
END CASE;
END;
/


CREATE OR REPLACE VIEW reqInfo AS
SELECT  osoby.imie, osoby.nazwisko, Konta.haslo, TO_CHAR(osoby.data_urodzenia, 'yyyy-MM-dd') as "Data", osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, osoby.nr_osoby
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr;
        
SELECT * FROM reqInfo WHERE nr_osoby = 2;

SELECT imie, nazwisko, haslo, "Data", pesel, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy FROM reqPacjenci WHERE nr_osoby = 2;