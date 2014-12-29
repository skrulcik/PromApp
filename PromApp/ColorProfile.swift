//
//  ColorProfile.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

//Single Class to hold all necessary color information for the app
class SKColor:UIColor
{
    class func hexColor(hexstr:String)->UIColor{
        let scan = NSScanner(string: hexstr)
        var numerical:UInt32 = 0
        if scan.scanHexInt(&numerical){
            numerical &= 0xFFFFFF //mask out blank channel
            let red = CGFloat((numerical & 0xFF0000) >> 16)/255.0
            let green = CGFloat((numerical & 0x00FF00) >> 8)/255.0
            let blue = CGFloat(numerical & 0xFF)/255.0
            return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
        }
        return white()
    }
    class func pink()->UIColor{
        return hexColor("FF7B9E")
        //return UIColor(red: 1.0, green: 123.0/255.0, blue: 158.0/255.0, alpha: 1.0)
        //return UIColor(red: 1.0, green: 134.0/255.0, blue: 165.0/255.0, alpha: 1.0) //Old Pink
    }
    class func adjPinkForNavBar()->UIColor{
        //ff7094 according to screenshot
        return UIColor(red: 1.0, green: 112.0/255.0, blue: 148.0/255.0, alpha: 1.0)
    }
    class func white()->UIColor{
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    class func triadBlue()->UIColor{
        //45AACC
        return UIColor(red:69.0/255.0, green: 170.0/255.0, blue: 204.0/255.0, alpha: 1.0)
    }
    class func triadBlueLight()->UIColor{
        //5CCDF2
        return UIColor(red: 92.0/255.0, green: 205.0/255.0, blue: 240.0/255.0, alpha: 1.0)
    }
    class func triadYellow()->UIColor{
        //B23D5A
        return UIColor(red: 178.0/255.0, green: 61.0/255.0, blue: 90.0/255.0, alpha: 1.0)
    }
    
    //MARK: Specifics
    class func PillButton()->UIColor{
        return pink()
    }
    class func AddImageButton()->UIColor{
        return pink()
    }
    class func NavBar()->UIColor{
        return adjPinkForNavBar()
    }
    class func TableBackground()->UIColor{
        return white()
    }
    class func GroupedTableBackground()->UIColor{
        return hexColor("F7F7F7") //Grouped background from IOS colors
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
    class func SearchBar()->UIColor{
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
