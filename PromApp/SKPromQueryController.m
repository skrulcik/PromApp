//
//  SKViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 8/5/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
#import "SKPromQueryController.h"
#import "SKAddDressViewController.h"

@interface SKPromQueryController ()
@property NSString *className;
@property CLLocationManager *locationManager;
@end

@implementation SKPromQueryController{
    NSIndexPath *selectedPath;
}
@synthesize className;
@synthesize locationManager;
@synthesize selectedProm;
@synthesize searchBar;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style className:[SKProm parseClassName]];
    if (self) {
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = PROM_TEXT_KEY;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = QUERY_LIMIT;
        selectedPath = nil;
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aCoder {
    self = [super initWithCoder:aCoder];
    if (self) {
        // Customize the table
        
        // The className to query on
        self.className = @"SKProm";
        
        // The key of the PFObject to display in the label of the default cell style
        self.textKey = PROM_TEXT_KEY;
        
        // Uncomment the following line to specify the key of a PFFile on the PFObject to display in the imageView of the default cell style
        self.imageKey = PROM_IMAGE_KEY;
        
        // Whether the built-in pull-to-refresh is enabled
        self.pullToRefreshEnabled = YES;
        
        // Whether the built-in pagination is enabled
        self.paginationEnabled = YES;
        
        // The number of objects to show per page
        self.objectsPerPage = QUERY_LIMIT;
        selectedPath = nil;
    }
    return self;
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];

    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [[CLLocationManager alloc] init];
    [self.locationManager startUpdatingLocation];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    [locationManager setDelegate:self];
    [self.locationManager startUpdatingLocation];
}


#pragma mark - UIViewController
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // PromApp is always in portrait
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}


#pragma mark - PFQueryTableViewController

- (void)objectsWillLoad {
    [super objectsWillLoad];

    // This method is called before a PFQuery is fired to get more objects
}

- (void)objectsDidLoad:(NSError *)error {
    [super objectsDidLoad:error];

    // This method is called every time objects are loaded from Parse via the PFQuery
}


// Override to customize what kind of query to perform on the class. The default is to query for
// all objects ordered by createdAt descending.
- (PFQuery *)queryForTable {
    //CLLocation *searchLocation = [locationManager location];
    //return [self queryForTableWithLocation:searchLocation];
    NSString* searchString = self.searchBar.text;
    if([searchString isEqualToString:@""]){
        return [self queryForTableWithLocation:[self.locationManager location]];
    }
    return [self queryForTableWithString:searchString];
}

- (PFQuery *)queryForTableWithLocation: (CLLocation *)searchLocation
{
    searchLocation = [self.locationManager location];
    PFQuery *query = [PFQuery queryWithClassName:@"Prom"];

    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }

    // Query for posts sort of kind of near our current location.
    PFGeoPoint *point = [PFGeoPoint geoPointWithLatitude:searchLocation.coordinate.latitude longitude:searchLocation.coordinate.longitude];
    NSLog(@"Search Lat %f Current Long %f", searchLocation.coordinate.latitude, searchLocation.coordinate.longitude);
    [query whereKey:PROM_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
    query.limit = QUERY_LIMIT;

    return query;
}

- (PFQuery *)queryForTableWithString: (NSString *)searchString
{
    PFQuery *query = [PFQuery queryWithClassName:@"Prom"];
    
    // If Pull To Refresh is enabled, query against the network by default.
    if (self.pullToRefreshEnabled) {
        query.cachePolicy = kPFCachePolicyNetworkOnly;
    }
    if (self.objects.count == 0) {
        query.cachePolicy = kPFCachePolicyCacheThenNetwork;
    }
    [query whereKey:@"schoolName" containsString:searchString];
    //[query whereKey:PROM_LOCATION_KEY nearGeoPoint:point withinKilometers:SEARCH_RADIUS];
    query.limit = QUERY_LIMIT;
    
    return query;
}

#pragma mark - Search

-(void) searchBarSearchButtonClicked:(UISearchBar *)searchBar
{
    self.objectsPerPage = QUERY_LIMIT;
    [self loadObjects];
}


// Override to customize the look of a cell representing an object. The default is to display
// a UITableViewCellStyleDefault style cell with the label being the textKey in the object,
// and the imageView being the imageKey in the object.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath object:(PFObject *)object {
    static NSString *CellIdentifier = @"Cell";

    PFTableViewCell *cell = (PFTableViewCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
    cell = [[PFTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    // Configure the cell
    cell.textLabel.text = [object objectForKey:self.textKey];
    if ([indexPath isEqual:selectedPath]) {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    } else {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }

    return cell;
}


/*
// Override if you need to change the ordering of objects in the table.
- (PFObject *)objectAtIndex:(NSIndexPath *)indexPath {
return [self.objects objectAtIndex:indexPath.row];
}
*/

/*
// Override to customize the look of the cell that allows the user to load the next page of objects.
// The default implementation is a UITableViewCellStyleDefault cell with simple labels.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForNextPageAtIndexPath:(NSIndexPath *)indexPath {
static NSString *CellIdentifier = @"NextPage";

UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

if (cell == nil) {
cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
}

cell.selectionStyle = UITableViewCellSelectionStyleNone;
cell.textLabel.text = @"Load more...";

return cell;
}
*/

#pragma mark - UITableViewDataSource

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the specified item to be editable.
return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
if (editingStyle == UITableViewCellEditingStyleDelete) {
// Delete the object from Parse and reload the table view
} else if (editingStyle == UITableViewCellEditingStyleInsert) {
// Create a new instance of the appropriate class, and save it to Parse
}
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
// Return NO if you do not want the item to be re-orderable.
return YES;
}
*/

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
    selectedPath = indexPath;
    [tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationNone];
    SKProm *prom = (SKProm*)[self objectAtIndexPath:indexPath];
    self.selectedProm = prom;
}

@end