//
//  MainTabController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/23/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

class MainTabController:UITabBarController {
    
    override func viewDidLoad() {
        // The following fixes a bug where the second tab icon would disappear when selected
        // TODO: Fix this in storyboard or something
        tabBar.tintColor = SKColor.pink()
        if let items = tabBar.items as? [UITabBarItem] {
            if items.count > 1 {
                let item = items[1]
                item.selectedImage = UIImage(named: "LocationIconSelected")?
            }
        }
    }
    
    /* Presents dialog for adding dresses and proms */
    @IBAction func showAddOptionPane(sender:AnyObject){
        let view = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        //Button for adding dresses
        let addDressAction = UIAlertAction(title: "Register Dress",
            style: .Default, handler: {
                (action:UIAlertAction!) in
                view.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier(NewDressSegueID, sender: self)
        })
        //Button to search for proms
        let findPromAction = UIAlertAction(title: "Create a Prom",
            style: .Default, handler: {
                (action:UIAlertAction!) in
                view.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier(NewPromSegueID, sender: self)
        })
        //Cancel action to dismiss controller
        let cancel = UIAlertAction(title: "Cancel",
            style: .Cancel, handler: {
                (action:UIAlertAction!) in
                view.dismissViewControllerAnimated(true, completion: nil)
        })
        view.addAction(addDressAction)
        view.addAction(findPromAction)
        view.addAction(cancel)
        presentViewController(view, animated: true, completion: nil)
    }
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == NewPromSegueID {
            if let promcreator = segue.destinationViewController as? PromEditor {
                promcreator.title = "New Prom"
            }
        }
    }
    
    @IBAction func unwindFromNewProm(segue:UIStoryboardSegue){
        NSLog("Finished unwinding from new prom.")
    }
    
    @IBAction func unwindFromLogin(segue:UIStoryboardSegue) {
        if(viewControllers != nil && viewControllers!.count > 0){
            if let profile:ProfileController = viewControllers![0] as? ProfileController{
                NSLog("Unwound from login to main tab view.")
                profile.updateUserData(PFUser.currentUser())
            } else {
                NSLog("Attempted to unwind from login without creating profile view controller.")
            }
        }
    }
}