//
//  SKStore.m
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKStore.h"

@implementation SKStore
@dynamic address;
@dynamic derivedLocation;
@dynamic dressesSold;
@dynamic dressInventory;
@dynamic proms;
@dynamic description;
@dynamic profilePic;
@dynamic hours;


-(void)readableStoreInformation
{
    NSDictionary *info = [self dictionaryWithValuesForKeys:@[@"username", @"password"]];
    for(NSString *key in info){
        NSLog(@"%@:  %@", key, info[key]);
    }
}

@end
