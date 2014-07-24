//
//  SKPromDetailViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SKProm.h"

@interface SKPromDetailViewController : UITableViewController
@property (strong, nonatomic) IBOutlet UITableView *table;
@property SKProm *prom;
@end
