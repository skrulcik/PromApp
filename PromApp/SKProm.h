//
//  SKProm.h
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>
#import <MapKit/MapKit.h>
#import "SKDress.h"

@interface SKProm : PFObject <PFSubclassing>
@property NSString *schoolName;
@property NSString *address;
@property NSString *locationDescription;
@property NSString *time;
@property NSString *theme;
@property PFFile *image;
@property PFGeoPoint *preciseLocation;
@property NSMutableArray *dresses;


+ (NSString *)parseClassName;
- (BOOL) equalTo:(SKProm*)other;
- (NSString *)readableInfo;
- (BOOL) verifyDesigner:(NSString *)designer withStyle:(NSString *)styleNumber;
@end
