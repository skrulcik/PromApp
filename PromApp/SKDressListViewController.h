//
//  SKDressListViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/10/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKDressListViewController : UIViewController <UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *dressListView;
@property (nonatomic, strong) NSMutableArray *dressObjects;
-(void) loadDressInfo;
@end
