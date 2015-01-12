$(function() {
    //Verify page with Parse
    Parse.$ = jQuery;
    Parse.initialize("PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg", "QDNCcyQqQRlCjMSIrXanH37MioTb2IJoPIuD5d1C");

    //Temporary before users are available
    var dresses = [{designer:"Faviana", styleNumber:"fe456"},{designer:"Jovani", styleNumber:"JV-967"}];
    function optional_s(num){
        return (num == 1) ? "":"s";
    }
    function optional_es(num){
        return (num == 1) ? "":"es";
    }
    function loadProfile(){
        //Get common name of user from Parse (stored in profile attribute to maintain consistency with FB)
        var current = Parse.User.current();
        var profile = current.get("profile");
        if(profile){
            var fullName = profile["first_name"] + " " + profile["last_name"];
            $("#username").html(fullName);
        }
        loadProfImage(current);
        var numDresses = 0;
        if(current.get("dresses")){
            var dresses = current.get("dresses");
            numDresses = dresses.length;
            loadDresses(dresses);
        }
        if(numDresses == 0){
            $("#dresses").hide();
        }
        var numProms = 0;
        if(current.get("proms")){
            proms = current.get("proms");
            numProms = proms.length;
        }
        if(numProms == 0){
            $("#proms").hide();
        }
        //Display numerical data on page
        $("#dressNumber").html(numDresses + " Dress" + optional_es(numDresses));
        $("#promNumber").html(numProms  + " Prom" + optional_s(numProms));
    }
    function loadDresses(dresses){
        $('#dresslist').empty(); //Clears out existing dress list views
        $.each(dresses, function(index, dress) {
            //Create a container for dress information, then subviews
            var dressInfo = document.createElement('div');
            dressInfo.setAttribute("class", "col-sm-8 col-md-3");
            var dressInfo_thumb = document.createElement('div');
            dressInfo_thumb.setAttribute("class", "thumbnail dress");
            var dressInfo_thumb_img = document.createElement('img');
            dressInfo_thumb_img.setAttribute('class', 'img-responsive');
            var dressInfo_thumb_caption = document.createElement('div');
            dressInfo_thumb_caption.setAttribute('class', 'caption');
            var caption_designer = document.createElement('h4');
            var caption_styleNumber = document.createElement('h5');
            //Retrieve data from model to fill in information
            dress.fetch({
              success: function(myObject) {
                caption_designer.innerHTML = dress.get("designer");
                caption_styleNumber.innerHTML = dress.get("styleNumber");
                //Retrieve stored picture from model
                var dressPic = dress.get("image");
                if (dressPic) {
                    dressInfo_thumb_img.src = dressPic.url();
                } else {
                    dressInfo_thumb_img.setAttribute("data-src", "holder.js/200x300");
                }
              },
              error: function(myObject, error) {
                // The object was not refreshed successfully.
                // error is a Parse.Error with an error code and message.
                alert("Server Error: ", error.code);
              }
            });
            //Add children to parent elements
            dressInfo_thumb_caption.appendChild(caption_designer);
            dressInfo_thumb_caption.appendChild(caption_styleNumber);
            dressInfo_thumb.appendChild(dressInfo_thumb_img);
            dressInfo_thumb.appendChild(dressInfo_thumb_caption);
            dressInfo.appendChild(dressInfo_thumb);
            //Append the view for the dress into the list section
            $('#dresslist').append(dressInfo);
        });
    }
    function loadProfImage(user){
        if(Parse.FacebookUtils.isLinked(user)){
            var URL = "https://graph.facebook.com/"+ user.get("profile")["id"]+"/picture?type=large";
            $('#profile img').attr("src", URL);
        } else {
            // For non-facebook users, get image if it exists
            var image = user.get("image");
            if(image && image.url() != ""){
                $('#profile img').attr("src", image.url());
            }
        }
        
    }
    loadProfile();
});



