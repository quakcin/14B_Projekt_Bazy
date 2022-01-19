export NLS_LANG=AMERICAN_AMERICA.AL32UTF8
SET NLS_LANG=AMERICAN_AMERICA.AL32UTF8
NLS_LANG=AMERICAN_AMERICA.AL32UTF8
(
   echo @"./DROPs.sql"
   echo @"./CREATE.sql"
   echo @"./Pacjenci.sql"
   echo @"./Lekarze.sql"
   echo @"./Insert.sql"
   echo @"./leki.sql"
   echo @"./Wizyty.sql"
   echo @"./Producenci_Lekow.sql"
   echo @"./recepty.sql"
   echo @"./Panel_Administratora.sql"
   echo @"./LOGOWANIE.sql"
   echo @"./rejestracja.sql"
   echo @"./odswiezanie_sesji.sql"
) | sqlplus system/123qwe
