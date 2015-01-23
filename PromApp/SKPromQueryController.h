//
//  SKPromQueryController.h
//  PromApp
//
//  Created by Scott Krulcik on 8/5/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>
#import <ParseUI/ParseUI.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SKProm.h"

//These constants should be defined in the class that deploys this controller (usually modal)
//The properties of PFQueryTableViewController should be set by that class
static NSString * const PROM_LOCATION_KEY = @"preciseLocation";
static NSString * const STORE_LOCATION_KEY = @"location";
static NSString * const PROM_TEXT_KEY = @"schoolName";
static NSString * const PROM_IMAGE_KEY = @"image";
static int const SEARCH_RADIUS = 40;
static int const QUERY_LIMIT = 10;

@interface SKPromQueryController : PFQueryTableViewController <CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property SKProm* selectedProm;

@end
