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

CREATE SEQUENCE Leki_sequence
INCREMENT BY 1
START WITH 1
NOCYCLE;


CREATE TABLE Adresy(
    Nr_Adresu NUMERIC PRIMARY KEY,
    Miasto NVARCHAR2(40) NOT NULL,
    Ulica NVARCHAR2(50) NOT NULL,
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
     CONSTRAINT Adres_fk FOREIGN KEY(Adres_Nr) REFERENCES Adresy(Nr_Adresu) ON DELETE CASCADE,
     CONSTRAINT Kontakt_fk FOREIGN KEY(Kontakt_Nr) REFERENCES Kontakty(Nr_Kontaktu) ON DELETE CASCADE
    );
    
CREATE TABLE Specjalizacje (
    Nr_Specjalizacji NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nazwa_Specjalizacji NVARCHAR2(40) NOT NULL UNIQUE,
    Opis NVARCHAR2(500)
);

CREATE TABLE Pacjenci(
    Nr_Karty_Pacjenta NUMBER PRIMARY KEY,
    Osoba_Nr NUMBER NOT NULL,
    CONSTRAINT Osoba_fk FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
    );
    
CREATE TABLE Recepty(
    Nr_Recepty Number GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Wizyta_Nr Number NOT NULL,
    Data_Wystawienia DATE  DEFAULT SYSDATE,
    Data_Waznosci DATE  DEFAULT SYSDATE+30,
    Zalecenia NVARCHAR2(256)
);
	
CREATE TABLE Lekarze(
    Nr_Lekarza NUMBER PRIMARY KEY,
    Osoba_Nr NUMBER NOT NULL,
    Specjalizacja_Nr NUMBER NOT NULL,
    Ostatnia_Recepta NUMBER,
    CONSTRAINT Osoba_fk_Lekarze FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby),
    CONSTRAINT Recepta_fk_Lekarze FOREIGN KEY(Ostatnia_Recepta) REFERENCES Recepty(Nr_Recepty),
    CONSTRAINT Specjalizacja_fk FOREIGN KEY(Specjalizacja_Nr) REFERENCES Specjalizacje(Nr_Specjalizacji)
    );
    
CREATE TABLE Konta(
    id_Konta NUMBER PRIMARY KEY,
    login NVARCHAR2(30) UNIQUE,
    haslo NVARCHAR2(32) NOT NULL,
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

CREATE TABLE Producenci_Lekow(
    Nr_Producenta NUMBER GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    Nazwa_Producenta NVARCHAR2(100) NOT NULL UNIQUE,
    Adres_Nr NUMBER NOT NULL,
    Kontakt_NR NUMBER NOT NULL,
    CONSTRAINT Adres_fk_Produc FOREIGN KEY(Adres_Nr) REFERENCES Adresy(Nr_Adresu),
    CONSTRAINT Kontakt_fk_Produc FOREIGN KEY(Kontakt_Nr) REFERENCES Kontakty(Nr_Kontaktu)
);

CREATE TABLE Leki(
    Nr_Leku NUMBER PRIMARY KEY,
    Nazwa_Leku NVARCHAR2(256) NOT NULL,
    Producent_Nr NUMBER NOT NULL,
    Opis NVARCHAR2(500),
    CONSTRAINT Produc_fk_Leki FOREIGN KEY(Producent_Nr) REFERENCES Producenci_Lekow(Nr_Producenta)
);

CREATE TABLE Leki_Z_Apteki(
    Lek_Nr NUMBER NOT NULL,
    Cena NUMERIC(5,2) NOT NULL,
    Zdjecie VARCHAR2(512),
    Odnosnik VARCHAR2(512),
    CONSTRAINT Leki_fk_Apteka FOREIGN KEY(Lek_Nr) REFERENCES Leki(Nr_Leku)
);


CREATE TABLE Lek_Na_Recepte(
    Recepta_Nr NUMBER NOT NULL,
    Lek_Nr NUMBER,
    CONSTRAINT Lek_NR_fk FOREIGN KEY(Lek_Nr) REFERENCES Leki(Nr_Leku) ON DELETE SET NULL,
    CONSTRAINT Recepta_fk FOREIGN KEY(Recepta_Nr) REFERENCES Recepty(Nr_Recepty),
    CONSTRAINT LekRec UNIQUE (Recepta_Nr, Lek_Nr)
);

CREATE TABLE Wizyty(
Nr_Wizyty Number GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
Lekarz_Nr Number,
Pacjent_Nr Number,
Data_Wizyty DATE NOT NULL,
Opis NVARCHAR2(256),
Czy_Odbyta NVARCHAR2(16) DEFAULT 'Zaplanowana',
CONSTRAINT Lekarz_fk_Wizyty FOREIGN KEY(Lekarz_Nr) REFERENCES Lekarze(Nr_Lekarza) ON DELETE SET NULL,
CONSTRAINT Pacjent_fk_Wizyty FOREIGN KEY(Pacjent_Nr) REFERENCES Pacjenci(Nr_Karty_Pacjenta) ON DELETE SET NULL
);

CREATE OR REPLACE TRIGGER check_dates_trigger
  BEFORE INSERT OR UPDATE ON Osoby
  FOR EACH ROW
BEGIN
  IF( :new.Data_Urodzenia > SYSDATE )
  THEN
    RAISE_APPLICATION_ERROR( -20001, 
          'Błędna data urodzenia: Data w polu data urodzenia musi byc mniejsza lub rowna aktualnej:' );
  END IF;
END;
/

CREATE OR REPLACE TRIGGER check_Wizyty_dates_trigger
  BEFORE INSERT ON Wizyty
  FOR EACH ROW
BEGIN
  IF( :new.Data_Wizyty < SYSDATE )
  THEN
    RAISE_APPLICATION_ERROR( -20002, 
          'Błędna data wizyty: Data w polu data wizyty musi być większa lub równa aktualnej:' );
  END IF;
END;
/