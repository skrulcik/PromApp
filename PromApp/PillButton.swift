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

class AddImagePill:PillButton {
    var stroke:Int = 3
    var foreground:UIColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        let tvert = CGRect(x: Int(rect.midX)-stroke/2, y: (Int(rect.minY)*1+Int(rect.midY))/2,
            width: stroke, height: Int(rect.height)-((Int(rect.minY)*1+Int(rect.midY))/2 * 2))
        let thor = CGRect(x: (Int(rect.minX)*1+Int(rect.midX))/2, y:Int(rect.midY)-stroke/2,
                width: Int(rect.width)-((Int(rect.minX)*1+Int(rect.midX))/2 * 2), height: stroke)
        foreground.setFill()
        let vertPath = UIBezierPath(rect: tvert)
        vertPath.fill()
        let horpath = UIBezierPath(rect: thor)
        horpath.fill()
    }
}