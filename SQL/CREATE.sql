CREATE SEQUENCE Adresy_sequence
INCREMENT BY 1
START WITH 2
NOCYCLE;

CREATE SEQUENCE Kontakty_sequence
INCREMENT BY 1
START WITH 2
NOCYCLE;

CREATE SEQUENCE Konta_sequence
INCREMENT BY 1
START WITH 2
NOCYCLE;

CREATE SEQUENCE Osoby_sequence
INCREMENT BY 1
START WITH 2
NOCYCLE;

CREATE SEQUENCE Pacjenci_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;

CREATE SEQUENCE Lekarze_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;


CREATE TABLE Adresy(
    Nr_Adresu NUMERIC PRIMARY KEY,
    Miasto NVARCHAR2(30) NOT NULL,
    Ulica NVARCHAR2(30) NOT NULL,
    Nr_Domu NVARCHAR2(5) NOT NULL,
    Nr_Mieszkania NVARCHAR2(5),
    Kod_Pocztowy NVARCHAR2(6) NOT NULL
);

CREATE TABLE Kontakty(
    Nr_Kontaktu NUMBER PRIMARY KEY,
    Telefon NVARCHAR2(9),
    Email NVARCHAR2(40)
);

CREATE TABLE Osoby(
     Nr_Osoby NUMBER PRIMARY KEY,
     Nazwisko NVARCHAR2(40) NOT NULL,
     Imie NVARCHAR2(30) NOT NULL,
     Data_Urodzenia DATE NOT NULL,
     PESEL NVARCHAR2(11) NOT NULL UNIQUE,
     Adres_Nr NUMBER NOT NULL,
     Kontakt_NR NUMBER NOT NULL,
     CONSTRAINT Adres_fk FOREIGN KEY(Adres_Nr) REFERENCES Adresy(Nr_Adresu),
     CONSTRAINT Kontakt_fk FOREIGN KEY(Kontakt_Nr) REFERENCES Kontakty(Nr_Kontaktu)
    );
    
CREATE TABLE Specjalizacje (
    Nr_Specjalizacji NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nazwa_Specjalizacji NVARCHAR2(40) NOT NULL,
    Opis NVARCHAR2(500)
);

CREATE TABLE Pacjenci(
    Nr_Karty_Pacjenta NUMBER PRIMARY KEY,
    Osoba_Nr NUMBER NOT NULL,
    CONSTRAINT Osoba_fk FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
    );
	
CREATE TABLE Lekarze(
    Nr_Lekarza NUMBER PRIMARY KEY,
    Osoba_Nr NUMBER NOT NULL,
    Specjalizacja_Nr NUMBER NOT NULL,
    CONSTRAINT Osoba_fk_Lekarze FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby),
    CONSTRAINT Specjalizacja_fk FOREIGN KEY(Specjalizacja_Nr) REFERENCES Specjalizacje(Nr_Specjalizacji)
    );
    
CREATE TABLE Konta(
    id_Konta NUMBER PRIMARY KEY,
    login NVARCHAR2(30) UNIQUE,
    haslo NVARCHAR2(32),
    typ_konta NVARCHAR2(10),
    Osoba_Nr NUMBER NOT NULL,
    CONSTRAINT check_account_type CHECK( typ_konta IN('admin', 'lekarz', 'pacjent')),
    CONSTRAINT Osoba_fk_Konta FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
);

CREATE TABLE Sesje(
    Id_Sesji NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    token NVARCHAR2(32) UNIQUE NOT NULL,
    EXPR DATE DEFAULT SYSDATE+1 NOT NULL,
    Osoba_Nr NUMBER,
    CONSTRAINT Osoba_fk_Sesje FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
);




CREATE OR REPLACE TRIGGER check_dates_trigger
  BEFORE INSERT OR UPDATE ON Osoby
  FOR EACH ROW
BEGIN
  IF( :new.Data_Urodzenia > SYSDATE )
  THEN
    RAISE_APPLICATION_ERROR( -20001, 
          'Błędna data urodzenia: Data w polu data urodzenia musi być mniejsza lub równa aktualnej:' );
  END IF;
END;
/