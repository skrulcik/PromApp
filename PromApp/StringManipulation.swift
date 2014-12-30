//
//  StringManipulation.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

func removeAllWhiteSpace(str:String?)->String{
    if str != nil {
        let len = countElements(str!)
        return (str! as NSString).stringByReplacingOccurrencesOfString("\\s", withString: "", options: .RegularExpressionSearch, range:NSRange(location: 0, length: len)) as String
    } else {
        return "" //Non-optional return type
    }
}