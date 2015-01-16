
$(function() {
    //Verify page with Parse
    Parse.$ = jQuery;
    Parse.initialize("PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg",
                        "QDNCcyQqQRlCjMSIrXanH37MioTb2IJoPIuD5d1C");

   /* Given the id of an error alert div, it will display the appropriate \
    * color and given text
    */
    function showError(errorid, message){
        $(errorid).removeClass("hidden");
        $(errorid).html(message);
    }
    function clearError(errorid){
        $(errorid).addClass('hidden');
    }

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
        if(current){
            current.fetch().then(function(){
                displayProfile(current);
            }, function(error){
                //Error fetching user, try once more
                current.fetch().then(function(){
                    displayProfile(current);
                }, function(error){
                    alert("User could not be loaded, please check your internet connection.");
                });
            });   
        } else {
            alert("You must be signed in to go to this page.");
            window.location = "https://www.prom-app.com";
        }
    }
    function displayProfile(current){
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
        if(numDresses != 0){
            displayDresses(dresses);
        }
        var numProms = 0;
        var proms = current.get("proms");
        if(proms){
            numProms = proms.length;
        }
        if(numProms != 0){
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

    function cancelNewDress(){
        $('#editdress').remove();
        // If there are no dresses, this would show the placeholder again
        // If there are dresses, placeholder would be removed -> no effect
        $('#dress-placeholder').show();
    }
    function saveNewDress(){
        var designer = $('#editdress-designer').val();
        var styleNumber = $('#editdress-styleNumber').val();
        var color = $('#edidress-color').val();
        var imgInput = $('#editdress-image')[0];
        var imgfile;
        // If image exists, load it into the image spot
        if(imgInput && imgInput.files && imgInput.files.length > 0){
            imgfile = imgInput.files[0];
        }
        if(!designer){
            showError("#editdress-status", "Designer is a required field.");
            return;
        }
        if(!styleNumber){
            showError("#editdress-status", "Style number is a required field.");
            return;
        }
        if(!imgfile){
            showError("#editdress-status", "Please provide an image.");
            return;
        } 
        var filetype = "";
        var name = designer + styleNumber;
        var len = imgfile.name.length;
        if(len > 4){
            filetype = imgfile.name.substring(len-4, len);
        }
        switch (filetype.toLowerCase()) {
            case ".png":
                name += '.png'
                break;
            case ".jpg":
            case "jpeg":
                name += '.jpg'
                break;
            default:
                showError("#editdress-status",
                            "Please upload a PNG, JPG, or JPEG image.");
                return;
        }

        // Fill dress object with data
        var Dress = Parse.Object.extend("Dress"); // Create Dress class
        var newDress = new Dress(); // Instantiate blank dress
        // Must save image file before association
        var dressImage = new Parse.File(name, imgfile);

        dressImage.save().then(function() {
            // Image saved successfully:
            newDress.set('image', dressImage);
            // Set default fields (designer, style no.)
            newDress.set('designer', designer);
            newDress.set('styleNumber', styleNumber);
            // Set optional fields (color, prom-in future implementation)
            if(color){
                newDress.set('dressColor', color);
            }
            return newDress.save();
        }).then(function(){
            Parse.User.current().addUnique('dresses', newDress);
            return Parse.User.current().save();
        }).then(function(){
            $('#editdress').remove(); // Remove vestigal editing box
            loadProfile();
        }, function(error) {
          // Well...damn, it didn't save
            showError("#editdress-status",
                        "Dress could not be saved: error " + error.code);
        });
    }

    /* Utility methods to create similar DOM elements */
    function ContainerFormGroup(obj){
        var grp = document.createElement('div');
        grp.setAttribute('class', 'form-group');
        grp.appendChild(obj);
        return grp;
    }
    function TextInput(id, placeholder){
        var field = document.createElement('input');
        field.setAttribute('id', id);
        field.setAttribute('type', 'text');
        field.setAttribute('placeholder', placeholder);
        field.setAttribute('class', 'form-control');
        return field;
    }

    /* Creates an editable dress info object */
    function newDressForm(){
        $('#dress-placeholder').hide(); // If empty area, clear the placeholder
        clearError('#editdress-status'); // Remove error if it's there
        // Prevent user from adding multiple dresses at once:
        if (!$('#editdress').length){
            // Create a container for dress information, then subviews
            var dressInfo = document.createElement('div');
            dressInfo.setAttribute("id", "editdress");
            dressInfo.setAttribute("class", "col-sm-8 col-md-3");
            var dressInfoTitle = document.createElement('h4');
            dressInfoTitle.innerHTML = "New Dress";
            var dressInfo_thumb = document.createElement('div');
            dressInfo_thumb.setAttribute("class", "thumbnail object-display");
            var dressInfo_thumb_img = document.createElement('input');
            dressInfo_thumb_img.setAttribute('type', 'file');
            dressInfo_thumb_img.setAttribute('id', 'editdress-image');
            var dressInfo_thumb_caption = document.createElement('div');
            dressInfo_thumb_caption.setAttribute('class', 'caption');
            var designer_field = TextInput('editdress-designer',
                                                'Designer Name');
            var styleNumber_field = TextInput('editdress-styleNumber',
                                                'Style Number');
            var color_field = TextInput('editdress-color',
                                                'Color');

            // Create hidden alert area to show info after failures
            var status = document.createElement('div');
            status.setAttribute('id', 'editdress-status');
            status.setAttribute('class','form-group alert alert-danger hidden');
            status.setAttribute('role', 'alert');
            
            //Add buttons to bottom area
            var button_area = document.createElement('p');
            var cancel_button = document.createElement('a');
            var save_button = document.createElement('a');
            cancel_button.setAttribute('class', 'btn btn-default');
            cancel_button.setAttribute('role', 'button');
            cancel_button.innerHTML = 'Cancel';
            cancel_button.onclick = cancelNewDress;
            save_button.setAttribute('class', 'btn btn-primary pull-right');
            save_button.setAttribute('role', 'button');
            save_button.innerHTML = 'Save';
            save_button.onclick = saveNewDress;

            //Add children to parent elements
            button_area.appendChild(cancel_button);
            button_area.appendChild(save_button);
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(dressInfoTitle));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(status));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(dressInfo_thumb_img));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(designer_field));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(styleNumber_field));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(color_field));
            dressInfo_thumb_caption.appendChild(ContainerFormGroup(button_area));
            dressInfo_thumb.appendChild(dressInfo_thumb_caption);
            dressInfo.appendChild(dressInfo_thumb);

            //Append the view for the dress into the list section
            $('#dresslist').append(dressInfo);
        }
        
        $('html, body').animate({
                scrollTop: $("#editdress").offset().top
            }, 500);
    }

    loadProfile();
    $('#add_dress').click(function(){newDressForm();});
});



