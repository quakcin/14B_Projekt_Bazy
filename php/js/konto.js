/*
  UWAGA: Edytując ten plik pamiętaj o: ZACHOWANIU POPRAWNEGO STYLU
         INDENTACJI I WSZYSTKIEGO CO WPŁYWA NA JEGO CZYTELNOŚĆ!
         Uprzejmie dziękuje.
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

// -- Edytor pobiera dane z serwera za pomocą funkcji `req_${name}`
//    i aktualizuje je za pomocą `upt_${name}`. Rendereuje je w
//    postaci formularza z polami zawartymi w parametrze schemes
//
//    Struktura obiektów tablicy schemes:
//    {n: "nazwa", l: "Label", t: "Typ"}
//
//    Dodatkowo funkcja przyjmuje tablicę dodatkowych przycisków
//    Struktura obiektów tablicy przycisków:
//    {val: "Napis", evt: funkcja(e)}
//
//    Wciśnięcie przyciska wywoła podaną funkcję z parametrem
//    p_id z jakim panel został wywołany.

const addScheme = function (name, title, schemes, buttons = [], proxy = null)
{
  cSchemes.push({
    name: name,
    title: title,
    schemes: schemes,
    buttons: buttons,
    proxy: proxy
  });
}

// -- Szukajka wywoluje po stronie serwera funkcje sCommand z
//    parametrem key, która zwraca wynik wyszukiwania, kolejno
//    ten jest renderowany w polu #search-results w postaci
//    wierszy z polami ${fields} i przyciskiem akcji ${action}
//
//    Za pomocą funkcji: uncomplexResult przyjumujacy e.target
//    z argumentwo wywolan funkcji przycisku, otrzymamy tablice
//    wartosci wszystkich kolumn z klikniętego wiersza.

const addResult = function (name, sCommand, fields, action = null)
{
  cResults.push({
    name: name,
    sCommand: sCommand,
    fields: fields,
    action: action
  });
}

// --------------------------------------------------
// -- Wyszukiwacze schematów po nazwach
// --------------------------------------------------

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

// --------------------------------------------------
// -- Definicje rodzajów paneli
// --------------------------------------------------

const P_EDIT     = 'db-edit';         // -- Edytor Danych
const P_SEARCH   = 'db-search';       // -- Wyszukiwarka
const P_LOGOUT   = 'other-log-out';   // -- Wylogowywanie
const P_HOMEPAGE = 'other-home';      // -- Strona Główna
const cPanels    = [];

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
    {
      if (scheme.proxy)
        scheme.proxy(e);
      else
        alert("Dokonano Zmian!");
      return;
    }
    console.log(e);
    alert(`Wystąpił błąd: ${e.err}`);
  }, `upt_${scheme.name}`, formParams);
    
}

// --------------------------------------------------
// -- Wywołania Paneli
// --------------------------------------------------

const invokeSearch = function (name, p_id)
{
  // -- remember: name and personal id
  const sbx = document.getElementById("search-box");
  sbx.setAttribute("data-name", name);
  sbx.setAttribute("data-p_id", p_id);
  document.getElementById("search-box").value = "";
  performSearch();
}

const invokeEditor = function (name, p_id) 
{
  dbReq((e) =>
  {
    if (e.success == false)
    {
      console.log("invokeEditor()", e);
      alert(`Wystąpił błąd: ${e.err}`);
      return;
    }
    
    const self = document.getElementById(P_EDIT);
    const scheme = findScheme(name).schemes;
    const cBtns = findScheme(name).buttons;
    
    while (self.firstChild)
      self.removeChild(self.lastChild);

    // -- title

    const title = document.createElement('div');
    title.setAttribute('class', 'db-form-title');
    title.innerText = findScheme(name).title;
    self.appendChild(title);

    // - Column div
    const fCol = document.createElement('div');
    fCol.setAttribute('class', 'first-column');
    const sCol = document.createElement('div');
    sCol.setAttribute('class', 'second-column');

    // - low button div
    const dButton = document.createElement('div');
    dButton.setAttribute('class', 'button-column');

    self.appendChild(fCol);
    self.appendChild(sCol);
    self.appendChild(dButton);
	
    // -- fields
    
    let dbIter = 0;
    for (let item of scheme)
    {
      const wrapper = document.createElement('div');
      const label = document.createElement('div');

      if ("l" in item)
        label.textContent = item.l;
      else
        label.textContent = item.n;

      wrapper.appendChild(label);

      if (item.t == 'select')
      {
        const inp = document.createElement('select');
        inp.setAttribute('id', `form_${item.n}`); // IMPORTANT        
        for (let opt of item.opt)
        {
          const cOpt = document.createElement('option');
          cOpt.value = opt;
          cOpt.innerText = opt;
          inp.appendChild(cOpt);
        }
        inp.value = e.db[0][dbIter++];
        wrapper.appendChild(inp);
      }
      else
      {
        const inp = document.createElement('input');
        inp.setAttribute('type', item.t);      
        inp.setAttribute('id', `form_${item.n}`); // IMPORTANT
        inp.setAttribute('value', e.db[0][dbIter++]);

        if ("restrict" in item)
          inp.setAttribute('disabled', '');
        
        wrapper.appendChild(inp);
      }

      // -- dodanie wrappera do odpowiedniej kolumny
      (scheme.indexOf(item) < 7 ? fCol : sCol ).appendChild(wrapper);      

      // style do diva kiedy jest haslo
      if (item.t == 'password')
      {
        wrapper.setAttribute('style', 'position: relative; display: block;');
        wrapper.setAttribute('id', 'passwd-eye');

        const eye_slash = document.createElement('i');
        eye_slash.setAttribute('class', 'hide bi bi-eye-slash ');
        wrapper.appendChild(eye_slash);
        passwd_show();        
      }      
    }
	
	  // TO-DO: setMaxDate(document.getElementById("form_data_uro")); // max data urodzenia na dzień dzisiejszy
    //        tylko jako dekoratory dla renderera.
	
    // -- Przycisk do zatwierdzenia zmian!
    const fin = document.createElement('input');
    fin.setAttribute('type', 'button');
    fin.setAttribute('value', 'Zapisz');
    fin.setAttribute('data-name', name);
    dButton.appendChild(fin);
    
    fin.onclick = (e) => {
      editorCommit(e.target, p_id);
    }

    // -- Przyciski dodatkowe (ze schematu)
    for (let btn of cBtns)
    {
      const bt = document.createElement('input');
      bt.setAttribute('type', 'button');
      bt.setAttribute('value', btn.val);
      dButton.appendChild(bt);
      bt.onclick = (e) => {
        btn.evt(p_id);
      };
    }
  }, `req_${name}`, ["p_id", p_id]);
}

const invokeHomePage = function ()
{
  window.location.href = './index';
}

const hideAllPanelsExcept = function (type)
{
  for (let elem of document.getElementsByClassName('db-panel'))
    elem.setAttribute("style", "display: none;");
  
  const panel = document.getElementById(type);
  if (panel)
    panel.setAttribute("style", "");        
}

// --------------------------------------------------
// -- Wywołanie Panelu z poziomu Menu
// --------------------------------------------------

const menuAction = function (sender)
{
  console.log(sender);
  const type = sender.dataset['type'];
  const name = sender.dataset['name'];

  hideAllPanelsExcept(type);

  if (type == P_EDIT)
    invokeEditor(name, G_PERSON_ID);
  else if (type == P_SEARCH)
    invokeSearch(name, G_PERSON_ID);
  else if (type == P_LOGOUT)
    dbDropSession();
  else if (type == P_HOMEPAGE)
    invokeHomePage();
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
// -- Obsługa Szukajki
// ---------------------------------------------------------------

const renderCalcRowWidth = function (resScheme)
{
  let finWidth = 0;
  for (let field of resScheme.fields)
    finWidth += field.s;
  finWidth += 100; // TO-DO: + (resScheme.fields.length - 1) * 15;
  console.log(finWidth);
  return finWidth;
}

const renderSearchResult = function (dbRow, resScheme, index)
{
  const rowID = crypto.randomUUID();
  const row = document.createElement('div');
  row.setAttribute('class', 'row');
  row.setAttribute('id', rowID);
  row.setAttribute('style', `width: ${renderCalcRowWidth(resScheme)}px`);
  
  for (let item of dbRow)
  {
    const col = document.createElement('div');
    col.setAttribute('style', `width: ${resScheme.fields[dbRow.indexOf(item)].s}px`);
    if (index == 0)
      col.style.fontWeight = 'bold';
    col.textContent = item;
    row.appendChild(col);
  }

  if (resScheme.action != null)
  {
    const col = document.createElement('div');
    const btn = document.createElement('input');

    col.setAttribute('style', `width: 100px`);
    
    btn.setAttribute('type', 'button');
    btn.setAttribute('value', resScheme.action.name);
    btn.setAttribute('data-row', rowID);
    btn.onclick = resScheme.action.action;
    if (index != 0)
      col.appendChild(btn);
    row.appendChild(col);
  }
  
  console.log(dbRow, resScheme);
  return row;
}

// -- Dzialanie: Wykona przeszukanie bazy danych
//    oraz wyrenderuje rezultaty na stronie.
const performSearch = function ()
{
  const sbr = document.getElementById("search-results");
  const sbx = document.getElementById("search-box");
  const res = findResultScheme(sbx.dataset['name']);
  const p_id = sbx.dataset['p_id'];
  const key = sbx.value;

  // renderer:
  const tab = document.createElement('div');
  tab.setAttribute('class', 'superTable');
  while (sbr.firstChild)
    sbr.removeChild(sbr.lastChild);
  
  dbReq((e) => {
    console.log(e);

    if (e.success)
    {
      const fields = [];
      for (let field of res.fields)
        fields.push(field.n);
      let results = [];
      results.push(fields);
      results = results.concat(e.db);
      for (let elem of results)
        tab.appendChild(
          renderSearchResult(elem, res, results.indexOf(elem))
        );
    }
    sbr.appendChild(tab);
  }, res.sCommand, ["key", key, "p_id", p_id]);
}

document.getElementById("search-button").onclick = (e) => {
  performSearch();
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
  addResult("pacWizyty", "szukajWizyty",
    [
      {n: "Numer", s: 60},
      {n: "Imie", s: 120},
      {n: "Nazwisko", s: 120},
      {n: "Specjalizacja", s: 110},
      {n: "Data", s: 180},
      {n: "Opis", s: 350},
      {n: "Status", s: 100},
      {n: "Pacjent", s: 60}
    ],
    {
      name: "Odwolaj",
      action: (e) =>
      {
        const items = uncomplexResult(e.target);
        dbReq((e) => {
          console.log(e);
          if (e.success == false)
            alert("Serwer nie odpowiada!");
          performSearch();
        }, "odwolajWizyte", ["nrwiz", items[0]]);
      }
    }
  );
  addResult("pacRecepty", "szukajRecepty",
    [
      {n: 'Nr Recepty', s: 110},
      {n: 'Wizyta', s: 80},
      {n: 'Lek / Leki', s: 200},
      {n: 'Zalecenia', s: 200},      
      {n: 'Imie', s: 130},
      {n: 'Nazwisko', s: 130},
      {n: 'Data Waznosci', s: 150}
    ],
    {
      name: 'Apteka',
      action: (e) =>
      {
        const items = uncomplexResult(e.target)[2];
        const drugs = items.split(", ");
        for (let drug of drugs)
          window.open(`https://www.doz.pl/apteka/szukaj?search=${drug}`, '_blank').focus();
        // -- TO-DO: Przerobic na takie samo dzialanie, ale na
        //           naszej stronie w naszej bazie lekow!
      }
    }
  );
  // -- Schematy Dla Edytora:
  addScheme("pacKonto", "Moje Konto", [
    {n: "imie", l: "Imię", t: "text"},
    {n: "nazwisko", l: "Nazwisko", t: "text"},
    {n: "haslo", l: "Hasło", t: "password"},
    {n: "data_uro", l: "Data urodzenia", t: "date"},
    {n: "pesel", l: "Pesel", t: "text"},
    {n: "telefon", l: "Telefon", t: "text"},
    {n: "email", l: "E-Mail", t: "text"},
    {n: "miasto", l: "Miasto", t: "text"},
    {n: "ulica", l: "Ulica", t: "text"},
    {n: "nr_domu", l: "Numer domu", t: "text"},
    {n: "nr_lokalu", l: "Numer lokalu / mieszkania", t: "text"},
    {n: "kod_poczt", l: "Kod pocztowy", t: "text"}
  ],
  [
    {val: "Usuń Konto", evt: (e) => {
      const sec = parseInt(Math.random() * 999) % 888 + 111;
      if (sec == prompt(`Wpisz ${sec} aby usnąć konto!`))
        dbReq((e) => {
          if (e.success == false)
            alert("Nie udało się usunąć konta!");
          else
            window.location.href = './index';
        }, "pacjentUsunKonto");
      else
        alert("Kod się nie zgadza!");
    }}
  ] 
  );
  // -- Panels:
  addPanel("Strona Glowna", "n/a", P_HOMEPAGE);
  addPanel("Moje Konto", "pacKonto", P_EDIT);
  addPanel("Wizyty", "pacWizyty", P_SEARCH);
  addPanel("Recepty", "pacRecepty", P_SEARCH);
  addPanel("Wyloguj", "n/a", P_LOGOUT);
}

// ---------------------------------------------------------------
// -- Tworzenie Dashboarda dla: Lekarza
// ---------------------------------------------------------------

const initLekarz = function ()
{
  addScheme("lekKonto", "Moje Konto", [
    {n: "imie", l: "Imię", t: "text"},
    {n: "nazwisko", l: "Nazwisko", t: "text"},
    {n: "haslo", l: "Hasło", t: "password"},
    {n: "data_uro", l: "Data urodzenia", t: "date"},
    {n: "pesel", l: "Pesel", t: "text"},
    {n: "telefon", l: "Telefon", t: "text"},
    {n: "email", l: "E-Mail", t: "text"},
    {n: "miasto", l: "Miasto", t: "text"},
    {n: "ulica", l: "Ulica", t: "text"},
    {n: "nr_domu", l: "Numer domu", t: "text"},
    {n: "nr_lokalu", l: "Numer lokalu / mieszkania", t: "text"},
    {n: "kod_poczt", l: "Kod pocztowy", t: "text"}
  ]);
  addScheme("lekEdycjaWizyty", "Edytuj wizytę", [
    {n: "Zalecenia", l: "Zalecenia", t: "text"},
    {n: "NowyStatus", l: "Status wizyty", t: "select", opt: ["Odbyta",  "Zaplanowana", "Odwołana", "Przeniesiona"]}
  ], [
    {val: "Dodaj Recepte", evt: (p_id) => {
      // alert("TO-DO: Dodaj, dodawanie recept!");
      hideAllPanelsExcept(P_EDIT);
      invokeEditor("dodajRecepte", p_id);
    }},
    {val: "Odwolaj", evt: (p_id) => {
      dbReq((e) => {
        if (e.success)
          alert("Odwolano Wizyte!");
        else
          alert("Server nie odpowiada!");
      }, "odwolajWizyte", ["nrwiz", p_id]);
    }}    
  ]);  
  addResult("lekWizyty", "szukajWizyty",
    [
      {n: "Numer", s: 70},
      {n: "Pacjent", s: 70},
      {n: "Imie", s: 120},
      {n: "Nazwisko", s: 120},
      {n: "Data", s: 180},
      {n: "Opis", s: 350},
      {n: "Status", s: 130}
    ],
    {
      name: "Edytuj",
      action: (e) =>
      {
        const nrWiz = uncomplexResult(e.target)[0];
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("lekEdycjaWizyty", nrWiz);
      }
    }
  );  
  addResult("lekPacjenci", "szukajPacjentow",
    [
      {n: "Numer", s: 70},
      {n: "Imie", s: 120},
      {n: "Nazwisko", s: 120},
      {n: "Data Urodzenia", s: 180},
      {n: "Ostatnia Wizyta", s: 180},      
    ],
    {
      name: "Wiecej",
      action: (e) =>
      {
        console.log("PODGLAD", e);
      }
    }
  );
  addResult("recLekarze", "szukajRecept",
    [
      {n: "Numer", s: 70},
      {n: "Wizyta", s: 70},
      {n: "Lek / Leki", s: 200},
      {n: "Zalecenia", s: 200},            
      {n: "Imie", s: 120},
      {n: "Nazwisko", s: 120},
      {n: "Data Waznosci", s: 180},      
    ],
    {
      name: "Zaznacz",
      action: (e) =>
      {
        const wiz = uncomplexResult(e.target)[1];
        dbReq((e) => {
          if (e.success == false)
            alert("Nie Udało się zaznaczyć wizyty!");
        }, "zaznaczRecepte", ["wiz", wiz]);
      }
    }
  );
  addScheme("dodajRecepte", "Dodaj Recepte Do Wizyty", [
    {n: "poczatek", l: "Ważna od", t: "date"},
    {n: "waznosc", l: "Ważna do", t: "date"},
    {n: "zalecenia", l: "Zalecenia / Dawkowanie", t: "text"}
  ], [/* Bez Dodatkowych Przycisków */], (e) => {
    // -- Recepte dodaje edytor przez upt_dodajRecepte
    //    Ta funkcja obsluguje to co sie ma stać potem.
    alert("Dodano Recepte, Teraz zrób coś!");
  });
  addPanel("Strona Glowna", "n/a", P_HOMEPAGE);
  addPanel("Moje Konto", "lekKonto", P_EDIT);
  addPanel("Moje Wizyty", "lekWizyty", P_SEARCH);
  addPanel("Moje Recepty", "recLekarze", P_SEARCH);    
  addPanel("Moi Pacjenci", "lekPacjenci", P_SEARCH);
  addPanel("Wyloguj", "n/a", P_LOGOUT); 
}


// ---------------------------------------------------------------
// -- Tworzenie Dashboarda dla: Admina
// ---------------------------------------------------------------

const szukajkiAdmina = function ()
{
  addResult
  (
    "acLekarze", "szukajLekarzy",
    [
      {n: "Login", s: 150},
      {n: "Imie", s: 200},
      {n: "Nazwisko", s: 200},
      {n: "Specjalizacja", s: 150},     
      {n: "Pesel", s: 130},
      {n: "Lekarz", s: 100}      
    ],
    {
      name: "Więcej", action: (e) =>
      {
        const nrLek = uncomplexResult(e.target).at(-1);
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("edLekarz", nrLek);
      }
    }
  );
  addResult
  (
    "acPacjenci", "szukajPacjentow",
    [
      {n: "Login", s: 150},
      {n: "Imie", s: 200},
      {n: "Nazwisko", s: 200},
      {n: "Pesel", s: 130},
      {n: "Data Urodzenia", s: 180},      
      {n: "Pacjent", s: 100}      
    ],
    {
      name: "Więcej", action: (e) =>
      {
        const nrPac = uncomplexResult(e.target).at(-1);
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("edPacjent", nrPac);
      }
    }
  );
  addResult
  (
    "acAdmin", "szukajAdminow",
    [
      {n: "Login", s: 150},
      {n: "Imie", s: 200},
      {n: "Nazwisko", s: 200},
      {n: "E-Mail", s: 200},
      {n: "P_ID", s: 80}      
    ],
    {
      name: "Usuń", action: (e) =>
      {
        const adminID = uncomplexResult(e.target).at(-1);
        dbReq((e) =>
        {
          if (e.success == false)
            alert(`Nie udało się usunąć konta admina, ${e.err}`);
        }, "usun_admina", ["p_id", adminID]);
      }
    }
  );
  addResult
  (
    "wizyty", "szukajWizyt",
    [
      {n: "Nr", s: 80},
      {n: "Data", s: 160},
      {n: "Opis", s: 300},
      {n: "Status", s: 130},
      {n: "Lekarz", s: 80},
      {n: "Imie", s: 150},
      {n: "Nazwisko", s: 150},
      {n: "Specjalizacja", s: 150},
      {n: "Pacjent", s: 80},
      {n: "Imie", s: 150},
      {n: "Nazwisko", s: 150}
    ],
    {
      name: "Więcej", action: (e) =>
      {
        const nrWiz = uncomplexResult(e.target).at(0);
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("edWizyta", nrWiz);
      }
    }
  );
  addResult
  (
    "producenci", "szukajProducentow",
    [
      {n: "ID", s: 60},      
      {n: "Nazwa", s: 400},
      {n: "E-Mail", s: 300},
      {n: "Telefon", s: 180}
    ],
    {
      name: "Więcej", action: (e) =>
      {
        const prodID = uncomplexResult(e.target).at(0);
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("edProducent", prodID);
      }
    }
  );
  addResult
  (
    "specjalizacje", "szukajSpecjalizacji",
    [
      {n: "Specjalizacja", s: 200},
      {n: "Opis", s: 300},      
      {n: "Dostępni Lekarze", s: 200}
    ],
    {
      name: "Więcej", action: (e) =>
      {
        const nazwa = uncomplexResult(e.target).at(0);
        hideAllPanelsExcept(P_EDIT);
        invokeEditor("edSpecjalizacja", nazwa);
      }
    }
  );  
}

const edytoryAdmina = function ()
{
  addScheme
  (
    "edLekarz", "Edytowanie Danych Lekarza",
    [
      {n: "imie", l: "Imię", t: "text"},
      {n: "nazw", l: "Nazwisko", t: "text"},
      {n: "urod", l: "Data Urodzenia", t: "date"},
      {n: "pesl", l: "Pesel", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"},
      {n: "mias", l: "Miasto", t: "text"},
      {n: "ulic", l: "Ulica", t: "text"},
      {n: "ndom", l: "Nr Domu", t: "text"},
      {n: "nlok", l: "Nr Mieszkania", t: "text"},
      {n: "pocz", l: "Kod Pocztowy", t: "text"},
      {n: "spec", l: "Specjalizacja", t: "select", opt: ["Alergolog", "Dentysta", "Dermatolog", "Ginekolog", "Hematolog", "Kardiolog", "Lekarz Rodzinny", "Neurolog", "Okulista", "Pediatra", "Psychiatra", "Reumatolog", "Urolog"]}
    ],
    [
      {val: "Usuń Konto", evt: (p_id) =>
        {
          dbReq((e) => { if (e.success == false) alert(`Wystąpił błąd: ${e.err}`); }, "usun_lekarza", ["p_id", p_id]);
        }
      },
      {val: "Resetuj Hasło", evt: (p_id) =>
        {
          const newPsswd = parseInt(Math.random() * 9999) % 1000 + 1111;
          dbReq((e) => {
            if (e.success)
              alert(`Nowe hasło po zresetowaniu: ${newPsswd}`);
            else
              alert(`Nie udało się zresetować hasła!`);
          }, "resetLekarz", ["p_id", p_id, "psswd", newPsswd]);
        }
      }
    ]
  );
  addScheme
  (
    "edPacjent", "Edytowanie Danych Pacjentów",
    [
      {n: "imie", l: "Imię", t: "text"},
      {n: "nazw", l: "Nazwisko", t: "text"},
      {n: "urod", l: "Data Urodzenia", t: "date"},
      {n: "pesl", l: "Pesel", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"},
      {n: "mias", l: "Miasto", t: "text"},
      {n: "ulic", l: "Ulica", t: "text"},
      {n: "ndom", l: "Nr Domu", t: "text"},
      {n: "nlok", l: "Nr Mieszkania", t: "text"},
      {n: "pocz", l: "Kod Pocztowy", t: "text"},
    ],
    [
      {val: "Usuń Konto", evt: (p_id) =>
        {
          dbReq((e) => { if (e.success == false) alert(`Wystąpił błąd: ${e.err}`); }, "usun_pacjenta", ["p_id", p_id]);
        }
      },      
      {val: "Resetuj Hasło", evt: (p_id) =>
        {
          const newPsswd = parseInt(Math.random() * 9999) % 1000 + 1111;
          dbReq((e) => {
            if (e.success)
              alert(`Nowe hasło po zresetowaniu: ${newPsswd}`);
            else
              alert(`Nie udało się zresetować hasła!`);
          }, "resetPacjent", ["p_id", p_id, "psswd", newPsswd]);
        }
      }
    ]    
  );
  addScheme
  (
    "edProducent", "Edytowanie Producentów Leków",
    [
      {n: "nazw", l: "Nazwa Producenta", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"},
      {n: "mias", l: "Miasto", t: "text"},
      {n: "ulic", l: "Ulica", t: "text"},
      {n: "ndom", l: "Nr Domu", t: "text"},
      {n: "nlok", l: "Nr Mieszkania", t: "text"},
      {n: "pocz", l: "Kod Pocztowy", t: "text"}
    ],
  );
  addScheme
  (
    "edSpecjalizacja", "Edytowanie Specjalizacji",
    [
      {n: "nazw", l: "Nazwa", t: "text", restrict: true},
      {n: "opis", l: "Opis", t: "text"}
    ],
  );
  addScheme
  (
    "edWizyta", "Edytowanie Wybranej Wizyty",
    [
      {n: "data", l: "Data", t: "datetime-local"},
      {n: "opis", l: "Opis", t: "text"},
      {n: "stat", l: "Status", t: "text"},
      {n: "lknr", l: "Nr Lekarza", t: "number"},
      {n: "lkim", l: "Imię", t: "text", restrict: true},
      {n: "lknz", l: "Nazwisko", t: "text", restrict: true},
      {n: "pcnr", l: "Nr Pacjęta", t: "number"},
      {n: "pcim", l: "Imię", t: "text", restrict: true},
      {n: "pcnz", l: "Nazwisko", t: "text", restrict: true}
    ]
  );  
  addScheme
  (
    "edTMP", "Edytowanie Danych Lekarza",
    [
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},
      {n: "", l: "", t: ""},      
    ],
  );
}

const inserteryAdmina = function ()
{
  addScheme
  (
    "insLekarz", "Dodawanie Konta Lekarza",
    [
      {n: "logn", l: "Login", t: "text"},
      {n: "pwwd", l: "Hasło", t: "password"},      
      {n: "imie", l: "Imię", t: "text"},
      {n: "nazw", l: "Nazwisko", t: "text"},
      {n: "urod", l: "Data Urodzenia", t: "date"},
      {n: "pesl", l: "Pesel", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"},
      {n: "mias", l: "Miasto", t: "text"},
      {n: "ulic", l: "Ulica", t: "text"},
      {n: "ndom", l: "Nr Domu", t: "text"},
      {n: "nlok", l: "Nr Mieszkania", t: "text"},
      {n: "pocz", l: "Kod Pocztowy", t: "text"},
      {n: "spec", l: "Specjalizacja", t: "select", opt: ["Alergolog", "Dentysta", "Dermatolog", "Ginekolog", "Hematolog", "Kardiolog", "Lekarz Rodzinny", "Neurolog", "Okulista", "Pediatra", "Psychiatra", "Reumatolog", "Urolog"]}
    ],
  );
  addScheme
  (
    "insAdmin", "Dodawanie Konta Admina",
    [
      {n: "logn", l: "Login", t: "text"},
      {n: "pwwd", l: "Hasło", t: "password"},      
      {n: "imie", l: "Imię", t: "text"},
      {n: "nazw", l: "Nazwisko", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"}
    ],
  );
  addScheme
  (
    "insSpecjalizacja", "Dodawanie Specjalizacji",
    [
      {n: "nazw", l: "Nazwa Specjalizacji", t: "text"},
      {n: "opis", l: "Opis", t: "text"}
    ],
  );
  addScheme
  (
    "insProducent", "Dodawanie Producenta Leków",
    [
      {n: "nazw", l: "Nazwa", t: "text"},
      {n: "tele", l: "Telefon", t: "text"},
      {n: "mail", l: "E-Mail", t: "text"},
      {n: "mias", l: "Miasto", t: "text"},
      {n: "ulic", l: "Ulica", t: "text"},
      {n: "ndom", l: "Nr Domu", t: "text"},
      {n: "nlok", l: "Nr Mieszkania", t: "text"},
      {n: "pocz", l: "Kod Pocztowy", t: "text"},
    ],
  );  
}

const initAdmin = function ()
{
  szukajkiAdmina(); edytoryAdmina(); inserteryAdmina();
  addPanel("Strona Glowna", "n/a", P_HOMEPAGE);
  addPanel("Konta Lekarzy", "acLekarze", P_SEARCH);
  addPanel("Konta Pacjentów", "acPacjenci", P_SEARCH);
  addPanel("Konta Adminów", "acAdmin", P_SEARCH);
  addPanel("Wizyty", "wizyty", P_SEARCH);
  addPanel("Producenci", "producenci", P_SEARCH);
  addPanel("Specjalizacje", "specjalizacje", P_SEARCH);

  addPanel("Dodaj Lekarza", "insLekarz", P_EDIT);
  addPanel("Dodaj Admin", "insAdmin", P_EDIT);
  addPanel("Dodaj Specjalizacje", "insSpecjalizacja", P_EDIT);
  addPanel("Dodaj Producenta", "insProducent", P_EDIT);
 
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
      else if (e.acType == 'lekarz')
        initLekarz();
      else if (e.acType == 'admin')
        initAdmin();
    }
  }, "ping");
}
