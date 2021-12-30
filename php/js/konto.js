/*
  WANR: schematy/pola musza byc takie same jak selecty po
        stronie serwera, inaczej edytor i search box
        nie beda dzialac wgle!
*/

dbRestrict(
  "Prosze sie zalogowac!", "./logowanie",
  ["admin", "pacjent", "lekarz"]
);

let G_PERSON_ID = null;


// ---------------------------------------------------------------
// -- Obsluga Interfejsu i jego elementow
// ---------------------------------------------------------------


// -- Init: Schematy Bazy:
const cSchemes = []; // -- dla edytora
const cResults = []; // -- dla szukajki

const addScheme = function (name, schemes)
{
  cSchemes.push({
    name: name,
    schemes: schemes,
  });
}

const addResult = function (name, sCommand, action = null)
{
  cResults.push({
    name: name,
    sCommand: sCommand,
    action: action
  });
}

const findScheme = function (name)
{
  for (let scheme of cSchemes)
    if (scheme.name == name)
      return scheme;
  
  return null;
}

const findResultScheme = function (name)
{
  for (let res of cResults)
    if (res.name == name)
      return res;
  return null;
}

const P_EDIT = 'db-edit';
const P_SEARCH = 'db-search';
const P_LOGOUT = 'other-log-out';
const cPanels = [];

const editorCommit = function (e, p_id)
{
  const scheme = findScheme(e.dataset['name']);
  // -- collect: all information from form
  //             in dbReq like manner
  const formParams = ["p_id", p_id];
  for (let sc of scheme.schemes)
  {
    formParams.push(sc.n);
    formParams.push(document.getElementById(`form_${sc.n}`).value);
  }

  // -- now: tell server to update data!
  dbReq((e) => {
    // -- to-do: Handle response!
    console.log(e);
    if (e.success)
      return;
    console.log(e);
    alert('Serwer teraz nie odpowiada, prosimy sprobwac pozniej!');
  }, `upt_${scheme.name}`, formParams);
    
}

const invokeSearch = function (name, p_id)
{
  // -- remember: name and personal id
  const sbx = document.getElementById("search-box");
  sbx.setAttribute("data-name", name);
  sbx.setAttribute("data-p_id", p_id);
}

const invokeEditor = function (name, p_id) 
{
  // -- first: ask server for data
  // -- then: build forms + insert received data

  dbReq((e) => {
    console.log("ivk", e);
    if (e.success == false)
    {
      console.log("invokeEditor()", e);
      alert("Serwer nie odpowiada, prosimy sprobowac pozniej!");
      return;
    }
    
    const self = document.getElementById(P_EDIT);
    const scheme = findScheme(name).schemes;

    while (self.firstChild)
      self.removeChild(self.lastChild);

    let dbIter = 0;
    for (let item of scheme)
    {
      const wrapper = document.createElement('div');
      const label = document.createElement('div');
      const inp = document.createElement('input');
      inp.setAttribute('type', item.t);      
      inp.setAttribute('id', `form_${item.n}`);

      inp.setAttribute('value', e.db[0][dbIter++]);
      label.textContent = item.n;
      wrapper.appendChild(label);
      wrapper.appendChild(inp);
      self.appendChild(wrapper);
    }

    // -- Przycisk do zatwierdzenia zmian!
    const fin = document.createElement('input');
    fin.setAttribute('type', 'button');
    fin.setAttribute('value', 'Zapisz');
    fin.setAttribute('data-name', name);
    self.appendChild(fin);
    
    fin.onclick = (e) => {
      editorCommit(e.target, p_id);
    }
  }, `req_${name}`, ["p_id", p_id]);
}

const menuAction = function (sender)
{
  console.log(sender);
  const type = sender.dataset['type'];
  const name = sender.dataset['name'];

  for (let elem of document.getElementsByClassName('db-panel'))
    elem.setAttribute("style", "display: none;");

  const panel = document.getElementById(type);
  if (panel)
    panel.setAttribute("style", "");    
  
  if (type == P_EDIT)
    invokeEditor(name, G_PERSON_ID);
  else if (type == P_SEARCH)
    invokeSearch(name, G_PERSON_ID);
  else if (type == P_LOGOUT)
    dbDropSession();
}

const addPanel = function (str, name, type)
{
  const btn = document.createElement("input");
  btn.setAttribute("type", "button");
  btn.setAttribute("value", str);
  btn.setAttribute("data-type", type);
  btn.setAttribute("data-name", name);

  btn.onclick = (e) => {
    menuAction(e.target);
  }

  wMenu.appendChild(btn);
}

// ---------------------------------------------------------------
// -- Obsluga Szukajki
// ---------------------------------------------------------------

const renderSearchResult = function (dbRow, resScheme)
{
  const rowID = crypto.randomUUID();
  const row = document.createElement('div');
  row.setAttribute('class', 'row');
  row.setAttribute('id', rowID);
  
  for (let item of dbRow)
  {
    const col = document.createElement('div');
    col.textContent = item;
    row.appendChild(col);
  }

  if (resScheme.action != null)
  {
    const col = document.createElement('div');
    const btn = document.createElement('input');
    btn.setAttribute('type', 'button');
    btn.setAttribute('value', resScheme.action.name);
    btn.setAttribute('data-row', rowID);
    btn.onclick = resScheme.action.action;
    col.appendChild(btn);
    row.appendChild(col);
  }
  
  console.log(dbRow, resScheme);
  return row;
}

document.getElementById("search-button").onclick = (e) => {
  const sbr = document.getElementById("search-results");
  const sbx = document.getElementById("search-box");
  const res = findResultScheme(sbx.dataset['name']);
  const p_id = findResultScheme(sbx.dataset['p_id']);
  const key = sbx.value;

  // renderer:
  const tab = document.createElement('div');
  tab.setAttribute('class', 'superTable');
  while (sbr.firstChild)
    sbr.removeChild(sbr.lastChild);
  
  dbReq((e) => {
    console.log(e);

    if (e.success)
      for (let elem of e.db)
        tab.appendChild(
          renderSearchResult(elem, res)
        );
    sbr.appendChild(tab);
  }, res.sCommand, ["key", key, "p_id", p_id]);
}


// -- Przyjmuje ref na przycisk wiersza,
//    po czym zwraca elementy z danego wiersza.
const uncomplexResult = function (elem)
{
  const row = document.getElementById(elem.dataset['row']);
  const finArr = [];
  for (let i = 0; i < row.childElementCount - 1; i++)
    finArr.push(row.children[i].textContent);
  return finArr;
}


// ---------------------------------------------------------------
// -- Tworzenie Dashboarda dla: Pacjenta
// ---------------------------------------------------------------


const initPacjent = function ()
{
  // -- Schematy Dla Szukajki:
  addResult("pacWizyty", "szukajWizyty", {
    name: "Usun",
    action: (e) => {
      console.log(uncomplexResult(e.target));
      /*
      const row = document.getElementById(
        e.target.dataset['row']
      );
      console.log(row);
      */
    }
  });
  // -- Schematy Dla Edytora:
  addScheme("pacKonto", [
    {n: "imie", t: "text"},
    {n: "nazwisko", t: "text"},
    {n: "haslo", t: "password"},
    {n: "data_uro", t: "date"},
    {n: "pesel", t: "text"},
    {n: "telefon", t: "text"},
    {n: "email", t: "text"},
    {n: "miasto", t: "text"},
    {n: "ulica", t: "text"},
    {n: "nr_domu", t: "text"},
    {n: "nr_lokalu", t: "text"},
    {n: "kod_poczt", t: "text"}
  ]);
  // -- Panels:
  addPanel("Moje Konto", "pacKonto", P_EDIT);
  addPanel("Wizyty", "pacWizyty", P_SEARCH);
  addPanel("Wyloguj", "n/a", P_LOGOUT);
}


// ---------------------------------------------------------------
// -- Decyzja jak wyrenderowac strone
// ---------------------------------------------------------------


document.body.onload = (e) => {
  dbReq((e) => {
    if (e.success)
    {
      G_PERSON_ID = e.nrOsoby;
      if (e.acType == 'pacjent')
        initPacjent();
    }
  }, "ping");
}
