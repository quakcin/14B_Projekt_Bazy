<?php
  header('Content-Type: application/json; charset=utf-8');

  //  -- Polaczenie Z Baza

  $db = oci_connect("system", "1234", "localhost/xe");

  if (!$db)
  {
    echo (oci_error())['message'];
    exit;
  }


  //  -- Uwierzytelnianie

  $acType = "N";

  //  -- Bufor Wyjscia


  $ret = array();

  // -- **parser** dla sql'a

  function dbRequire ($query)
  {
    global $db;
    global $ret;
    $parsed = oci_parse($db, $query);

    if (!$parsed)
    {
      echo "PAR ERROR";
      exit;
    }

    $result = oci_execute($parsed);

    if (!$result)
    {
      echo "EXE ERROR";
      exit;
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
      array_push($ret, $cRow);
    }
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
    global $ret;
    dbRequire("select * from osoba_informacje");
  }

  $cmds = [
    new Command("test", "test", "N")
  ];


  for ($i = 0; $i < count($cmds); $i++)
    if 
    (
      strcmp($_GET["cmd"], $cmds[$i]->name) == 0
      && strcmp($acType, $cmds[$i]->acType) == 0
    )
    {
      call_user_func($cmds[$i]->fn, []);
      break;
    }

  //  -- Zwracanie tablicy $ret jako JSON
  echo json_encode($ret, JSON_INVALID_UTF8_SUBSTITUTE);
?>