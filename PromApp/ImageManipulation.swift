//
//  ImageManipulation.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/26/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

func validImageDimensions(width:Int!, height:Int!)->Bool{
    return width > 0 && height > 0
}

/* Returns copy of image "scaled to fit" width and height
*   Requires image is valid image, and width and height are
*   greater than 0
*   Ensures result image has width and height equal to those that are
*   given. */
func scale(image:UIImage!, toFitWidth width:Int!, Height height:Int!)->UIImage!
{
    assert(validImageDimensions(width, height), "Error: Invalid image dimensions.")
    var goal_w:Int = width
    var goal_h:Int = height
    if image.size.height > image.size.width {
        //Portrait image
        goal_w = Int(Float(width)/Float(height) * Float(goal_h))
    } else if image.size.height < image.size.width {
        //Landscape image
        goal_h = Int(Float(height)/Float(width) * Float(goal_w))
    }
    assert(goal_w<=width && goal_h<=height, "Error: Scaling Image failed due to improper result dimensions")
    UIGraphicsBeginImageContextWithOptions(CGSize(width: width, height: height), true, 0.0)
    let scaledImageRect = CGRect(x: (width-goal_w)/2, y: (height-goal_h)/2, width: goal_w, height: goal_h)
    image.drawInRect(scaledImageRect)
    let constrainedImage = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return constrainedImage
}