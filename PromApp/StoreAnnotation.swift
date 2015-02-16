//
//  StoreAnnotation.swift
//  PromApp
//
//  Created by Scott Krulcik on 11/29/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

import Foundation
import UIKit
import MapKit

class StoreAnnotation:NSObject, MKAnnotation
{
    var coordinate: CLLocationCoordinate2D
    var store:PFObject
    var name:String
    var address:String
    // Required fields for annotations that allow callouts
    var title: String
    var subtitle: String
    
    init(coordinate: CLLocationCoordinate2D, store:PFObject){
        self.coordinate = coordinate
        self.store = store
        // Set store information for callout
        self.name = store.objectForKey("name") as String
        self.address = store.objectForKey("address") as String
        // Set fields for detailed callout
        self.title = name
        self.subtitle = address
    }
}
