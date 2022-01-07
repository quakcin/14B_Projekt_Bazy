/*KURSOR nr 1: Funkcja operujaca na kursorze zwraca ilosc lekow na recepte które zostay wystawione w ciagu ostatniego miesiaca.*/

CREATE OR REPLACE FUNCTION ZestawienieMiesieczneLeki_ILOSC
RETURN NUMBER
IS
CURSOR ReceptyOstatniMiesiac IS
SELECT * FROM Recepty
INNER JOIN Lek_Na_Recepte ON lek_na_recepte.recepta_nr = recepty.nr_recepty
WHERE recepty.data_wystawienia >= sysdate-30;
v_ilosc NUMBER := 0;
BEGIN
FOR lek IN ReceptyOstatniMiesiac LOOP
v_ilosc := v_ilosc + 1;
END LOOP;
RETURN v_ilosc;
END;
/

SELECT ZestawienieMiesieczneLeki_ILOSC from dual;

/*KURSOR nr 2: Funkcja operujaca na kursorze zwraca srednia ilosc lekow wystawionych na jedna recepte w ciagu ostatniego miesiaca.*/

CREATE OR REPLACE FUNCTION ZestawienieMiesieczneLeki_SREDNIA
RETURN NUMBER
IS
CURSOR ReceptyIloscLekow IS
SELECT recepty.nr_recepty, count(lek_na_recepte.lek_nr) as il_lekow FROM Recepty
INNER JOIN Lek_Na_Recepte ON lek_na_recepte.recepta_nr = recepty.nr_recepty
WHERE recepty.data_wystawienia >= sysdate-30
GROUP BY recepty.nr_recepty;
v_ilosc NUMBER := 0;
v_counter NUMBER := 0;
v_result DECIMAL(4,2);
BEGIN
FOR rec IN ReceptyIloscLekow LOOP
v_ilosc := v_ilosc + rec.il_lekow;
v_counter := v_counter + 1;
END LOOP;
RETURN TRUNC(v_ilosc/v_counter, 2);
END;
/

SELECT ZestawienieMiesieczneLeki_SREDNIA from dual;

CREATE OR REPLACE FUNCTION pacjent_odwiedziny_fun (nr_pacjenta pacjenci.NR_KARTY_PACJENTA%type)
RETURN NUMBER
IS
CURSOR dane IS
SELECT osoby.imie, osoby.nazwisko, nr_wizyty from wizyty
    INNER JOIN pacjenci ON  pacjenci.NR_KARTY_PACJENTA=nr_pacjenta
    INNER JOIN osoby ON osoby.nr_osoby = pacjenci.osoba_nr
    WHERE pacjent_nr=nr_pacjenta AND czy_odbyta='Odbyta';
v_odwiedziny NUMBER :=0;
BEGIN
FOR rec IN dane LOOP
v_odwiedziny := v_odwiedziny + 1;
END LOOP;
RETURN v_odwiedziny;
END;
/
--SELECT pacjent_odwiedziny_fun(1) from dual;

CREATE OR REPLACE FUNCTION pacjent_ost_wizyta (nr_pacjenta pacjenci.NR_KARTY_PACJENTA%type)
RETURN DATE
IS
CURSOR dane IS
SELECT osoby.imie, osoby.nazwisko, nr_wizyty, data_wizyty from wizyty
    INNER JOIN pacjenci ON  pacjenci.NR_KARTY_PACJENTA=nr_pacjenta
    INNER JOIN osoby ON osoby.nr_osoby = pacjenci.osoba_nr
    WHERE pacjent_nr=nr_pacjenta AND czy_odbyta='Odbyta';
v_max_data DATE := TO_DATE('01/01/1000','DD/MM/YYYY');
BEGIN
FOR rec IN dane LOOP
IF(rec.data_wizyty > v_max_data) THEN
    v_max_data:=rec.data_wizyty;
END IF;
END LOOP;
RETURN v_max_data;
END;
/
--SELECT pacjent_ost_wizyta(1) from dual;