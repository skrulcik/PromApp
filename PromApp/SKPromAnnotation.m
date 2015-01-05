//
//  SKPromAnnotation.m
//  PromApp
//
//  Created by Scott Krulcik on 7/23/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromAnnotation.h"
@interface SKPromAnnotation()


@end

@implementation SKPromAnnotation
@synthesize prom;
@synthesize latitude = _latitude;
@synthesize longitude = _longitude;

- (id)initWithLatitude:(CLLocationDegrees)latitude
		  andLongitude:(CLLocationDegrees)longitude {
	if (self = [super init]) {
		self.latitude = latitude;
		self.longitude = longitude;
	}
	return self;
}

- (CLLocationCoordinate2D)coordinate {
	CLLocationCoordinate2D coordinate;
	coordinate.latitude = self.latitude;
	coordinate.longitude = self.longitude;
	return coordinate;
}

- (NSString *)title
{
    return self.prom.schoolName;
}

- (NSString *)subtitle
{
    return self.prom.address;
}

@end