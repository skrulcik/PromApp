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

static NSString * const PROM_LOCATION_KEY = @"preciseLocation";
static int const SEARCH_RADIUS = 75; //in km
static int const QUERY_LIMIT = 30; //Don't want 

@interface SKPromFinderViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate, UISearchBarDelegate>

@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;
@property (weak, nonatomic) IBOutlet MKMapView *map;
@property (strong, nonatomic) CLLocationManager *locationManager;

- (void)viewWillAppear:(BOOL)animated;
- (void) searchBarSearchButtonClicked:(UISearchBar *)searchBar;
- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance;

@end
