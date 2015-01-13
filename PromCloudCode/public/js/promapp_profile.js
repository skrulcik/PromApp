$(function() {
    //Verify page with Parse
    Parse.$ = jQuery;
    Parse.initialize("PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg",
                        "QDNCcyQqQRlCjMSIrXanH37MioTb2IJoPIuD5d1C");

    function optional_s(num){
        return (num == 1) ? "":"s";
    }
    function optional_es(num){
        return (num == 1) ? "":"es";
    }
    function loadProfile(){
        //Get common name of user from Parse (stored in profile attribute to
        //maintain consistency with FB)
        var current = Parse.User.current();
        var profile = current.get("profile");
        if(profile){
            var fullName = profile["name"];
            $("#username").html(fullName);
        }
        loadProfImage(current);
        var numDresses = 0;
        var dresses = current.get("dresses");
        if(dresses){
            numDresses = dresses.length;
        }
        if(numDresses == 0){
            $("#dresses").hide();
        } else {
            displayDresses(dresses);
        }
        var numProms = 0;
        var proms = current.get("proms");
        if(proms){
            numProms = proms.length;
        }
        if(numProms == 0){
            $("#proms").hide();
        } else {
            displayProms(proms);
        }
        var numStores = 0;
        var stores = current.get("stores");
        if(stores){
            numStores = stores.length;
        }
        if(numStores == 0){
            $("#stores").hide();
        } else {
            displayStores(stores);
        }
        //Display numerical data on page
        $("#dressNumber").html(numDresses + " Dress" + optional_es(numDresses));
        $("#promNumber").html(numProms  + " Prom" + optional_s(numProms));
    }
    function displayDresses(dresses){
        $('#dresslist').empty(); //Clears out existing dress list views
        $.each(dresses, function(index, dress) {
            //Create a container for dress information, then subviews
            var dressInfo = document.createElement('div');
            dressInfo.setAttribute("class", "col-sm-8 col-md-3");
            var dressInfo_thumb = document.createElement('div');
            dressInfo_thumb.setAttribute("class", "thumbnail object-display");
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
                    //Placeholder
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
    function displayProms(proms){
        $('#promlist').empty(); //Clears out existing prom list views
        $.each(proms, function(index, prom) {
            //Create a container for prom information, then subviews
            var promInfo = document.createElement('div');
            promInfo.setAttribute("class", "col-sm-8 col-md-3");
            var promInfo_thumb = document.createElement('div');
            promInfo_thumb.setAttribute("class", "thumbnail object-display");
            var promInfo_thumb_img = document.createElement('img');
            promInfo_thumb_img.setAttribute('class', 'img-responsive');
            var promInfo_thumb_caption = document.createElement('div');
            promInfo_thumb_caption.setAttribute('class', 'caption');
            var caption_schoolName = document.createElement('h4');
            var caption_locationDescription = document.createElement('h5');
            //Retrieve data from model to fill in information
            prom.fetch({
              success: function(myObject) {
                caption_schoolName.innerHTML = prom.get("schoolName");
                caption_locationDescription.innerHTML = prom.get("locationDescription");
                //Retrieve stored picture from model
                var promPic = prom.get("image");
                if (promPic) {
                    promInfo_thumb_img.src = promPic.url();
                } else {
                    //placeholder
                }
              },
              error: function(myObject, error) {
                // The object was not refreshed successfully.
                // error is a Parse.Error with an error code and message.
                alert("Server Error: ", error.code);
              }
            });
            //Add children to parent elements
            promInfo_thumb_caption.appendChild(caption_schoolName);
            promInfo_thumb_caption.appendChild(caption_locationDescription);
            promInfo_thumb.appendChild(promInfo_thumb_img);
            promInfo_thumb.appendChild(promInfo_thumb_caption);
            promInfo.appendChild(promInfo_thumb);
            //Append the view for the prom into the list section
            $('#promlist').append(promInfo);
        });
    }
    function displayStores(stores){
        $('#storelist').empty(); //Clears out existing store list views
        $.each(stores, function(index, store) {
            //Create a container for store information, then subviews
            var storeInfo = document.createElement('div');
            storeInfo.setAttribute("class", "col-sm-8 col-md-3");
            var storeInfo_thumb = document.createElement('div');
            storeInfo_thumb.setAttribute("class", "thumbnail object-display");
            var storeInfo_thumb_img = document.createElement('img');
            storeInfo_thumb_img.setAttribute('class', 'img-responsive');
            var storeInfo_thumb_caption = document.createElement('div');
            storeInfo_thumb_caption.setAttribute('class', 'caption');
            var caption_name = document.createElement('h4');
            var caption_address = document.createElement('h5');
            //Retrieve data from model to fill in information
            store.fetch({
              success: function(myObject) {
                caption_name.innerHTML = store.get("name");
                caption_address.innerHTML = store.get("website");
                //Retrieve stored picture from model
                var storePic = store.get("image");
                if (storePic) {
                    storeInfo_thumb_img.src = storePic.url();
                } else {
                    //placeholder
                }
              },
              error: function(myObject, error) {
                // The object was not refreshed successfully.
                // error is a Parse.Error with an error code and message.
                alert("Server Error: ", error.code);
              }
            });
            
            //Add children to parent elements
            storeInfo_thumb_caption.appendChild(caption_name);
            storeInfo_thumb_caption.appendChild(caption_address);
            storeInfo_thumb.appendChild(storeInfo_thumb_img);
            storeInfo_thumb.appendChild(storeInfo_thumb_caption);
            storeInfo.appendChild(storeInfo_thumb);
            //Append the view for the store into the list section
            $('#storelist').append(storeInfo);
        });
    }
    function loadProfImage(user){
        if(Parse.FacebookUtils.isLinked(user)){
            var URL = "https://graph.facebook.com/"+ user.get("profile")["id"];
            URL += "/picture?type=large";
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



