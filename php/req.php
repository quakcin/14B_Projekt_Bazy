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

    $buff = dbRequire(
      "CALL Pacjent_add('" . $_GET["login"] . "', '" . $_GET["haslo"] . "', '" . $_GET["imie"] . "', '" . $_GET["nazwisko"] . "', to_date('" . $_GET["dataurodz"] . "', 'YYYY-MM-DD'), '" . $_GET["pesel"] . "', '" . $_GET["telefon"] . "', '" . $_GET["mail"] . "', '" . $_GET["miasto"] . "', '" . $_GET["ulica"] . "', '" . $_GET["dom"] . "', " . ($_GET["lokal"] == "" ? "NULL" : "'" . $_GET["lokal"] . "'") . ", '" . $_GET["poczta"] . "')"
    ); 

    $retDb = $buff;
  }

  function konto_info ()
  {
    global $retDb;
    global $retPacket;
    $buff = dbRequire(
        "SELECT  Konta.login, Konta.haslo, osoby.imie, osoby.nazwisko, osoby.data_urodzenia, osoby.pesel, kontakty.telefon, 
        kontakty.email, adresy.miasto, adresy.ulica, adresy.nr_domu, adresy.nr_mieszkania, 
        adresy.kod_pocztowy
        FROM Osoby
        INNER JOIN Adresy ON osoby.adres_nr = adresy.nr_adresu
        INNER JOIN Kontakty ON osoby.kontakt_nr = kontakty.nr_kontaktu
        INNER JOIN Konta ON Osoby.Nr_osoby=Konta.Osoba_Nr
        WHERE osoby.nr_osoby='" . $retPacket['nrOsoby'] . "'"
    );
    $retDb = $buff;
  }

  // -- Wszystkie Polecenia oblugiwane po stronie php
  //    Format:   (  JS, PHP, Dostep, [parametry z _GET]  )

  $cmds = [
    new Command("ping", "serverPing", "brak", []),
    new Command("ping", "serverPing", "pacjent", []),
    new Command("ping", "serverPing", "admin", []),

    new Command("ac_debug", "konto_info", "pacjent", []),
    new Command("ac_debug", "konto_info", "admin", []),

    new Command("dropSess", "wylogowywanie", "pacjent", []),
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

