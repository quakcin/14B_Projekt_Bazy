CREATE TABLE Konta(
    id_Konta NUMBER PRIMARY KEY,
    login NVARCHAR2(30) UNIQUE,
    haslo NVARCHAR2(32),
    typ_konta NVARCHAR2(10),
    Osoba_Nr NUMBER,
    CONSTRAINT check_account_type CHECK( typ_konta IN('admin', 'lekarz', 'pacjent')),
    CONSTRAINT Osoba_fk_Konta FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
);

CREATE TABLE Sesje(
    Id_Sesji NUMBER PRIMARY KEY,
    token NVARCHAR2(16) UNIQUE,
    EXPR DATE,
    Osoba_Nr NUMBER,
    CONSTRAINT Osoba_fk_Sesje FOREIGN KEY(Osoba_Nr) REFERENCES Osoby(Nr_Osoby)
);

INSERT INTO Konta VALUES(1, 'PACJENT1', 'HASLOP1', 'pacjent', 1);

INSERT INTO Sesje VALUES (1, 'ABC', sysdate+1, 1);
