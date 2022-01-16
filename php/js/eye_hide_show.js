let showFlag = false;
let passwordField;

function passwd_show(passwdId)
{
  passwordField = document.getElementById(passwdId);
  console.log(passwordField);
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
