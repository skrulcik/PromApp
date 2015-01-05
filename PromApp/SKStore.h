//
//  SKStore.h
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>
#import <Parse/PFObject+Subclass.h>
#import "SKDress.h"
#import "SKProm.h"


@interface SKStore : PFUser <PFSubclassing>
@property NSString *address;
@property CLLocationCoordinate2D *derivedLocation;
@property NSMutableArray *dressesSold;
@property NSMutableArray *dressInventory;
@property NSMutableArray *proms;
@property NSString *description;
@property UIImage *profilePic;
@property NSString *hours;

- (void) readableStoreInformation;

@end
