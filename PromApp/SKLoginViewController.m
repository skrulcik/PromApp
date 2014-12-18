//
//  SKLoginViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 6/30/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKLoginViewController.h"
#import "SKStoreEditorTableController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SKLoginViewController ()

@end

@implementation SKLoginViewController

@synthesize fBookButton;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


/* Updates user profile with latest information from facebook
 */
- (void) updateFacebookProfile:(PFUser *)parseUser{
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 if(user != NULL){
                     [parseUser setObject:user forKey:@"profile"];
                 }
             } else {
                 NSLog(@"Error retrieving facebook data: %@", error);
             }
         }];
    } else {
        NSLog(@"no active session");
    }
}

- (IBAction)fBookLoginPressed:(id)sender {
    NSArray *permissions = @[ @"public_profile", @"email", @"user_friends"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"%@", [error description]);
            NSLog(@"Uh oh. The user cancelled the Facebook login.");
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook!");
            //TODO: open account creation screen
            [self performSegueWithIdentifier:@"finishLogin" sender:self];
        } else {
            NSLog(@"User logged in through Facebook!");
            [self updateFacebookProfile:[PFUser currentUser]];
            [self performSegueWithIdentifier:@"finishLogin" sender:self];
        }
    }];
}
@end
