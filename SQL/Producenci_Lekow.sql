CREATE OR REPLACE VIEW Producenci_Lekow_view AS
SELECT producenci_lekow.nr_producenta, producenci_lekow.nazwa_producenta, adresy.Kod_Pocztowy, adresy.miasto, 
    adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania,
    kontakty.email, kontakty.telefon 
    FROM producenci_lekow 
    INNER JOIN Adresy ON adresy.nr_adresu = producenci_lekow.adres_nr
    INNER JOIN Kontakty ON kontakty.nr_kontaktu = producenci_lekow.kontakt_nr;
 
 
CREATE OR REPLACE TRIGGER Producent_Lekow_add_trigger
INSTEAD OF INSERT ON Producenci_Lekow_view
FOR EACH ROW
BEGIN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.nextval, :NEW.Miasto, :NEW.Ulica, :NEW.Nr_Domu, :NEW.Nr_Mieszkania, :NEW.Kod_Pocztowy);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.nextval, :NEW.Telefon, :NEW.Email);
    INSERT INTO Producenci_Lekow (nazwa_producenta, Adres_Nr, Kontakt_NR) VALUES (:NEW.Nazwa_Producenta, ADRESY_SEQUENCE.currval, KONTAKTY_SEQUENCE.currval);
    
END;
/   

--SELECT * FROM Producenci_Lekow_view;