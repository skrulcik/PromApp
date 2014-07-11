//
//  SKProfileViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKProfileViewController.h"
#import "SKLoginViewController.h"

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
}

- (void) viewDidAppear:(BOOL)animated
{
    if(![PFUser currentUser]){
        [self showLoginScreen];
    }
}

- (void) updateData
{
    if([PFUser currentUser]){
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
                
                [usernameLabel setText:name];
                [emailLabel setText:email];
            }
        }];
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


//The following handle retrieving the profile photo
// Called every time a chunk of the data is received
- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [_imageData appendData:data]; // Build the image
}

// Called when the entire image is finished downloading
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    // Set the image in the header imageView
    profilePicture.image = [UIImage imageWithData:_imageData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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

@end
