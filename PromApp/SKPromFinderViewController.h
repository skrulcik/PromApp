//
//  UITPromFinderViewController.h
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import <Parse/Parse.h>
#import "SKProm.h"
#import "SKStore.h"

static NSString * const PROM_LOCATION_KEY = @"preciseLocation";
static NSString * const STORE_LOCATION_KEY = @"location";
static int const SEARCH_RADIUS = 20;
static int const QUERY_LIMIT = 20; //Don't want

@interface SKPromFinderViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) SKProm *currentProm;
@property (strong, nonatomic) SKStore*currentStore;

- (void)viewWillAppear:(BOOL)animated;
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;
- (IBAction) unwindFromPromDetail:(UIStoryboardSegue *) segue;

@end
