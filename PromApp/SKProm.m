//
//  SKProm.m
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKProm.h"
#import <Parse/PFObject+Subclass.h>

@implementation SKProm
@dynamic schoolName;
@dynamic address;
@dynamic locationDescription;
@dynamic time;
@dynamic theme;
@dynamic dresses;
@dynamic preciseLocation;

- (BOOL) equalTo:(SKProm*)other
{
    if ([self.schoolName isEqualToString:other.schoolName])
    {
        return YES;
    } else{
        return NO;
    }
}

+ (NSString *)parseClassName
{
    return @"Prom";
}

-(NSString *)readableInfo
{
    NSString *info=[NSString stringWithFormat:@"School:%@\nAddress:%@\nLocation:%@\nTime:%@\nTheme:%@\nDresses:%@\nCoordinates:\n%f\n%f",
                    self.schoolName, self.address, self.locationDescription, self.time, self.theme, self.dresses, self.preciseLocation.latitude, self.preciseLocation.longitude];
    return info;
}

@end
