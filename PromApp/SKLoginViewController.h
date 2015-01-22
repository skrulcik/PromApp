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
@property (weak, nonatomic) IBOutlet UITextField *emailField;
@property (weak, nonatomic) IBOutlet UITextField *pwdField;
@property (weak, nonatomic) IBOutlet UIButton *loginButt;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createUserButt;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createStoreButt;

- (IBAction)fBookLoginPressed:(id)sender;
- (IBAction)emailLoginPressed:(id)sender;

@end
