INSERT INTO Recepty (Wizyta_Nr) VALUES (1); 
INSERT INTO Lek_Na_Recepte(Recepta_Nr, Lek_Nr) VALUES (3,1);
INSERT INTO Lek_Na_Recepte(Recepta_Nr, Lek_Nr) VALUES (3,2);
INSERT INTO Lek_Na_Recepte(Recepta_Nr, Lek_Nr) VALUES (3,3);

CREATE OR REPLACE VIEW Pacjent_Recepty AS
SELECT recepty.nr_recepty, wizyty.nr_wizyty, leki.nazwa_leku, osoby.imie, osoby.nazwisko, recepty.data_waznosci, Wizyty.pacjent_nr FROM Recepty
INNER JOIN Lek_Na_Recepte ON lek_na_recepte.recepta_nr = recepty.nr_recepty
INNER JOIN Leki ON leki.nr_leku = lek_na_recepte.lek_nr
INNER JOIN Wizyty ON wizyty.nr_wizyty = recepty.wizyta_nr
INNER JOIN Lekarze ON lekarze.nr_lekarza = wizyty.lekarz_nr
INNER JOIN Osoby ON osoby.nr_osoby = lekarze.osoba_nr;


--SELECT * FROM Pacjent_Recepty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = 2);