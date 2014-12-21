//
//  SKMainTabViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PromApp-Swift.h"

@interface SKMainTabViewController : UITabBarController
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addDressButton;

- (IBAction) unwindFromLogin:(UIStoryboardSegue *) segue;
- (IBAction) unwindFromAddProm:(UIStoryboardSegue *) segue;
//+ (UIImage *)navBackgroundWithColor:(UIColor *)color;

@end
