//
//  PromInfoController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/28/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

class PromInfoController:UIViewController {
    
    @IBOutlet weak var subscribedButt: SubscribedButton!
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
    
    @IBAction func subscribePressed(sender: AnyObject) {
        NSLog("Subscribe Button Pressed")
        if promObject != nil {
            let user = PFUser.currentUser()
            if user.isFollowingProm(promObject!){
                let askDialog = UIAlertController(title: "Are you sure?", message: "Are you sure you want to unfollow this prom?", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let unfollow = UIAlertAction(title: "Un-follow", style: .Default, handler: {
                    (alertAction:UIAlertAction!) in
                    //User wants to unsubscribe
                    if self.promObject != nil {
                        user.removeObject(self.promObject!, forKey: "proms")
                        self.updateButtonState()
                        user.saveInBackgroundWithBlock(nil)
                    }
                })
                askDialog.addAction(cancel)
                askDialog.addAction(unfollow)
                presentViewController(askDialog, animated: true, completion: nil)
            } else {
                //User has not subscribed, so subscribe them
                user.addObject(self.promObject!, forKey: "proms")
                user.saveInBackgroundWithBlock(nil)
                updateButtonState()
            }
        }
    }
    
    func updateButtonState(){
        if promObject != nil{
            //Check if user is subscribed to prom
            subscribedButt.subscribed = PFUser.currentUser().isFollowingProm(promObject!)
            //Force redraw if state changed
            subscribedButt.setNeedsDisplay()
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
        updateButtonState()//check if user subscribed
    }
}