//
//  SKProfileViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface SKProfileViewController : UIViewController <NSURLConnectionDataDelegate>
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;

- (void) updateData;
- (void) clearData;
- (void) showLoginScreen;
- (IBAction)logoutUser:(id)sender;
@end
