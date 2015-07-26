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
    var title:String?
    var subtitle:String?
    
    init(storeCoordinate: CLLocationCoordinate2D, store storeObject:PFObject){
        coordinate = storeCoordinate
        store = storeObject
        // Set store information for callout
        name = store.objectForKey("name") as? String ?? ""
        address = store.objectForKey("address") as? String ?? ""
        // Set fields for detailed callout
        title = name
        subtitle = address
    }
}
