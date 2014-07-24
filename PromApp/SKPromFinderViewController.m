//
//  UITPromFinderViewController.m
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromFinderViewController.h"
#import "SKProm.h"
#import "SKPromAnnotation.h"
#import "SKPromDetailViewController.h"


@interface SKPromFinderViewController ()
@property NSMutableArray *promsToDisplay;  //Nearby proms to pin onto map
@property CLLocation *mapCenter;

@end

@implementation SKPromFinderViewController
@synthesize map;
@synthesize searchBar;
@synthesize promsToDisplay;
@synthesize currentProm;
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
    
    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    //Set up delegates
    self.searchBar.delegate = self;
    self.locationManager.delegate = self;
    self.map.delegate = self;
    [self.locationManager startUpdatingLocation];
    
    //Add the Shoppe pin
    CLLocationCoordinate2D theShoppe = CLLocationCoordinate2DMake(43.080732, -73.785629);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(theShoppe, 2500, 2500);
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    self.mapCenter = [[CLLocation alloc] initWithLatitude:theShoppe.latitude longitude:theShoppe.longitude];
    if([map.annotations count]==0){
        MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
        point.coordinate = theShoppe;
        point.title = @"The Shoppe";
        point.subtitle = @"I'm here!!!";
        [self.map addAnnotation:point];
    }

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"%f",self.locationManager.location.coordinate.latitude);
    if(self.locationManager.location.coordinate.latitude !=0){
        self.mapCenter = self.locationManager.location;
    }
    [self queryForAllPostsNearLocation:self.mapCenter withNearbyDistance:kCLLocationAccuracyBest];
}

- (void)viewDidAppear:(BOOL)animated
{

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
    } else return nil;
}

- (void) mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    if([control isKindOfClass:[UIButton class]]){
        SKPromAnnotation *promNote = (SKPromAnnotation *) [view annotation];
        self.currentProm = promNote.prom;
        //NSLog(@"%@", [promNote.prom readableInfo]);
        [self performSegueWithIdentifier:@"showPromDetail" sender:self ];
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
            MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(searchArea, 800, 800);
            [self.map setRegion:[self.map regionThatFits:region] animated:YES];
            self.mapCenter = [[CLLocation alloc] initWithLatitude:searchArea.latitude longitude:searchArea.longitude];
            [self queryForAllPostsNearLocation:self.mapCenter withNearbyDistance:kCLLocationAccuracyBest];
        }
    }];
}

#pragma mark - Query for nearby proms

- (void)queryForAllPostsNearLocation:(CLLocation *)searchLocation withNearbyDistance:(CLLocationAccuracy)nearbyDistance {
    if(self.promsToDisplay == nil){
        self.promsToDisplay = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];
    }
	PFQuery *query = [PFQuery queryWithClassName:[SKProm parseClassName]];
	// Check locally then externally
	if ([self.promsToDisplay count] == 0) {
		query.cachePolicy = kPFCachePolicyCacheThenNetwork;
	}
    
	// Query for posts sort of kind of near our current location.
	PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:searchLocation.coordinate.latitude longitude:searchLocation.coordinate.longitude];
    NSLog(@"Search Lat %f Current Long %f", searchLocation.coordinate.latitude, searchLocation.coordinate.longitude);
	[query whereKey:PROM_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
	query.limit = QUERY_LIMIT;
    
	[query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
		if (error) {
			NSLog(@"%s Query failed.", __PRETTY_FUNCTION__);
		} else {
            //NSLog(@"Query returned %lu proms.", (unsigned long)[objects count]);
			NSMutableArray *newProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];   //Proms that are not being displayed
			NSMutableArray *allNewProms = [[NSMutableArray alloc] initWithCapacity:QUERY_LIMIT];//All proms returned by the query
			for (PFObject *object in objects) {
				SKProm *newProm = [[SKProm alloc] init];
                newProm.schoolName = [object objectForKey:@"schoolName"];
                newProm.address = [object objectForKey:@"address"];
                newProm.locationDescription = [object objectForKey:@"locationDescription"];
                newProm.time = [object objectForKey:@"time"];
                newProm.theme = [object objectForKey:@"theme"];
                newProm.dresses = [object objectForKey:@"dresses"];
                newProm.preciseLocation = [object objectForKey:@"preciseLocation"];
                //NSLog(@"Prom Info:%@",newProm.readableInfo);
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
			[self.promsToDisplay removeObjectsInArray:promsToRemove];
			for (SKProm *newProm in newProms) {
				SKPromAnnotation *promPoint = [[SKPromAnnotation alloc] initWithLatitude:newProm.preciseLocation.latitude andLongitude:newProm.preciseLocation.longitude];
                promPoint.prom = newProm;
                [self.map addAnnotation:promPoint];
                NSLog(@"Added annotation.");
			}
            //NSLog(@"Annotations: %@",[self.map annotations]);
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
    if([segue.identifier isEqualToString:@"showPromDetail"]){
        SKPromDetailViewController *detail = (SKPromDetailViewController*) [[segue destinationViewController] viewControllers][0];
        detail.prom = self.currentProm;
    }
}


@end
