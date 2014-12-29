//
//  ColorProfile.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

class SKColor:UIColor
{
    class func pink()->UIColor{
        //FF7B9E
        return UIColor(red: 1.0, green: 123.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        //return UIColor(red: 1.0, green: 134.0/255.0, blue: 165.0/255.0, alpha: 1.0) //Old Pink
    }
    class func adjPinkForNavBar()->UIColor{
        //On screen is ff7b9e according to photoshop
        //ff7094 according to screenshot
        return UIColor(red: 1.0, green: 112.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    }
    class func white()->UIColor{
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    class func triadBlue()->UIColor{
        //4EADCC
        return UIColor(red:78.0/255.0, green: 173.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    class func triadBlueLight()->UIColor{
        //5CCDF2
        return UIColor(red: 92.0/255.0, green: 205.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    }
    
    //MARK: Specifics
    class func pillButton()->UIColor{
        return pink()
    }
    class func addImageButton()->UIColor{
        return pink()
    }
    class func navBar()->UIColor{
        return adjPinkForNavBar()
    }
    class func tableBackground()->UIColor{
        return white()
    }
    class func groupedTableBackground()->UIColor{
        return UIColor.grayColor()
    }
    class func LargeCellText()->UIColor{
        return UIColor.blackColor()
    }
    class func SmallCellText()->UIColor{
        return UIColor.darkGrayColor()
    }
    class func TabBarHighlight()->UIColor{
        return pink()
    }
    class func searchBar()->UIColor{
        return triadBlue()
    }
    class func SubscribedButtonBackground()->UIColor{
        return UIColor.grayColor()
    }
    class func SubscribedButtonForeground()->UIColor{
        return white()
    }
    class func SubscribedButtonSelected()->UIColor{
        return pink()
    }
}
