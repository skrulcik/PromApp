//
//  PromSearchTable.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation


class PromSearchTable:UITableViewController {
    @IBAction func cancelPressed(sender:AnyObject){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func newPressed(sender:AnyObject){
        NSLog("Creating new prom instance")
        self.performSegueWithIdentifier("NewProm", sender: self)
    }
}