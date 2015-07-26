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
func scale(image:UIImage, toFitWidth width:Int, Height height:Int)->UIImage!
{
    assert(validImageDimensions(width, height: height), "Error: Invalid image dimensions.")
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

/* Merges two images into one horizontally */
func mergeHorizontal(img1:UIImage, img2:UIImage) -> UIImage{
    // First calculate maximum dimensions
    let full_width = img1.size.width + img2.size.width
    let full_height = max(img1.size.height, img2.size.height)
    let size = CGSize(width: full_width, height: full_height)
    
    // Create context to manipulate images in
    UIGraphicsBeginImageContext(size)
    // Draw images in context
    img1.drawInRect(CGRect(x: 0, y: 0, width: img1.size.width, height: full_height))
    img2.drawInRect(CGRect(x: img1.size.width, y:0, width: img2.size.width, height: full_height))
    // Save context as image
    let full_image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    return full_image
}

func mergeHorizontal(imgList:Array<UIImage>) -> UIImage{
    if imgList.count < 1 {
        return UIImage()
    } else {
        var baseImage = imgList[0]
        for i in 1..<imgList.count {
            baseImage = mergeHorizontal(baseImage, img2: imgList[i])
        }
        return baseImage
    }
}