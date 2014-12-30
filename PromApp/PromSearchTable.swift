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
    @IBOutlet weak var search: UISearchBar!
    @IBAction func cancelPressed(sender:AnyObject){
        self.presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
    }
    @IBAction func newPressed(sender:AnyObject){
        NSLog("Creating new prom instance.")
        self.performSegueWithIdentifier(NewPromSegueID, sender: self)
    }
    
    //MARK: UISearchBarDelegate
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        searchString = searchBar.text
        searchForProms()
    }
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        refreshControl?.enabled = false
    }
    
    //MARK: Refresh Control
    func refreshView(sender:AnyObject){
        if proms.count == maxObjects{
            //Table has reached search capacity
            //Add capacity to table to load more matching schools
            maxObjects += 10
        }
        //Redo search
        searchForProms()
    }
    override func viewDidLoad() {
        search.backgroundColor = SKColor.SearchBar()
        tableView.backgroundColor = SKColor.TableBackground()
    }
    override func viewWillAppear(animated: Bool) {
        createRefreshControl()
    }
    func createRefreshControl() {
        //FIXME: try UISearchCOntroller
        if refreshControl == nil && false{
            refreshControl = UIRefreshControl()
            refreshControl?.backgroundColor = SKColor.triadBlueLight()
            let reloadFont = UIFont(name: "Palatino-Italic", size: 20)
            let reloadColor = SKColor.white()
            let attribs:Dictionary<NSObject, AnyObject> = [NSForegroundColorAttributeName:reloadColor]//, NSFontAttributeName:reloadFont]
            refreshControl!.attributedTitle = NSAttributedString(string: "Loading Proms...",
                attributes: attribs)
            refreshControl!.addTarget(self, action: "refreshView:", forControlEvents: .ValueChanged)
        }
    }
    
    //MARK: Queries
    func searchForProms(){
        if searchString == nil{
            self.refreshControl?.endRefreshing()
            NSLog("Attempted to search for prom without assigning search string.")
        } else {
            NSLog("Searching for proms with string %@", searchString!)
            let query = PFQuery(className: SKProm.parseClassName())
            query.cachePolicy = kPFCachePolicyCacheThenNetwork //Note: will not work with local datastore
            query.whereKey("schoolName", containsString: searchString!)
            query.limit = maxObjects
            //query.orderByAscending("preciseLocation") //TODO: figure out how to look for closest proms first
            query.findObjectsInBackgroundWithBlock({
                (objects:Array!, error:NSError!) in
                if objects != nil {
                    if objects.count != 0{
                        for object in objects{
                            if let prom = object as? SKProm{
                                if contains(self.proms, prom){
                                    NSLog("Queried for same prom twice")
                                } else {
                                    self.proms.append(prom)
                                }
                            }
                        }
                        NSLog("Succeeded in finding %lu proms with search %@.", objects.count, self.searchString!)
                        self.tableView.reloadData()
                        self.refreshControl?.endRefreshing()
                    } else {
                        NSLog("Did not find any results for prom search %@. %@", self.searchString!)
                    }
                } else {
                    NSLog("Error searching descriptions for string \"%@\". %@", self.searchString!, error.description)
                }
            })
        }
        self.refreshControl?.endRefreshing()
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
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if (proms.count > 0) {
            tableView.separatorStyle = .SingleLine
            return 1;
        } else {
            //Adapted from Obj-C AppCoda tutorial
            //TODO: Display a message when the table is empty
            /*let messageLabel = UILabel(frame: CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height))
            
            messageLabel.text = "Pull down to refresh, or try a new search."
            messageLabel.textColor = UIColor.blackColor()
            messageLabel.numberOfLines = 0
            messageLabel.textAlignment = .Center
            messageLabel.font = UIFont(name: "Palatino-Italic", size: 20)
            messageLabel.sizeToFit();
            
            self.tableView.backgroundView = messageLabel;
            self.tableView.separatorStyle = .None;*/
        }
        return 0
    }
    
    //MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.row < proms.count){
            performSegueWithIdentifier(PromFromListSegueID, sender: self)
        }else{
            NSLog("Attempted to edit index out of bounds in prom query controller.")
        }
    }
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == PromFromListSegueID){
            if let promInfo = segue.destinationViewController as? PromInfoController {
                if let indx = tableView.indexPathForSelectedRow(){
                    if(indx.row < proms.count){
                        tableView.deselectRowAtIndexPath(indx, animated: true)
                        promInfo.promObject = proms[indx.row]
                    }
                }
            }
        } else if segue.identifier == NewPromSegueID {
            if let promEdit = segue.destinationViewController as? PromEditor {
                promEdit.title = "Create Prom"
            }
        }
    }
    
    @IBAction func unwindFromNewProm(segue:UIStoryboardSegue){
        NSLog("Finished unwinding from new prom.")
    }
    
    
}