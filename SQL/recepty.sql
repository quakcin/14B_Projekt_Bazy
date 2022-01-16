/*INSERT INTO Recepty (Wizyta_Nr) VALUES (12);
INSERT INTO Lek_Na_Recepte VALUES (3,218);
INSERT INTO Lek_Na_Recepte VALUES (3,203);
INSERT INTO Lek_Na_Recepte VALUES (3,260);
INSERT INTO Lek_Na_Recepte VALUES (3,17);*/




CREATE OR REPLACE VIEW Pacjent_Recepty AS
SELECT recepty.nr_recepty, wizyty.nr_wizyty, leki.nazwa_leku, recepty.zalecenia, osoby.imie, osoby.nazwisko, recepty.data_waznosci, Wizyty.pacjent_nr FROM Recepty
LEFT JOIN Lek_Na_Recepte ON lek_na_recepte.recepta_nr = recepty.nr_recepty
LEFT JOIN Leki ON leki.nr_leku = lek_na_recepte.lek_nr
INNER JOIN Wizyty ON wizyty.nr_wizyty = recepty.wizyta_nr
INNER JOIN Lekarze ON lekarze.nr_lekarza = wizyty.lekarz_nr
INNER JOIN Osoby ON osoby.nr_osoby = lekarze.osoba_nr;

/*SELECT * FROM Pacjent_Recepty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 2);*/

/*SELECT TO_CHAR(SYSDATE, 'yyyy-MM-dd') , TO_CHAR(SYSDATE+30, 'yyyy-MM-dd'), '' FROM DUAL; */


CREATE OR REPLACE VIEW ReceptyLekarza AS
SELECT Nr_Recepty, Osoba_Nr FROM recepty
INNER JOIN Wizyty ON wizyty.nr_wizyty = recepty.wizyta_nr
INNER JOIN Lekarze ON Lekarze.Nr_Lekarza = Wizyty.lekarz_nr;

SELECT Nr_Recepty FROM ReceptyLekarza WHERE Osoba_Nr = 18;