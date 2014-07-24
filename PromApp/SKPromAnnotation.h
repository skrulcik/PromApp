//
//  SKPromAnnotation.h
//  PromApp
//
//  Created by Scott Krulcik on 7/23/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "SKProm.h"

@interface SKPromAnnotation : NSObject <MKAnnotation> {
    CLLocationDegrees _latitude;
    CLLocationDegrees _longitude;
}

@property (nonatomic) CLLocationDegrees latitude;
@property (nonatomic) CLLocationDegrees longitude;
@property (nonatomic) SKProm *prom;

- (id)initWithLatitude:(CLLocationDegrees)latitude
andLongitude:(CLLocationDegrees)longitude;

@end
