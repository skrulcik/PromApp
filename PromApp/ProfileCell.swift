//
//  ProfileCell.swift
//  PromApp
//
//  Created by Scott Krulcik on 9/26/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit

class ProfileCell: UITableViewCell
{
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UILabel!
    
    override init() {
        super.init()
        
    }
    
    required override init(frame: CGRect) {
        super.init(frame: frame)
        
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    required override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
    }
    
    func setName(newName:String){
        self.nameLabel.text = newName
        println("Set name")
    }
}