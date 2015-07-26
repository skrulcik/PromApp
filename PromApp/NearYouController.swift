//
//  NearYouController.swift
//  PromApp
//
//  Created by Scott Krulcik on 1/17/15.
//  Copyright (c) 2015 Scott Krulcik. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class NearYouController : UIViewController, UISearchBarDelegate,
                            MKMapViewDelegate, UITableViewDelegate,
                            UITableViewDataSource, CLLocationManagerDelegate
{
    struct Constants {
        static let locationSelector = 0
        static let locationString = "Location"
        static let nameSelector = 1
        static let nameString = "Prom Name"
        static let placeholderString = "Search By: "
        
        static let mapRadius = CLLocationDistance(3500)
    }
    
    //  View to hold map or table view
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var dynamicResults: DynamicResult!
    
    var locationManager:CLLocationManager
    var searchMode:Int = 0
    var promResults = [SKProm]()
    var storeResults = [PFObject]()
    var currentProm:SKProm?
    var currentStore:PFObject?
    
    // MARK: UIView
    required init?(coder aDecoder: NSCoder) {
        locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization() // Prompt user for access
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
        
        // Fix tab bar highlight issue
        view.tintColor = SKColor.triadBlueLight()
        
        // Configure search bar
        searchBar.backgroundColor = SKColor.SearchBar()
        searchBar.tintColor = SKColor.white()
        searchBar.placeholder = Constants.placeholderString + Constants.locationString
    }
    
    override func viewWillAppear(animated: Bool) {
        configureMap()
        super.viewWillAppear(animated)
    }

    // TODO: Investigate
//    override func touchesBegan(touches: NSSet, withEvent event: UIEvent) {
//        // Dismiss keyboard when user clicks on screen
//        searchBar.resignFirstResponder()
//    }

    // MARK: Result view creation
    func configureMap() {
        locationManager.startUpdatingLocation()
        var frm = dynamicResults.frame
        var searchHeight:CGFloat = searchBar.frame.height
        var newFrame = CGRect(x: frm.minX, y: frm.minY-searchHeight,
                                width: frm.width, height:frm.height)
        var map = MKMapView(frame: newFrame)
        
        // Configure map to display current location
        map.delegate = self
        map.showsUserLocation = true
        map.setUserTrackingMode(.Follow, animated: true)

        //Get search area from location manager
        if locationManager.location != nil {
            var center = locationManager.location!.coordinate
            var region = MKCoordinateRegionMakeWithDistance(center,
                Constants.mapRadius, Constants.mapRadius)
            map.setRegion(region, animated: false)
            let proms = queryForPromsNearLocation(location: locationManager.location!)
            placePinsForPromsInMap(proms, map: map)
            let stores = queryForStoresNearLocation(location: locationManager.location!)
            placePinsForStoresInMap(stores, map: map)
        }
        
        dynamicResults.setChild(childView: map)
    }
    func configureTable() {
        var frm = dynamicResults.frame
        var searchHeight:CGFloat = searchBar.frame.height
        var newFrame = CGRect(x: frm.minX, y: frm.minY-searchHeight,
            width: frm.width, height:frm.height)
        var tbl = UITableView(frame: newFrame, style: .Plain)
        tbl.delegate = self
        tbl.dataSource = self
        tbl.registerNib(UINib(nibName: objectCellNibName, bundle:nil), forCellReuseIdentifier: objectCellID)
        
        if promResults.count != 0 {
            tbl.reloadData()
        }
        
        dynamicResults.setChild(childView: tbl)
    }
    
    
    // MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchMode = selectedScope
        if(selectedScope == Constants.nameSelector){
            // Search by name
            searchBar.placeholder = Constants.placeholderString + Constants.nameString
            configureTable()
        } else {
            // Search by location
            searchBar.placeholder = Constants.placeholderString + Constants.locationString
            configureMap()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // First find address from string
        if let search = searchBar.text {
            searchBar.resignFirstResponder() // Hide keyboard
            
            var searchLocation:CLLocation?
            
            // Determine search type
            if(self.searchMode == Constants.locationSelector){
                // Search by location, should have a map view
                let views = dynamicResults.subviews
                if views.count != 1 {
                    NSLog("Error with results view, %d active subvies.", views.count)
                } else if let mapview = views[0] as? MKMapView {
                    let geocoder = CLGeocoder()
                    geocoder.geocodeAddressString(search) {
                        (placemarks: [CLPlacemark]?, error: NSError?) in
                        if let location = placemarks?.last?.location {
                            searchLocation = location
                            let searchCenter = CLLocationCoordinate2DMake(location.coordinate.latitude,
                                location.coordinate.longitude)
                            let searchRegion = MKCoordinateRegionMakeWithDistance(searchCenter,
                                Constants.mapRadius, Constants.mapRadius)
                            mapview.setRegion(mapview.regionThatFits(searchRegion), animated: true)
                            
                            // Search for local POIs and place pins
                            var proms = self.queryForPromsNearLocation(location: searchLocation!)
                            // Place pins for all proms
                            self.placePinsForPromsInMap(proms, map: mapview)
                            var stores = self.queryForStoresNearLocation(location: searchLocation!)
                            self.placePinsForStoresInMap(stores, map: mapview)
                            // Place different pins for stores
                        }
                    }
                } else {
                    NSLog("Result and search scope out of sync. Cast MapView failed.")
                }
            } else if searchMode == Constants.nameSelector {
                // Search based on peom name
                promResults = queryForPromsWithString(searchString: searchBar.text!)
                // Place pins for proms
                if let tbl = dynamicResults.subviews[0] as? UITableView {
                    tbl.reloadData()
                } else {
                    NSLog("Result and search scope out of sync. Cast UITableView failed.")
                }
                // For now, don't search for stores
            }
        }
    }
    
    // MARK: Prom Queries
    func queryForPromsNearLocation(location loc:CLLocation) -> [SKProm] {
        var promsToDisplay = [SKProm]() // Holds Prom objects to be shown on map
        // Create Parse Query object to make request to server
        let query = PFQuery(className: SKProm.parseClassName())
        // Convert location into Parse GeoPoint
        let point = PFGeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        NSLog("Searching for Proms near Lat: %f Long: %f", loc.coordinate.latitude, loc.coordinate.longitude)
        query.whereKey(Prom_locationKey, nearGeoPoint: point, withinMiles: searchRadius)
        query.limit = stdQueryLimit
        if let proms = query.findObjects() as? [SKProm]{
            for prom in proms {
                promsToDisplay.append(prom) // Collect all new proms
            }
        }
        return promsToDisplay
    }
    func queryForPromsWithString(searchString search:String) -> [SKProm] {
        var promsToDisplay = [SKProm]() // Holds Prom objects to be shown on map
        // Create Parse Query object to make request to server
        let query = PFQuery(className: SKProm.parseClassName())
        // Convert location into Parse GeoPoint
        query.whereKey(Prom_searchKey, containsString: search.lowercaseString)
        
        // Restrict query to relatively close areas
        let place = PFGeoPoint(location: locationManager.location)
        query.whereKey(Prom_locationKey, nearGeoPoint: place, withinMiles: maxSearchRadius)
        
        query.limit = stdQueryLimit
        if let proms = query.findObjects() as? [SKProm]{
            NSLog("Found %d proms matching string %@.", proms.count, search.lowercaseString)
            for prom in proms {
                promsToDisplay.append(prom) // Collect all new proms
            }
        } else {
            NSLog("Failed to parse results of prom name query.")
        }
        return promsToDisplay
    }
    
    // MARK: Store Queries
    func queryForStoresNearLocation(location loc:CLLocation) -> [PFObject] {
        return queryForObjectsNearLocation(location: loc, className: "Store", locationKey: Store_locationKey)
    }
    func queryForStoresWithString(searchString search:String) -> [PFObject] {
        return queryForObjectsWithString(searchString: search, className: "Store", searchKey: Store_searchKey, locationKey: Store_locationKey)
    }

    
    // MARK: Generic Queries
    func queryForObjectsNearLocation(location loc:CLLocation,
                        className:String, locationKey:String) -> [PFObject] {
        var objsToDisplay = [PFObject]() // Holds Prom objects to be shown on map
        // Create Parse Query object to make request to server
        let query = PFQuery(className: className)
        // Convert location into Parse GeoPoint
        let point = PFGeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        NSLog("Searching for %@s near Lat: %f Long: %f", className, loc.coordinate.latitude, loc.coordinate.longitude)
        query.whereKey(locationKey, nearGeoPoint: point, withinMiles: searchRadius)
        query.limit = stdQueryLimit
        if let objs = query.findObjects() as? [PFObject]{
            for obj in objs {
                objsToDisplay.append(obj) // Collect all new proms
            }
        }
        return objsToDisplay
    }
    func queryForObjectsWithString(searchString search:String,
        className:String, searchKey:String, locationKey:String) -> [PFObject] {
            var objsToDisplay = [PFObject]() // Holds Prom objects to be shown on map
            // Create Parse Query object to make request to server
            let query = PFQuery(className: className)
            // Convert location into Parse GeoPoint
            query.whereKey(searchKey, containsString: search.lowercaseString)
            
            // Restrict query to relatively close areas
            let place = PFGeoPoint(location: locationManager.location)
            query.whereKey(locationKey, nearGeoPoint: place, withinMiles: maxSearchRadius)
            
            query.limit = stdQueryLimit
            if let objs = query.findObjects() as? [PFObject]{
                for obj in objs {
                    objsToDisplay.append(obj) // Collect all new proms
                }
            }
            return objsToDisplay
    }
    
    // MARK: MKMapViewDelegate
    func mapView(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        // Do not supply new annotation for use location
        if annotation.isKindOfClass(MKUserLocation) {
            return nil // This may cause error!!
        }
        
        // Check for custom annotation types
        if annotation.isKindOfClass(SKPromAnnotation){
            let annote = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "PromAnnotation")
            annote.enabled = true
            annote.canShowCallout = true
            annote.leftCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            return annote
            
        } else if annotation.isKindOfClass(StoreAnnotation) {
            let annote = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "StoreAnnotation")
            annote.enabled = true
            annote.canShowCallout = true
            annote.pinColor = .Purple
            annote.rightCalloutAccessoryView = UIButton(type: .DetailDisclosure) as UIView
            return annote
        }
        return nil
    }
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control.isKindOfClass(UIButton){
            if view.annotation!.isKindOfClass(SKPromAnnotation) {
                if let promNote = view.annotation as? SKPromAnnotation {
                    currentProm = promNote.prom
                    performSegueWithIdentifier("ViewPromFromMap", sender: self)
                }
            } else if view.annotation!.isKindOfClass(StoreAnnotation) {
                if let storeNote = view.annotation as? StoreAnnotation {
                    currentStore = storeNote.store
                    // Clear default text
                    storeNote.title = ""
                    storeNote.subtitle = ""
                    
                    // Add Designer logos to store detail:
                    // Use designer list to create image to show with store
                    let designerRelation = currentStore!.relationForKey("designers")
                    let designerQuery = designerRelation.query()
                    designerQuery.findObjectsInBackgroundWithBlock({
                        (objectList:Array<AnyObject>!, error:NSError!) in
                        // Use array to hold images for each designer while fetching
                        if let designerList = objectList as? Array<PFObject> {
                            var images = [UIImage]()
                            for designer in designerList {
                                if let designerImage = designer.objectForKey("logo") as? PFFile {
                                    let rawImage = designerImage.getData()
                                    let parsedImage:UIImage? = UIImage(data: rawImage)
                                    if parsedImage != nil {
                                        images.append(parsedImage!)
                                    }
                                } else {
                                    NSLog("Error parsing image for %@", designer.objectForKey("name") as! String)
                                }
                            }
                            // Combine images together so they can all be added to store callout
                            let finalImage = mergeHorizontal(images)
                            let logoView = UIImageView(image: finalImage)
                            // Add more detailed view
                            let customView = UIView(frame: CGRect(x: 0, y: 0, width: logoView.frame.width+100, height: 50))
                            let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 50))
                            label.text = "Designers:"
                            customView.addSubview(label)
                            customView.addSubview(logoView)
                            view.leftCalloutAccessoryView = customView
                        }
                    })
                }
                NSLog("Could not perform segue to show store details.")
            }
        }
    }
    
    // MARK: Annotations
    func placePinsForPromsInMap(proms:[SKProm], map:MKMapView){
        for prom in proms {
            let promPoint = SKPromAnnotation(latitude: prom.preciseLocation.latitude, andLongitude: prom.preciseLocation.longitude)
            promPoint.prom = prom
            map.addAnnotation(promPoint)
        }
    }
    func placePinsForStoresInMap(stores:[PFObject], map:MKMapView){
        for store in stores {
            if let loc = store.objectForKey(Store_locationKey) as? PFGeoPoint {
                let coord = CLLocationCoordinate2D(latitude: loc.latitude, longitude: loc.longitude)
                let storePoint = StoreAnnotation(storeCoordinate: coord, store: store)
                storePoint.store = store
                map.addAnnotation(storePoint)
            }
        }
    }
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            // Results section
            return promResults.count
        }
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        print("Attempted to fill cell")
        if let cell = tableView.dequeueReusableCellWithIdentifier(objectCellID) as? ObjectCell{
            let proms = promResults
            if indexPath.row < proms.count {
                //Ensure valid array access
                fillPromCell(cell, withProm: proms[indexPath.row])
            }
            return cell
        }
        // Don't make a fuss over errors, just return empty cell
        return UITableViewCell()
    }
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        if (indexPath.section == 0) {
            return CGFloat(dressCellHeight)
        }else{
            return 0
        }
    }
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        if (indexPath.section == 0){
            //Is a prom cell
            if PFUser.currentUser() != nil{
                let proms = promResults
                if indexPath.row < proms.count {
                    //Ensure valid array access
                    currentProm = proms[indexPath.row]
                    performSegueWithIdentifier("ViewPromFromMap", sender: self)
                } else {
                    NSLog("Tried to view non-existant prom.")
                }
                
            }
        }
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    // MARK: Cell Management
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
    
    // MARK: Navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ViewPromFromMap" {
            if let detail = segue.destinationViewController as? PromInfoController {
                detail.promObject = currentProm
            }
        }
    }
}