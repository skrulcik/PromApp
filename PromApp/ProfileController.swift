//
//  ProfileController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/16/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import UIKit

//Constants
let profileCellHeight:Double = 180.0
let dressCellHeight:Double = 80.0
let dressCellNibName = "DressCell"
let dressCellID = "DressCell"
let profCellNibName = "ProfileCellLayout"
let profCellID = "ProfileCell"

let defaultName:String = "FirstName Last"
let dressKey:String = "dressIDs"
let nameKey:NSString = NSString(string: "name")
let userDataKey:String = "profile"
let picURLKey:NSString = NSString(string:"pictureURL")
let fbIDKey:String = "id"

let EditDressSegue = "EditDress"


class ProfileController:UIViewController, NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource
{
    private var imageData:NSMutableData?
    private var profName:String = defaultName
    private var profImage:UIImage?
    
    @IBOutlet weak var listView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.listView.registerNib(UINib(nibName: profCellNibName, bundle: nil), forCellReuseIdentifier: profCellID)
        self.listView.registerNib(UINib(nibName: dressCellNibName, bundle: nil), forCellReuseIdentifier: dressCellID)
    }
    
    
    /****************************
    * Updating and Loading Data *
    *****************************/
    
    /* Given a URL, retrieve the profile picture */
    func updateProfPictureWithURL(urlString:String){
        // Download the user's facebook profile picture
        imageData = NSMutableData()// the data will be loaded in here
        let pictureURL:NSURL = NSURL(string: urlString)!
        let urlRequest:NSMutableURLRequest = NSMutableURLRequest(URL: pictureURL, cachePolicy: NSURLRequestCachePolicy.UseProtocolCachePolicy, timeoutInterval: 2.0)
        // Run network request asynchronously
        let urlConnection:NSURLConnection = NSURLConnection(request: urlRequest, delegate: self)!
    }
    
    func setProfImage(image:UIImage)
    {
        profImage = image
        var cells = self.listView.visibleCells()
        if cells.count > 0{
            var profCell =  cells[0] as ProfileCell
            profCell.profPic.image = self.profImage
        }
    }
    
    /* Update cells to display new data*/
    func updateListView(){
        self.listView.reloadData()
    }
    
    /* When view loads:
    * - Start updating profile picture
    * - Load dresses into table
    */
    override func viewDidLoad() {
        let user = PFUser.currentUser()
        if let profile: AnyObject = user.objectForKey("profile"){
            //Get FB ID so we can create url for picture
            if let idstring:String = profile.objectForKey(fbIDKey) as? String{
                profile.setValue("https://graph.facebook.com/\(idstring)/picture?type=small", forKey: picURLKey)
            }
            
            // Load profile name if it is there, otherwise load
            var profileName:NSString? = profile[nameKey] as? NSString
            profName = profileName != nil ? profileName!:defaultName
            
            // Update Profile Picture
            if let urlString:String = profile[picURLKey] as? NSString{
                updateProfPictureWithURL(urlString)
            }
            
            // Load Profile and Dress Information to table
            updateListView()
        } else {
            println("Error: could not load profile for user \(user)")
        }
    }
    
    /***************************************
    * Clearing Old Data & Logging in Users *
    ****************************************/
    func clearProfImage()
    {
        self.setProfImage(UIImage(named:"FBBlankProfilePhoto")!)
    }
    func clearData()
    {
        profName = defaultName
        clearProfImage()
    }
    func showLoginScreen()
    {
        self.parentViewController?.performSegueWithIdentifier("showLogin", sender: self)
    }
    @IBAction func logoutUser()
    {
        PFUser.logOut()
        assert(PFUser.currentUser() == nil)
        updateListView() //Clear dresses from view
    }
    
    /******************************
    * NSURLConnectionDataDelegate *
    *******************************/
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.imageData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let image:UIImage = UIImage(data: self.imageData!)!
        self.setProfImage(image)
    }
    
    /**********************
    * UITableViewDelagate *
    ***********************/
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            return CGFloat(profileCellHeight)
        }else{
            return CGFloat(dressCellHeight)
        }
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
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 0){
            //Is profile cell
            return nil //Do not allow selection
        } else{
            return indexPath
        }
    }
    
    /************************
    * UITableViewDataSource *
    *************************/
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2 //one for profile, one for dresses
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0){
            return 1
        } else if (section == 1){
            var dressCount:Int? = (PFUser.currentUser()?.objectForKey("dresses") as? NSMutableArray)?.count
            return dressCount != nil ? dressCount!:0
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
    
    
    /*************
    * Navigation *
    **************/
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == EditDressSegue){
            if let dressController = (segue.destinationViewController as? UINavigationController)?.childViewControllers[0] as? SKAddDressViewController {
                if let indx = listView.indexPathForSelectedRow(){
                    if let dressList = PFUser.currentUser().objectForKey("dresses") as? NSMutableArray{
                        if(indx.row < dressList.count){
                            self.listView.deselectRowAtIndexPath(indx, animated: true)
                            if let dress = dressList[indx.row] as? SKDress{
                                dressController.setupWithDress(dress)
                            } else {
                                println("Could not retrieve dress information from server")
                            }
                        }
                    }
                }
            }
        }
    }
    
    func unwindFromSaveDress(segue: UIStoryboardSegue) {
        self.listView.reloadData()
        println("reload data")
    }
    
}


