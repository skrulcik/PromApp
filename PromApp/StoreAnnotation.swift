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
    var title: String
    var subtitle: String
    var store:PFObject
    
    init(coordinate: CLLocationCoordinate2D, store:PFObject){
        self.coordinate = coordinate
        self.store = store
        self.title = store.objectForKey("name") as String
        self.subtitle = store.objectForKey("address") as String
    }
}
