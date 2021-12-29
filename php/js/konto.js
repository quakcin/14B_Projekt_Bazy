/*
  WANR: schematy/pola musza byc takie same jak selecty po
        stronie serwera, inaczej edytor i search box
        nie beda dzialac wgle!
*/

dbRestrict(
  "Prosze sie zalogowac!", "./logowanie",
  ["admin", "pacjent", "lekarz"]
);

// -- Init: Schematy Bazy
const cSchemes = [];

const addScheme = function (name, schemes)
{
  cSchemes.push({
    name: name,
    schemes: schemes,
  });
}

const findScheme = function (name)
{
  for (let scheme of cSchemes)
    if (scheme.name == name)
      return scheme;
  
  console.log("ERR!");
  return null;
}


const P_EDIT = 'db-edit';
const P_SEARCH = 'db-search';
const cPanels = [];

const editorCommit = function (e)
{
  const scheme = findScheme(e.dataset['name']);
  // -- collect: all information from form
  //             in dbReq like manner
  const formParams = [];
  for (let sc of scheme.schemes)
  {
    formParams.push(sc.n);
    formParams.push(document.getElementById(`form_${sc.n}`).value);
  }
  console.log(formParams);
  // -- now: tell server to update data!
  dbReq((e) => {
    // -- to-do: Handle response!
    console.log(e);
  }, `upt_${scheme.name}`, formParams);
    
}

const invokeEditor = function (name) 
{
  // -- first: ask server for data
  // -- then: build forms + insert received data

  dbReq((e) => {

    console.log(e); // -- to-do: error handling
    
    const self = document.getElementById(P_EDIT);
    const scheme = findScheme(name).schemes;

    while (self.firstChild)
      self.removeChild(self.lastChild);

    for (let item of scheme)
    {
      const wrapper = document.createElement('div');
      const label = document.createElement('div');
      const inp = document.createElement('input');
      inp.setAttribute('type', item.t);
      inp.setAttribute('id', `form_${item.n}`);
      label.textContent = item.n;
      wrapper.appendChild(label);
      wrapper.appendChild(inp);
      self.appendChild(wrapper);
    }

    // append commit button
    const fin = document.createElement('input');
    fin.setAttribute('type', 'button');
    fin.setAttribute('value', 'Zapisz');
    fin.setAttribute('data-name', name);
    self.appendChild(fin);

    fin.onclick = (e) => {
      editorCommit(e.target);
    }
  }, `req_${name}`);
}

const menuAction = function (sender)
{
  const type = sender.dataset['type'];
  const name = sender.dataset['name'];

  for (let elem of document.getElementsByClassName('db-panel'))
    elem.setAttribute("style", "display: none;");

  const panel = document.getElementById(type);
  panel.setAttribute("style", "");    
  
  if (type == P_EDIT)
    invokeEditor(name);
  // console.log(type, name);
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

/*
  Dzialanie:
  1. Dodanie schematu pol z bazy
     do tworzenia formulazy itp..

  2. Dodanie paneli (bocznych opcji)
     utilzujacy szukajke i edytor
*/

const initPacjent = function ()
{
  // -- Schemes:
  addScheme("pacKonto", [
    {n: "imie", t: "text"},
    {n: "naziwsko", t: "text"}
  ]);
  // -- Panels:
  addPanel("Moje Konto", "pacKonto", P_EDIT);
  addPanel("Wizyty", "pacWizyty", P_SEARCH);
}


document.body.onload = (e) => {
  initPacjent();
}
