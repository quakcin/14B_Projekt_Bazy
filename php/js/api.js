//
//  --  Komunikator Z Serwerem PHP
//

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
      window.location.href = './index';
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
    scheduleMessesage(errMsg, 8);
    window.location.href = errUrl;
  }

  dbReq((e) => {
    console.log("RESRICT RESP:", e);
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


//
//  -- Kolejka komunkatów międzystronna
//

const scheduleMessesage = function (content, timeout)
{
  localStorage.setItem("msg", JSON.stringify({
    content: content,
    timeout: timeout
  }));
}

const displayMessesage = function (content, timeout)
{

  const msgBox = document.createElement("div");
  const tID = crypto.randomUUID();
  msgBox.id = tID;
  msgBox.setAttribute("class", "api_msg");
  msgBox.innerText = content;

  document.body.appendChild(msgBox);

  setTimeout((e) => {
    if (document.getElementById(tID) != null)
      document.getElementById(tID).remove();
  }, timeout * 1000);
  document.getElementById(tID).onclick = (e) => {
    e.srcElement.remove();
  }
}

//
//  -- Main
//

const apiInit = function ()
{
  document.head.innerHTML += `<link rel="stylesheet" type="text/css" href="./css/apiStyle.css">'`;
  const cMsg = localStorage.getItem("msg");
  if (cMsg != null)
  {
    const msg = JSON.parse(cMsg);
    displayMessesage(msg.content, msg.timeout);
    localStorage.removeItem("msg");
  }
}

setTimeout(() => {
  apiInit();  
}, 1000);
