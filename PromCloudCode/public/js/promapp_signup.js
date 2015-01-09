function makeBadStatus(elem){
	elem.style.background = "#F55"
}
function onfacebooklogin(elem){
	alert("Facebook login successful.");
}
function onlogin(elem){
	var email = document.getElementById("login-email");
	var password = document.getElementById("login-pwd");
	if(login(email.value, password.value)){
		alert("Login successful.");
	} else {
		//Incorrect username and password
		alert("Please enter a valid email address.");
		makeBadStatus(email);
		makeBadStatus(password);
	}
}
function onsignup(elem){
	var email = document.getElementById("signup-email");
	var password = document.getElementById("signup-pwd");
	var password2 = document.getElementById("signup-verify-pwd");
	if(password.value != password2.value){
		alert("Sorry, passwords do not match.");
		return;
	}
	if(areValidCredentials(email.value, password.value)){
		alert("You've been signed up!");
	} else {
		//Incorrect username and password
		alert("Please enter a valid email address.");
		makeBadStatus(email);
		makeBadStatus(password);
		makeBadStatus(password2);
	}
}
function areValidCredentials(email, password){
	if(email == "" || password == "") {
		return false
	}
	return true;
}
function login(email, password){
	return areValidCredentials(email, password);
}