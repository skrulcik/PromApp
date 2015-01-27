
$(function() {
    //Verify page with Parse
    Parse.$ = jQuery;
    Parse.initialize("PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg",
                        "QDNCcyQqQRlCjMSIrXanH37MioTb2IJoPIuD5d1C");
    /* Define Model **************************/
    // For now, don't use any special methods
    var Prom = Parse.Object.extend("Prom");
    var Dress = Parse.Object.extend("Dress");
    var Store = Parse.Object.extend("Store");
    
    /* Underscore Templates ******************/
    // Access template variables using data.<varname>
    // Suggested by http://www.bennadel.com/blog/2411-using-underscore-js-templates-to-render-html-partials.htm
    _.templateSettings.variable = "data";
    // Pre-compile templates for fast reuse
    var EditTemplate = _.template($("script.editor_template").html());

    /* Template Data *************************/
    // Instructions for Underscore to use to construct
    // each type of editor
    var NewDressData = {
        title:"New Dress",
        id:"editdress",
        textInputs:[{
            id:"editdress-designer",
            placeholder:"Designer"
        },{
            id:"editdress-styleNumber",
            placeholder:"Style Number"
        },{
            id:"editdress-color",
            placeholder:"Color"
        }]
    };
    var NewStoreData = {
        title:"New Store",
        id:"editstore",
        textInputs:[{
            id:"editstore-address",
            placeholder:"Address"
        },{
            id:"editstore-name",
            placeholder:"Store Name"
        },{
            id:"editstore-website",
            placeholder:"Website   (http://...)"
        },{
            id:"editstore-phone",
            placeholder:"Phone Number"
        },{
            id:"editstore-hours",
            placeholder:"Store Hours"
        }]
    };
    var NewPromData = {
        title:"New Prom",
        id:"editprom",
        textInputs:[{
            id:"editprom-schoolname",
            placeholder:"School Name"
        },{
            id:"editprom-schooladdress",
            placeholder:"School Address"
        },{
            id:"editprom-locationdescription",
            placeholder:"Event Location"
        },{
            id:"editprom-theme",
            placeholder:"Theme"
        }]
    };
    // EditorData allows key style access to template data
    //      for each tyoe of editor
    var EditorData = {
        dress:NewDressData,
        store:NewStoreData,
        prom:NewPromData
    };
    // Note: Editor Object for View defined below event handlers

    /* Conveniance Methods *******************/
    /* Given the id of an error alert div, it will display the appropriate \
    * color and given text */
    function showError(errorid, message){
        console.log(message)
        $(errorid).removeClass("hidden");
        $(errorid).html(message);
    }
    function clearError(errorid){
        $(errorid).addClass('hidden');
    }

    /* Event Handlers ************************/
    // Cancel and save for dress creation
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
        // Ensure required fields are filled out
        if(!designer){
            showError("#editdress-status", "Designer is a required field.");
            return;
        }
        if(!styleNumber){
            showError("#editdress-status", "Style number is a required field.");
            return;
        }

        // Fill dress object with data
        var newDress = new Dress(); // Instantiate blank dress

        // If image exists, save it before saving the dress
        if(imgInput && imgInput.files && imgInput.files.length > 0){
            // Retrieve image file from file input
            var imgfile = imgInput.files[0];
            // Ensure image file is of an acceptable type
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
        } else {
            // Set default fields (designer, style no.)
            newDress.set('designer', designer);
            newDress.set('styleNumber', styleNumber);
            // Set optional fields (color, prom-in future implementation)
            if(color){
                newDress.set('dressColor', color);
            }
            newDress.save().then(function(){
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
    }
    // Cancel and save for prom creation
    function cancelNewProm(){
        $('#editprom').remove();
        // If there are no proms, this would show the placeholder again
        // If there are proms, placeholder would be removed -> no effect
        $('#prom-placeholder').show();
    }
    function saveNewProm(){
        var schoolName = $('#editprom-schoolname').val();
        var schoolAddress = $('#editprom-schooladdress').val();
        var locationDescription = $('#editprom-locationdescription').val();
        var theme = $('#editprom-theme').val();
        var imgInput = $('#editprom-image')[0];
        if(!schoolName){
            showError("#editprom-status", "School Name is a required field.");
            return;
        }
        if(!schoolAddress){
            showError("#editprom-status", "School Address is a required field.");
            return;
        }
        if(!locationDescription){
            showError("#editprom-status", "Please provide a description of the venue.");
            return;
        } 

        // Fill dress object with data
        var newProm = new Prom(); // Instantiate blank prom object
        
        // If image exists, save image first then prom
        if(imgInput && imgInput.files && imgInput.files.length > 0){
            var imgfile = imgInput.files[0];
            var filetype = "";
            var name = "prom-image";
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
                    showError("#editprom-status",
                                "Please upload a PNG, JPG, or JPEG image.");
                    return;
            }
            // Must save image file before association
            var promImage = new Parse.File(name, imgfile);

            promImage.save().then(function() {
                // Image saved successfully:
                newProm.set('image', promImage);
                // Set default fields
                newProm.set('schoolName', schoolName);
                newProm.set('address', address);
                newProm.set('locationDescription', locationDescription);
                // Set optional fields
                if(theme){
                    newProm.set('theme', theme);
                }
                return newProm.save();
            }).then(function(){
                Parse.User.current().addUnique('proms', newProm);
                return Parse.User.current().save();
            }).then(function(){
                $('#editprom').remove(); // Remove vestigal editing box
                loadProfile();
            }, function(error) {
              // Well...damn, it didn't save
                showError("#editprom-status",
                            "Prom could not be saved: error " + error.code);
            });
        } else {
            // Set default fields
            newProm.set('schoolName', schoolName);
            newProm.set('address', address);
            newProm.set('locationDescription', locationDescription);
            // Set optional fields
            if(theme){
                newProm.set('theme', theme);
            }
            newProm.save().then(function(){
                Parse.User.current().addUnique('proms', newProm);
                return Parse.User.current().save();
            }).then(function(){
                $('#editprom').remove(); // Remove vestigal editing box
                loadProfile();
            }, function(error) {
              // Well...damn, it didn't save
                showError("#editprom-status",
                            "Prom could not be saved: error " + error.code);
            });
        }
    }
    // Cancel and save for store creation
    function cancelNewStore(){
        $('#editstore').remove();
        // If there are no stores, this would show the placeholder again
        // If there are stores, placeholder would be removed -> no effect
        $('#store-placeholder').show();
    }
    function saveNewStore(){
        var name = $('#editstore-name').val();
        var address = $('#editstore-address').val();
        var phone = $('#editstore-phone').val();
        var website = $('#editstore-website').val();
        var hours = $('#editstore-hours').val();
        var imgInput = $('#editstore-image')[0];
        if(!name){
            showError("#editstore-status", "You must provide a store name.");
            return;
        }
        if(!(address || phone || website)){
            showError("#editstore-status", "Please provide address, phone number or website for contact.");
            return;
        }

        // Fill dress object with data
        var newStore = new Store(); // Instantiate blank dress

        // If image exists, save it before store
        if(imgInput && imgInput.files && imgInput.files.length > 0){
            // Retrieve image from file
            var imgfile = imgInput.files[0];

            // Create file name for image
            var filetype = "";
            var name = "store-image";
            var len = imgfile.name.length;
            if(len > 4){
                filetype = imgfile.name.substring(len-4, len);
            }
            // Ensure file is of accepted type
            switch (filetype.toLowerCase()) {
                case ".png":
                    name += '.png'
                    break;
                case ".jpg":
                case "jpeg":
                    name += '.jpg'
                    break;
                default:
                    showError("#editstore-status",
                                "Please upload a PNG, JPG, or JPEG image.");
                    return;
            }

            // Must save image file before association
            var storeImage = new Parse.File(name, imgfile);

            storeImage.save().then(function() {
                // Image saved successfully:
                newStore.set('image', storeImage);
                newStore.set('name', name);
                // Set optional fields (We know at least one contact field should be filled)
                if(address){
                    newStore.set('address', address);
                }
                if(phone){
                    newStore.set('phone', phone);
                }
                if(website){
                    newStore.set('website', website);
                }
                if(hours){
                    newStore.set('hours', hours);
                }
                return newStore.save();
            }).then(function(){
                Parse.User.current().addUnique('stores', newStore);
                return Parse.User.current().save();
            }).then(function(){
                $('#editstore').remove(); // Remove vestigal editing box
                loadProfile();
            }, function(error) {
              // Well...damn, it didn't save
                showError("#editstore-status",
                            "Store could not be saved: error " + error.code);
            });
        } else {
            // There is no image to save
            // Set required fields
            newStore.set('name', name);
            // Set optional fields (We know at least one contact field should be filled)
            if(address){
                newStore.set('address', address);
            }
            if(phone){
                newStore.set('phone', phone);
            }
            if(website){
                newStore.set('website', website);
            }
            if(hours){
                newStore.set('hours', hours);
            }
            newStore.save().then(function(){
                Parse.User.current().addUnique('stores', newStore);
                return Parse.User.current().save();
            }).then(function(){
                $('#editstore').remove(); // Remove vestigal editing box
                loadProfile();
            }, function(error) {
              // Well...damn, it didn't save
                showError("#editstore-status",
                            "Store could not be saved: error " + error.code);
            });
        }
    }

    // Organize event handlers for access with keys
    // Cancel button actions:
    var cancelHandlers = {
        dress:cancelNewDress,
        prom:cancelNewProm,
        store:cancelNewStore
    };
    // Save button actions:
    var saveHandlers = {
        dress:saveNewDress,
        prom:saveNewProm,
        store:saveNewStore
    };

    /* The following are specific implementations of editors for each data type.
     * A generic editor may be possible in the future. Currently this uses the 
     * abstract editor template, but assigns the onclick functions in a hard-coded way
     */
    var Editor = Parse.View.extend({
        initialize: function(options){
            this.edittype = options.edittype // Key to represent desired editor style
            this.template = EditTemplate;    // Underscore template for view
            this.fillData = EditorData[this.edittype];
            this.render();
        },
        render: function(){
            var templateOptions = EditorData[this.edittype]; // Options for desired editor style
            this.$el.html(this.template(templateOptions));
            return this;
        },
        bindButtons: function(){
            /* NOTE: This must be called AFTER the element is in the DOM */
            this.$('.btn-save').click(saveHandlers[this.edittype]);
            this.$('.btn-cancel').click(cancelHandlers[this.edittype]);
        }
    });

    /* Given a type of object ("dress", "prom", "store") newForm displays
    *   the corresponding form for object creation. */
    function newForm(type){
        // id's are named in a standard way
        // use form type to generate id_names
        var ph_id = '#'+type+'-placeholder';
        var edit_id = '#edit'+type;
        var status_id = edit_id+'-status';
        var list_id = '#'+type+'list';

        $(ph_id).hide(); // If empty area, clear the placeholder
        clearError(status_id); // Remove error if it's there
        // Prevent user from adding multiple dresses at once:
        if (!$(edit_id).length){
            //Append the view for the dress into the list section
            // first create actual editor object, using type to
            //      specify which type of editor is wanted
            var typeEditor = new Editor({edittype: type});
            // Actually add to DOM
            $(list_id).append(typeEditor.el);
            typeEditor.bindButtons();
        }
        // Scrolls to new form (Useful for mobile)
        $('html, body').animate({
                scrollTop: $(edit_id).offset().top
            }, 500);
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
        if(!stores){
            /* NOTE:
            * When a store account is created, it is assigned an empty array for
            * its 'stores' property. Therefore a length of zero does not imply
            * that the account cannot create stores.
            */
            $("#stores").hide();
        } else {
            if(numStores > 0){
                displayStores(stores);
            }
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
    $('#add_dress').click(function(){newForm("dress");});
    $('#add_prom').click(function(){newForm("prom");});
    $('#add_store').click(function(){newForm("store");});
});



