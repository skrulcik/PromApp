//
//  PillButton.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/22/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

class PillButton: UIButton {
    var fillColor:UIColor = UIColor(red: 1.0, green: 134.0/255.0, blue: 165.0/255.0, alpha: 1.0)
    
    override func drawRect(rect: CGRect) {
        let rounded = UIBezierPath(roundedRect: rect, cornerRadius: rect.height/2)
        fillColor.setFill()
        rounded.fill()
    }
}