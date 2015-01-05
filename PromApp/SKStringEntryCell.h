//
//  SKTableViewCell.h
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SKStringEntryCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *field;
@property NSString *key;
@end
