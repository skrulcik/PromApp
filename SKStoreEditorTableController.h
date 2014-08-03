//
//  SKStoreEditorTableController.h
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SKStore.h"


@interface SKStoreEditorTableController :UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
@property SKStore *store;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
- (id)initForCreation;
- (id)initForStore:(SKStore *)storeObject ;
@end
