let showFlag = false;
let passwordField;




function passwd_show()
{
	if(document.getElementById('passwdArea') != null)
	  passwordField = document.getElementById('passwdArea');
	else if (document.getElementById('form_haslo') != null)
	  passwordField = document.getElementById('form_haslo');
	let show= document.querySelector('.show');
	let hide = document.querySelector('.hide');

	show.onclick = function()
	{
		passwordField.setAttribute("type", "text");
		show.style.display = "none";
		hide.style.display = "block";
	}

	hide.onclick = function()
	{
		passwordField.setAttribute("type", "password");
		hide.style.display = "none";
		show.style.display = "block";
	}
}
