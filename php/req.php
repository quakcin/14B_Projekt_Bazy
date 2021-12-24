<?php
  header('Content-Type: application/json; charset=utf-8');

  //  -- Bufor Wyjscia

  $retDb = array();
  $retPacket = array();
  $retPacket['success'] = true;
  $retPacket['token'] = $_GET["token"];

  // -- **parser** dla sql'a

  function dbRequire ($query)
  {
    global $db;
    global $retPacket;
    
    $dbRet = array();
    $parsed = @oci_parse($db, $query);

    if (!$parsed)
    {
      $retPacket['err'] = (oci_error($db))['message'];
      $retPacket['success'] = false;
      return $dbRet;
    }

    $result = @oci_execute($parsed);

    if (!$result)
    {
      $retPacket['err'] = (oci_error($parsed))['message'];
      $retPacket['success'] = false;
      return $dbRet;
    }

    while ( ($row = oci_fetch_array($parsed, OCI_ASSOC+OCI_RETURN_NULLS) ) != false) 
    {
      $cRow = [];
      foreach ($row as $item) 
        if ($item !== null)
          array_push($cRow, $item !== null
            ? $item
            : ""
          );
      array_push($dbRet, $cRow);
    }
    return $dbRet;
  }

  //  -- Polaczenie Z Baza

  $db = @oci_connect("system", "1234", "localhost/xe");

  if (!$db)
  {
    $retPacket['err'] = (oci_error())['message'];
    $retPacket['success'] = false;
    echo json_encode($retPacket, JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
  }


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
      WHERE konta.typ_konta='pacjent' and sesje.token=" . "'" . $retPacket['token'] . "'";

    $buff = dbRequire($verfTokn);

    $result = ($buff == null) ? [] : $buff[0];

    if (count($result) > 0)
    {
      $retPacket['acType'] = $result[0];
      $retPacket['id_osoby'] = $result[1];
    }

  }
  verifyToken();

  //  -- Polecenia

  class Command 
  {
    public $acType; // P - Pacjent, L - Lekarz, A - Admin, N - Kazdy
    public $name;
    public $fn;
    public function __construct($name, $fn, $acType)
    {
      $this->acType = $acType;
      $this->name = $name;
      $this->fn = $fn;
    }
  }

  function test()
  {
    global $retDb;
    $retDb = dbRequire("select * from osoby");
  }

  function logowaniePacjenta () // TO-DO!!!
  {
    global $retPacket;

    $newToken = "";
    for ($i = 0; $i < 32; $i++)
      $newToken .= (
        (rand(0, 1) == 0)
          ? chr(rand(97, 122))
          : chr(rand(48, 57))
      );

    $retPacket['token'] = $newToken;

    // -- tworzenie sesji przez serwer, jesli dane sie zgadzaja

    dbRequire(
      "CALL add_session('" . $_GET["user"] . 
      "','" . $_GET["password"] . 
      "', '" . $newToken . "')"
    );

  }

  // -- Testowanie: http://localhost/req.php?token=nil&cmd=test
  // JS, PHP, Dostep
  $cmds = [
    new Command("test", "test", "brak"),
    new Command("test", "test", "pacjent"),
    new Command("zalogujPacjenta", "logowaniePacjenta", "brak")
  ];

  $cmdResolved = false;

  for ($i = 0; $i < count($cmds); $i++)
    if 
    (
      strcmp($retPacket['acType'], $cmds[$i]->acType) == 0
      && strcmp($_GET["cmd"], $cmds[$i]->name) == 0
    )
    {
      call_user_func($cmds[$i]->fn, []);
      $cmdResolved = true;
      break;
    }

  // -- upewnienie sie ze polecenie zostalo wykonane

  if (!$cmdResolved)
  {
    $retPacket['err'] = "Command " . $_GET["cmd"] . " does not exists!";
    $retPacket['success'] = false;
  }

  //  -- Zwracanie tablicy $ret jako JSON
  
  $retPacket['db'] = $retDb;
  echo json_encode($retPacket, JSON_INVALID_UTF8_SUBSTITUTE);
?>

