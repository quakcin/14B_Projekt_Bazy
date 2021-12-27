CREATE OR REPLACE PROCEDURE add_session(p_login Konta.login%TYPE, p_haslo Konta.haslo%TYPE, p_token sesje.token%TYPE)
IS
    osoba_id osoby.nr_osoby%TYPE;
    count_ac NUMERIC;
    count_ses NUMERIC;
BEGIN

    SELECT COUNT(id_konta) INTO count_ac FROM Konta WHERE login=p_login and haslo=p_haslo;
    SELECT COUNT(sesje.Osoba_Nr) INTO count_ses FROM Sesje INNER JOIN Konta on sesje.osoba_nr=konta.osoba_nr WHERE login=p_login and haslo=p_haslo;
    IF count_ac > 0 and count_ses < 3 THEN
        SELECT Osoba_Nr INTO osoba_id FROM KONTA WHERE login=p_login and haslo=p_haslo;
        INSERT INTO Sesje (token, Osoba_Nr) VALUES (p_token, (SELECT Osoba_Nr FROM KONTA WHERE login=p_login));
    END IF;
    
END;
/

--EXECUTE add_session('PACJENT1','HASLOP1', '7858588'); 