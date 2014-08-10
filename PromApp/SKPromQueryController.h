//
//  SKPromQueryController.h
//  PromApp
//
//  Created by Scott Krulcik on 8/5/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>

//These constants should be defined in the class that deploys this controller (usually modal)
//The properties of PFQueryTableViewController should be set by that class
static NSString * const PROM_LOCATION_KEY = @"preciseLocation";
static NSString * const PROM_TEXT_KEY = @"schoolName";
static int const SEARCH_RADIUS = 75; //In km
static int const QUERY_LIMIT = 10;

@interface SKPromQueryController : PFQueryTableViewController <CLLocationManagerDelegate>

-(IBAction)cancelPressed:(id)sender;
@end
