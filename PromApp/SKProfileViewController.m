//
//  SKProfileViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKProfileViewController.h"
#import "SKLoginViewController.h"
#import <ParseFacebookUtils/PFFacebookUtils.h>

@interface SKProfileViewController ()

@end

@implementation SKProfileViewController
@synthesize usernameLabel;
@synthesize emailLabel;
@synthesize profilePicture;

NSMutableData *_imageData;

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
    [self updateData];
    self.profilePicture.layer.cornerRadius = self.profilePicture.frame.size.width / 2;
    self.profilePicture.clipsToBounds = YES;
}

- (void) viewDidAppear:(BOOL)animated
{
    if(![PFUser currentUser]){
        [self showLoginScreen];
    }
}

- (void) updateData
{
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        if([PFFacebookUtils isLinkedWithUser:currentUser]){
            // Create request for user's Facebook data
            FBRequest *request = [FBRequest requestForMe];

            // Send request to Facebook
            [request startWithCompletionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
                if (!error) {
                    // result is a dictionary with the user's Facebook data
                    NSDictionary *userData = (NSDictionary *)result;
                    
                    NSString *facebookID = userData[@"id"];
                    NSString *name = userData[@"name"];
                    NSString *email = userData[@"email"];
                    
                    // Download the user's facebook profile picture
                    _imageData = [[NSMutableData alloc] init]; // the data will be loaded in here
                    
                    // URL should point to https://graph.facebook.com/{facebookId}/picture?type=large&return_ssl_resources=1
                    NSURL *pictureURL = [NSURL URLWithString:[NSString stringWithFormat:@"https://graph.facebook.com/%@/picture?type=large&return_ssl_resources=1", facebookID]];
                    
                    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:pictureURL
                                                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                                          timeoutInterval:2.0f];
                    // Run network request asynchronously
                    NSURLConnection *urlConnection = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self];
                    self.usernameLabel.text = name;
                    self.emailLabel.text = email;
                }
            }];
        } else {
            self.usernameLabel.text = currentUser.username;
            self.emailLabel.text = currentUser.email;
        }
    } else {
        [self clearData];
    }
}

- (void) showLoginScreen
{
    [self.parentViewController performSegueWithIdentifier:@"showLogin" sender:self];
}

- (IBAction)logoutUser:(id)sender {
    [PFUser logOut];
    NSLog(@"Logged out user.");
    [self showLoginScreen];
}

- (void) clearData
{
    [usernameLabel setText:@"User Name"];
    [emailLabel setText:@"email"];
    profilePicture.image = [UIImage imageNamed:@"FBBlankProfilePhoto"];
    
}


#pragma mark - NSURLConnectionDataDelegate
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_imageData appendData:data]; // Build the image
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    UIImage *image = [UIImage imageWithData:_imageData];
    profilePicture.image = image;
}
@end
