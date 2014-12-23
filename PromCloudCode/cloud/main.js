
//Use image library
var Image = require("parse-image");

var MAX_W = 80.0
var MAX_H = 120.0

Parse.Cloud.beforeSave("Dress", function(request, response) {
                       
                    var dress = request.object;
                    
                    if (!dress.get("image")) {
                        response.error("Cannot save dress without providing an image.");
                        return;
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