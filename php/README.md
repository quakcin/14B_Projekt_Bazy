# Pliki Serwera 
Założylismy że strony będą komunikować się z bazą danych przy pomocy *pre-komunikatora* - to jest, pliku **req.php** obsługującego komunikację między klientem a użytkownikiem.
Plik req.php wymaga podania co najmniej dwuch parametrów metodą **GET**, a są to parametry: *token* oraz *cmd*. Parametr cmd jest używany przez serwer do uruchamiania
odpowiednich podprogramów, natomiast parametr token służy do określenia przez serwer, rodzaju podłączonego użytkownika - tzn. czy użytkownik jest zalogowany lub jaki też
rodzaj konta jest zalogowany. Jako odpowiedź, serwer *powinien* zwrócić JSON'a z zawsze-obecnym polem **success** oraz innymi ewentualnymi polami jak **err**, **db**, **acType** itp... którymi już obsługą zajmie się *javascript* po stronie klienta.
