//
//  SKProm.m
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKProm.h"
#import <Parse/PFObject+Subclass.h>
#import "SKDress.h"

@implementation SKProm
@dynamic image;
@dynamic schoolName;
@dynamic address;
@dynamic locationDescription;
@dynamic time;
@dynamic theme;
@dynamic preciseLocation;

+ (NSArray *)requiredKeys{
    return @[@"locationDescription",@"schoolName",@"address"];
}
+ (NSString *)parseClassName
{
    return @"Prom";
}

+ (SKProm *)defaultProm{
    SKProm *prom = [[SKProm alloc] init];
    prom.schoolName = @"School Name";
    prom.address = @"School address";
    prom.locationDescription = @"Description";
    prom.time = @"Prom Time";
    prom.theme = @"Prom theme";
    prom.preciseLocation = [[PFGeoPoint alloc] init];
    return prom;
}

- (BOOL) equalTo:(SKProm*)other
{
    if ([self.schoolName isEqualToString:other.schoolName])
    {
        return YES;
    } else{
        return NO;
    }
}

-(NSString *)readableInfo
{
    NSString *info=[NSString stringWithFormat:@"School:%@\nAddress:%@\nLocation:%@\nTime:%@\nTheme:%@\nCoordinates:\n%f\n%f",
                    self.schoolName, self.address, self.locationDescription, self.time, self.theme, self.preciseLocation.latitude, self.preciseLocation.longitude];
    return info;
}

- (BOOL) verifyDesigner:(NSString *)designer withStyle:(NSString *)styleNumber{
    // Query against for similar dresses in this prom
    PFQuery *q = [[PFQuery alloc] initWithClassName:[SKDress parseClassName]];
    [q whereKey:@"prom" equalTo:self];
    // Use search optimized strings for designer and styleNo
    [q whereKey:@"designerSearch" containsString:designer];
    [q whereKey:@"styleNumberSearch" equalTo:styleNumber];
    long num_matches = [q countObjects];
    NSLog(@"Found %ld matches for %@ %@. \n", num_matches, designer, styleNumber);
    return num_matches == 0;
}

@end
