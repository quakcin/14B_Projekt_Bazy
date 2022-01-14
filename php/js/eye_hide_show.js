let showFlag = false;
let passwordField;




function passwd_show()
{
  if(document.getElementById('passwdArea') != null)
	passwordField = document.getElementById('passwdArea');
  else if (document.getElementById('form_haslo') != null)
	passwordField = document.getElementById('form_haslo');
  let hide = document.querySelector('.hide');

  hide.onclick = function()
  {
	const type = passwordField.getAttribute("type") === "password"
	? "text"
	: "password";
	passwordField.setAttribute('type' , type);
	this.classList.toggle('bi-eye');
  }
}
