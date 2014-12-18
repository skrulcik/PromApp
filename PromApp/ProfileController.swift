//
//  ProfileController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/16/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import UIKit


class ProfileController:UIViewController, NSURLConnectionDataDelegate, UITableViewDelegate, UITableViewDataSource
{
    // These will be be static constants once supported
    private let PROF_SECTION = 0
    private let DRESS_SECTION = 1
    private let PROM_SECTION = 2
    
    private var imageData:NSMutableData?
    private var profName:String = defaultName
    private var promCount:Int? = 0
    private var dressCount:Int? = 0
    private var profImage:UIImage?
    
    @IBOutlet weak var listView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        println("Initialized")
    }
    
    
    //MARK:Updating and Loading Data
    
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
    
    func updateUserData(currentUser:PFUser?){
        if (currentUser != nil) {
            currentUser!.fetchIfNeededInBackgroundWithBlock({
                (user:PFObject!, error:NSError!) in
                if (error != nil){
                    println("Error fetching user info: \(error)")
                } else {
                    if let profile: NSDictionary = user!.objectForKey("profile") as? NSDictionary{
                        //Get FB ID so we can create url for picture
                        if let idstring:String = profile.objectForKey("id") as? String{
                            profile.setValue("https://graph.facebook.com/\(idstring)/picture?type=large", forKey: picURLKey)
                        }
                        
                        // Load profile name if it is there, otherwise load
                        var profileName:NSString? = profile[nameKey] as? NSString
                        self.profName = profileName != nil ? profileName!:defaultName
                        
                        // Update Dress and Prom Information
                        if let promList = user.objectForKey(promKey) as? NSArray {
                            self.promCount = promList.count
                        }
                        if let dressList = user.objectForKey(dressKey) as? NSArray {
                            self.dressCount = dressList.count
                        }
                        
                        // Update Profile Picture
                        if let urlString:String = profile[picURLKey] as? NSString{
                            self.updateProfPictureWithURL(urlString)
                        }
                    } else {
                        println("Error: could not load profile for user \(user)")
                    }
                }
            })
        }
    }

    /* When view loads:
    * - Start updating profile picture
    * - Load dresses into table
    */
    override func viewDidLoad() {
        listView.registerNib(UINib(nibName: profCellNibName, bundle: nil), forCellReuseIdentifier: profCellID)
        listView.registerNib(UINib(nibName: dressCellNibName, bundle: nil), forCellReuseIdentifier: dressCellID)
        if let user:PFUser = PFUser.currentUser(){
                updateUserData(user)
                // Load Profile and Dress Information to table
                updateListView()
        } else {
            println("User not logged in. Showing Login Screen.")
            self.clearData()
            self.showLoginScreen()
        }
    }
    
    //MARK: Clearing Old Data & Logging in Users
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
        showLoginScreen()
    }
    
    //MARK: NSURLConnectionDataDelegate
    func connection(connection: NSURLConnection, didReceiveData data: NSData) {
        self.imageData?.appendData(data)
    }
    
    func connectionDidFinishLoading(connection: NSURLConnection) {
        let image:UIImage = UIImage(data: self.imageData!)!
        self.setProfImage(image)
    }
    
    //MARK: UITableViewDelagate
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
    
    //MARK: UITableViewDataSource
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
        switch indexPath.section {
            case PROF_SECTION:
                if let cell:ProfileCell = listView.dequeueReusableCellWithIdentifier(profCellID, forIndexPath: indexPath) as? ProfileCell {
                    // Crop image to a circle for styling
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width / 2;
                    cell.profPic.clipsToBounds = true;
                    if profImage != nil {
                        cell.profPic.image = profImage
                    }
                    
                    // Display name
                    cell.nameLabel.text = profName
                    // Display data information
                    cell.setInfoLabel(promCount!, dressCount: dressCount!)
                    return cell
            }
            case DRESS_SECTION:
                if let cell:SKDressInfoTableViewCell = listView.dequeueReusableCellWithIdentifier(dressCellID, forIndexPath: indexPath) as? SKDressInfoTableViewCell{
                    return cell
                    
            }
            default:
                return UITableViewCell()
        }
        return UITableViewCell() //Default case won't work because of lack of implicit fallthrough
    }
    
    
    //MARK: Navigation
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
    
    @IBAction func unwindFromSaveDress(segue: UIStoryboardSegue) {
        listView.reloadData()
    }
    
}


