NLS_LANG=.WE8MSWIN1252
(
   echo @"./DROPs.sql"
   echo @"./CREATE.sql"
   echo @"./Pacjenci.sql"
   echo @"./Lekarze.sql"
   echo @"./Producenci_Lekow.sql"
   echo @"./Insert.sql"
   echo @"./Wizyty.sql"
   echo @"./leki.sql"
   echo @"./recepty.sql"
   echo @"./LOGOWANIE.sql"
   echo @"./rejestracja.sql"
   echo @"./odświeżanie sesji.sql"
) | sqlplus system/root
