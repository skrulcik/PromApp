//
//  SKDress.h
//  PromApp
//  An extension of PFObject, the Dress object stores the information necessary to identify a particular dress (designer, style number),
//  as well as connecting it to a user object. In the future it will also hold associations to Prom and Store objects.
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>
#import "SKProm.h"

@interface SKDress : PFObject <PFSubclassing>

@property PFUser *owner;
@property PFUser *store;
@property NSString *designer;
@property NSString *styleNumber;
@property NSString *dressColor;
@property SKProm *prom;
@property PFFile *image;

+ (NSString *)parseClassName;
- (BOOL) isSimilar:(SKDress *)dress;

@end
