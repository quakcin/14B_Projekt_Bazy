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

  $db = @oci_connect("system", "1234", "localhost/xe");

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

  function serverPing()
  {
    global $retPacket;
    $retPacket['ip'] = $_SERVER['REMOTE_ADDR'];
  }

  // -- niezaleznie od rodzaju konta, logowanie 
  //    po stronie sql wyglada tak samo
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

  function wylogowywanie ()
  {
    global $retPacket;
    dbRequire("delete from sesje where token = '" . $retPacket['token'] . "'");
  }

  function rejestracja ()
  {
    global $retPacket;
    global $retDb;

    $qr = "CALL Pacjent_add('" . $_GET["login"] . "', '" . $_GET["haslo"] . "', '" . $_GET["imie"] . "', '" . $_GET["nazwisko"] . "', to_date('" . $_GET["dataurodz"] . "', 'YYYY-MM-DD'), '" . $_GET["pesel"] . "', '" . $_GET["telefon"] . "', '" . $_GET["mail"] . "', '" . $_GET["miasto"] . "', '" . $_GET["ulica"] . "', '" . $_GET["dom"] . "', " . ($_GET["lokal"] == "" ? "NULL" : "'" . $_GET["lokal"] . "'") . ", '" . $_GET["poczta"] . "')";
    $retPacket['qr'] = $qr;  
    $buff = dbRequire($qr); 

    $retDb = $buff;
  }

  function konto_info ()
  {
    global $retDb;
    global $retPacket;
    $buff = dbRequire("SELECT * FROM Pacjenci_view WHERE nr_osoby=" . $retPacket['nrOsoby']);

    // TO-DO: --> $buff = dbRequire("call dane_osoby_proc(" . $retPacket['nrOsoby'] . ")");
    $retDb = $buff;
  }

  // Perm: Pacjenci
  function req_pacKonto ()
  {
    global $retPacket;
    global $retDb;
    $retDb = dbRequire("select * from reqPacjenci where nr_osoby = " . $retPacket['nrOsoby']);
  }

  // Perm: Pacjenci
  function upt_pacKonto ()
  {
    global $retPacket;
    dbRequire("UPDATE Pacjenci_view SET imie = '" . $_GET["imie"] . "', nazwisko = '" . $_GET["nazwisko"] . "', haslo = '" . $_GET["haslo"] . "', data_urodzenia = to_date('" . $_GET["data_uro"] . "', 'YYYY-MM-DD'), pesel = '" . $_GET["pesel"] . "', telefon = '" . $_GET["telefon"] . "', email = '" . $_GET["email"] . "', miasto = '" . $_GET["miasto"] . "', ulica = '" . $_GET["ulica"] . "', NR_DOMU = '" . $_GET["nr_domu"] . "', NR_MIESZKANIA = " . ($_GET["nr_lokalu"] == "" ? "NULL" : "'" . $_GET["nr_lokalu"] . "'") . ", KOD_POCZTOWY = '" . $_GET["kod_poczt"] . "' WHERE nr_osoby = " . $retPacket['nrOsoby']);
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

  function szukajPacjenta ()  // -- TO-DO: Dodac Inne Pola do szukajki
  {
    $qr = packSearchQuerry($_GET["key"], "pacjenci_view",
      ["imie", "nazwisko"]
    );
    $buff = dbRequire($qr);
    global $retDb;
    $retDb = $buff;
  }

  // Perm: Pacjent
  function szukajWizytyPacjent ()
  {
    global $retPacket;
    global $retDb;
    $qr = packSearchQuerry($_GET["key"], "pacjent_wizyty",
      ["imie", "nazwisko", "nazwa_specjalizacji", '"Data_Wizyty"', "nr_wizyty"]
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
    dbRequire("CALL odwolaj_wizyte(" . $nrWizyty . "," . $retPacket['nrOsoby'] . ")");
  }

  function indexSpecjalizacje ()
  {
    global $retDb;
    $retDb = dbRequire("SELECT Nazwa_Specjalizacji FROM Specjalizacje");
  }

  function szukajRecepty ()
  {
    global $retPacket;
    global $retDb;
    $qr = packSearchQuerry($_GET["key"], "pacjent_recepty",
      ["nr_recepty", "nr_wizyty", "nazwa_leku", "imie", "nazwisko", "data_waznosci"]
    );
    $qr .= " AND pacjent_nr = (SELECT NR_KARTY_PACJENTA FROM Pacjenci INNER JOIN Osoby ON pacjenci.osoba_nr = osoby.nr_osoby WHERE osoby.nr_osoby = " . $retPacket['nrOsoby'] . ")";
    $retPacket['qr'] = $qr;
    $retDb = dbRequire($qr);
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
    global $retDb;
    $retDb = dbRequire("SELECT Dostepnosc_wizyty(" . $_GET["lekarz"] . ", '" . $_GET["time"] . "') FROM DUAL");
  }
  
  function dodajWizyte ()
  {
    global $retPacket;
    dbRequire("CALL Umow_Wizyte(" . $_GET["lekarz"] .  ", " . $retPacket["nrOsoby"] . ", '" . $_GET["time"] . "', '" . $_GET["opis"] . "')");    
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

    new Command("indexSpec", "indexSpecjalizacje", "brak", []),
    new Command("indexSpec", "indexSpecjalizacje", "admin", []),
    new Command("indexSpec", "indexSpecjalizacje", "lekarz", []),
    new Command("indexSpec", "indexSpecjalizacje", "pacjent", []),

    // UWAGA: Polecenia Tylko Dla Pacjenta, p_id nie wymagane!
    new Command("req_pacKonto", "req_pacKonto", "pacjent", []),
    new Command("upt_pacKonto", "upt_pacKonto", "pacjent", ["imie", "nazwisko","haslo","data_uro", "pesel","telefon","email","miasto","ulica","nr_domu","nr_lokalu","kod_poczt"]),

    // TO-DO: new Command("szukajPacjenta", "szukajPacjenta", "admin", ["key"]),
    // TO-DO: new Command("szukajPacjenta", "szukajPacjenta", "lekarz", ["key"]),

    new Command("szukajWizyty", "szukajWizytyPacjent", "pacjent", ["key"]),
    new Command("odwolajWizyte", "odwolajWizytePacjent", "pacjent", ["nrwiz"]),
    new Command("szukajRecepty", "szukajRecepty", "pacjent", ["key"]),

    // -- Wizyty:
    new Command("rodzajeLekarzy", "rodzajeLekarzy", "pacjent", []),
    new Command("dostepniLekarze", "dostepniLekarze", "pacjent", ["spec"]),
    new Command("czyLekarzDostepny", "czyLekarzDostepny", "pacjent", ["lekarz", "time"]),    
    new Command("dodajWizyte", "dodajWizyte", "pacjent", ["lekarz", "time", "opis"]),    
  
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

