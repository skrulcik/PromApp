//
//  TableHeader.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/29/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
import UIKit

class TableHeader:UIView {
    @IBOutlet var textLabel:UILabel!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        loadColors()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        loadColors()
    }
    
    func loadColors(){
        self.backgroundColor = SKColor.TableHeader()
        if textLabel != nil {
            self.textLabel.textColor = SKColor.TableHeaderText()
            self.textLabel.textAlignment = .Left
            self.textLabel.font = UIFont.systemFontOfSize(smallFontSize)
        }
    }
}