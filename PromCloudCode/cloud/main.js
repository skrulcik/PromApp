
//Use image library
var Image = require("parse-image");

Parse.Cloud.beforeSave("Dress", function(request, response) {
                       
                    var dress = request.object;
                    
                    if (!dress.get("image")) {
                        response.error("No dress image found.");
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
                            // Crop the image to the smaller of width or height.
                            var size = Math.min(image.width(), image.height());
                            return image.crop({
                            left: (image.width() - size) / 2,
                            top: (image.height() - size) / 2,
                            width: size,
                            height: size
                        });

                        }).then(function(image) {
                            // Resize the image to 80x80.
                            return image.scale({
                                width: 80,
                                height: 80
                            });
                                
                        }).then(function(image) {
                            // Make sure it's a JPEG to save disk space and bandwidth.
                            return image.setFormat("PNG");
                        }).then(function(image) {
                            // Get the image data in a Buffer.
                            return image.data();
                        }).then(function(buffer) {
                            // Save the image into a new file.
                            var base64 = buffer.toString("base64");
                            var cropped = new Parse.File("thumbnail.png", { base64: base64 });
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