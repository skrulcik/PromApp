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
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(animated: Bool) {
        if promObject != nil {
            reloadData(promObject!)
        }
    }
    
    @IBAction func subscribePressed(sender: AnyObject) {
        if promObject != nil {
            let user = PFUser.currentUser()
            if user.isFollowingProm(promObject!){
                let askDialog = UIAlertController(title: "Are you sure?", message: "Are you sure you want to unfollow this prom?", preferredStyle: .Alert)
                let cancel = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
                let unfollow = UIAlertAction(title: "Un-follow", style: .Default, handler: {
                    (alertAction:UIAlertAction!) in
                    //User wants to unsubscribe
                    NSLog("User unsubscribing from prom. %@", self.promObject!.objectId)
                    user.removeObject(self.promObject!, forKey: "proms")
                    self.updateButtonState()
                    user.saveInBackgroundWithBlock(nil)
                })
                askDialog.addAction(cancel)
                askDialog.addAction(unfollow)
                presentViewController(askDialog, animated: true, completion: nil)
            } else {
                //User has not subscribed, so subscribe them
                NSLog("User subscribing to prom. %@", self.promObject!.objectId)
                user.addObject(self.promObject!, forKey: "proms")
                user.saveInBackgroundWithBlock(nil)
                updateButtonState()
            }
        }
    }
    
    @IBAction func viewDressesPresses(sender: AnyObject) {
        if promObject != nil {
            performSegueWithIdentifier(DressesFromPromID, sender: self)
        }
    }
    
    func updateButtonState(){
        if promObject != nil{
            //Check if user is subscribed to prom
            subscribedButt.subscribed = PFUser.currentUser().isFollowingProm(promObject!)
            //Force redraw if state changed
            if subscribedButt.subscribed {
                subscribedButt.setTitle("Following 👍", forState:.Normal)
                
            } else {
                subscribedButt.setTitle("Subscribe", forState:.Normal)
            }
            subscribedButt.setNeedsDisplay()
        }
    }
    
    func reloadData(prom:SKProm){
        //If the user has write access, allow them to edit
        if let acl = prom.ACL {
            if acl.getWriteAccessForUser(PFUser.currentUser()) {
                //Add edit button to navigation bar
                let editButton = UIBarButtonItem(barButtonSystemItem: .Edit, target: self, action: "editProm")
                self.navigationItem.rightBarButtonItem = editButton
            }
        }
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
                if let valString = prom.objectForKey(key) as? String {
                    infoString += String(format: "%@: %@\n", readable[key]!, valString)
                }
            }
        }
        infoLabel.text = infoString
        infoLabel.font = UIFont.smallFont()
        updateButtonState()//check if user subscribed
    }
    
    func editProm(){
        //Edit button was pressed
        //Double check the user is allowed to edit the prom
        if promObject != nil &&
                promObject!.ACL.getWriteAccessForUser(PFUser.currentUser()) {
            self.performSegueWithIdentifier(EditPromSegueID, sender: self)
        }
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == DressesFromPromID{
            if let dressListView = segue.destinationViewController as? DressListForProm{
                dressListView.prom = self.promObject
            }
        } else if segue.identifier == EditPromSegueID && promObject != nil {
            if let promEditController = segue.destinationViewController as? PromEditor{
                promEditController.setupWithProm(self.promObject!)
            }
        }
    }
    @IBAction func unwindFromEditProm(segue: UIStoryboardSegue){
        NSLog("Unwound from edit dress.")
    }
}