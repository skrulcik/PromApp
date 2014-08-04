//
//  SKImageEditorCell.h
//  PromApp
//
//  Created by Scott Krulcik on 8/3/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SKImageEditorCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet PFImageView *imageView;
@property NSString *key;

@end
