
$(function(){

	Parse.$ = jQuery;

	Parse.initialize("PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg",
						"QDNCcyQqQRlCjMSIrXanH37MioTb2IJoPIuD5d1C");

	  window.fbAsyncInit = function() {
	    Parse.FacebookUtils.init({ // this line replaces FB.init({
	      appId      : '487852221345366', // Facebook App ID
	      status     : true,  // check Facebook Login status
	      cookie     : true,  // enable cookies
	      xfbml      : true,  // initialize Facebook social plugins on the page
	      version    : 'v2.3' // point to the latest Facebook Graph API version
	    });
	 
	    // Run code after the Facebook SDK is loaded.
	    if (Parse.User.current()) {
	    	Parse.User.logOut();
	    }
	  };
	 
	  (function(d, s, id){
	    var js, fjs = d.getElementsByTagName(s)[0];
	    if (d.getElementById(id)) {return;}
	    js = d.createElement(s); js.id = id;
	    js.src = "https://connect.facebook.net/en_US/sdk.js";
	    fjs.parentNode.insertBefore(js, fjs);
	  }(document, 'script', 'facebook-jssdk'));

  	/* Given the id of an error alert div, it will display the appropriate \
	* color and given text
	*/
	function showError(message){
		$("#status").html(message)
			.addClass("red")
			.addClass("accent-2")
			.addClass("white-text")
			.addClass("text-darken-3")
			.removeClass("hide");
	}

	function facebookLogin(){
		Parse.FacebookUtils.logIn(null, {
		  success: function(user) {
		    if (!user.existed()) {
		      window.location = 'profile.html';
		    } else {
		      window.location = 'profile.html';
		    }
		  },
		  error: function(user, error) {
		    alert("You must sign in to use PromApp. If you do not want to login with facebook, please sign up with using your email below.");
		  }
		});
	}
	function signIn(){
		if (!$(".signin-only").hasClass("hide")) {
			$(".signin-only").addClass("hide");
			return;
		}
		var userEmailInput = $("#girl-email");
		var userPwdInput = $("#girl-pwd");
	    var userEmail = userEmailInput.val();
	    var userPass = userPwdInput.val();
		
		// Guard against invalid inputs
		if (userEmailInput.hasClass("invalid")) {
			showError(userEmailInput[0].validationMessage);
			return;
		} else if (!userEmailInput.val()) {
	    	showError("Please enter an email address.");
	    	return;
		}
		if (userPwdInput.hasClass("invalid")) {
			showError(userPwdInput[0].validationMessage);
			return;
		} else if (!userPwdInput.val()) {
	    	showError("Please enter a password.");
	    	return;
		}

	    Parse.User.logIn(userEmail, userPass, {
	       success: function(user) {
	            // Do stuff after successful login.
	            window.location = 'profile.html';
	        },
	        error: function(user, error) {
	        	if(error.code == 100){
	        		showError("Failed login, could not connect to sign-on server.");
	        	} else if(error.code == 101){
	        		userEmailInput.addClass("invalid");
	        		userPwdInput.addClass("invalid");
	        		showError("Failed login, email and password did not match an existing user.");
	        	} else {
	        		showError(error.error);
	        	}
	        }
	    });
	}

	function signUp(){
		if ($(".signin-only").hasClass("hide")) {
			$(".signin-only").removeClass("hide");
			return;
		}
		var userEmailInput = $("#girl-email");
		var userPwdInput = $("#girl-pwd");
		var userPwdInput2 = $("#girl-pwd2");
		var userNameInput = $("#girl-name");
	    var userEmail = userEmailInput.val();
	    var userPass = userPwdInput.val();
	    var userPass2 = userPwdInput2.val();
	    var userNameString = userNameInput.val();
		
		// Guard against invalid inputs
		if (userEmailInput.hasClass("invalid")) {
			showError(userEmailInput[0].validationMessage);
			return;
		} else if (!userEmailInput.val()) {
	    	showError("Please enter an email address.");
	    	return;
		}
		if (userPwdInput.hasClass("invalid")) {
			showError(userPwdInput[0].validationMessage);
			return;
		} else if (!userPwdInput.val()) {
	    	showError("Please enter a password.");
	    	return;
		}
		if (!userPass2 || userPass2 != userPass) {
			showError("Passwords must match");
			return;
		}
		if (!userNameString) {
			showError("Please provide a name");
		}

		Parse.User.signUp(userEmail, userPass, {}, {
	       success: function(user) {
	            //Set name data in "profile" dictionary to maintain consistency with FB
		        user.set("profile", {name: userNameString, email: userEmail});
		        user.save().then(function(user) {
					// The save was successful.
		            window.location = 'profile.html';
				}, function(error) {
					alert("Successfully signed up but there were errors saving \
							your name and email. Try editing your profile.");
				});
	        },
	        error: function(user, error) {
		        $("#signup-status").removeClass("hidden");
	        	if(error.code == 100){
	        		$("#signup-status").html("Failed login, could not connect \
	        									to sign-on server.");
	        	} else if(error.code == 101){
	        		$("#signup-status").html("Failed login, email and password \
	        									did not match existing user.");
	        	} else {
	        		$("#signup-status").html(error.error);
	        	}
	        }
	    });
	}

	$("#girl-sign-in").click(function(){ signIn();});
	$("#girl-sign-up").click(function(){ signUp();});
	$("#facebook-button").click(function(){ facebookLogin();});
	
});
