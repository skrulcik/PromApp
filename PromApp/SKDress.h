//
//  SKDress.h
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>

@interface SKDress : PFObject

@property PFUser *owner;
@property PFUser *store;
@property NSString *designer;
@property NSString *styleNumber;
@property UIColor *dressColor;
@property UIImage *image;

@end
