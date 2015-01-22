//
//  SKLoginViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 6/30/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKLoginViewController.h"
#import <Parse/Parse.h>
#import <ParseFacebookUtils/PFFacebookUtils.h>
#import "PromApp-Swift.h"

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
- (void) updateFacebookProfile:(PFUser *)parseUser withBlock:(void (^)(void))callbackBlock{
    //TODO: if connection unavailable: 1) Show alert 2) Check if profile already available
    if (FBSession.activeSession.isOpen) {
        [[FBRequest requestForMe] startWithCompletionHandler:
         ^(FBRequestConnection *connection, NSDictionary<FBGraphUser> *user, NSError *error) {
             if (!error) {
                 if(user != NULL && [parseUser objectForKey:@"email"] == nil){
                     [parseUser setObject:user forKey:@"profile"];
                     [parseUser setObject:user[@"email"] forKey:@"email"];
                     [parseUser setObject:user[@"email"] forKey:@"username"];
                     [parseUser save]; //Save synchronously
                 }
             } else {
                 NSLog(@"Error retrieving facebook data: %@", error);
             }
             callbackBlock();
         }];
    } else {
        NSLog(@"no active session");
    }
}

// MARK: Security
- (void) setAppPermissionsForUser:(PFUser *)user {
    if(user != NULL){
        NSLog(@"Setting default ACL for user %@.", user.objectId);
        PFACL *acl = [PFACL ACL];
        [acl setPublicReadAccess:YES];
        [acl setPublicWriteAccess:NO];
        [acl setWriteAccess:true forUser:user];
        [PFACL setDefaultACL:acl withAccessForCurrentUser:YES];
    } else {
        NSLog(@"Attempted to set ACL for non-existant user.");
    }
}


// MARK: Button handlers
- (IBAction)fBookLoginPressed:(id)sender {
    NSArray *permissions = @[ @"public_profile", @"email", @"user_friends"];
    [PFFacebookUtils logInWithPermissions:permissions block:^(PFUser *user, NSError *error) {
        if (!user) {
            NSLog(@"The user cancelled the Facebook login.");
            NSLog(@"%@", [error description]);
        } else if (user.isNew) {
            NSLog(@"User signed up and logged in through Facebook.");
            //TODO: open account creation screen
            [self setAppPermissionsForUser:user];
            [self updateFacebookProfile:user withBlock:^{
                [self performSegueWithIdentifier:@"finishLogin" sender:self];
            }];
        } else {
            NSLog(@"User logged in through Facebook.");
            if([PFUser currentUser] != NULL){
                [self setAppPermissionsForUser:[PFUser currentUser]];
                [self updateFacebookProfile:[PFUser currentUser] withBlock:^{
                    [self performSegueWithIdentifier:@"finishLogin" sender:self];
                }];
            }
        }
    }];
}

- (IBAction)emailLoginPressed:(id)sender {
    UIAlertController *login_alert = [self loginControllerWithMessage:@""];
    [self presentViewController:login_alert animated:YES completion:nil];
}


// MARK: Login & Signup controllers
- (UIAlertController *) loginControllerWithMessage:(NSString *)message
{
    UIAlertController *loginWindow= [UIAlertController
                               alertControllerWithTitle:@"Email Login"
                               message:message
                               preferredStyle:UIAlertControllerStyleAlert];
    loginWindow.view.tintColor = [SKColor triadBlue];
    
    /* Create two separate actions:
     * 1. Login-> go directly to email login
     *      Only ask about forgotten password if login fails
     * 2. Signup-> add name field, just accept password
     */
    UIAlertAction *login = [UIAlertAction actionWithTitle:@"Login"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      NSLog(@"Would have logged in user");
//TODO: Login with email
                                                      if(loginWindow.textFields.count >= 2){
                                                          UITextField *emailField = loginWindow.textFields[0];
                                                          NSString *email = emailField.text;
                                                          UITextField *passField = loginWindow.textFields[1];
                                                          NSString *pass = passField.text;
                                                          NSLog(@"Logging in user with username %@", email);
                                                          
                                                          // Ensure required fields are completed
                                                          if(email == nil || [email isEqualToString:@""]){
                                                              // Email incomplete, show login screen again with email prompt
                                                              UIAlertController *enterEmail = [self loginControllerWithMessage:@"Please enter an email address."];
                                                              [self presentViewController:enterEmail animated:YES completion:nil];
                                                          }
                                                          if(pass == nil || [pass isEqualToString:@""]){
                                                              // No password entered, show login again with email prompt
                                                              UIAlertController *enterPass = [self loginControllerWithMessage:@"Please enter a password."];
                                                              if(enterPass.textFields.count ==2){
                                                                  UITextField *emailField = enterPass.textFields[0];
                                                                  emailField.text = email;
                                                              }
                                                              [self presentViewController:enterPass animated:YES completion:nil];
                                                          }
                                                          
                                                          [PFUser logInWithUsernameInBackground:email password:pass block:^(PFUser *user, NSError *error){
                                                              if(!error){
                                                                  // Successful login
                                                                  [self setAppPermissionsForUser:user]; // Proper ACLs for object creation
                                                                  [self performSegueWithIdentifier:@"finishLogin" sender:self];
                                                              } else {
                                                                  NSLog(@"Error logging in user %@. %@", email, error.description);
                                                                  // Show error dialog
                                                                  [self showLoginError:[error userInfo][@"error"]];
                                                              }
                                                          }];
                                                      } else {
                                                          NSLog(@"Login page error. Login textboxes could not be found.");
                                                      }
                                                  }];
    UIAlertAction *signup = [UIAlertAction actionWithTitle:@"Create Account"
                                                    style:UIAlertActionStyleDefault
                                                  handler:^(UIAlertAction *action){
                                                      // This window will close, so open a new signup window
                                                      NSString *email;
                                                      NSString *pass;
                                                      if(loginWindow.textFields.count >= 2){
                                                          //Fill in with existing information if possible
                                                          UITextField *emailField = loginWindow.textFields[0];
                                                          email = emailField.text;
                                                          UITextField *passField = loginWindow.textFields[1];
                                                          pass = passField.text;
                                                      }
                                                      UIAlertController *signup = [self signUpControllerWithEmail:email pass:pass message:nil];
                                                      [self presentViewController:signup animated:YES completion:nil];
                                                  }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                   }];
    
    // First add actions to login dialog
    [loginWindow addAction: login];
    [loginWindow addAction: signup];
    [loginWindow addAction: cancel];
    
    // Next add text fields for email and password (name field only if needed)
    [loginWindow addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"user@example.com";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
    }];
    [loginWindow addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.secureTextEntry = YES;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
    }];
    
    return loginWindow;
}

/* Creates signup controller, and fills in fields with existing information. */
- (UIAlertController *) signUpControllerWithEmail:(NSString *)email pass:(NSString *)password message:(NSString *) message
{
    UIAlertController *signupWindow= [UIAlertController
                                     alertControllerWithTitle:@"Email Login"
                                     message:message
                                     preferredStyle:UIAlertControllerStyleAlert];
    signupWindow.view.tintColor = [SKColor triadBlue];
    
    /* Signup handler attempts to sign up through Parse
     * Also handles any possible issues, including
     * "forgot password" via login failure alert
     */
    UIAlertAction *signup = [UIAlertAction actionWithTitle:@"Register Account"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       if(signupWindow.textFields.count == 3){
                                                           // Gather data from alert sign up controller
                                                           UITextField *nameField = signupWindow.textFields[0];
                                                           NSString *name = nameField.text;
                                                           UITextField *emailField = signupWindow.textFields[1];
                                                           NSString *email = emailField.text;
                                                           UITextField *passField = signupWindow.textFields[2];
                                                           NSString *pass = passField.text;
                                                           NSLog(@"Logging in user with username %@", email);
                                                           
                                                           // Ensure all required fields are filled out
                                                           if(name == nil || [name isEqualToString:@""]){
                                                               // Show signup window again, with email prompt
                                                               UIAlertController *enterName = [self signUpControllerWithEmail:email
                                                                                                                         pass:pass
                                                                                                                      message:@"Please enter a name."];
                                                               [self presentViewController:enterName animated:YES completion:nil];
                                                           }
                                                           if(email == nil || [email isEqualToString:@""]){
                                                               // Show signup window again, with email prompt
                                                               UIAlertController *enterEmail = [self signUpControllerWithEmail:email
                                                                                                                          pass:pass
                                                                                                                       message:@"Please enter an email address."];
                                                               [self presentViewController:enterEmail animated:YES completion:nil];
                                                           }
                                                           if(pass == nil || [pass isEqualToString:@""]){
                                                               // No password, show signup window with password prompt
                                                               UIAlertController *enterPass = [self signUpControllerWithEmail:email
                                                                                                                         pass:pass
                                                                                                                      message:@"Please enter a password."];
                                                               if(enterPass.textFields.count ==2){
                                                                   UITextField *emailField = enterPass.textFields[0];
                                                                   emailField.text = email;
                                                               }
                                                               [self presentViewController:enterPass animated:YES completion:nil];
                                                           }
                                                           
                                                           // Create blank user object
                                                           PFUser *user = [PFUser user];
                                                           // Initial login information
                                                           user.username = email;
                                                           user.password = pass;
                                                           user.email = email;
                                                           // Profile stores data to maintain consistency with facebook
                                                           NSDictionary *profile = @{@"name":name, @"email":email};
                                                           [user setObject:profile forKey:@"profile"];
                                                           
                                                           
                                                           [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                                                               if (!error) {
                                                                   // Successful login
                                                                   NSLog(@"Created account for user %@ with email %@", user.objectId, email);
                                                                   [self setAppPermissionsForUser:user]; // Proper ACLs for object creation
                                                                   [self performSegueWithIdentifier:@"finishLogin" sender:self];
                                                               } else {
                                                                   NSLog(@"Error logging in user %@. %@", email, error.description);
                                                                   // Show error dialog
                                                                   [self showLoginError:[error userInfo][@"error"]];
                                                               }
                                                           }];
                                                       } else {
                                                           NSLog(@"Create account page error. Sign up textboxes could not be found.");
                                                       }
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                   }];
    
    // First add actions to login dialog
    [signupWindow addAction: cancel];
    [signupWindow addAction: signup];
    
    // Next add text fields for email and password (name field only if needed)
    [signupWindow addTextFieldWithConfigurationHandler:^(UITextField *textField){
        textField.placeholder = @"Your Name";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
    }];
    [signupWindow addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"user@example.com";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
        if( email != nil && ![@"" isEqualToString:email]){
            textField.text = email;
        }
    }];
    [signupWindow addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"password";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.secureTextEntry = YES;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
        if( password != nil && ![@"" isEqualToString:password]){
            textField.text = password;
        }
    }];
    
    return signupWindow;
}

// MARK: Password reset
/* Presents a modal alert for the user to enter their email,
 * then performs a password reset via parse.
 */
- (void) passwordResetRequest {
    
    UIAlertController *verifyWindow= [UIAlertController
                                      alertControllerWithTitle:@"Reset Password"
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleAlert];
    verifyWindow.view.tintColor = [SKColor triadBlue];
    
    UIAlertAction *verify = [UIAlertAction actionWithTitle:@"Reset"
                                                     style:UIAlertActionStyleDefault
                                                   handler:^(UIAlertAction *action){
                                                       if(verifyWindow.textFields.count == 1){
                                                           // Gather data from alert sign up controller
                                                           UITextField *emailField = verifyWindow.textFields[0];
                                                           NSString *email = emailField.text;
                                                           NSLog(@"Creating new password for user with username %@", email);
                                                           
                                                           // Ensure all required fields are filled out
                                                           if(email == nil || [email isEqualToString:@""]){
                                                               // Show signup window again, with email prompt
                                                               [self showResetError:@"Please enter an email address."];
                                                           } else {
                                                               // Create new password request for user
                                                               [PFUser requestPasswordResetForEmailInBackground:email block:^(BOOL succeeded, NSError *error){
                                                                   if(succeeded){
                                                                       NSLog(@"Successfully sent password request to %@", email);
                                                                       UIAlertController *successController = [UIAlertController alertControllerWithTitle:@"Email sent!"
                                                                                                                                                  message:@"It should appear in your inbox soon." preferredStyle:UIAlertControllerStyleAlert];
                                                                       [successController addAction:[UIAlertAction actionWithTitle:@"Okay"
                                                                                                                             style:UIAlertActionStyleCancel
                                                                                                                           handler:nil]];
                                                                       [self presentViewController:successController
                                                                                          animated:YES
                                                                                        completion:nil];
                                                                   } else {
                                                                       NSLog(@"Error logging in user %@. %@", email, error.description);
                                                                       // Show error dialog
                                                                       [self showResetError:[error userInfo][@"error"]];
                                                                   }
                                                               }];
                                                           }
                                                           
                                                       } else {
                                                           NSLog(@"Reset password page error. Textboxes could not be found.");
                                                       }
                                                   }];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel"
                                                     style:UIAlertActionStyleCancel
                                                   handler:^(UIAlertAction *action){
                                                   }];
    
    // First add actions to login dialog
    [verifyWindow addAction: cancel];
    [verifyWindow addAction: verify];
    
    // Next add text field for email
    [verifyWindow addTextFieldWithConfigurationHandler:^(UITextField *textField) {
        textField.placeholder = @"user@example.com";
        textField.keyboardType = UIKeyboardTypeDefault;
        textField.clearsOnBeginEditing = NO;
        textField.borderStyle = UITextBorderStyleRoundedRect;
        if(textField.superview){
            textField.superview.superview.layer.borderWidth = 0.75f;
            textField.superview.superview.layer.borderColor = [SKColor white].CGColor;
        }
    }];
    
    [self presentViewController:verifyWindow animated:YES completion:nil];

}

// MARK: Error Dialogs
/* Generic method to make error messages a one-liner */
- (void) showLoginError {
    [self showLoginError:@"Could not complete login."];
}
- (void) showLoginError:(NSString *)message{
    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Login Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    error.view.tintColor = [SKColor triadBlue];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    UIAlertAction *forgotPassword = [UIAlertAction actionWithTitle:@"Forgot Password?"
                                                             style:UIAlertActionStyleDefault
                                                           handler:^(UIAlertAction *alertAction){
                                                               [self passwordResetRequest];
                                                           }];
    
    [error addAction:forgotPassword];
    [error addAction:cancel];
    [self presentViewController:error animated:YES completion:nil];
}
- (void) showResetError:(NSString *)message{
    UIAlertController *error = [UIAlertController alertControllerWithTitle:@"Password Reset Error"
                                                                   message:message
                                                            preferredStyle:UIAlertControllerStyleAlert];
    error.view.tintColor = [SKColor triadBlue];
    UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Okay"
                                                     style:UIAlertActionStyleCancel
                                                   handler:nil];
    [error addAction:cancel];
    [self presentViewController:error animated:YES completion:nil];
}
@end
