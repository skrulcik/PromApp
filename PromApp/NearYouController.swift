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
    
    required init(coder aDecoder: NSCoder) {
        locationManager = CLLocationManager()
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.requestAlwaysAuthorization() // Prompt user for access
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.startUpdatingLocation()
    }
    
    override func viewWillAppear(animated: Bool) {
        configureMap()
        super.viewWillAppear(animated)
    }
    
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
            var center = locationManager.location.coordinate
            var region = MKCoordinateRegionMakeWithDistance(center,
                Constants.mapRadius, Constants.mapRadius)
            map.setRegion(region, animated: false)
            let proms = queryForPromsNearLocation(location: locationManager.location)
            placePinsForPromsInMap(proms, map: map)
        }
        
        dynamicResults.setChild(childView: map)
    }
    func configureTable() {
        var frm = dynamicResults.frame
        var searchHeight:CGFloat = searchBar.frame.height
        var newFrame = CGRect(x: frm.minX, y: frm.minY-searchHeight,
            width: frm.width, height:frm.height)
        var res = UIView(frame: newFrame)
        res.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.9, alpha: 1.0)
        dynamicResults.setChild(childView: res)
    }
    
    
    // MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        searchMode = selectedScope
        if(selectedScope == Constants.nameSelector){
            // Search by name
            configureTable()
        } else {
            // Search by location
            configureMap()
        }
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        // First find address from string
        let search = searchBar.text
        searchBar.resignFirstResponder() // Hide keyboard
        
        var searchLocation:CLLocation?
        
        let geocoder = CLGeocoder()
        geocoder.geocodeAddressString(search, completionHandler: {
            (placemarks:[AnyObject]!, error:NSError!) in
            if let place = placemarks.last as? CLPlacemark {
                searchLocation = place.location
                let searchCenter = CLLocationCoordinate2DMake(place.location.coordinate.latitude,
                    place.location.coordinate.longitude)
                let searchRegion = MKCoordinateRegionMakeWithDistance(searchCenter,
                    Constants.mapRadius, Constants.mapRadius)
                if let map = self.dynamicResults.subviews.last as? MKMapView {
                    map.setRegion(map.regionThatFits(searchRegion), animated: true)
                } else {
                    NSLog("Could not load result view as map.");
                }
            }
        })
        
        // Determine search type
        if(self.searchMode == Constants.locationSelector){
            // Search by location, should have a map view
            let views = dynamicResults.subviews
            if views.count != 1 {
                NSLog("Error with results view, %d active subvies.", views.count)
            } else if let mapview = views[0] as? MKMapView {
                if searchLocation != nil {
                    // Search for local POIs and place pins
                    var proms = queryForPromsNearLocation(location: searchLocation!)
                    // Place pins for all proms
                    placePinsForPromsInMap(proms, map: mapview)
                    var stores = queryForStoresNearLocation(location: searchLocation!)
                    // Place different pins for stores
                }
            } else {
                NSLog("Result and search scope out of sync. Cast MapView failed.")
            }
        } else if searchMode == Constants.nameSelector {
            // Search based on peom name
            var proms = queryForPromsWithString(searchString: searchBar.text)
            // Place pins for proms
            // For now, don't search for stores
        }
    }
    
    // MARK: Prom Queries
    func queryForPromsNearLocation(location loc:CLLocation) -> [SKProm] {
        var promsToDisplay = [SKProm]() // Holds Prom objects to be shown on map
        // Create Parse Query object to make request to server
        let query = PFQuery(className: SKProm.parseClassName())
        // Convert location into Parse GeoPoint
        let point = PFGeoPoint(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude)
        NSLog("Searching for Proms near Lat: %f Long: %f")
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
        return [SKProm]()
    }
    
    // MARK: Store Queries
    func queryForStoresNearLocation(location loc:CLLocation) -> [PFObject] {
        return queryForObjectsNearLocation(location: loc, className: "Store", locationKey: Store_locationKey)
    }
    func queryForStoresWithString(searchString search:String) -> [PFObject] {
        return queryForObjectsWithString(searchString: search, className: "Store", nameKey: "name")
    }

    
    // MARK: Generic Queries
    func queryForObjectsNearLocation(location loc:CLLocation,
                        className:String, locationKey:String) -> [PFObject] {
        return [PFObject]()
    }
    func queryForObjectsWithString(searchString search:String,
                        className:String, nameKey:String) -> [PFObject] {
        return [PFObject]()
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
            annote.rightCalloutAccessoryView = UIButton.buttonWithType(.DetailDisclosure) as UIView
            return annote
            
        } else if annotation.isKindOfClass(StoreAnnotation) {
            let annote = MKPinAnnotationView(annotation: annotation, reuseIdentifier: "StoreAnnotation")
            annote.enabled = true
            annote.canShowCallout = true
            return annote
        }
        return nil
    }
    func mapView(mapView: MKMapView!, annotationView view: MKAnnotationView!, calloutAccessoryControlTapped control: UIControl!) {
        if control.isKindOfClass(UIButton){
            if view.annotation.isKindOfClass(SKPromAnnotation) {
                if let promNote = view.annotation as? SKPromAnnotation {
                    currentProm = promNote.prom
                    performSegueWithIdentifier("ViewPromFromMap", sender: self)
                }
            } else if view.annotation.isKindOfClass(StoreAnnotation) {
                if let storeNote = view.annotation as? StoreAnnotation {
                    currentStore = storeNote.store
                    NSLog("Could not perform segue to show store details.")
                }
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
    
    // MARK: UITableViewDataSource
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 0
    }
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        return UITableViewCell()
    }
}