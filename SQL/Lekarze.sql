CREATE OR REPLACE VIEW Lekarze_view AS
SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy, specjalizacje.nazwa_specjalizacji, specjalizacje.opis, lekarze.nr_lekarza
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby = Konta.Osoba_Nr
        INNER JOIN Lekarze ON osoby.nr_osoby = lekarze.osoba_Nr
        INNER JOIN Specjalizacje ON lekarze.Specjalizacja_Nr = specjalizacje.nr_specjalizacji;
        
        
CREATE OR REPLACE TRIGGER Lekarz_add_trigger
INSTEAD OF INSERT ON Lekarze_view
FOR EACH ROW
DECLARE
v_Nr_Specjalizacji specjalizacje.nr_specjalizacji%TYPE;
BEGIN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.NEXTVAL, :NEW.Miasto, :NEW.Ulica, :NEW.Nr_Domu, :NEW.Nr_Mieszkania, :NEW.Kod_Pocztowy);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.NEXTVAL, :NEW.Telefon, :NEW.Email);
    INSERT INTO Osoby VALUES (OSOBY_SEQUENCE.NEXTVAL, :NEW.Nazwisko, :NEW.Imie, :NEW.Data_Urodzenia, :NEW.PESEL, ADRESY_SEQUENCE.currval, KONTAKTY_SEQUENCE.currval);
    --INSERT INTO Specjalizacje VALUES(Specjalizacje_sequence.NEXTVAL, :NEW.Nazwa_Specjalizacji, :NEW.Opis); 
    SELECT Nr_Specjalizacji INTO v_Nr_Specjalizacji FROM Specjalizacje WHERE nazwa_specjalizacji=:NEW.nazwa_specjalizacji;
    INSERT INTO Lekarze VALUES (Lekarze_sequence.NEXTVAL, OSOBY_SEQUENCE.currval, v_nr_specjalizacji);
    INSERT INTO Konta VALUES (KONTA_SEQUENCE.NEXTVAL, :NEW.Login, :NEW.Haslo, 'lekarz', OSOBY_SEQUENCE.CURRVAL);
END;
/
