<?php
  /*
    Komunikator miedzy skryptami strony,
    serwerem php a baza danych.

    Obsluguje zarowno klientow zalogowanych
    jak i tych nie zalogowanych.
    
    Zawsze zwraca obiekt JSON zawierajacy
    niezbedne informacje dla JS'a osblugujacego
    projekt po stronie klienta.
  */  

  // -- Naglowek dla wyjscia

  header('Content-Type: application/json; charset=utf-8');

  //  -- Bufory Wyjscia

  $retDb = array();
  $retPacket = array();
  $retPacket['success'] = true;
  $retPacket['token'] = "nil";

  // -- Handler bledow

  function packetThrow ($errorMsg, $dbOut)
  {
    global $retPacket;
    $retPacket['success'] = false;
    $retPacket['err'] = $errorMsg;
    $retPacket['db'] = $dbOut;
    echo json_encode(
      $retPacket, 
      JSON_INVALID_UTF8_SUBSTITUTE
    );
    exit;
  }

  // -- Kontrola poprawnosci zapytania

  if (   !isset($_GET['token']) || !isset($_GET['cmd'])   )
    packetThrow("Missing token or command", []);
  else
    $retPacket['token'] = $_GET["token"];

  // -- Perser dla sql'a

  function dbRequire ($query)
  {
    global $db;
    global $retPacket;
    
    $dbRet = array();
    $parsed = @oci_parse($db, $query);

    if (!$parsed)
      packetThrow((oci_error($db))['message'], []);

    $result = @oci_execute($parsed);

    if (!$result)
      packetThrow((oci_error($parsed))['message'], []);

    $row = @oci_fetch_array(
      $parsed, 
      OCI_ASSOC+OCI_RETURN_NULLS
    );

    while ($row != false)
    {
      $col = [];
      foreach ($row as $item) 
        array_push($col, $item !== null
          ? $item
          : ""
        );
      array_push($dbRet, $col);
      $row = @oci_fetch_array(
        $parsed, 
        OCI_ASSOC+OCI_RETURN_NULLS
      );
    }
  
    $commit = @oci_commit($db);
    if (!$commit)
      packetThrow((oci_error($db))['message'], []);
  
    return $dbRet;
  }

  //  -- Polaczenie Z Baza

  $db = @oci_connect("system", "1234", "localhost/xe", "AL32UTF8");

  if (!$db)
    packetThrow((oci_error())['message'], []);


  //  -- Uwierzytelnianie

  $retPacket['acType'] = "brak"; // -- czyli niezalogowany!
                                 // -- pacjent
                                 // -- lekarz
                                 // -- admin

  function verifyToken () // -- TO-DO:  Usuwanie wygaslych sesji.
  {
    global $retPacket;

    $verfTokn = "select Konta.typ_konta, Sesje.Osoba_Nr from Sesje
                 INNER JOIN osoby on osoby.nr_osoby = sesje.osoba_nr
                 INNER JOIN Konta on osoby.nr_osoby = konta.osoba_nr
                 WHERE sesje.token=" . "'" . $retPacket['token'] . "'";

    $buff = dbRequire($verfTokn);

    $result = ($buff == null) ? [] : $buff[0];

    if (count($result) > 0)
    {
      $retPacket['acType'] = $result[0];
      $retPacket['nrOsoby'] = $result[1];  // -- uzywane przez php do tworzenia kwerend
                                           //    sql, do wskazywania na konkretna osobe
    }

  }
  verifyToken();

  //  -- Polecenia po stronie php wywolywane po przez zapytanie
  //     najczesciej generowane w JS przy pomocji funkcji dbReq()

  class Command 
  {
    public $parmList;
    public $acType;
    public $name;
    public $fn;
    public function __construct($name, $fn, $acType, $parmList)
    {
      $this->parmList = $parmList;
      $this->acType = $acType;
      $this->name = $name;
      $this->fn = $fn;
    }
  }

  // -- szukamy klucza $key z widoku $view w polach $fields
  function packSearchQuerry ($key, $view, $fields)
  {
    $key = strtolower($key);
    $querry = "SELECT * FROM " . $view . " WHERE (";
    foreach ($fields as $index => $field)
      $querry .= (
        "LOWER(" . $field . ") LIKE ('%" . $key . "%') " . (($index !== array_key_last($fields)) ? "OR " : ")")
      );
    
    global $retPacket;
    return $querry;
  }
  
  // -------------------------------------
  // -- Uniwersalne (Konto):
  // -------------------------------------

  // Perm: wszyscy
  function serverPing()
  {
    global $retPacket;
    $retPacket['ip'] = $_SERVER['REMOTE_ADDR'];
  }

  // Perm: niezalogowani
  function logowanie ()
  {
    global $retPacket;
    global $retDb;

    $newToken = "";
    for ($i = 0; $i < 32; $i++)
      $newToken .= (
        (rand(0, 1) == 0)
          ? chr(rand(97, 122))
          : chr(rand(48, 57))
      );

    $retPacket['token'] = $newToken;

    // -- tworzenie sesji przez serwer sql

    dbRequire(
      "CALL add_session('" . $_GET["user"] . 
      "','" . $_GET["password"] . 
      "', '" . $newToken . "')"
    );

    // -- jesli udalo sie stworzyc sesje, kwerenda 
    //    zwroci nr osoby oraz rodzaj konta

    $conf = dbRequire("select sesje.osoba_nr, konta.typ_konta 
                       from sesje inner join osoby 
                       on sesje.osoba_nr = osoby.nr_osoby 
                       inner join konta on 
                       konta.osoba_nr = osoby.nr_osoby 
                       where sesje.token = '" . $newToken . "'");

    if ($conf != NULL)
      if (count($conf[0]) > 0)
      {
        $retDb = $conf[0];
        $retPacket['nrOsoby'] = $conf[0][0];
        $retPacket['acType'] = $conf[0][1];
        return;
      }

    // -- informacja o nieudanym logowaniu dla JS'a

    packetThrow('Failed to login!', []);
  }

  // Perm: Admin, Lekarz, Pacjent
  function wylogowywanie ()
  {
    global $retPacket;
    dbRequire("delete from sesje where token = '" . $retPacket['token'] . "'");
  }
  
  // Perm: niezarejestrowani
  function rejestracja ()
  {
    global $retPacket;
    global $retDb;

    $qr = "CALL Pacjent_add('" . $_GET["login"] . "', '" . $_GET["haslo"] . "', '" . $_GET["imie"] . "', '" . $_GET["nazwisko"] . "', to_date('" . $_GET["dataurodz"] . "', 'YYYY-MM-DD'), '" . $_GET["pesel"] . "', '" . $_GET["telefon"] . "', '" . $_GET["mail"] . "', '" . $_GET["miasto"] . "', '" . $_GET["ulica"] . "', '" . $_GET["dom"] . "', " . ($_GET["lokal"] == "" ? "NULL" : "'" . $_GET["lokal"] . "'") . ", '" . $_GET["poczta"] . "')";
    $retPacket['qr'] = $qr;  
    $buff = dbRequire($qr); 

    $retDb = $buff;
  }

  // Perm: Admin, Lekarz, Pacjent
  function req_ac_info()
  {
    global $retPacket;
    global $retDb;
    $retDb = dbRequire("select * from reqInfo where nr_osoby = " . $retPacket['nrOsoby']);    
  }

  // Perm: Admin, Lekarz, Pacjent
  function upt_ac_info()
  {
    global $retPacket;
    $qr = "CALL uptInfo('" . $_GET["imie"] . "', '" . $_GET["nazwisko"] . "', '" . $_GET["haslo"] . "', '" . $_GET["data_uro"] . "', '" . $_GET["pesel"] . "', '" . $_GET["telefon"] . "', '" . $_GET["email"] . "', '" . $_GET["miasto"] . "', '" . $_GET["ulica"] . "', '" . $_GET["nr_domu"] . "', " . ($_GET["nr_lokalu"] == "" ? "NULL" : "'" . $_GET["nr_lokalu"] . "'") . ", '" . $_GET["kod_poczt"] . "', " . $retPacket['nrOsoby'] . ")";
    $retPacket['qr'] = $qr;
    dbRequire($qr);
  }
  
  // -------------------------------------
  // -- Tylko Panel Lekarza:
  // -------------------------------------
 
  function szukajWizytyLekarza ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "Lekarz_Wizyty",
      ["Nr_Wizyty", "Imie", "Nazwisko", "\"Data Wizyty\"", "Opis", "czy_odbyta"]
    );  
    $qr .= " AND lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ")";
    $qr = str_replace("*", "Nr_Wizyty, pacjent_nr, Imie, Nazwisko, \"Data Wizyty\", Opis, czy_odbyta", $qr);
  
    $retDb = dbRequire($qr);
  }

  function req_lekEdycjaWizyty ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT '', czy_odbyta from wizyty where nr_wizyty = " . $_GET['p_id']);      
  }

  function upt_lekEdycjaWizyty ()
  {
    global $retDb;
    global $retPacket;
    $qr = "CALL lekWizUpdate('" . $_GET["Zalecenia"] . "', '" . $_GET["NowyStatus"] . "', " . $_GET["p_id"] . ")";
    $retPacket['qr'] = $qr;
    dbRequire($qr);
  }

  function szukajPacjentow ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "pacjentLekarzaInfo",
      ["nr_karty_pacjenta", "imie", "nazwisko", "data_urodzenia", "\"Ostatnia\""]
    );  
    $qr .= " AND lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ")";
    $qr = str_replace("*", "nr_karty_pacjenta, imie, nazwisko, TO_CHAR(data_urodzenia, 'dd.mm.yyyy'), TO_CHAR(\"Ostatnia\", 'dd.mm.yyyy HH24:mi')", $qr);
    $retDb = dbRequire($qr);    
  }

  // Perm: Lekarz
  function odwolajWizyteLekarze()
  {
    global $retPacket;
    $nrWizyty = $_GET["nrwiz"];
    dbRequire("CALL OdwolajWizyteLek(" . $nrWizyty . ")");
  }

  function req_dodajRecepte()
  {
    global $retDb;
    $retDb = dbRequire("SELECT TO_CHAR(SYSDATE, 'yyyy-MM-dd'), TO_CHAR(SYSDATE+30, 'yyyy-MM-dd'), '' FROM DUAL");
  }

  function upt_dodajRecepte()
  {
    global $retPacket;
    dbRequire("CALL DodajRecepte_z_Wizyty(" . $retPacket['nrOsoby'] . ", " . $_GET["p_id"] . ", TO_DATE('" . $_GET["poczatek"] . "', 'yyyy-MM-dd'), TO_DATE('" . $_GET["waznosc"] . "', 'yyyy-MM-dd'), '" . $_GET["zalecenia"] . "')");
  }

  function szukajReceptyLekarza()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "Lekarz_Recepty",
      ["nr_recepty", "nr_wizyty", "zalecenia", "nazwa_leku", "imie", "nazwisko", "data_waznosci"]
    );

    $qr = str_replace("*", "nr_recepty, Nr_Wizyty, LISTAGG(nazwa_leku, ', ') as \"Nazwa Leku\", zalecenia, Imie, Nazwisko, TO_CHAR(data_waznosci, 'dd/mm/yyyy') as \"Data Waznosci\"", $qr); 
    $qr .= " AND lekarz_nr = (SELECT Nr_Lekarza FROM lekarze INNER JOIN Osoby ON Lekarze.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ") GROUP BY nr_recepty, nr_wizyty, imie, nazwisko, data_waznosci, zalecenia";

    $retPacket['qr'] = $qr;  
    $retDb = dbRequire($qr);
  }

  function zaznaczRecepte()
  {
    global $retPacket;
    dbRequire("CALL ZaznaczRecepte(" . $retPacket['nrOsoby'] . ", " . $_GET["wiz"] . ")");
  }
          
  // -------------------------------------
  // -- Tylko Panel Pacjenta:
  // -------------------------------------

  // Perm: Pacjent
  function szukajWizytyPacjent ()
  {
    global $retPacket;
    global $retDb;
    $qr = packSearchQuerry($_GET["key"], "pacjent_wizyty",
      ["imie", "nazwisko", "nazwa_specjalizacji", '"Data_Wizyty"', "nr_wizyty", "opis", "czy_odbyta"]
    );

    $qr .= " AND pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ")";
    $retPacket['qr'] = $qr;

    $retDb = dbRequire($qr);
  }

  // Perm: Pacjent
  function odwolajWizytePacjent()
  {
    global $retPacket;
    $nrWizyty = $_GET["nrwiz"];
    dbRequire("CALL OdwolajWizytePac(" . $nrWizyty . "," . $retPacket['nrOsoby'] . ")");
  }

  function indexSpecjalizacje ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT Nazwa_Specjalizacji FROM Specjalizacje");
  }

  // Perm: Pacjenci
  function szukajReceptyPacjenta ()
  {
    global $retPacket;
    global $retDb;
    $qr = packSearchQuerry($_GET["key"], "pacjent_recepty",
      ["nr_recepty", "nr_wizyty", "nazwa_leku", "zalecenia", "imie", "nazwisko", "data_waznosci"]
    );
    $qr .= " AND pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ") GROUP BY nr_recepty, nr_wizyty, zalecenia, imie, nazwisko, data_waznosci";

    $qr = str_replace("*", "nr_recepty, nr_wizyty, LISTAGG(nazwa_leku,', ') AS \"Nazwa Leku\" , zalecenia, Imie, nazwisko, TO_CHAR(data_waznosci, 'dd/mm/yyyy') AS \"Data Waznosci\"", $qr);
  
    $retPacket['qr'] = $qr;
    $retDb = dbRequire($qr);
  }

  function pacjentUsunKonto()
  {
    global $retPacket;
    dbRequire("delete from Pacjenci_view where nr_osoby = " . $retPacket['nrOsoby']);
  }

  // -------------------------------------
  // -- Panel: Administratora
  // -------------------------------------
  

  function adm_szukaj_lekarzy ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "Lekarze_view",
      ["login", "imie", "nazwisko", "nazwa_specjalizacji", "pesel", "nr_lekarza"]
    );  
    $qr = str_replace("*", "login, imie, nazwisko, nazwa_specjalizacji, pesel, nr_lekarza", $qr);
  
    $retDb = dbRequire($qr);
  }

  function adm_szukaj_pacjentow ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "AdminView_Pacjent",
      ["login", "imie", "nazwisko", '"Data urodzenia"', "pesel", "nr_karty_pacjenta"]
    );  
    $qr = str_replace("*", "login, imie, nazwisko, pesel, \"Data urodzenia\", nr_karty_pacjenta", $qr);
  
    $retDb = dbRequire($qr);
  }

  function adm_szukaj_adminow ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "AdminView_Admin",
      ["login", "imie", "nazwisko", "email", "nr_osoby"]
    );
  
    $retDb = dbRequire($qr);
  }

  function adm_szukaj_wizyt ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "AdminView_Wizyta",
      ["nr_wizyty", "\"Data_Wizyty\"", "opis", "czy_odbyta", "lekarz_nr",
       "\"Imie lekarza\"", "\"Nazwisko lekarza\"", "nazwa_specjalizacji",
       "pacjent_nr", "\"Imie pacjenta\"", "\"Nazwisko pacjenta\""
      ]
    );
  
    $retDb = dbRequire($qr);  
  } 

  function adm_szukaj_producentow ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "Producenci_Lekow_view",
      ["nr_producenta", "nazwa_producenta", "email", "telefon"]
    );  
    $qr = str_replace("*", "nr_producenta, nazwa_producenta, email,  telefon", $qr);
  
    $retDb = dbRequire($qr);
  }


  function adm_szukaj_specjalizacji ()
  {
    global $retPacket;
    global $retDb;

    $qr = packSearchQuerry($_GET["key"], "AdminView_Specjalizacje",
      ["nazwa_specjalizacji"]
    );  
  
    $retDb = dbRequire($qr);
  }

  function adm_req_lekarz ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT imie, nazwisko, TO_CHAR(data_urodzenia, 'yyyy-MM-dd'), pesel, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy, nazwa_specjalizacji FROM Lekarze_view WHERE Nr_lekarza = " . $_GET["p_id"]);
  }

  function adm_req_pacjent ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT imie, nazwisko, TO_CHAR(data_urodzenia, 'yyyy-MM-dd'), pesel, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy FROM Pacjenci_view WHERE Nr_osoby = (SELECT Osoba_Nr FROM Pacjenci WHERE Nr_Karty_Pacjenta = " . $_GET["p_id"] . ")");
  }

  function adm_req_producent ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT nazwa_producenta, telefon, email, miasto, ulica, nr_domu, nr_mieszkania, kod_pocztowy FROM Producenci_Lekow_view WHERE nr_producenta = " . $_GET["p_id"]);
  }

  function adm_req_specjalizacja ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT nazwa_specjalizacji, opis FROM AdminView_Specjalizacje WHERE nazwa_specjalizacji = '" . $_GET["p_id"] . "'");
  }  

  function adm_req_wizyta ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT \"Data_Wizyty\", Opis, czy_odbyta, lekarz_nr, \"Imie lekarza\", \"Nazwisko lekarza\", pacjent_nr, \"Imie pacjenta\", \"Nazwisko pacjenta\" FROM AdminView_Wizyta WHERE nr_wizyty = " . $_GET["p_id"]);
    $retDb[0][0] = str_replace(" ", "T", $retDb[0][0]);    
  }  

  function adm_upt_lekarz ()
  {
    dbRequire("CALL AdminEdytuj_Lekarza(" . $_GET["p_id"] . ", '" . $_GET["imie"] . "', '" . $_GET["nazw"] . "', to_date('" . $_GET["urod"] . "', 'YYYY-MM-DD'), '" . $_GET["pesl"] . "', '" . $_GET["tele"] . "', '" . $_GET["mail"] . "', '" . $_GET["mias"] . "', '" . $_GET["ulic"] . "', '" . $_GET["ndom"] . "', '" . $_GET["nlok"] . "', '" . $_GET["pocz"] . "', '" . $_GET["spec"] . "')");
  }

  function adm_upt_pacjent ()
  {
    dbRequire("CALL AdminEdytuj_Pacjenta(" . $_GET["p_id"] . ", '" . $_GET["imie"] . "', '" . $_GET["nazw"] . "', to_date('" . $_GET["urod"] . "', 'YYYY-MM-DD'), '" . $_GET["pesl"] . "', '" . $_GET["tele"] . "', '" . $_GET["mail"] . "', '" . $_GET["mias"] . "', '" . $_GET["ulic"] . "', '" . $_GET["ndom"] . "', '" . $_GET["nlok"] . "', '" . $_GET["pocz"] . "')");
  }

  function adm_upt_producent ()
  {
    dbRequire("CALL AdminEdytuj_Producenta(" . $_GET["p_id"] . ", '" . $_GET["nazw"] . "', '" . $_GET["tele"] . "', '" . $_GET["mail"] . "', '" . $_GET["mias"] . "', '" . $_GET["ulic"] . "', '" . $_GET["ndom"] . "', '" . $_GET["nlok"] . "', '" . $_GET["pocz"] . "')");    
  }

  function adm_upt_specjalizacja ()
  {
    dbRequire("UPDATE specjalizacje SET  opis = '" . $_GET["opis"] . "' WHERE nazwa_specjalizacji = '" . $_GET["p_id"] . "'");
  }

  function adm_upt_wizyta ()
  {
    $data = str_replace("T", " ", $_GET["data"]);
    dbRequire("CALL AdminEdytuj_Wizyte(" . $_GET["p_id"] . ", to_date('" . $data . "', 'YYYY-MM-DD HH24:mi'), '" . $_GET["opis"] . "', '" . $_GET["stat"] . "', " . $_GET["lknr"] . ", " . $_GET["pcnr"] . ")");
  }

  function adm_reset_lekarz ()
  {
    dbRequire("CALL ResetHaslaLekarz(" . $_GET["p_id"] . ", " . $_GET["psswd"] . ")");
  }

  function adm_reset_pacjent ()
  {
    dbRequire("CALL ResetHaslaPacjent(" . $_GET["p_id"] . ", " . $_GET["psswd"] . ")");
  }

  function adm_ins_lekarz ()
  {
    dbRequire("INSERT INTO Lekarze_view VALUES ('" . $_GET["logn"] . "', '" . $_GET["pwwd"] . "', '" . $_GET["imie"] . "', '" . $_GET["nazw"] . "', TO_DATE('" . $_GET["urod"] . "', 'YYYY-MM-DD'), '" . $_GET["pesl"] . "', '" . $_GET["tele"] . "', '" . $_GET["mail"] . "', '" . $_GET["mias"] . "', '" . $_GET["ulic"] . "', '" . $_GET["ndom"] . "', '" . $_GET["nlok"] . "', '" . $_GET["pocz"] . "', '" . $_GET["spec"] . "', NULL, NULL, NULL)");
  }

  function adm_ins_admin ()
  {
    dbRequire("CALL admin_add('" . $_GET["logn"] . "', '" . $_GET["pwwd"] . "', '" . $_GET["imie"] . "', '" . $_GET["nazw"] . "', '" . $_GET["tele"] . "', '" . $_GET["mail"] . "')");
  }

  function adm_ins_specjalizacja ()
  {
    dbRequire("INSERT INTO Specjalizacje (Nazwa_Specjalizacji, Opis) VALUES ('" . $_GET["nazw"] . "', '" . $_GET["opis"] . "')");
  }

  function adm_ins_producent ()
  {
    dbRequire("CALL producLekow_add('" . $_GET["nazw"] . "', '" . $_GET["pocz"] . "', '" . $_GET["mias"] . "', '" . $_GET["ulic"] . "', '" . $_GET["ndom"] . "', '" . $_GET["nlok"] . "', '" . $_GET["mail"] . "', '" . $_GET["tele"] . "')");
  }
  
  function adm_ins_lek ()
  {
    dbRequire("INSERT INTO Leki_view VALUES (NULL, '" . $_GET["nazw"] . "', '" . $_GET["opis"] . "', " . $_GET["prod"] . ", " . $_GET["cena"] . ", '" . $_GET["aptk"] . "', '" . $_GET["zdjc"] . "')");
  }

  function adm_usun_admina ()
  {
    dbRequire("CALL AdminUsun_admina(" . $_GET["p_id"] . ")");
  }

  function adm_usun_lekarza ()
  {
    dbRequire("DELETE FROM Lekarze_view WHERE nr_lekarza = " . $_GET["p_id"]);
  }

  function adm_usun_pacjenta ()
  {
    dbRequire("CALL AdminUsun_pacjenta(" . $_GET["p_id"] . ")");
  }  

  // -------------------------------------
  // -- Apteka:
  // -------------------------------------

  function apt_szukaj ()
  {
    global $retDb;

    if ($_GET["prod"] == "Wszystkie")
    {
      $retDb[0] = dbRequire("SELECT nazwa_leku, cena, odnosnik, zdjecie, opis, nr_leku FROM Leki_view WHERE LOWER(nazwa_leku) LIKE '%" . $_GET["key"] . "%' AND ROWNUM < 100");
      if ($_GET["typ"] != 'Bez Recepty')
        $retDb[1] = dbRequire("SELECT Lek_Nr FROM Lek_Na_Recepte WHERE recepta_nr = " . $_GET["typ"]);      
      else
        $retDb[1] = array();
    }
    else
    {
      $retDb[0] = dbRequire("SELECT nazwa_leku, cena, odnosnik, zdjecie, opis, nr_leku FROM Leki_view WHERE Producent_Nr = " . $_GET["prod"] . " AND LOWER(nazwa_leku) LIKE '%" . $_GET["key"] . "%' AND ROWNUM < 100");
      if ($_GET["typ"] != 'Bez Recepty')
        $retDb[1] = dbRequire("SELECT Lek_Nr FROM Lek_Na_Recepte WHERE recepta_nr = " . $_GET["typ"]);      
      else
        $retDb[1] = array();  
    }
  }

  function apt_szukaj_recepty ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT nazwa_leku, cena, odnosnik, zdjecie, opis, nr_leku FROM Leki_view INNER JOIN Lek_Na_Recepte ON lek_na_recepte.lek_nr = Nr_leku WHERE lek_na_recepte.recepta_nr = " . $_GET["rec"]);    
  }

  function apt_init ()
  {
    global $retDb;
    global $retPacket;

    if ($retPacket['acType'] == 'lekarz')
    {
      $retDb[0] = dbRequire("SELECT Nr_Recepty FROM ReceptyLekarza WHERE Osoba_Nr = " . $retPacket['nrOsoby']);  
      $retDb[1] = dbRequire("SELECT Ostatnia_Recepta FROM Lekarze WHERE osoba_nr = " . $retPacket['nrOsoby']);
      $retDb[2] = dbRequire("SELECT Nazwa_Producenta, Nr_Producenta FROM producenci_lekow"); 
    }
    else if ($retPacket['acType'] == 'admin' || $retPacket['acType'] == 'brak')
    {
      $retDb = dbRequire("SELECT Nazwa_Producenta, Nr_Producenta FROM producenci_lekow");
    }
    else if ($retPacket['acType'] == 'pacjent')
    {
      $retDb[0] = dbRequire("SELECT Nr_Recepty FROM Pacjent_Recepty WHERE pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ") GROUP BY nr_recepty ORDER BY nr_recepty");        
      $retDb[1] = dbRequire("SELECT Nazwa_Producenta, Nr_Producenta FROM producenci_lekow");      
    }
  }

  // Perm: Lekarz
  function apt_dodaj_recepte ()
  {
    global $retDb;
    dbRequire("INSERT INTO Lek_Na_Recepte VALUES(" . $_GET["rec"] . "," . $_GET["lek"] . ")");
  }

  // Perm: Lekarz
  function apt_usun_recepte ()
  {
    global $retDb;
    dbRequire("DELETE FROM  Lek_Na_Recepte WHERE recepta_nr = " . $_GET["rec"] . " AND lek_nr = " . $_GET["lek"]);
  }

  // Perm: Admin
  function apt_usun_lek ()
  {
    dbRequire("DELETE FROM  Leki_View WHERE nr_leku = " . $_GET["lek"]);
  }
  
  // -------------------------------------
  // -- Wizyty:
  // -------------------------------------

  // Perm: pacjent
  function rodzajeLekarzy ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT Nazwa_Specjalizacji FROM Specjalizacje ORDER BY nazwa_specjalizacji");
  }

  function dostepniLekarze ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT lekarze.nr_lekarza, osoby.imie, osoby.nazwisko FROM Lekarze
                        INNER JOIN Specjalizacje ON specjalizacje.nr_specjalizacji = lekarze.specjalizacja_nr
                        INNER JOIN Osoby ON  osoby.nr_osoby = lekarze.osoba_nr
                        WHERE Specjalizacje.Nazwa_Specjalizacji = '" . $_GET["spec"] . "'");
  }

  function czyLekarzDostepny ()
  {
    global $retDb; // DD.MM.YYYY HH:MM
    $hours = ["10:00", "11:30", "13:00", "14:30", "16:00", "17:30", "19:00"];

    for ($i = 0; $i < 7; $i++)
    {
      $ctime = $_GET["time"] . " " . $hours[$i];
      $retDb[$i] = dbRequire("SELECT Dostepnosc_wizyty(" . $_GET["lekarz"] . ", '" . $ctime . "') FROM DUAL")[0];    
    }  
  }
  
  function dodajWizyte ()
  {
    global $retPacket;
    dbRequire("CALL Umow_Wizyte(" . $_GET["lekarz"] .  ", " . $retPacket["nrOsoby"] . ", '" . $_GET["time"] . "', '" . $_GET["opis"] . "')");    
  }

  function req_inserter ()
  {
    global $retDb;
    for ($i = 0; $i < 32; $i++)
      $retDb[0][$i] = "";
  }
  
  // -------------------------------------
  // -- Uniwersalne (Informator):
  // -------------------------------------

  function ludziSzukaj ()
  {
    global $retDb;

    global $retPacket;
    $retPacket['qr'] = "SELECT imie, nazwisko, Nazwa_Specjalizacji, Telefon, Email FROM Lekarze_view WHERE LOWER(Imie) LIKE '%" . $_GET["imie"] . "%' AND LOWER(Nazwisko) LIKE '%" . $_GET["nazwisko"] . "%'";
  
    $retDb[0] = dbRequire("SELECT imie, nazwisko, Nazwa_Specjalizacji, Telefon, Email FROM Lekarze_view WHERE LOWER(Imie) LIKE '%" . $_GET["imie"] . "%' AND LOWER(Nazwisko) LIKE '%" . $_GET["nazwisko"] . "%'");
    $retDb[1] = dbRequire("SELECT imie, nazwisko, TO_CHAR(data_urodzenia, 'dd.mm.yyyy'), miasto, Telefon, Email FROM Pacjenci_view WHERE LOWER(Imie) LIKE '%" . $_GET["imie"] . "%' AND LOWER(Nazwisko) LIKE '%" . $_GET["nazwisko"] . "%'");
  }

  
  // -------------------------------------
  // -- Index:
  // -------------------------------------
  
  function index_init ()
  {
    global $retDb;

    $retDb[1] = dbRequire("SELECT dwaj_lekarze_info() FROM dual");
    $retDb[2] = dbRequire("SELECT NajczesciejOdwiedzanyLekarz() FROM dual");
    $retDb[3] = dbRequire("SELECT NajczesciejOdwiedzaniLekarze() FROM dual");
    $retDb[4] = dbRequire("SELECT COUNT(Nr_leku) Ilosc_leków FROM leki");
    $retDb[5] = dbRequire("SELECT Leki.NAZWA_LEKU ,COUNT(Lek_NR) Ilosc_Przepisan FROM LEK_NA_RECEPTE INNER JOIN LEKI ON Lek_Nr=LEKI.NR_Leku GROUP BY Lek_NR,Leki.NAZWA_LEKU FETCH FIRST ROW ONLY");
    // TO-DO:   $retDb[6] = dbRequire("SELECT NajdroższyLek() FROM dual");
    $retDb[7] = dbRequire("SELECT TO_CHAR(DATA_WIZYTY,'HH24:MI') godzina,count(TO_CHAR(DATA_WIZYTY,'HH24:MI')) Ilosc_wizyt FROM WIZYTY GROUP BY TO_CHAR(DATA_WIZYTY,'HH24:MI') FETCH FIRST ROW ONLY");
  }
  
  // -- Wszystkie Polecenia oblugiwane po stronie php
  //    Format:   (  JS, PHP, Dostep, [parametry z _GET]  )

  $cmds = [
    new Command("ping", "serverPing", "pacjent", []),
    new Command("ping", "serverPing", "lekarz", []),
    new Command("ping", "serverPing", "admin", []),
    new Command("ping", "serverPing", "brak", []),

    new Command("ac_debug", "konto_info", "pacjent", []),
    new Command("ac_debug", "konto_info", "lekarz", []),
    new Command("ac_debug", "konto_info", "admin", []),

    new Command("indexInit", "index_init", "brak", []),
    new Command("indexInit", "index_init", "admin", []),
    new Command("indexInit", "index_init", "lekarz", []),
    new Command("indexInit", "index_init", "pacjent", []),

    // Perm: Zalogowani
    new Command("req_pacKonto", "req_ac_info", "pacjent", []),
    new Command("req_lekKonto", "req_ac_info", "lekarz",  []),
    new Command("req_admKonto", "req_ac_info", "admin",   []),  
    new Command("upt_pacKonto", "upt_ac_info", "pacjent", ["imie", "nazwisko","haslo","data_uro", "pesel","telefon","email","miasto","ulica","nr_domu","nr_lokalu","kod_poczt"]),
    new Command("upt_lekKonto", "upt_ac_info", "lekarz",  ["imie", "nazwisko","haslo","data_uro", "pesel","telefon","email","miasto","ulica","nr_domu","nr_lokalu","kod_poczt"]),
    new Command("upt_admKonto", "upt_ac_info", "admin",   ["imie", "nazwisko","haslo","data_uro", "pesel","telefon","email","miasto","ulica","nr_domu","nr_lokalu","kod_poczt"]),  

    // Perm: Lekarze
    new Command("szukajWizyty", "szukajWizytyLekarza", "lekarz", ["key"]),
    new Command("req_lekEdycjaWizyty", "req_lekEdycjaWizyty", "lekarz", ["p_id"]),
    new Command("upt_lekEdycjaWizyty", "upt_lekEdycjaWizyty", "lekarz", ["p_id", "Zalecenia", "NowyStatus"]),    
    new Command("odwolajWizyte", "odwolajWizyteLekarze", "lekarz", ["nrwiz"]),      
    new Command("req_dodajRecepte", "req_dodajRecepte", "lekarz", ["p_id"]),
    new Command("upt_dodajRecepte", "upt_dodajRecepte", "lekarz", ["p_id", "poczatek", "waznosc", "zalecenia"]),  
    new Command("dodajWizyte", "dodajWizyte", "pacjent", ["lekarz", "time", "opis"]),    
    new Command("szukajPacjentow", "szukajPacjentow", "lekarz", ["key"]),
    new Command("szukajRecept", "szukajReceptyLekarza", "lekarz", ["key"]),  
    new Command("zaznaczRecepte", "zaznaczRecepte", "lekarz", ["wiz"]),  
  
    // Perm: Pacjencji
    new Command("szukajWizyty", "szukajWizytyPacjent", "pacjent", ["key"]),
    new Command("odwolajWizyte", "odwolajWizytePacjent", "pacjent", ["nrwiz"]),
    new Command("szukajRecepty", "szukajReceptyPacjenta", "pacjent", ["key"]),
    new Command("rodzajeLekarzy", "rodzajeLekarzy", "pacjent", []),
    new Command("dostepniLekarze", "dostepniLekarze", "pacjent", ["spec"]),
    new Command("czyLekarzDostepny", "czyLekarzDostepny", "pacjent", ["lekarz", "time"]),    
    new Command("pacjentUsunKonto", "pacjentUsunKonto", "pacjent", []),    

    // Perm: Admin
    new Command("resetLekarz", "adm_reset_lekarz", "admin", ["p_id", "psswd"]),
    new Command("resetPacjent", "adm_reset_pacjent", "admin", ["p_id", "psswd"]),  
    new Command("szukajLekarzy", "adm_szukaj_lekarzy", "admin", ["key"]),
    new Command("szukajPacjentow", "adm_szukaj_pacjentow", "admin", ["key"]),
    new Command("szukajAdminow", "adm_szukaj_adminow", "admin", ["key"]),
    new Command("szukajWizyt", "adm_szukaj_wizyt", "admin", ["key"]),
    new Command("szukajProducentow", "adm_szukaj_producentow", "admin", ["key"]),
    new Command("szukajSpecjalizacji", "adm_szukaj_specjalizacji", "admin", ["key"]),
    new Command("usun_admina", "adm_usun_admina", "admin", ["p_id"]),
    new Command("usun_lekarza", "adm_usun_lekarza", "admin", ["p_id"]),
    new Command("usun_pacjenta", "adm_usun_pacjenta", "admin", ["p_id"]),      
  
    new Command("req_edLekarz", "adm_req_lekarz", "admin", ["p_id"]),
    new Command("req_edPacjent", "adm_req_pacjent", "admin", ["p_id"]),
    new Command("req_edProducent", "adm_req_producent", "admin", ["p_id"]),
    new Command("req_edSpecjalizacja", "adm_req_specjalizacja", "admin", ["p_id"]),
    new Command("req_edWizyta", "adm_req_wizyta", "admin", ["p_id"]),

    new Command("upt_edLekarz", "adm_upt_lekarz", "admin", ["p_id", "imie", "nazw", "urod", "pesl", "tele", "mail", "mias", "ulic", "ndom", "nlok", "pocz", "spec"]),
    new Command("upt_edPacjent", "adm_upt_pacjent", "admin", ["p_id", "imie", "nazw", "urod", "pesl", "tele", "mail", "mias", "ulic", "ndom", "nlok", "pocz"]),
    new Command("upt_edProducent", "adm_upt_producent", "admin", ["p_id", "nazw", "tele", "mail", "mias", "ulic", "ndom", "nlok", "pocz"]),
    new Command("upt_edSpecjalizacja", "adm_upt_specjalizacja", "admin", ["p_id", "nazw", "opis"]),
    new Command("upt_edWizyta", "adm_upt_wizyta", "admin", ["p_id", "data", "opis", "stat", "lknr", "pcnr"]),

    new Command("req_insLekarz", "req_inserter", "admin", ["p_id"]),
    new Command("req_insAdmin", "req_inserter", "admin", ["p_id"]),
    new Command("req_insSpecjalizacja", "req_inserter", "admin", ["p_id"]),
    new Command("req_insProducent", "req_inserter", "admin", ["p_id"]),
    new Command("req_insLek", "req_inserter", "admin", ["p_id"]),  

    new Command("upt_insLekarz", "adm_ins_lekarz", "admin", ["p_id"]),
    new Command("upt_insAdmin", "adm_ins_admin", "admin", ["p_id"]),
    new Command("upt_insSpecjalizacja", "adm_ins_specjalizacja", "admin", ["p_id"]),
    new Command("upt_insProducent", "adm_ins_producent", "admin", ["p_id"]),
    new Command("upt_insLek", "adm_ins_lek", "admin", ["p_id"]),  

    // -- Informator

    new Command("ludziSzukaj", "ludziSzukaj", "admin", ["imie", "nazwisko"]),
    new Command("ludziSzukaj", "ludziSzukaj", "lekarz", ["imie", "nazwisko"]),
    new Command("ludziSzukaj", "ludziSzukaj", "pacjent", ["imie", "nazwisko"]),

    // -- Apteka
    new Command("aptekaSzukajRecepty", "apt_szukaj_recepty", "pacjent", ["rec"]),  
    new Command("aptekaSzukaj", "apt_szukaj", "pacjent", ["key", "typ"]),
    new Command("aptekaSzukaj", "apt_szukaj", "lekarz", ["key", "typ"]),
    new Command("aptekaSzukaj", "apt_szukaj", "admin", ["key", "typ"]),
    new Command("aptekaSzukaj", "apt_szukaj", "brak", ["key", "typ"]),  

    new Command("aptekaInit", "apt_init", "lekarz", []),
    new Command("aptekaInit", "apt_init", "admin", []),
    new Command("aptekaInit", "apt_init", "pacjent", []),
    new Command("aptekaInit", "apt_init", "brak", []),  
    
    new Command("aptekaDodajRecepte", "apt_dodaj_recepte", "lekarz", ["lek", "rec"]),
    new Command("aptekaUsunRecepte", "apt_usun_recepte", "lekarz", ["lek", "rec"]),
    new Command("aptekaUsunLek", "apt_usun_lek", "admin", ["lek"]),     
        
    // -- Logowanie:  
    new Command("dropSess", "wylogowywanie", "pacjent", []),
    new Command("dropSess", "wylogowywanie", "lekarz", []),
    new Command("dropSess", "wylogowywanie", "admin", []),
    new Command("zaloguj", "logowanie", "brak", ["user", "password"]),
    new Command("zarejestruj", "rejestracja", "brak", [
      "imie", "nazwisko", "dataurodz", "pesel", "miasto", "ulica", 
      "dom", "lokal", "poczta", "telefon", "login", "haslo"
    ])
  ];

  $cmdResolved = false;

  for ($i = 0; $i < count($cmds); $i++)
    if 
    (
      strcmp($retPacket['acType'], $cmds[$i]->acType) == 0
      && strcmp($_GET["cmd"], $cmds[$i]->name) == 0
    )
    {
      // -- sprawdzanie integralnosci parametrow
      foreach ($cmds[$i]->parmList as $parm)
        if (!isset($_GET[$parm]))
          packetThrow("Missing parameter: " . $parm, []);

      // -- wywolanie php-sided funkcji
      call_user_func($cmds[$i]->fn, []);
      $cmdResolved = true;
      break;
    }

  // -- upewnienie sie ze jakies polecenie zostalo wykonane

  if (!$cmdResolved)
    packetThrow("Command " . $_GET["cmd"] . " does not exists!", []);

  //  -- Zwracanie tablico-obiektu $retPacket jako JSON
  
  $retPacket['db'] = $retDb;
  echo json_encode(
    $retPacket, 
    JSON_INVALID_UTF8_SUBSTITUTE
  );
?>

