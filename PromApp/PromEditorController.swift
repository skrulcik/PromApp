//
//  PromDetailController.swift
//  PromApp
//
//  Created by Scott Krulcik on 12/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//  Some code adapted from http://stackoverflow.com/questions/18880364/uiimagepickercontroller-breaks-status-bar-appearance
//

import Foundation

class PromEditor:UITableViewController, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    
    @IBOutlet var cancelButton:UIBarButtonItem?
    @IBOutlet var doneButton:UIBarButtonItem?
    var promImageView:UIImageView? {
        get {
            if let cell:SKImageEditorCell = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: 0, inSection: 0)) as? SKImageEditorCell {
                return cell.basicImage
            } else {
                NSLog("Invalid attempt to access image editor cell of the prom editor.")
                return nil
            }
        }
    }
    
    //Model Representations
    private var _isNewProm:Bool
    private var _imageChanged:Bool
    private var promData:Dictionary<String, AnyObject>
    private var prom:SKProm?
    
    //Will be static/class variables in the future
    private var keyForRowIndex:Array<String>
    private var readableNames:Dictionary<String, String>
    
    //MARK: Initialization
    required init?(coder aDecoder: NSCoder) {
        keyForRowIndex = ["image",
                            "schoolName",
                            "address",
                            "locationDescription",
                            "theme",
                            "time"]
        readableNames = ["image":"",
                            "schoolName":"School Name",
                            "address":"School Address",
                            "locationDescription":"Prom Venue",
                            "theme":"Theme",
                            "time":"Time"]
        _isNewProm = true
        _imageChanged = false
        promData = Dictionary()
        prom = SKProm()
        
        super.init(coder: aDecoder)
    }
    
    //MARK: Post Initialization Data Setup
    /* Set up data after initialization, which is handled
    *  by the storyboard
    */
    // Get ready to edit a prom
    func setupWithProm(promObject:SKProm!){
        _isNewProm = false
        prom = promObject
        for key in keyForRowIndex{
            if let val:AnyObject = prom?.objectForKey(key){
                if key == "image" {
                    _imageChanged = true
                }
                promData.updateValue(val, forKey: key)
            }
        }
    }
    
    //MARK: UIView
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.registerNib(UINib(nibName: "StringEntryCell", bundle: nil), forCellReuseIdentifier:"StringEntry")
        tableView.registerNib(UINib(nibName: "ImageEditorCell", bundle: nil), forCellReuseIdentifier:"ImageEditor")
        tableView.backgroundColor = SKColor.GroupedTableBackground()
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        tableView.reloadData()
    }
    
    //MARK: Image Management
    func showImagePickerForSourceType(sourceType:UIImagePickerControllerSourceType)
    {
        if promImageView != nil && promImageView!.isAnimating() {
            promImageView!.stopAnimating()
        }
        let imagePicker:UIImagePickerController = UIImagePickerController()
        imagePicker.modalPresentationStyle = .CurrentContext
        imagePicker.sourceType = sourceType
        imagePicker.delegate = self //Needed to preserve status bar state
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    /* Called when user edits image
    *   - If no camera is available, open photo library
    *   - Otherwise, open an action sheet so the user
    *       can choose between camera and photo library */
    @IBAction func addImage(sender:AnyObject)
    {
        //TODO: Handle users who do not grant photo access
        if !(UIImagePickerController.isSourceTypeAvailable(.Camera)){
            NSLog("User adding prom image via photo library.(Camera Unavailable)")
            showImagePickerForSourceType(.PhotoLibrary)
        } else {
            //Both camera and photo library are available, open dialog to choose
            let chooser = UIAlertController(title: nil,
                                            message: nil,
                                            preferredStyle: .ActionSheet)
            let cancel = UIAlertAction(title:"Cancel", style: .Cancel, handler: nil)
            let picker = UIAlertAction(title: "Choose Existing", style: .Default, handler:{
                (action:UIAlertAction!) in
                NSLog("User adding prom image via photo library.")
                self.showImagePickerForSourceType(.PhotoLibrary)
            })
            let camera = UIAlertAction(title: "Open Camera", style: .Default, handler:{
                (action:UIAlertAction!) in
                NSLog("User adding prom image via camera.")
                self.showImagePickerForSourceType(.Camera)
            })
            chooser.addAction(cancel)
            chooser.addAction(picker)
            chooser.addAction(camera)
            presentViewController(chooser, animated: true, completion: nil)
        }
    }
    /* Ensures status bar color maintains white background
    *   link in header shows the post this solution is
    *   based on. */
    func navigationController(navigationController: UINavigationController, willShowViewController viewController: UIViewController, animated: Bool) {
        UIApplication.sharedApplication().setStatusBarStyle(.LightContent, animated: false)
    }

    //MARK: UIImagePickerControllerDelegate implementation
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image: UIImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            NSLog("Successfully picked image for prom.")
            if promImageView != nil{
                NSLog("Updated image view to show image for prom.")
                _imageChanged = true
                promImageView!.image = image
            }
        } else {
            throwAlert(fromPresenter: self, ofType: .Default, withArg: "Invalid image selection.")
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        NSLog("Image picker was cancelled.")
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
    //MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
     func textFieldDidEndEditing(textField: UITextField) {
        if let keyCell = textField.superview?.superview as? SKStringEntryCell {
            if textField.text != "" {
                promData[keyCell.key] = textField.text
            }
        } else {
            NSLog("Failed to cast textField's superview \(textField.superview?.superview) as String editor cell.")
        }
    }
    //Not part of delegate, but used to make edits stop:
    // TODO: Investigate
//    override func touchesBegan(touches: Set<NSObject>, withEvent event: UIEvent) {
//        self.view.endEditing(true)
//    }

    //MARK: Button Presses
    @IBAction func savePressed(sender:AnyObject){
        NSLog("Save dress pressed.")
        self.view.endEditing(true) //End editing of any text fields
        saveProm(completion: {
            if self._isNewProm {
                self.performSegueWithIdentifier(NewPromUnwindID, sender: self)
            } else {
                self.performSegueWithIdentifier(EditPromUnwindID, sender: self)
            }
        })
    }
    @IBAction func cancelPressed(sender:AnyObject){
        NSLog("Canceling prom editor.")
        if self._isNewProm {
            self.performSegueWithIdentifier(NewPromUnwindID, sender: self)
        } else {
            self.performSegueWithIdentifier(EditPromUnwindID, sender: self)
        }
    }
    
    //MARK: Saving
    /* Stores data from editor in a dictionary temporarily.
    *   If no data is entered for a field, the dictionary 
    *   will get the value from the prom if possible.
    *   If cancelled, we don't need to undo any changes to 
    *   the prom object. If saved, we attempt to use values
    *   from this dictionary to overwrite the dress data. */
    func updateTempData(prom:SKProm){
        for i in 0..<keyForRowIndex.count {
            if "image" == keyForRowIndex[i] && _imageChanged{
                //accessing image cell
                if let cell:SKImageEditorCell = tableView(tableView, cellForRowAtIndexPath: NSIndexPath(forRow: i,inSection: 0)) as? SKImageEditorCell{
                    if let currentPic = cell.basicImage.image {
                        promData.updateValue(currentPic, forKey: keyForRowIndex[i])
                    }
                }
            }
            //TODO: Fill in existing prom data
        }
    }
    
    func dataHasRequiredFields()->Bool{
        if let req_keys:Array<String> = SKProm.requiredKeys() as? Array<String>{
            for req_key in req_keys{
                if promData.indexForKey(req_key) == nil{
                    throwAlert(fromPresenter: self,
                        ofType: .MissingRequiredField,
                        withArg: readableNames[req_key]!)
                    return false
                }
            }
        }
        return true
    }
    
    func saveProm(completion block:(() -> Void)?){
        if prom != nil {
            updateTempData(prom!)
            if dataHasRequiredFields() {
                //Required fields are filled out, so try to save dress
                //First load basic objects from data into
                for (key,value) in promData{
                    NSLog("Parsing \(key)...")
                    if key == "image"{
                        //Image key requires compression and conversion to file
                        NSLog("Compressing image for dress prior to save.")
                        if let originalImage = promImageView?.image {
                            let constrained:UIImage = scale(originalImage, toFitWidth: MAX_IMG_WIDTH, Height: MAX_IMG_HEIGHT)
                            let imageData:NSData = UIImageJPEGRepresentation(constrained, 0.7)!
                            let nospaces = removeAllWhiteSpace(prom!.schoolName)
                            let filename = String(format: "%@Picture.jpg", nospaces)
                            let imageFile = PFFile(name: filename, data: imageData)
                            prom!.image = imageFile
                            NSLog("Saving image file for prom.")
                            //Save image file synchronously, cannot save prom with pointer to unsaved image
                            prom!.image.save()
                        }
                    } else if key != "address"{
                        //Address will be used to generate precise location later, which is asynchronous
                        //All non-image, non-address fields are values that don't require processing
                        NSLog("Setting \(value) for \(key) for prom \(prom!.objectId).")
                        prom!.setObject(value, forKey: key)
                    }
                }
                if let addr = promData["address"] as? String {
                    let gcoder = CLGeocoder()
                    gcoder.geocodeAddressString(addr, completionHandler: {
                        (placeMarks: [CLPlacemark]?, error: NSError?) in
                        if let error = error {
                            //Could not attemp to parse address
                            NSLog("Error parsing address for prom \(self.prom!.objectId). Address:\(addr) Error: \(error.description)")
                            throwAlert(fromPresenter: self, ofType: .FailedSave, withArg: "Could not parse address: \(error)")
                        } else if let placemark:CLPlacemark = placeMarks?.last {
                            NSLog("Resolved address [%@] to location: ", addr, placemark)
                            let promPoint = PFGeoPoint(location: placemark.location)
                            self.prom!.setObject(addr, forKey: "address")
                            self.prom!.setObject(promPoint, forKey: "preciseLocation")
                            if let user = PFUser.currentUser() where self._isNewProm {
                                NSLog("About to register new prom with server.")
                                let acl = PFACL(user: user)
                                acl.setPublicReadAccess(true)
                                self.prom?.ACL = acl
                            }
                            self.prom!.saveInBackgroundWithBlock({
                                (succeeded: Bool, error: NSError?) in
                                if(succeeded){
                                   NSLog("Succeeded in saving prom \(self.prom!.objectId)")
                                    if let user = PFUser.currentUser(){
                                        if !user.isFollowingProm(self.prom!){
                                            user.addObject(self.prom!, forKey: "proms")
                                            user.saveInBackgroundWithBlock(nil)
                                        }
                                    }
                                    if block != nil {
                                        block!()
                                    }
                                } else {
                                    NSLog("Failed to save prom \(self.prom!.objectId)")
                                    throwAlert(fromPresenter: self, ofType: .FailedSave, withArg: "Server error: \(error)")
                                }
                            })
                        } else {
                            //Address parsed, but no results found
                            //If placemarks has no elements, above if let will fail when last property is nil
                            NSLog("No location results for prom \(self.prom!.objectId) with address:\(addr)")
                            throwAlert(fromPresenter: self, ofType: .FailedSave, withArg: "Could not create location from address.")
                        }
                    })
                } else {
                    NSLog("Failed to save prom \(self.prom!.objectId)")
                    throwAlert(fromPresenter: self, ofType: .FailedSave, withArg: "Error converting address.")
                }
            }
        } else {
            NSLog("Attempted to save a 'nil' prom.")
        }
    }
    
    //MARK: UITableViewDataSource
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row > keyForRowIndex.count{
            NSLog("Attempted access of invalid row #%d of prom editor.", indexPath.row)
        } else{
            let key:String = keyForRowIndex[indexPath.row]
            if key == "image"{
                //Image editing requires special table cell
                if let cell:SKImageEditorCell = tableView.dequeueReusableCellWithIdentifier("ImageEditor") as? SKImageEditorCell{
                    //The following attaches cell's edit image button to PromEditor's addImage event
                    cell.editButton!.addTarget(self, action:Selector("addImage:"), forControlEvents: .TouchUpInside)
                    cell.key = key
                    if(!_isNewProm && self.prom?.image != nil){
                        if let pfview:PFImageView = cell.basicImage as? PFImageView{
                            pfview.file = self.prom?.image
                            pfview.loadInBackground(nil)
                        }
                    }
                    return cell
                }
                return SKImageEditorCell()
            } else {
                //key for cell corresponds to a string editor
                if let cell = tableView.dequeueReusableCellWithIdentifier("StringEntry") as? SKStringEntryCell{
                    cell.field!.delegate = self
                    cell.key = key
                    
                    //Fill in generic information first
                    if(!_isNewProm){
                        //Don't fill in fields with any default info
                        if let currentVal = prom?.objectForKey(key) as? String {
                            if(currentVal != ""){
                                //If empty string, leave more descriptive placeholder
                                cell.field!.text = currentVal
                            }
                        }
                    }
                    if cell.field!.text == "" {
                        cell.field!.placeholder = readableNames[key]
                    }
                    return cell
                }
                return SKStringEntryCell()
            }
        }
        return UITableViewCell()
    }
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1;
    }
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(section == 0){
            return keyForRowIndex.count
        }
        return 0
    }
    //MARK: UITableViewDelegate
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if(indexPath.section == 0 && keyForRowIndex[indexPath.row] == "image"){
            //Is image editor cell
            return 200
        }
        return 43
    }
    /* Prevents image editing to be selected (highlighted) */
    override func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if(indexPath.section == 0 && keyForRowIndex[indexPath.row] == "image"){
            //Is image editor cell
            return nil //Do not allow selection
        } else{
            return indexPath
        }
    }
}

