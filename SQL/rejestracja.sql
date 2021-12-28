CREATE OR REPLACE PROCEDURE Pacjent_add(p_login Konta.login%TYPE, p_haslo Konta.haslo%TYPE, p_imie osoby.imie%TYPE, 
                                        p_nazwisko osoby.nazwisko%TYPE, p_data_ur osoby.data_urodzenia%TYPE, p_PESEL osoby.pesel%TYPE,
                                        p_telefon kontakty.nr_kontaktu%TYPE, p_email kontakty.telefon%TYPE, p_miasto adresy.miasto%TYPE,
                                        p_ulica adresy.ulica%TYPE, p_dom adresy.nr_domu%TYPE, p_mieszk adresy.nr_mieszkania%TYPE, p_kodPoczt adresy.kod_pocztowy%TYPE)
IS
BEGIN
    INSERT INTO Pacjenci_view 
    VALUES (p_login, p_haslo, p_imie, p_nazwisko, p_data_ur, p_PESEL, p_telefon, p_email, p_miasto, p_ulica, p_dom, p_mieszk, p_kodPoczt, NULL);
END;
/

--EXECUTE Pacjent_add('pajac', 'pajac1234', 'Tomek', 'Skalski', TO_DATE('2001-12-11', 'YYYY-MM-DD'), '01258741258', '512398521', 'szymsmi@gmail.com', 'Kielce', 'Wikaryjska', '60', NULL, '25-255');