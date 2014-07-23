//
//  UITPromFinderViewController.m
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromFinderViewController.h"
#import "SKProm.h"


@interface SKPromFinderViewController ()
@property NSMutableArray *promsToDisplay;  //Nearby proms to pin onto map

@end

@implementation SKPromFinderViewController
@synthesize map;
@synthesize searchBar;
@synthesize promsToDisplay;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [self.locationManager startUpdatingLocation];
    //Set up delegates
    self.map.delegate = self;
    self.searchBar.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D theShoppe = CLLocationCoordinate2DMake(43.080725, -73.785757);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(theShoppe, 800, 800);
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = theShoppe;
    point.title = @"The Shoppe";
    point.subtitle = @"I'm here!!!";
    [self.map addAnnotation:point];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"Before");
    [self.locationManager startUpdatingLocation];
    [self queryForAllPostsNearLocation:self.locationManager.location withNearbyDistance:kCLLocationAccuracyBest];
    NSLog(@"After");
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
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(searchArea, 800, 800);
            [self.map setRegion:[self.map regionThatFits:region] animated:YES];
        }
    }];
}

#pragma mark - Query for nearby proms

- (void)queryForAllPostsNearLocation:(CLLocation *)currentLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
	PFQuery *query = [PFQuery queryWithClassName:[SKProm parseClassName]];
    
	// Check locally then externally
	if ([self.promsToDisplay count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:currentLocation.coordinate.latitude longitude:currentLocation.coordinate.longitude];
    NSLog(@"Current Lat %f Current Long %f", currentLocation.coordinate.latitude, currentLocation.coordinate.longitude);
	[query whereKey:PROM_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
	query.limit = QUERY_LIMIT;
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"%sERROR: unsuccessful PFGeoPoint query.!", __PRETTY_FUNCTION__);
		} else {
            NSLog(@"Found this many: %lu", (unsigned long)[objects count]);
			// 1. Find genuinely new posts:
			NSMutableArray *newProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
			// (Cache the objects we make for the search in step 2:)
			NSMutableArray *allNewProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
			for (PFObject *object in objects) {
				SKProm *newProm = [[SKProm alloc] init];
                newProm.schoolName = [object objectForKey:@"schoolName"];
                newProm.address = [object objectForKey:@"address"];
                newProm.locationDescription = [object objectForKey:@"locationDescription"];
                newProm.time = [object objectForKey:@"time"];
                newProm.theme = [object objectForKey:@"theme"];
                newProm.dresses = [object objectForKey:@"dresses"];
                newProm.preciseLocation = [object objectForKey:@"preciseLocation"];
				[allNewProms addObject:newProm];
				BOOL found = NO;
				for (SKProm *existingProm in promsToDisplay) {
					if ([newProm equalTo:existingProm]) {
						found = YES;
					}
				}
				if (!found) {
					[newProms addObject:newProm];
				}
			}
			// newPosts now contains our new objects.
            
			// 2. Find posts in promsToDisplay that didn't make the cut.
			NSMutableArray *promsToRemove = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
			for (SKProm *currentProm in promsToDisplay) {
				BOOL found = NO;
				// Use our object cache from the first loop to save some work.
				for (SKProm *newestProm in allNewProms) {
					if ([currentProm equalTo:newestProm]) {
						found = YES;
					}
				}
				if (!found) {
					[promsToRemove addObject:currentProm];
				}
			}
			// proms to remove are those that hwere there already, but not returned again by the query
            
			// 3. Configure our new posts; these are about to go onto the map.
            [promsToDisplay addObjectsFromArray:newProms];
			[promsToDisplay removeObjectsInArray:promsToRemove];
			for (SKProm *newProm in newProms) {
				MKPointAnnotation *promPoint = [[MKPointAnnotation alloc] init];
                promPoint.coordinate = CLLocationCoordinate2DMake(newProm.preciseLocation.latitude, newProm.preciseLocation.longitude);
                promPoint.title = newProm.schoolName;
                promPoint.subtitle = newProm.address;
                [self.map addAnnotation:promPoint];
                NSLog(@"Added annotation");
			}
            NSLog(@"Annotations: %@",[self.map annotations]);
		}
	}];
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
