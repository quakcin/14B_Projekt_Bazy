/*
  --
  --  Komunikator Z Serwerem PHP
  --
*/

// -- Wywołuje callbacka (odpowiedź) dla polecenia command o argumentach packed
const dbReq = function (callback, command, packed = [])
{
  const localToken = localStorage.getItem("token");
  const cToken = (localToken != null) 
    ? localToken
    : "nil";

  let reqUrl = `./req.php?token=${cToken}&cmd=${command}`;

  for (let i = 0; i < packed.length; i += 2)
    reqUrl += `&${packed[i]}=${packed[i + 1]}`;

  console.log(reqUrl);

  fetch(new Request(reqUrl))
  .then(response => response.json())
  .then(json => {
    callback(json);
  });
}

// -- Wylogowywyuje niezależnie od rodzaju konta
const dbDropSession = function ()
{
  dbReq((e) => {
    if (e.success)
    {
      localStorage.clear();
      window.location.href = './index.html';
    }
    else
      alert(
        `Wylogowywanie nie powiodlo sie: ${e.err}`
      );
  }, "dropSess", []);
}

// -- Ogranicza dostęp do strony dla konkretnych użytkowników
const dbRestrict = function (errMsg, errUrl, acTypes)
{
  const dbTrespasser = function ()
  {
    alert(`${errMsg}`); // --> turn into some api kind of stuff
    window.location.href = errUrl;
  }

  dbReq((e) => {

    if (e.success)
    {
      if (!(acTypes.includes(e.acType)))
        dbTrespasser();
    }
    else
      alert(
        'Serwer obecnie nie odpowiada, prosze sprobowac puzniej!'
      );

  }, "ping");
}
