<!DOCTYPE html>
<!--
  Mini Projekt Baz Danych
  2ID14B, Przychodnia
-->
<html lang="pl">
  <head>

  </head>
  <body>
    <script src="js/req.js"></script>
    <script>
      // -- ok
      dbReq((j) => {
        console.log("got:", j);
      }, "test");
      // -- invalid
      dbReq((j) => {
        console.log("got:", j);
      }, "test2");
    </script>

    <!-- Podmień zaloguj z Moje Konto w przypadku zalogowania -->
    <!-- Zrub wrapper do logowania w php -->
    <!-- Dodaj loggera do js'a zeby dodawal tokena do linkow -->
    <!-- Wrapper moze obejmowac cale menu -->
    <a href="logowanie.php">Zaloguj</a> 
    <a href="rejestracja.php">Zarejestruj Sie</a> 
    <a href="konto.php">Moje Konto</a> 

    <a href="wizyty.php"> Umuw sie na wizyte </a>
    <a href="informator.php"> Informacje o Pacjencie / Lekarzu </a>
    <a href="apteka.php"> Apteka </a>

  </body>
</html>