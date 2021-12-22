/*--DROPY
DROP TABLE Adresy CASCADE CONSTRAINTS;
DROP TABLE Kontakty CASCADE CONSTRAINTS;
DROP TABLE Osoby CASCADE CONSTRAINTS;

--SEKWENCJE
CREATE SEQUENCE Adresy_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;

CREATE SEQUENCE Kontakty_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;

CREATE SEQUENCE Osoby_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;

CREATE SEQUENCE Pacjenci_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;

--CREATE
CREATE TABLE Adresy(
    Nr_Adresu NUMERIC DEFAULT Adresy_sequence.nextval PRIMARY KEY,
    Miasto NVARCHAR2(30) NOT NULL,
    Ulica NVARCHAR2(30) NOT NULL,
    Nr_Domu NUMBER NOT NULL,
    Nr_Mieszkania NUMBER,
    Kod_Pocztowy NVARCHAR2(6) NOT NULL
);

CREATE TABLE Kontakty(
    Nr_Kontaktu NUMBER DEFAULT Kontakty_sequence.nextval PRIMARY KEY,
    Telefon NVARCHAR2(9),
    Email NVARCHAR2(40)
);

CREATE TABLE Osoby(
     Nr_Osoby NUMBER DEFAULT Osoby_sequence.nextval PRIMARY KEY,
     Nazwisko NVARCHAR2(40) NOT NULL,
     Imie NVARCHAR2(30) NOT NULL,
     Data_Urodzenia DATE NOT NULL,
     PESEL NVARCHAR2(11) NOT NULL UNIQUE,
     Adres_Nr NUMBER NOT NULL,
     Kontakt_NR NUMBER NOT NULL, 
     CONSTRAINT Adres_fk FOREIGN KEY(Adres_Nr) REFERENCES Adresy(Nr_Adresu),
     CONSTRAINT Kontakt_fk FOREIGN KEY(Kontakt_Nr) REFERENCES Kontakty(Nr_Kontaktu)
    );
    
CREATE TABLE Pacjenci(
    Nr_Karty_Pacjenta NUMBER DEFAULT Pacjenci_sequence.nextval PRIMARY KEY,
    Osoba_Nr NUMBER NOT NULL,
    CONSTRAINT Osoba_fk FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
    );
    

CREATE OR REPLACE VIEW Osoba_Informacje AS
SELECT  osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy
        FROM Osoby
        INNER JOIN Adresy on osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty on osoby.kontakt_nr = kontakty.nr_kontaktu;



CREATE OR REPLACE PROCEDURE DodajPacjenta(p_imie osoby.imie%TYPE, p_nazwisko osoby.nazwisko%TYPE, p_data_ur date, 
p_PESEL osoby.pesel%TYPE, p_telefon kontakty.telefon%TYPE, p_mail kontakty.email%TYPE, p_miasto adresy.miasto%TYPE, 
p_ulica adresy.ulica%TYPE, p_nr_d adresy.nr_domu%TYPE, p_nr_m adresy.nr_mieszkania%TYPE, p_kodpoczt adresy.kod_pocztowy%TYPE)
IS
BEGIN
    INSERT INTO Adresy VALUES (ADRESY_SEQUENCE.nextval, p_miasto, p_ulica, p_nr_d, p_nr_m, p_kodpoczt);
    INSERT INTO Kontakty VALUES (KONTAKTY_SEQUENCE.nextval, p_telefon, p_mail);
    INSERT INTO Osoby VALUES (OSOBY_SEQUENCE.nextval, p_nazwisko, p_imie, p_data_ur, p_PESEL, ADRESY_SEQUENCE.curRval, KONTAKTY_SEQUENCE.curRval);
END;
/
EXECUTE DodajPacjenta('Andrzej', 'Niewulis', sysdate-5, '44552213698', '888444111', 'aa@wp.pl', 'Czêstochowa', 'Limanowskiego', 7, NULL, '74-841');
*/
SELECT * FROM OSOBY;
SELECT * FROM ADRESY;
SELECT * FROM KONTAKTY;
SELECT * FROM osoba_informacje;
