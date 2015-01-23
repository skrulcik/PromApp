
//Use image library
var Image = require("parse-image");
var _ = require('underscore');

var MAX_W = 80.0
var MAX_H = 120.0

/* Adds a lowercase search name for case-insensitive searches */
Parse.Cloud.beforeSave("Prom", function(request, response){
                       Parse.Cloud.useMasterKey();//Enable superuser superpowers
                       var prom = request.object;
                       var schoolName = prom.get("schoolName")
                       var lowName = schoolName.toLowerCase()
                       prom.set("searchName", lowName)
                       response.success()
                       })

/* Compresses image and creates thumbnail for faster retrieval. */
Parse.Cloud.beforeSave("Dress", function(request, response) {
                    Parse.Cloud.useMasterKey();//Enable superuser superpowers
                    var dress = request.object;

                    if(dress.get("designer") && dress.get("styleNumber")){
                       var designer = dress.get("designer").replace(/ /g, '');
                       designer = designer.toLowerCase();
                       var styleNo = dress.get("styleNumber").replace(/ /g, '');
                       styleNo = styleNo.toLowerCase();
                       dress.set("designerSearch", designer);
                       dress.set("styleNumberSearch", styleNo);
                    } else {
                       response.error("Missing required fields.");
                    }
                       
                    if (!dress.dirty("image")) {
                        // The profile photo isn't being modified.
                        response.success();
                        return;
                    }

                    //The following generates a thumbnail image to be used in table view
                    Parse.Cloud.httpRequest({
                        url: dress.get("image").url()
                        }).then(function(response) {
                            var image = new Image();
                            return image.setData(response.buffer);
                        }).then(function(image) {
                            if(image.width() > MAX_W || image.height() > MAX_H){
                                //Shrink image to thumbnail for display in long lists
                                var goal_w = MAX_W;
                                var goal_h = MAX_H;
                                if(image.height() > image.width()){
                                    goal_h = (image.height()/image.width()) * goal_w;
                                } else {
                                    goal_w = (image.width()/image.height()) * goal_h;
                                }
                                return image.scale({
                                                   width: goal_w,
                                                   height: goal_h
                                                   });
                            } else{
                                return image;
                            }
                        }).then(function(image){
                                if(image.width() > MAX_W){
                                    return image.crop({
                                                      left: (image.width()-MAX_W)/2,
                                                      top: 0,
                                                      width: MAX_W,
                                                      height: MAX_H
                                                      });
                                } else if(image.height() > MAX_H){
                                    //Crop to bounds of box
                                    return image.crop({
                                                      left: 0,
                                                      top: (image.height()-MAX_H)/2,
                                                      width: MAX_W,
                                                      height: MAX_H,
                                                      success: function(postimage) {
                                                      // The image was cropped.
                                                      },
                                                      error: function(error) {
                                                      // The image could not be cropped.
                                                      console.log("Error cropping " + error);
                                                      response.error(error);
                                                      }
                                                      });
                                } else{
                                    return image;
                                }
                        }).then(function(image) {
                            // Make sure it's a JPEG to save disk space and bandwidth.
                            return image.setFormat("PNG");
                        }).then(function(image) {
                            // Get the image data in a Buffer.
                            return image.data();
                        }).then(function(buffer) {
                            // Save the image into a new file.
                            var base64 = buffer.toString("base64");
                            var fileName = dress.get("designer") + dress.get("styleNumber") + "thumbnail.png";
                            var cropped = new Parse.File(fileName, { base64: base64 });
                            return cropped.save();
                        }).then(function(cropped) {
                            // Attach the image file to the original object.
                            dress.set("imageThumbnail", cropped);
                        }).then(function(result) {
                            response.success();
                        }, function(error) {
                            response.error(error);
                        });
                    });

// Remove references to a prom before it is deleted
Parse.Cloud.beforeDelete('Prom', function(request, response) {
                         // First remove from User objects
                         // Dealing with users we need master key
                         Parse.Cloud.useMasterKey();
                         
                         // Get prom object from request
                         var prom = request.object;
                         
                         // Query for all dresses with a reference to this prom
                         var query = new Parse.Query("Dress")
                         query.equalTo("prom", prom);
                         query.include("prom");
                         query.each(function(dress){
                                    dress.unset("prom");
                                    dress.save();
                                    });
                         // Query for all users with a reference to this prom
                         var query = new Parse.Query("_User");
                         query.equalTo("proms", request.object);
                         query.include("proms");
                         query.each(function (user) {
                                    user.remove("proms", prom);
                                    user.save();
                                    }).then(function() {
                                            response.success();
                                            }, function(error) {
                                            response.error(error);
                                            });
})

Parse.Cloud.job("emailSetup", function(request, status) {
                // Set up to modify user data
                Parse.Cloud.useMasterKey();
                var counter = 0;
                var numUpdated = 0;
                var errors = "";
                // Query for all users
                var query = new Parse.Query(Parse.User);
                query.each(function(user) {
                    var userEmail = user.get("email");
                     if(userEmail && userEmail != ""){
                         user.set("username", userEmail);
                         numUpdated += 1;
                     } else {
                         var profile = user.get("profile");
                         if(profile){
                             var profEmail = profile["email"];
                             if(profEmail && profEmail != ""){
                                 user.set("email", profEmail);
                                 user.set("username", profEmail);
                                 numUpdated += 1;
                             } else {
                                 errors += "\nUser "+ user.get("username") + " did not have an email in their profile.";
                             }
                         } else {
                             errors += "\nUser "+ user.get("username") + " did not have profile.";
                         }
                     }
                    status.message(counter + " users processed.");
                    counter += 1;
                    return user.save();
                }).then(function() {
                  // Set the job's success status
                  status.success("Updated email addresses for "+numUpdated+" users.");
                }, function(error) {
                  // Set the job's error status
                  status.error("Found errors: \n"+errors);
                });
                });
