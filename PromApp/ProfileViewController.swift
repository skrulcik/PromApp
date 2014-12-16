//
//  ProfileViewController.swift
//  PromApp
//
//  Created by Scott Krulcik on 9/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit

// Constants
let profileCellHeight:Double = 180.0
let dressCellHeight:Double = 80.0
let dressCellID = "DressCell"
let profCellID = "ProfileCell"

let defaultName:String = "FirstName Last"
let dressKey:String = "dressIDs"
let nameKey:NSString = NSString(string: "name")
let userDataKey:String = "profile"
let picURLKey:NSString = NSString(string:"pictureURL")
let fbIDKey:String = "id"

let EditDressSegue = "EditDress"

class ProfileViewController:UIViewController, NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource
{
    //Store all information needed for table locally
    //This is to minimize calls to parse for new information
    private var currentUser:PFUser?
    private var dressList:NSMutableArray?//Array<String>?
    private var imageData:NSMutableData?
    private var profName:String = defaultName
    private var profImage:UIImage?          // profImage is special, it does not point to the
    
    @IBOutlet weak var listView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Register cell list
    }
    
    //Profile Management
    func updateData()
    // Fills local data with new information
    // Does NOT update table
    {
        self.currentUser = PFUser.currentUser()
        if self.currentUser != nil{
            updateFBProfile(currentUser!, {
                (result:NSDictionary?) in
                if let userData = result
                {
                    if let idstring:String = userData.objectForKey(fbIDKey) as? String{
                        userData.setValue("https://graph.facebook.com/\(idstring)/picture?type=large", forKey: picURLKey)
                    }
                    self.currentUser!.setObject(userData, forKey: "profile")
                    self.updateDresses()
                    if let name = userData[nameKey] as? NSString{
                        self.profName = name as String
                    }
                    if let urlString:String = userData[picURLKey] as? NSString{
                        self.updateProfPicRemote(urlString)
                    }
                    self.currentUser!.saveInBackground()
                }
                self.listView.reloadData()
            })
        } else {
            self.clearData()
            self.showLoginScreen()
        }
    }
    func updateFBProfile(user:PFUser, completion: (result: NSDictionary) -> Void){
        let request:FBRequest = FBRequest.requestForMe()
        request.startWithCompletionHandler({
            (connection:FBRequestConnection!, result:AnyObject!, error:NSError!) in
            if let userData = result as? NSDictionary{
                user.setObject(userData, forKey:"profile")
                completion(result: userData)
            }else{
                completion(result: user.objectForKey("profile") as NSDictionary)
            }
        })
    }
    func updateDresses()
    {
        if currentUser != nil && dressList == nil{
            self.dressList = currentUser!.objectForKey(dressKey) as? NSMutableArray
        }
    }
    func updateProfPicRemote(urlString:String)
    {
        // Download the user's facebook profile picture
        self.imageData = NSMutableData()// the data will be loaded in here
        let pictureURL:NSURL = NSURL(string: urlString)!
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: pictureURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 2.0)
        // Run network request asynchronously
        let urlConnection:NSURLConnection = NSURLConnection(request: urlRequest, delegate: self)!
    }
    func clearData()
    {
        self.currentUser = nil
        self.dressList = nil
        self.profName = defaultName
        self.clearProfImage()
    }
    func clearDresses()
    {
        self.dressList = nil
    }
    func clearProfImage()
    {
        self.setProfImage(UIImage(named:"FBBlankProfilePhoto")!)
    }
    
    func forceTableReload()
    {
        listView.reloadData()
    }
    
    func setProfImage(image:UIImage)
    {
        self.profImage = image
        var cells = self.listView.visibleCells()
        if cells.count > 0{
            var profCell =  cells[0] as ProfileCell
            profCell.profPic.image = self.profImage
        }
    }
    
    //User Interface Manipulation
    func showLoginScreen()
    {
        self.parentViewController?.performSegueWithIdentifier("showLogin", sender: self)
    }
    @IBAction func logoutUser()
    {
        PFUser.logOut()
        assert(PFUser.currentUser() == nil)
        self.updateData()
        self.forceTableReload()
    }
    
    //UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.listView as UITableView).registerNib(UINib(nibName: "ProfileCellLayout", bundle: nil), forCellReuseIdentifier: profCellID)
        (self.listView as UITableView).registerNib(UINib(nibName: "DressCell", bundle: nil), forCellReuseIdentifier: "DressCell")
        self.updateData()
    }
    
    /*override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() == nil){
            self.showLoginScreen()
        }
    }*/
    
    //NSURLConnectionDataDelegate
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.imageData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let image:UIImage = UIImage(data: self.imageData!)!
        self.setProfImage(image)
    }
    
    //UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 //one for profile, one for dresses
    }
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if(section == 0){
            //Profile
            return nil
        } else if (section == 1){
            //Dresses
            return nil//"My Dresses"
        } else if (section == 2){
            //Proms
            return nil;//"My Proms"
        } else {
            return nil;
        }
    }
    //UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.updateData()
        if (section == 0){
            return 1
        } else {
            if currentUser != nil{
                //Only look for dresses if someone is logged in
                println("Here is info: current \(currentUser) dresslist: \(dressList) count: \(dressList)")
                if dressList != nil {
                    return dressList!.count //Number of dresses + profile slot
                }else{
                    //Try to fill dressList once
                    updateDresses()
                    if(dressList != nil){
                        return dressList!.count
                    }
                }
            } else {
                println("Error finding user")
            }
        }
        return 0
    }
    
    func tableView(tableView: UITableView,
        heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            return CGFloat(profileCellHeight)
        }else{
            return CGFloat(dressCellHeight)
        }
    }
    
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 0){
            //Is profile cell
            return nil //Do not allow selection
        } else{
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        println("Looking for cell at \(indexPath)")
        if(indexPath.section == 0 && indexPath.row == 0){
            //Profile Cell
            var cell = tableView.dequeueReusableCellWithIdentifier(profCellID) as? ProfileCell
            if (cell == nil) {
                //cell = ProfileCell()!
                cell = ProfileCell(style: .Default, reuseIdentifier: "ProfileCell")
                //cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: "ProfileCell") as? ProfileCell
            }
            //we know that cell is not empty now so we use ! to force unwrapping
            cell!.profPic.layer.cornerRadius = cell!.profPic.frame.size.width / 2;
            cell!.profPic.clipsToBounds = true;
            if self.profImage != nil {
                cell!.profPic.image = self.profImage
            }
            cell!.nameLabel.text = self.profName
            return cell!
        }else if (indexPath.section == 1 && indexPath.row < dressList?.count){
            //Dress Cell
            //variable type is inferred
            var cell = tableView.dequeueReusableCellWithIdentifier(dressCellID) as? SKDressInfoTableViewCell
            if (cell == nil) {
                //cell = SKDressInfoTableViewCell()!
                cell = SKDressInfoTableViewCell(style: .Default, reuseIdentifier: "DressCell")
                //cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: dressCellID) as? SKDressInfoTableViewCell
            }
            if currentUser != nil {//PFUser.currentUser(){
                if dressList != nil {
                    //we know that cell is not empty now so we use ! to force unwrapping
                    let dressIndex = (indexPath.row)
                    if(dressIndex < dressList!.count){ //Ensure valid access
                        let idString = dressList![dressIndex] as String
                        let currentDress:SKDress = PFQuery.getObjectOfClass(SKDress.parseClassName(), objectId: idString) as SKDress
                        println("Current Dress \(currentDress)")
                        cell!.designerLabel.text! = currentDress.designer
                        cell!.styleNumberLabel.text! = currentDress.styleNumber
                        let dressImageView = cell?.dressPicView
                        let dressPicFile:PFFile = currentDress.image
                        dressPicFile.getDataInBackgroundWithBlock({
                            (imageData:NSData!, error:NSError!) in
                            if(imageData != nil){
                                println("Should update Pic")
                                let dressImage:UIImage = UIImage(data: imageData!)!
                                dressImageView!.image = dressImage
                            }
                        })
                    }
                }
            }
            return cell!
        }
        return UITableViewCell(style: .Default, reuseIdentifier: "Cell")
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == 0 && indexPath.row == 0){
            //Is the profile cell
            println("Would have edited user cell")
        } else if (indexPath.section == 1){
            //Is the profile cell
            if(dressList != nil && indexPath.row < dressList!.count){
                performSegueWithIdentifier(EditDressSegue, sender: self)
            } else {
                println("Tried to edit non-existant dress")
            }
        }
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if(indexPath.section == 1){
            return true
        }
        return false
    }
    
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if(editingStyle == .Delete){
            print("Delete row \(indexPath)")
            //First delete dressID from user dress list
            if let user:PFUser = PFUser.currentUser(){
                let dressIndex = (indexPath.row)
                if(dressList != nil && dressIndex < dressList!.count){
                    if let idString = dressList![dressIndex] as? String{
                        user.removeObjectsInArray([idString], forKey: dressKey)     //Remove dress from user list
                        user.saveInBackground()                                     //Save changes to user list
                        dressList?.removeObject(idString)                           //Update local list as well
                        let currentDress:SKDress = PFQuery.getObjectOfClass(SKDress.parseClassName(), objectId: idString) as SKDress
                        if(currentDress.objectForKey("prom") != nil){
                            currentDress.prom!.removeObjectsInArray([currentDress], forKey: "dresses");
                        }
                        currentDress.deleteInBackground()                           //Delete the dress from the server
                        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)//Remove the cell
                    }
                }
            }
            
        }
    }
    
    //Navigation------------------------------------------
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == EditDressSegue){
            if let destViewController = segue.destinationViewController as? UINavigationController{
                if let dressController = destViewController.childViewControllers[0] as? SKAddDressViewController{
                    if let indx = listView.indexPathForSelectedRow(){
                        if(dressList != nil && indx.row < dressList!.count){
                            self.listView.deselectRowAtIndexPath(indx, animated: true)
                            if let dressString = dressList?.objectAtIndex(indx.row) as? String {
                                let q:PFQuery = PFQuery(className: "Dress")
                                if let dress = q.getObjectWithId(dressString) as? SKDress{
                                    dressController.setupWithDress(dress)
                                } else {
                                    println("Could not retrieve dress information from server")
                                }
                            } else {
                                println("Error retrieving dressID object from list.")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @IBAction func unwindFromSaveDress(segue: UIStoryboardSegue) {
        self.listView.reloadData()
        println("reload data")
    }
}
