<?php
  header('Content-Type: application/json; charset=utf-8');

  //  -- Bufor Wyjscia


  $retDb = array();
  $retPacket = array();
  $retPacket['success'] = true;

  //  -- Polaczenie Z Baza

  $db = @oci_connect("system", "1234", "localhost/xe");

  if (!$db)
  {
    $retPacket['err'] = (oci_error())['message'];
    echo json_encode($retPacket, JSON_INVALID_UTF8_SUBSTITUTE);
    exit;
  }


  //  -- Uwierzytelnianie

  $acType = "N";
  $retPacket['acType'] = $acType;

  // -- **parser** dla sql'a

  function dbRequire ($query)
  {
    global $db;
    global $retPacket;
    // global $ret;
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

  $cmds = [
    new Command("test", "test", "N")
  ];

  $cmdResolved = false;

  for ($i = 0; $i < count($cmds); $i++)
    if 
    (
      strcmp($_GET["cmd"], $cmds[$i]->name) == 0
      && strcmp($acType, $cmds[$i]->acType) == 0
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
  // array_push($retPacket, $retDb);
  $retPacket['db'] = $retDb;
  echo json_encode($retPacket, JSON_INVALID_UTF8_SUBSTITUTE);
?>