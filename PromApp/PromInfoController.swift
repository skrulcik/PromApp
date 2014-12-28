//
//  PromInfoController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

class PromInfoController:UIViewController {
    
    @IBOutlet weak var promImage: PFImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var infoLabel: UITextView!
    @IBOutlet weak var dressButton: PillButton!
    var promObject:SKProm?
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidAppear(animated: Bool) {
        if promObject != nil {
            reloadData(promObject!)
        }
    }
    
    func reloadData(prom:SKProm){
        //Fill in title and image view first, then other data in loop
        if prom.schoolName != ""{
            nameLabel.text = prom.schoolName
            title = prom.schoolName //Set navbar title
        }
        promImage.file = prom.image
        promImage.loadInBackground(nil)
        var infoString = ""
        let readable:Dictionary<String, String> = Prom.readableNamesForKeys()
        for key in Prom.editableKeys() {
            if key != "schoolName" && key != "image" {
                if let valString = prom.objectForKey(key) as String!{
                    infoString += String(format: "%@: %@\n", readable[key]!, valString)
                }
            }
        }
        infoLabel.text = infoString
        infoLabel.font = UIFont.systemFontOfSize(smallFontSize)
    }
}