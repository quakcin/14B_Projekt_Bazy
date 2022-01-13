let passwordField = document.getElementById('passwdArea');
let show = document.querySelector('.show');
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