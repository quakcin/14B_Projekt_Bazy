insert into umawianie (lekarz_nr, pacjent_nr, Data_wizyty) values (1,1,sysdate);
select * from umawianie;

insert into spotkanie (lekarz_nr, pacjent_nr, Data_wizyty) values (1,1,sysdate);
select * from spotkanie;

/*--USP Zdrowie sp. z o.o.
insert into leki (Nazwa_Leku, Producent_Nr) values ('Apap',1);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Ibuprom',1);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Gripex',1);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Stoperan',1);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Verdin',1);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Xenna',1);
--Pelion S.A.
insert into leki (Nazwa_Leku, Producent_Nr) values ('Florcontrol',3);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witamina D3 2000',3);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witamina A+E',3);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witamina C',3);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Magnez+B6',3);
--Neuca S.A.
insert into leki (Nazwa_Leku, Producent_Nr) values ('Krem do rak z oliwa z oliwek',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Woda morksa',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Krem do stop z macznikiem',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Multi flora',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('AquaAPTEO',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witamina D 2000 Forte',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witaminy dla niej',4);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Witaminy dla niego',4);
--Celon Pharma
insert into leki (Nazwa_Leku, Producent_Nr) values ('Donepex',5);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Ketrel',5);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Lazivir',5);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Salmex',5);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Valzek',5);
--Farmacol
insert into leki (Nazwa_Leku, Producent_Nr) values ('Maximum total',6);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Artresan',6);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Koenzym Q10',6);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Protefix',6);
--Grupa Adamed
insert into leki (Nazwa_Leku, Producent_Nr) values ('Kerdex',7);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Hitaxa Fast',7);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Anesteloc',7);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Recigar',7);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Ibupar Forte',7);
insert into leki (Nazwa_Leku, Producent_Nr) values ('Nervomix',7);

select * from leki;

create or replace procedure add_leki_apteki
IS
i NUMBER := 1;
n_lek_nr NUMBER;
n_cena NUMBER(4,2);
BEGIN
FOR i IN 1 .. 20
LOOP
    n_lek_nr := i;
    n_cena := dbms_random.value(0,70);
    INSERT INTO Leki_Z_Apteki(lek_nr, cena)
    VALUES(n_lek_nr, n_cena);
END LOOP;
END;
/
execute add_leki_apteki;
select * from Leki_Z_Apteki;*/

--wizyty bez opisow

CREATE TABLE dostepne_godz(
godz NVARCHAR2(20)
);
INSERT INTO dostepne_godz VALUES ('10:00');
INSERT INTO dostepne_godz VALUES ('11:30');
INSERT INTO dostepne_godz VALUES ('13:00');
INSERT INTO dostepne_godz VALUES ('14:30');
INSERT INTO dostepne_godz VALUES ('16:00');
INSERT INTO dostepne_godz VALUES ('17:30');
INSERT INTO dostepne_godz VALUES ('19:00');
SELECT * FROM dostepne_godz;

ALTER SESSION SET nls_date_format = 'dd.mm.yyyy';
DROP PROCEDURE Zad2;
CREATE OR REPLACE PROCEDURE dodaj_wizyte_random
IS
dni NVARCHAR2(80);
godziny NVARCHAR2(80);
data_wizyty NVARCHAR2(80);
BEGIN
SELECT to_char(sysdate + round(dbms_random.VALUE(1,30))) INTO dni FROM dual;
SELECT * INTO godziny FROM(SELECT * FROM dostepne_godz ORDER BY DBMS_RANDOM.RANDOM) WHERE  ROWNUM < 2;
data_wizyty := (dni||' '||godziny);
INSERT INTO Wizyty (lekarz_nr, pacjent_nr, Data_wizyty) VALUES(round(DBMS_RANDOM.VALUE(1,4)),round(DBMS_RANDOM.VALUE(1,5)),
TO_DATE(data_wizyty,'DD.MM.YYYY HH24:MI'));
END;
/
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;
EXECUTE dodaj_wizyte_random;


DROP TABLE dostepne_godz;
DROP PROCEDURE dodaj_wizyte_random;
ALTER SESSION SET nls_date_format = 'dd-mm-yyyy';
SELECT * FROM wizyty;