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
        if(selectedScope == Constants.nameSelector){
            // Search by name
            configureTable()
        } else {
            // Search by location
            configureMap()
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