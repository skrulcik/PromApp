//
//  MainTabController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/23/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation

class MainTabController:UITabBarController {
    
    /* Presents dialog for adding dresses and proms */
    @IBAction func showAddOptionPane(sender:AnyObject){
        let view = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        //Button for adding dresses
        let addDressAction = UIAlertAction(title: "Add Dress",
            style: .Default, handler: {
                (action:UIAlertAction!) in
                view.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("NewDress", sender: self)
        })
        //Button to search for proms
        let findPromAction = UIAlertAction(title: "Find a Prom",
            style: .Default, handler: {
                (action:UIAlertAction!) in
                view.dismissViewControllerAnimated(true, completion: nil)
                self.performSegueWithIdentifier("FindProm", sender: self)
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