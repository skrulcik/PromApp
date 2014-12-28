//
//  PromSearchTable.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation


class PromSearchTable:UITableViewController, UISearchBarDelegate {
    var proms = [SKProm]()
    var maxObjects:Int = 10
    var searchString:String?
    
    //MARK: Event Responders
    @IBAction func cancelPressed(sender:AnyObject){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func newPressed(sender:AnyObject){
        NSLog("Creating new prom instance.")
        self.performSegueWithIdentifier("NewProm", sender: self)
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchString = searchBar.text
        searchForProms()
    }
    
    //MARK: Refresh Control
    override func viewDidLoad() {
        let reload = UIRefreshControl()
        reload.addTarget(self, action:"searchForProms:", forControlEvents: .ValueChanged)
    }
    
    //MARK: Queries
    func searchForProms(){
        if searchString == nil{
            NSLog("Attempted to search for prom without assigning search string.")
            return
        }
        NSLog("Searching for proms with string %@", searchString!)
        let query = PFQuery(className: SKProm.parseClassName())
        query.whereKey("schoolName", containsString: searchString!)
        query.limit = maxObjects
        //query.orderByAscending("preciseLocation")
        query.findObjectsInBackgroundWithBlock({
            (objects:Array!, error:NSError!) in
            if objects.count != 0{
                for object in objects{
                    if let prom = object as? SKProm{
                        self.proms.append(prom)
                    }
                }
                NSLog("Succeeded in finding %lu proms with search %@.", objects.count, self.searchString!)
                self.tableView.reloadData()
            } else {
                NSLog("Did not find any results for prom search %@. %@", self.searchString!, error.description)
            }
        })
    }
    
    //MARK:UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0 && indexPath.row < proms.count){
            var cell = tableView.dequeueReusableCellWithIdentifier("cell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Subtitle, reuseIdentifier: "cell")
            }
            let prom = proms[indexPath.row]
            cell!.textLabel?.text = prom.schoolName
            cell!.detailTextLabel?.text = prom.locationDescription
            return cell!
        } else {
            NSLog("Attempted to access invalid prom search table cell %@.", indexPath)
        }
        return UITableViewCell()
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return proms.count
        }
        return 0
    }
    
    
    
    
}