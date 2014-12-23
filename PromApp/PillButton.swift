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

class LogoutPill:PillButton {
    let top_buff = 0 //Pixel buffer between table and button
    let bottom_buff = 0
    let wl_ratio = 4
    override func drawRect(rect: CGRect) {
        let height = Int(rect.height) - top_buff - bottom_buff
        let width = wl_ratio * height
        let left_x = Int(rect.midX) - width/2
        let top_y = Int(rect.minY) + top_buff
        let base = CGRect(x: left_x, y: top_y, width: width, height: height)
        super.drawRect(base)
    }
}