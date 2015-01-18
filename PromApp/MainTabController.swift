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
        self.performSegueWithIdentifier("NewDress", sender: self)
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