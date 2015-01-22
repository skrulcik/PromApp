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
        return hexColor("FF7094")
        //hexColor("FF7B9E")
    }
    class func pinkLightCompliment()->UIColor{
        return hexColor("ff89a7")
    }
    class func neutralCompoundBrown()->UIColor{
        return hexColor("998680")//665955")
    }
    class func triadBlue()->UIColor{
        return hexColor("45AACC")
    }
    class func triadBlueLight()->UIColor{
        return hexColor("5CCDF2")
    }
    class func triadYellow()->UIColor{
        return hexColor("B23D5A")
    }
    class func white()->UIColor{
        return UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    }
    
    //MARK: Specifics
    class func PillButton()->UIColor{
        return pink()
    }
    class func LoginButton()->UIColor{
        return white()
    }
    class func LoginForeground()->UIColor{
        return pink()
    }
    class func AddImageButton()->UIColor{
        return pink()
    }
    class func NavBar()->UIColor{
        return pink()
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
        return neutralCompoundBrown()//UIColor.darkGrayColor()
    }
    class func TabBarHighlight()->UIColor{
        return pink()
    }
    class func SearchBar()->UIColor{
        return pinkLightCompliment()//pink()
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
    class func ImageBackground()->UIColor{
        return triadBlue()
    }
    class func TableHeader()->UIColor{
        return pink()
    }
    class func TableHeaderText()->UIColor{
        return white()
    }
    class func RoundedRect()->UIColor{
        return pink()
    }
    class func RoundedRectFore()->UIColor{
        return white()
    }
}
