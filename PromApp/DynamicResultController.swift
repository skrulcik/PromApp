//
//  TestController.swift
//  PromApp
//
//  Created by Scott Krulcik on 1/18/15.
//  Copyright (c) 2015 Scott Krulcik. All rights reserved.
//

import Foundation

class DynamicResult:UIView {
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    func setChild(childView child:UIView) {
        for subview in subviews {
            subview.removeFromSuperview()
        }
        if (subviews.count > 0){
            NSLog("Error removing subviews from dynamic result view")
        }
        self.addSubview(child)
    }
}