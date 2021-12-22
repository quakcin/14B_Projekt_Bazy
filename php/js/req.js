/*
  Komunikator z pre kontrolerem bazy danych
*/

// callback (json) => resolved json for command, and packed data
const dbReq = function (callback, command, packed = [])
{
  const localToken = localStorage.getItem("token");
  const cToken = (localToken != null) 
    ? localToken
    : "nil";

  let reqUrl = `./req.php?token=${cToken}&cmd=${command}`;

  for (let i = 0; i < packed.length; i += 2)
    reqUrl += `&${packed[i]}=${packed[i + 1]}`;

  fetch(new Request(reqUrl))
  .then(response => response.json())
  .then(json => {
    callback(json);
  });
}