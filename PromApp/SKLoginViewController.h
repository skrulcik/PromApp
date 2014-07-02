//
//  SKLoginViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 6/30/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>

#import <Parse/Parse.h>

@interface SKLoginViewController : UIViewController

@property (nonatomic, strong) IBOutlet UIButton *fBookButton;

- (IBAction)fBookLoginPressed:(id)sender;

@end
