//
//  ProfileViewController.swift
//  PromApp
//
//  Created by Scott Krulcik on 9/27/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit

let profileCellHeight:Double = 180.0
let dressCellHeight:Double = 80.0
let defaultName:String = "FirstName Last"

class ProfileViewController:UIViewController, NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource
{
    

    private var imageData:NSMutableData?
    private var profImage:UIImage?
    private var readableName:String = defaultName
    @IBOutlet weak var listView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // Register cell list
    }
    
    //Profile Management
    
    func updateData()
    {
        //print(PFUser.currentUser())
        if let currentUser:PFUser = PFUser.currentUser(){
            let userData:Dictionary<String, String> = currentUser.objectForKey("profile") as Dictionary<String, String>
            println("USer data is \(userData)")
            let name:String = userData["name"]!
            let urlString:String = userData["pictureURL"]!
            
            // Download the user's facebook profile picture
            self.imageData = NSMutableData()// the data will be loaded in here
            let pictureURL:NSURL = NSURL.URLWithString(urlString)
            
            let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: pictureURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 2.0)
            // Run network request asynchronously
            let urlConnection:NSURLConnection = NSURLConnection(request: urlRequest, delegate: self)
            self.updateNameField(name);
        } else {
            self.clearData();
        }
    }
    func updateNameField(name:String)
    {
        self.readableName = name
        self.listView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    func updateDresses()
    {
        if let user = PFUser.currentUser(){
            if let dressList = user.objectForKey("dressIDs") as? Array<SKDress>
            {
                var iPathList = [NSIndexPath]()
                for i in 1...dressList.count {
                    iPathList.append(NSIndexPath(forRow: i-1, inSection: 1))
                }
                self.listView.reloadRowsAtIndexPaths(iPathList, withRowAnimation: UITableViewRowAnimation.Automatic)
                println("Printed the following rows: \(iPathList)")
            }
        }
    }
    func clearData()
    {
        self.updateNameField("")
        self.clearImage()
    }
    func clearImage()
    {
        self.updateProfImage(UIImage(named:"FBBlankProfilePhoto"))
    }
    func updateProfImage(image:UIImage)
    {
        self.profImage = image
        self.listView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 0, inSection: 0)], withRowAnimation: UITableViewRowAnimation.Automatic)
    }
    
    //User Interface Manipulation
    func showLoginScreen()
    {
        self.parentViewController?.performSegueWithIdentifier("showLogin", sender: self)
        
    }
    @IBAction func logoutUser()
    {
        PFUser.logOut()
        self.showLoginScreen()
    }
    
    //UIViewController
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.updateData()
        (self.listView as UITableView).registerNib(UINib(nibName: "ProfileCellLayout", bundle: nil), forCellReuseIdentifier: "ProfileCell")
        (self.listView as UITableView).registerNib(UINib(nibName: "DressCell", bundle: nil), forCellReuseIdentifier: "DressCell")
    }
    
    override func viewDidAppear(animated: Bool) {
        if(PFUser.currentUser() == nil){
            self.showLoginScreen()
        }
    }
    
    //NSURLConnectionDataDelegate
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.imageData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let image:UIImage = UIImage(data: self.imageData!)
        self.updateProfImage(image)
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
            return nil//"My Proms"
        } else {
            return nil
        }
    }
    //UITableViewDelegate
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1;
        } else {
            let currentUser:PFUser = PFUser.currentUser()
            let keystring:String = "dressIDs"
            if let dressIDs:[AnyObject] = currentUser.objectForKey(keystring) as? [AnyObject]{
                return dressIDs.count //Number of dresses + profile slot
            } else {
                return 0;
            }
        }
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
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if(indexPath.section == 0){
            //Profile Cell
            //variable type is inferred
            var cell = tableView.dequeueReusableCellWithIdentifier("ProfileCell") as? ProfileCell
            if (cell == nil) {
                cell = ProfileCell()
            }
            //we know that cell is not empty now so we use ! to force unwrapping
            cell!.profPic.layer.cornerRadius = cell!.profPic.frame.size.width / 2;
            cell!.profPic.clipsToBounds = true;
            if self.profImage != nil {
                cell!.profPic.image = self.profImage
            }
            cell!.nameLabel.text = self.readableName
            return cell!
        }else{
            //Dress Cell
            //variable type is inferred
            var cell = tableView.dequeueReusableCellWithIdentifier("DressCell") as? SKDressInfoTableViewCell
            if (cell == nil) {
                cell = SKDressInfoTableViewCell()
            }
            if let user = PFUser.currentUser(){
                println("found user")
                if let dressList = user.objectForKey("dressIDs") as? Array<String>
                {
                    println("Found dressIDs")
                    //we know that cell is not empty now so we use ! to force unwrapping
                    let dressIndex = (indexPath.row)
                    if(dressIndex < dressList.count){
                        let idString = dressList[dressIndex]
                        let currentDress:SKDress = PFQuery.getObjectOfClass(SKDress.parseClassName(), objectId: idString) as SKDress
                        cell!.designerLabel.text! = currentDress.designer
                        cell!.styleNumberLabel.text! = currentDress.styleNumber
                        let dressImageView = cell?.dressPicView
                        let dressPicFile:PFFile = currentDress.image
                        dressPicFile.getDataInBackgroundWithBlock({
                            (imageData:NSData!, error:NSError!) in
                            if(imageData != nil){
                                println("Should update Pic")
                                let dressImage:UIImage = UIImage(data: imageData!)
                                dressImageView!.image = dressImage
                            }
                        })
                    }
                }
            }
            return cell!
        }
    }
}
