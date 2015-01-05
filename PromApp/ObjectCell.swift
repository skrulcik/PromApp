//
//  PromCell.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
import UIKit

class ObjectCell:UITableViewCell {
    @IBOutlet weak var picView: UIImageView!
    @IBOutlet weak var bigLabel: UILabel!
    @IBOutlet weak var littleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        bigLabel.textColor = SKColor.LargeCellText()
        littleLabel.textColor = SKColor.SmallCellText()
        bigLabel.font = UIFont.systemFontOfSize(largeFontSize)
        littleLabel.font = UIFont.systemFontOfSize(smallFontSize)
    }
}
