//
//  UITPromFinderViewController.m
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
#import <PromApp-Swift.h>
#import <Bolts/Bolts.h>
#import "SKPromFinderViewController.h"
#import "SKProm.h"
#import "SKPromAnnotation.h"

static uint8_t locationSearch = 0; //Scope bar index
static uint8_t nameSearch = 1; //Scope bar indices
static NSString *searchPlaceholderBase = @"Search By: ";
static NSString *locationPlaceholder = @"Location";
static NSString *namePlaceholder = @"Prom Name";

@interface SKPromFinderViewController ()
@property NSMutableArray *promsToDisplay;  //Nearby proms to pin onto map
@property NSMutableArray *storesToDisplay;
@property CLLocation *mapCenter;

@end

@implementation SKPromFinderViewController
@synthesize map;
@synthesize searchBar;
@synthesize promsToDisplay;
@synthesize storesToDisplay;
@synthesize currentProm;
@synthesize currentStore;
@synthesize mapCenter;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //To ensure mapview shows in right place
    [self setEdgesForExtendedLayout:UIRectEdgeNone];
    //Setup location manager
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager requestAlwaysAuthorization];   //Prompts user for access to location
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [self.locationManager startUpdatingLocation];
    //Set search bar delegate
    self.searchBar.delegate = self;
    self.searchBar.backgroundColor = [SKColor SearchBar];
    //Set map to show location and to continuously track
    self.map.delegate = self;
    self.map.showsUserLocation = YES;
    [self.map setUserTrackingMode:MKUserTrackingModeFollow animated:YES];
    CLLocationCoordinate2D searchArea = self.locationManager.location.coordinate;
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(searchArea, 2000, 2000);
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if(self.locationManager.location.coordinate.latitude !=0){
        self.mapCenter = self.locationManager.location;
    }
    [self queryForAllPostsNearLocation:self.mapCenter withNearbyDistance:kCLLocationAccuracyBest];
}

#pragma mark - MKMapViewDelegate
- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation{
    // If it's the user location, just return nil.
    if ([annotation isKindOfClass:[MKUserLocation class]])
        return nil;
    
    // Handle any custom annotations.
    if([annotation isKindOfClass:[SKPromAnnotation class]]){
        MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"PromAnnotation"];
        view.enabled = YES;
        view.canShowCallout = YES;
        view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return view;
    } else if ([annotation isKindOfClass:[StoreAnnotation class]]){
        MKPinAnnotationView *view = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"StoreAnnotation"];
        view.enabled = YES;
        view.canShowCallout = YES;
        view.pinColor = MKPinAnnotationColorPurple;
        //view.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        return view;
    }
    return nil;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([control isKindOfClass:[UIButton class]]){
        if([[view annotation] isKindOfClass:[SKPromAnnotation class]]){
            SKPromAnnotation *promNote = (SKPromAnnotation *) [view annotation];
            self.currentProm = promNote.prom;
            [self performSegueWithIdentifier:@"ViewPromFromMap" sender:self ];
        } else if([[view annotation] isKindOfClass:[StoreAnnotation class]]){
            StoreAnnotation *storeNote = (StoreAnnotation *) [view annotation];
            self.currentStore = (SKStore *)storeNote.store;
            //NSLog(@"%@", [promNote.prom readableInfo]);
            //[self performSegueWithIdentifier:@"showPromDetail" sender:self ];
        }
    }
}

#pragma mark - Search

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    NSString *search = self.searchBar.text;
    [self.searchBar resignFirstResponder];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:search completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            NSLog(@"Error retrieving address.\n%@", error);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Address" message:@"Verify search entry and check network connection." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
            [alert show];
        } else {
            CLPlacemark *placemark = [placemarks lastObject];
            CLLocationCoordinate2D searchArea = CLLocationCoordinate2DMake(placemark.location.coordinate.latitude, placemark.location.coordinate.longitude);
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(searchArea, 2000, 2000);
            [self.map setRegion:[self.map regionThatFits:region] animated:YES];
            self.mapCenter = [[CLLocation alloc] initWithLatitude:searchArea.latitude longitude:searchArea.longitude];
            [self queryForAllPostsNearLocation:self.mapCenter withNearbyDistance:kCLLocationAccuracyBest];
        }
    }];
}

- (void)searchBar:(UISearchBar *)searchBar
selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    if (selectedScope == locationSearch) {
        // Show user map and prompt to search by location
        // Put proper placeholder in the searchbar
        self.searchBar.placeholder = [searchPlaceholderBase stringByAppendingString:locationPlaceholder];
    } else if (selectedScope == nameSearch) {
        self.searchBar.placeholder = [searchPlaceholderBase stringByAppendingString:namePlaceholder];
    }
    
}

#pragma mark - Query for nearby proms

- (void)queryForAllPostsNearLocation:(CLLocation *)searchLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    [self queryForAllPromsNearLocation:searchLocation withNearbyDistance:nearbyDistance];
    [self queryForAllStoresNearLocation:searchLocation withNearbyDistance:nearbyDistance];
    
}
- (void)queryForAllPromsNearLocation:(CLLocation *)searchLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    if(self.promsToDisplay == nil){
        self.promsToDisplay = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
    }
	
    PFQuery *query = [PFQuery queryWithClassName:[SKProm parseClassName]];
	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:searchLocation.coordinate.latitude longitude:searchLocation.coordinate.longitude];
    NSLog(@"Search Lat %f Current Long %f", searchLocation.coordinate.latitude, searchLocation.coordinate.longitude);
	[query whereKey:PROM_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
	query.limit = QUERY_LIMIT;
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"%s Query failed.", __PRETTY_FUNCTION__);
		} else {
			NSMutableArray *newProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];   //Proms that are not being displayed
			NSMutableArray *allNewProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];//All proms returned by the query
			for (PFObject *object in objects) {
				SKProm *newProm = (SKProm *)object;
                if([newProm objectForKey:@"schoolName"] != nil){
                    [allNewProms addObject:newProm];
                    BOOL found = NO;
                    for (SKProm *existingProm in self.promsToDisplay) {
                        if ([newProm equalTo:existingProm]) {
                            found = YES;
                        }
                    }
                    if (!found) {
                        [newProms addObject:newProm];
                    }
                }
			}
            
			// 2. Find posts in promsToDisplay that didn't make the cut.
			NSMutableArray *promsToRemove = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
			for (SKProm *aProm in promsToDisplay) {
				BOOL found = NO;
				// Use our object cache from the first loop to save some work.
				for (SKProm *newestProm in allNewProms) {
					if ([aProm equalTo:newestProm]) {
						found = YES;
					}
				}
				if (!found) {
					[promsToRemove addObject:aProm];
				}
			}
			// proms to remove are those that hwere there already, but not returned again by the query
            
			// 3. Configure our new posts; these are about to go onto the map.
            [self.promsToDisplay addObjectsFromArray:newProms];
            [PFObject pinAll:newProms];
			[self.promsToDisplay removeObjectsInArray:promsToRemove];
			for (SKProm *newProm in newProms) {
				SKPromAnnotation *promPoint = [[SKPromAnnotation alloc] initWithLatitude:newProm.preciseLocation.latitude andLongitude:newProm.preciseLocation.longitude];
                promPoint.prom = newProm;
                [self.map addAnnotation:promPoint];
			}
		}
	}];
}

- (void)queryForAllStoresNearLocation:(CLLocation *)searchLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    if(self.storesToDisplay == nil){
        self.storesToDisplay = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
    }
    PFQuery *query = [PFQuery queryWithClassName:@"Store"];
    
    // Query for posts sort of kind of near our current location.
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:searchLocation.coordinate.latitude longitude:searchLocation.coordinate.longitude];
    NSLog(@"Store Lat %f Current Long %f", searchLocation.coordinate.latitude, searchLocation.coordinate.longitude);
    [query whereKey:STORE_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
    query.limit = QUERY_LIMIT;
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            NSLog(@"%s Query failed.", __PRETTY_FUNCTION__);
        } else {
            //NSLog(@"Query returned %lu proms.", (unsigned long)[objects count]);
            NSMutableArray *newStores = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];   //Proms that are not being displayed
            NSMutableArray *allNewStores = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];//All proms returned by the query
            for (PFObject *object in objects) {
                [allNewStores addObject:object];
                BOOL found = NO;
                for (PFObject *existingObj in self.storesToDisplay) {
                    if([(NSString *)[existingObj objectForKey:@"name"]
                        isEqualToString:(NSString *)[object objectForKey:@"name"]]){
                        found = YES;
                    }
                }
                if (!found) {
                    [newStores addObject:object];
                }
            }
            
            // 2. Find posts in promsToDisplay that didn't make the cut.
            NSMutableArray *storesToRemove = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
            for (PFObject *aStore in storesToDisplay) {
                BOOL found = NO;
                // Use our object cache from the first loop to save some work.
                for (PFObject *newestStore in allNewStores) {
                    if ([(NSString *)[aStore objectForKey:@"name"]
                         isEqualToString:(NSString *)[newestStore objectForKey:@"name"]]) {
                        found = YES;
                    }
                }
                if (!found) {
                    [storesToRemove addObject:aStore];
                }
            }
            // proms to remove are those that hwere there already, but not returned again by the query
            
            // 3. Configure our new posts; these are about to go onto the map.
            [self.storesToDisplay addObjectsFromArray:newStores];
            [self.storesToDisplay removeObjectsInArray:storesToRemove];
            for (PFObject *newStore in newStores) {
                PFGeoPoint *geo = [newStore objectForKey:@"location"];
                CLLocationCoordinate2D coord = CLLocationCoordinate2DMake(geo.latitude, geo.longitude);
                StoreAnnotation *storePoint = [[StoreAnnotation alloc] initWithStoreCoordinate:coord store:newStore];
                [self.map addAnnotation:storePoint];
            }
        }
    }];
}




#pragma mark - Navigation
- (IBAction) unwindFromPromDetail:(UIStoryboardSegue *) segue
{
    
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"ViewPromFromMap"]){
        PromInfoController *detail = (PromInfoController *) [segue destinationViewController];
        detail.promObject = currentProm;
    }
}


@end
