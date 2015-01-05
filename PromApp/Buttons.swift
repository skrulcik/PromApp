//
//  PillButton.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/22/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

class RoundedRectButton: UIButton{
    var foreground:UIColor = SKColor.RoundedRectFore()
    var fillColor:UIColor = SKColor.RoundedRect()
    var stroke:CGFloat = 3.0
    var radius:CGFloat = 0
    func loadColors(){
        //for subclasses to load custom colors if needed
    }
    
    override func drawRect(rect: CGRect) {
        loadColors()
        let rounded = UIBezierPath(roundedRect: rect, cornerRadius: radius)
        fillColor.setFill()
        rounded.fill()
        super.drawRect(rect)
    }
}

class PillButton: RoundedRectButton {
    override func loadColors(){
        super.loadColors()
        fillColor = SKColor.PillButton()
    }
    
    override func drawRect(rect: CGRect) {
        radius = rect.height/2 //"Pill shape" top/bottom=straight left/right=semicircle
        super.drawRect(rect)
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
    override func loadColors() {
        fillColor = SKColor.AddImageButton()
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect) //Button is square in storyboard, so will be circle
        
        //Draw "+" dynamically, so we don't mess with text size
        let tvert = CGRect(x: rect.midX-stroke/2, y: (rect.minY*1+rect.midY)/2,
            width: stroke, height: rect.height-((rect.minY*1+rect.midY)/2 * 2))
        let thor = CGRect(x: (rect.minX*1+rect.midX)/2, y:rect.midY-stroke/2,
                width: rect.width-((rect.minX*1+rect.midX)/2 * 2), height: stroke)
        foreground.setFill()
        let vertPath = UIBezierPath(rect: tvert)
        vertPath.fill()
        let horpath = UIBezierPath(rect: thor)
        horpath.fill()
    }
}

class SubscribedButton:PillButton{
    var subscribed = false
    
    override func loadColors() {
        super.loadColors()
        fillColor = subscribed ? SKColor.SubscribedButtonSelected():SKColor.SubscribedButtonBackground()
        foreground = SKColor.SubscribedButtonForeground()
        stroke = 3
    }
}


class RSSButton:SubscribedButton{
    override func drawRect(rect: CGRect) {
        //Set stroke
        let currentContext = UIGraphicsGetCurrentContext()
        CGContextSetLineWidth(currentContext, stroke)
        CGContextSetLineCap(currentContext, kCGLineCapRound);
        CGContextSetLineJoin(currentContext, kCGLineJoinRound);
        
        //Small rounded corners
        radius = rect.height/8
        super.drawRect(rect)
        
        foreground.setStroke()
        let r1 = (rect.width*1)/4
        let r2 = (rect.width*2)/4
        let r3 = (rect.width*3)/4
        for r in [r1, r2, r3]{
            let circ = UIBezierPath(arcCenter: CGPoint(x: rect.width/8, y: (rect.height*7)/8),
                radius: r, startAngle: 0, endAngle: 4.71, clockwise: false)
            CGContextBeginPath(currentContext);
            CGContextAddPath(currentContext, circ.CGPath);
            CGContextDrawPath(currentContext, kCGPathStroke);
        }
    }
}

