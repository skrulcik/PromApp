
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
	      version    : 'v2.2' // point to the latest Facebook Graph API version
	    });
	 
	    // Run code after the Facebook SDK is loaded.
	  };
	 
	  (function(d, s, id){
	    var js, fjs = d.getElementsByTagName(s)[0];
	    if (d.getElementById(id)) {return;}
	    js = d.createElement(s); js.id = id;
	    js.src = "https://connect.facebook.net/en_US/sdk.js";
	    fjs.parentNode.insertBefore(js, fjs);
	  }(document, 'script', 'facebook-jssdk'));

	function showError(errorid, message){
		/* Given the id of an error alert div, it will display the appropriate \
		* color and given text
		*/
		$(errorid).removeClass("hidden");
		$(errorid).html(message);
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
		    alert("You must sign in to use PromApp. \
		    		If you do not want to login with facebook, \
		    		please sign up with using your email below.");
		  }
		});
	}
	function signIn(){
	    var userEmail = $("#login-email").val();
	    var userPass = $("#login-password").val();
	    if(!userEmail){
	    	showError("#login-status", "Please enter an email address.");
	    	return;
	    }
	    if(!userPass){
	    	showError("#login-status", "Please enter a password.");
	    	return;
	    }

	    Parse.User.logIn(userEmail, userPass, {
	       success: function(user) {
	            // Do stuff after successful login.
	            window.location = 'profile.html';
	        },
	        error: function(user, error) {
		        $("#login-status").removeClass("hidden");
	        	if(error.code == 100){
	        		$("#login-status").html("Failed login, could not connect \
	        									to sign-on server.");
	        	} else if(error.code == 101){
	        		$("#login-status").html("Failed login, email and password \
	        									did not match existing user.");
	        	} else {
	        		$("#login-status").html(error.error);
	        	}
	        }
	    });
	}

	function signUp(){
		var email = $("#signup-email").val();
		var password = $("#signup-password").val();
		var password2 = $("#signup-password2").val();
		var name = $("#signup-name").val();
		if(!email){
			showError("#signup-status", "Please enter an email address.");
			return;
		}
		if(!password){
			showError("#signup-status", "Please enter a password.");
			return;
		}
		if(password != password2){
	        showError("#signup-status", "Passwords must match.");
			return;
		}
		if(!name){
			showError("#singup-status", "Please enter your full name.");
			return;
		}
		Parse.User.signUp(email, password, {}, {
	       success: function(user) {
	            //Set name data in "profile" dictionary to maintain consistency with FB
		        user.set("profile", {name: name, email: email});
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

	$("#sign-in-submit").click(function(){ signIn();});
	$("#sign-up-submit").click(function(){ signUp();});
	$("#facebook-button").click(function(){ facebookLogin();});

});
