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
    array_push($ret, "A");
    array_push($ret, "B");
    array_push($ret, "C");
    array_push($ret, "D");
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

  echo json_encode($ret);
?>