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
    private var profImage:UIImage?
    
    @IBOutlet weak var listView: UITableView!
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
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
            var profCell =  cells[0] as! ProfileCell
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
                    NSLog("Error fetching user info: %@", error)
                } else {
                    if let profile: NSDictionary = user!.objectForKey("profile") as? NSDictionary{
                        //Get FB ID so we can create url for picture
                        if let idstring:String = profile.objectForKey("id") as? String{
                            profile.setValue("https://graph.facebook.com/\(idstring)/picture?type=large", forKey: picURLKey as String)
                        }
                        
                        // Load profile name if it is there, otherwise load
                        var profileName = profile[nameKey] as? String
                        self.profName = profileName != nil ? profileName!:defaultName
                        
                        // Update Profile Picture
                        if let urlString = profile[picURLKey] as? String {
                            self.updateProfPictureWithURL(urlString)
                        }
                        self.updateListView()
                    } else {
                        NSLog("Error: could not load profile for user %@", user)
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
        listView.registerNib(UINib(nibName: objectCellNibName, bundle:nil), forCellReuseIdentifier: objectCellID)
        if let user:PFUser = PFUser.currentUser(){
                updateUserData(user)
        } else {
            NSLog("User not logged in. Showing Login Screen.")
            self.clearData()
            self.showLoginScreen()
        }
        self.listView.backgroundColor = SKColor.TableBackground()
    }
    override func viewWillAppear(animated: Bool) {
        updateListView()
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
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == PROM_SECTION {
            if let user = PFUser.currentUser(){
                return user.proms.count > 0 ? headerHeight:0
            }
        } else if section == DRESS_SECTION {
            if let user = PFUser.currentUser(){
                return user.dresses.count > 0 ? headerHeight:0
            }
        }
        return 0
    }
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(section == max(PROM_SECTION, DRESS_SECTION, PROF_SECTION)){
            //Max allows us to change order without changing this method
            return 10; //Buffer before logout button
        } else {
            return 0;
        }
    }
    func tableView(tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        //TODO: Potentially replace floating button with UIView Subclass
        return UIView() //Override default grey color for better look
    }
    func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section != PROF_SECTION {
            var nibViews = NSBundle.mainBundle().loadNibNamed("TableHeader", owner: self, options: nil)
            if let head = nibViews[0] as? TableHeader{
                head.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: headerHeight)
                head.loadColors()
                let label = head.textLabel
                if section == PROM_SECTION {
                    label.text = "Proms:"
                } else if section == DRESS_SECTION {
                    label.text = "Dresses:"
                }
                head.addSubview(label)
                return head
            }
        }
        return nil
    }
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 0){
            //Is profile cell
            return nil //Do not allow selection
        } else{
            return indexPath
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if(indexPath.section == PROF_SECTION && indexPath.row == 0){
            //Is the profile cell
        } else if (indexPath.section == DRESS_SECTION){
            //Is a dress cell
            if let user:PFUser = PFUser.currentUser(){
                if let dresses:Array<SKDress> = user.objectForKey("dresses") as? Array<SKDress>{
                    if(indexPath.row < dresses.count){
                        performSegueWithIdentifier(EditDressSegue, sender: self)
                    } else {
                        NSLog("Tried to edit non-existant dress.")
                    }
                }
            }
        } else if (indexPath.section == PROM_SECTION){
            //Is a prom cell
            if PFUser.currentUser() != nil{
                let proms = PFUser.currentUser().proms
                if(indexPath.row < proms.count){
                    performSegueWithIdentifier(PromFromProfileID, sender: self)
                } else {
                    NSLog("Tried to edit non-existant Prom.")
                }

            }
        }
        listView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if indexPath.section == DRESS_SECTION {
            return true
        } else if indexPath.section == PROM_SECTION {
            // First get proper prom object
            if let user:PFUser = PFUser.currentUser(){
                let proms:Array<SKProm> = user.proms
                if(indexPath.row < proms.count){
                    // Get prom associated with row
                    let prom = proms[indexPath.row]
                    prom.fetchIfNeeded()
                    if let acl = prom.ACL {
                        if acl.getWriteAccessForUser(PFUser.currentUser()) {
                            // User created prom, may edit
                            return true
                        }
                    }
                }
            }
        }
        return false
    }
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if (editingStyle == .Delete){
            if (indexPath.section == DRESS_SECTION){
                //Is a dress cell
                if let user:PFUser = PFUser.currentUser(){
                    let dresses:Array<SKDress> = user.dresses
                    if(indexPath.row < dresses.count){
                        let dress = dresses[indexPath.row]
                        user.removeObject(dress, forKey: "dresses")
                        user.saveInBackgroundWithBlock(nil)
                        dress.deleteInBackgroundWithBlock({
                            (success:Bool, error:NSError!) in
                            if(error != nil){
                                NSLog("Failed to delete dress for user %@.", user.objectId)
                            } else {
                                NSLog("Successfully deleted dress for user %@.", user.objectId)
                            }
                            tableView.reloadData()
                        })
                    } else {
                        NSLog("Tried to delete dress at non-existant index.")
                    }
                }
            } else if (indexPath.section == PROM_SECTION){
                //Is a dress cell
                if let user:PFUser = PFUser.currentUser(){
                    let proms:Array<SKProm> = user.proms
                    if(indexPath.row < proms.count){
                        // Get prom associated with row
                        let prom = proms[indexPath.row]
                        // Warn the user their deletions are permanent
                        let askUser = UIAlertController(title: "Are you sure?",
                            message: "Once a prom is deleted, all of its data will be lost forever.",
                            preferredStyle: .Alert)
                        let cancel = UIAlertAction(title: "Cancel",
                            style: .Cancel,
                            handler: nil)
                        let confirm = UIAlertAction(title: "Confirm", style: .Default, handler:{
                            (action:UIAlertAction!) in
                            // Remove from local User's reference
                            user.removeObject(prom, forKey: "proms")
                            user.saveInBackgroundWithBlock(nil)
                            // Note: Will be removed from user and dress references
                            //          in a cloud code operation upon delete
                            prom.deleteInBackgroundWithBlock({
                                (success:Bool, error:NSError!) in
                                if(error != nil){
                                    NSLog("Failed to delete prom for user %@.", user.objectId)
                                } else {
                                    NSLog("Successfully deleted prom for user %@.", user.objectId)
                                }
                                tableView.reloadData()
                            })
                        })
                        askUser.addAction(cancel)
                        askUser.addAction(confirm)
                        presentViewController(askUser, animated: true, completion: nil)
                    } else {
                        NSLog("Tried to delete prom at non-existant index.")
                    }
                }
            }
        }
    }
    
    //MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 3 //one for profile, one for dresses, one for proms
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == PROF_SECTION){
            return 1
        } else if (section == DRESS_SECTION){
            return PFUser.currentUser() != nil ? PFUser.currentUser().dresses.count:0
        } else if (section == PROM_SECTION){
            return PFUser.currentUser() != nil ? PFUser.currentUser().proms.count:0
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch indexPath.section {
            case PROF_SECTION:
                if let cell = listView.dequeueReusableCellWithIdentifier(profCellID) as? ProfileCell {
                    // Crop image to a circle for styling
                    cell.profPic.layer.cornerRadius = cell.profPic.frame.size.width / 2;
                    cell.profPic.clipsToBounds = true;
                    if profImage != nil {
                        cell.profPic.image = profImage
                    }
                    
                    // Display name
                    cell.nameLabel.text = profName
                    // Display data information
                    if let user = PFUser.currentUser() {
                        cell.setInfoLabel(user.proms.count, dressCount: user.dresses.count)
                    }
                    return cell
            }
            case DRESS_SECTION:
                if let cell = listView.dequeueReusableCellWithIdentifier(dressCellID) as? SKDressInfoTableViewCell{
                    if let user:PFUser = PFUser.currentUser(){
                        let dresses = PFUser.currentUser().dresses
                        if indexPath.row < dresses.count{
                            //Ensure valid array access
                            let dressPointer:SKDress = dresses[indexPath.row]
                            self.fillDressCell(cell, withDress: dressPointer)
                        }
                    }
                    return cell
                    
            }
            case PROM_SECTION:
                if let cell = listView.dequeueReusableCellWithIdentifier(objectCellID) as? ObjectCell{
                    if PFUser.currentUser() != nil{
                        let proms = PFUser.currentUser().proms
                        if indexPath.row < proms.count {
                            //Ensure valid array access
                            fillPromCell(cell, withProm: proms[indexPath.row])
                        }
                    }
                    return cell
            }
            default:
                return UITableViewCell()
        }
        return UITableViewCell() //Default case won't work because of lack of implicit fallthrough
    }
    
    //External methods to fill cells with Parse data asynchronously to preserve flow with poor connection
    func fillDressCell(cell:SKDressInfoTableViewCell, withDress dressPointer:SKDress){
        dressPointer.fetchIfNeededInBackgroundWithBlock({
            (dressObj:PFObject!, error:NSError!) in
            if let dress = dressObj as? SKDress {
                cell.designerLabel?.text = dress.designer
                cell.styleNumberLabel?.text = dress.styleNumber
                // Fill in dress picture over time
                let dressImageView = cell.dressPicView
                if let dressPicFile = dress.objectForKey("imageThumbnail") as? PFFile{
                    dressPicFile.getDataInBackgroundWithBlock({
                        (imageData:NSData!, error:NSError!) in
                        if(imageData != nil){
                            let dressImage:UIImage = UIImage(data: imageData!)!
                            dressImageView!.image = dressImage
                        } else{
                            NSLog("Error retrieving image data from dress. PFFile:%@ Error:%@", dressPicFile, error)
                        }
                    })
                }
            }
        })
    }
    func fillPromCell(cell:ObjectCell, withProm promPointer:SKProm){
        promPointer.fetchIfNeededInBackgroundWithBlock({
            (promObj:PFObject!, error:NSError!) in
            if let prom = promObj as? SKProm {
                cell.bigLabel.text = prom.schoolName
                cell.littleLabel.text = prom.locationDescription
                // Fill in dress picture over time
                let promImageView = cell.picView
                if let promPicFile = prom.objectForKey("image") as? PFFile{
                    promPicFile.getDataInBackgroundWithBlock({
                        (imageData:NSData!, error:NSError!) in
                        if(imageData != nil){
                            let promImage = UIImage(data: imageData!)!
                            promImageView!.image = promImage
                        } else{
                            NSLog("Error retrieving image data from dress. PFFile:%@ Error:%@", promPicFile, error)
                        }
                    })
                } else {
                    //Prom does not have image saved
                    promImageView.backgroundColor = SKColor.ImageBackground()
                    promImageView.image = UIImage(named: "BigP") //Logo overlay
                }
            }
        })
    }
    
    
    //MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if(segue.identifier == EditDressSegue){
            if let dressController = (segue.destinationViewController as? UINavigationController)?.childViewControllers[0] as? SKAddDressViewController {
                if let indx = listView.indexPathForSelectedRow(){
                    if PFUser.currentUser() != nil{
                        let dressList = PFUser.currentUser().dresses
                        if(indx.row < dressList.count){
                            self.listView.deselectRowAtIndexPath(indx, animated: true)
                            let dress = dressList[indx.row]
                            dress.fetchIfNeeded()
                            dressController.setupWithDress(dress)
                        }
                    }
                }
            }
        } else if(segue.identifier == PromFromProfileID){
            if let promInfo = segue.destinationViewController as? PromInfoController {
                if let indx = listView.indexPathForSelectedRow(){
                    if(PFUser.currentUser() != nil &&
                        indx.row < PFUser.currentUser().proms.count){
                        let prom = PFUser.currentUser().proms[indx.row]
                        prom.fetchIfNeeded()
                        promInfo.promObject = prom
                    }
                }
            }
        }
    }
    
    @IBAction func unwindFromSaveDress(segue: UIStoryboardSegue) {
        updateUserData(PFUser.currentUser())
    }
    
    @IBAction func unwindToProfileCancel(segue: UIStoryboardSegue){
    }
    
}


