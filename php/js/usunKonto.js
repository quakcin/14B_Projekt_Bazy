function delAccount( typeAccount, event)
{
	
	const warning = document.getElementById('del-container');
		warning.style.display = 'flex';
	allclose.onclick = function()
	{
		warning.style.display = 'none';
	};
	cancAcc.onclick = function(){
		alert("Nie usunieto!");
		warning.style.display = 'none'
	};
	deleteAcc.onclick = function() {
			switch(typeAccount)
			{
			case 0:
				dbReq((e) => {
							if (e.success == false)
								alert("Nie udało się usunąć konta!");
							else
								window.location.href = './index';
						}, "pacjentUsunKonto");
			break;
			case 1:
				const adminID = uncomplexResult(event.target).at(-1);
					dbReq((e) =>
					{
						if (e.success == false)
							alert(`Nie udało się usunąć konta admina, ${e.err}`);
						performSearch();
					}, "usun_admina", ["p_id", adminID]);
			break;
			case 2:
				dbReq((e) =>
						{
							if (e.success == false)
								alert(`Wystąpił błąd: ${e.err}`);
							hideAllPanelsExcept(P_SEARCH);
							invokeSearch('acLekarze', G_PERSON_ID);
						}, "usun_lekarza", ["p_id", event]);
			break;
			case 3:
				dbReq((e) =>
						{
							if (e.success == false)
								alert(`Wystąpił błąd: ${e.err}`);
							hideAllPanelsExcept(P_SEARCH);
							invokeSearch('acPacjenci', G_PERSON_ID);
						}, "usun_pacjenta", ["p_id", event]);
			break;
			}
			warning.style.display = 'none';
		};
	
}