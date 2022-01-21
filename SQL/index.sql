--%0
--SELECT NAZWA_SPECJALIZACJI FROM specjalizacje ORDER BY NAZWA_SPECJALIZACJI;
--%1 
--SELECT dwaj_lekarze_info() FROM dual;
--%2
--SELECT NajczesciejOdwiedzanajacyPacjent() FROM dual;
--%3
--SELECT NajczesciejOdwiedzaniLekarze() FROM dual;
--%4
--SELECT COUNT(Nr_leku) Ilosc_lekow FROM leki;
--%5
--SELECT NajwPrzepLek FROM DUAL;
--%6
--SELECT NajdrozszyLek() FROM dual
--%7
--SELECT NajczestszaGodzWizyt FROM DUAL;
--%8
--SELECT * FROM dostepne_godz;

--Proste selekty
--SELECT Zliczenia FROM DUAL;
CREATE OR REPLACE FUNCTION Zliczenia RETURN NVARCHAR2
IS
lekarze NUMBER;
pacjenci NUMBER;
wizyty NUMBER;
recepty NUMBER;
output NVARCHAR2(1000);
BEGIN
SELECT COUNT(NR_LEKARZA) INTO lekarze FROM LEKARZE;
SELECT COUNT(NR_karty_pacjenta) INTO pacjenci FROM PACJENCI;
SELECT COUNT(NR_WIZYTY) INTO wizyty FROM WIZYTY;
SELECT COUNT(NR_Recepty) INTO recepty FROM RECEPTY;
output:= '<br>Ilość lekarzy: '||lekarze||'<br>Ilość pacjentów: '||pacjenci||'<br>Ilość wizyt: '||wizyty||'<br>Ilość wypisanych recept: '||recepty;
RETURN output;
END;
/

--%1

CREATE OR REPLACE FUNCTION dwaj_lekarze_info RETURN NVARCHAR2
IS
CURSOR LekarzeImieNazSpec IS SELECT rownum kolumna, imie , nazwisko, NAZWA_SPECJALIZACJI specjalizacja FROM Lekarze
	INNER JOIN Osoby ON Osoby.Nr_Osoby = Lekarze.Osoba_nr
	INNER JOIN Specjalizacje ON Specjalizacje.Nr_Specjalizacji = Lekarze.Specjalizacja_nr;
imie1 Osoby.imie%type;
imie2 Osoby.imie%type;
spec1 Specjalizacje.NAZWA_SPECJALIZACJI%type;
spec2 Specjalizacje.NAZWA_SPECJALIZACJI%type;
nazw1 Osoby.nazwisko%type;
nazw2 Osoby.nazwisko%type;
output NVARCHAR2(1000);
BEGIN
FOR rec IN LekarzeImieNazSpec LOOP
	IF(rec.kolumna=1) THEN
		imie1:=rec.imie;
		nazw1:=rec.nazwisko;
		spec1:=rec.specjalizacja;
	END IF;
	IF(rec.kolumna=2) THEN
		imie2:=rec.imie;
		nazw2:=rec.nazwisko;
		spec2:=rec.specjalizacja;
	END IF;
END LOOP;
output:=imie1||' '||nazw1||' - '||spec1||', '||imie2||' '||nazw2||' - '||spec2;
RETURN output;
END;
/

--SELECT dwaj_lekarze_info() FROM dual;

--%2
CREATE OR REPLACE FUNCTION NajczesciejOdwiedzanajacyPacjent RETURN NVARCHAR2
IS
CURSOR PacImieNazOdw IS SELECT imie, nazwisko, count(Pacjent_Nr) Ilosc_Wizyt FROM wizyty
    INNER JOIN Pacjenci ON Pacjenci.NR_KARTY_PACJENTA = Wizyty.Pacjent_Nr
    INNER JOIN Osoby ON Osoby.Nr_Osoby = Pacjenci.Osoba_Nr
    WHERE wizyty.Czy_Odbyta='Odbyta'
    GROUP BY Pacjent_Nr, imie, nazwisko;
imie Osoby.imie%type;
nazw Osoby.nazwisko%type;
Ilosc_Wizyt NUMBER :=0;
output NVARCHAR2(1000);
BEGIN
FOR rec IN PacImieNazOdw LOOP
    IF(rec.Ilosc_Wizyt>Ilosc_Wizyt) THEN
        imie:=rec.imie;
        nazw:=rec.nazwisko;
        Ilosc_Wizyt:=rec.Ilosc_Wizyt;
    END IF;
END loop;
output:=imie||' '||nazw||' Ilosc wizyt: '||Ilosc_Wizyt;
RETURN output;
END;
/

--SELECT NajczesciejOdwiedzanajacyPacjent() FROM dual;

--%3
CREATE OR REPLACE FUNCTION NajczesciejOdwiedzaniLekarze RETURN NVARCHAR2
IS
CURSOR LekarzeImieNazSpecOdw IS SELECT imie, nazwisko, NAZWA_SPECJALIZACJI specjalizacja, count(Lekarz_Nr) Ilosc_Wizyt FROM wizyty
    INNER JOIN Lekarze ON Lekarze.Nr_Lekarza = Wizyty.Lekarz_Nr
    INNER JOIN Osoby ON Osoby.Nr_Osoby = Lekarze.Osoba_Nr
    INNER JOIN Specjalizacje ON Specjalizacje.Nr_Specjalizacji = Lekarze.Specjalizacja_nr
    WHERE wizyty.Czy_Odbyta='Odbyta'
    GROUP BY Lekarz_Nr, imie, nazwisko, NAZWA_SPECJALIZACJI;
imie1 Osoby.imie%type;  imie2 Osoby.imie%type;  imie3 Osoby.imie%type;  imie4 Osoby.imie%type;
nazw1 Osoby.nazwisko%type;  nazw2 Osoby.nazwisko%type;  nazw3 Osoby.nazwisko%type;  nazw4 Osoby.nazwisko%type;
spec1 Specjalizacje.NAZWA_SPECJALIZACJI%type;   spec2 Specjalizacje.NAZWA_SPECJALIZACJI%type;
spec3 Specjalizacje.NAZWA_SPECJALIZACJI%type;   spec4 Specjalizacje.NAZWA_SPECJALIZACJI%type;
Ilosc_Wizyt1 NUMBER :=0;    Ilosc_Wizyt2 NUMBER :=0;    Ilosc_Wizyt3 NUMBER :=0;    Ilosc_Wizyt4 NUMBER :=0;
output NVARCHAR2(1000);
BEGIN
FOR rec IN LekarzeImieNazSpecOdw LOOP
    IF(rec.Ilosc_Wizyt>Ilosc_Wizyt1) THEN
        imie1:=rec.imie;    nazw1:=rec.nazwisko;    spec1:=rec.specjalizacja;   Ilosc_Wizyt1:=rec.Ilosc_Wizyt;
    ELSIF(rec.Ilosc_Wizyt>Ilosc_Wizyt2 AND rec.Ilosc_Wizyt<=Ilosc_Wizyt1) THEN
        imie2:=rec.imie;    nazw2:=rec.nazwisko;    spec2:=rec.specjalizacja;   Ilosc_Wizyt2:=rec.Ilosc_Wizyt;
    ELSIF(rec.Ilosc_Wizyt>Ilosc_Wizyt3 AND rec.Ilosc_Wizyt<=Ilosc_Wizyt2) THEN
        imie3:=rec.imie;    nazw3:=rec.nazwisko;    spec3:=rec.specjalizacja;   Ilosc_Wizyt3:=rec.Ilosc_Wizyt;
    ELSIF(rec.Ilosc_Wizyt>Ilosc_Wizyt4 AND rec.Ilosc_Wizyt<=Ilosc_Wizyt3) THEN
        imie4:=rec.imie;    nazw4:=rec.nazwisko;    spec4:=rec.specjalizacja;   Ilosc_Wizyt4:=rec.Ilosc_Wizyt;
    END IF;
END loop;
output:='<br>'||imie1||' '||nazw1||' - '||spec1||' Ilosc wizyt: '||Ilosc_Wizyt1|| '<br>' ||imie2||' '||nazw2||' - '||spec2||' Ilosc wizyt: '||Ilosc_Wizyt2
|| '<br>' ||imie3||' '||nazw3||' - '||spec3||' Ilosc wizyt: '||Ilosc_Wizyt3|| '<br>' ||imie4||' '||nazw4||' - '||spec4||' Ilosc wizyt: '||Ilosc_Wizyt4;
RETURN output;
END;
/

--SELECT NajczesciejOdwiedzaniLekarze() FROM dual;

--%4
--SELECT COUNT(Nr_leku) Ilosc_lekow FROM leki;

--%5
CREATE OR REPLACE VIEW NajPrzepLek AS
SELECT Leki.NAZWA_LEKU ,COUNT(Lek_NR) Ilosc_Przepisan FROM LEK_NA_RECEPTE
INNER JOIN LEKI ON Lek_Nr=LEKI.NR_Leku 
GROUP BY Lek_NR,Leki.NAZWA_LEKU
FETCH FIRST ROW ONLY;

--SELECT * FROM NajPrzepLek;

CREATE OR REPLACE FUNCTION NajwPrzepLek RETURN NVARCHAR2
IS
nazwa LEKI.NAZWA_LEKU%TYPE;
Il_Przepisan NUMBER;
output NVARCHAR2(1000);
BEGIN
SELECT Leki.NAZWA_LEKU ,COUNT(Lek_NR) Ilosc_Przepisan INTO nazwa,Il_Przepisan FROM LEK_NA_RECEPTE
INNER JOIN LEKI ON Lek_Nr=LEKI.NR_Leku 
GROUP BY Lek_NR,Leki.NAZWA_LEKU
FETCH FIRST ROW ONLY;
output:=nazwa||' - Ilość przepisań: '||Il_Przepisan;
RETURN output;
END;
/

--SELECT NajwPrzepLek FROM DUAL;
--%6

CREATE OR REPLACE FUNCTION NajdrozszyLek RETURN NVARCHAR2
IS
CURSOR LekCena IS SELECT NAZWA_LEKU,CENA  FROM LEKI_Z_APTEKI
    INNER JOIN LEKI ON LEKI.NR_LEKU=LEKI_Z_APTEKI.Lek_NR;
najdrozszy NUMBER :=0;
nazwa LEKI.NAZWA_LEKU%TYPE;
output NVARCHAR2(1000);
BEGIN
FOR rec IN LekCena LOOP
    IF(rec.cena>najdrozszy)THEN
        najdrozszy:=rec.cena;
        nazwa:=rec.NAZWA_LEKU;
    END IF;
END LOOP;
output:=nazwa||' - Cena: '||najdrozszy||' PLN';
RETURN output;
END;
/
--SELECT NajdrozszyLek() FROM dual;
--%7

CREATE OR REPLACE FUNCTION NajczestszaGodzWizyt RETURN NVARCHAR2
AS
godz NVARCHAR2 (10);
Il_wizyt NUMBER;
output NVARCHAR2(1000);
BEGIN
SELECT TO_CHAR(DATA_WIZYTY,'HH24:MI') godzina, count(TO_CHAR(DATA_WIZYTY,'HH24:MI')) Ilosc_wizyt INTO godz, Il_wizyt FROM WIZYTY
GROUP BY TO_CHAR(DATA_WIZYTY,'HH24:MI') FETCH FIRST ROW ONLY;
output:=godz||'. Ilość wizyt odbytych o tej godzinie: '||Il_wizyt||'.';
RETURN output;
END;
/

--SELECT NajczestszaGodzWizyt FROM DUAL;
--%8
/*SELECT * FROM dostepne_godz;*/