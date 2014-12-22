//
//  SKMainTabViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKMainTabViewController.h"
#import "SKAddDressViewController.h"
#import "SKAddPromViewController.h"
#import "SKProfileViewController.h"
#import "SKLoginViewController.h"

@interface SKMainTabViewController ()

@end

@implementation SKMainTabViewController
@synthesize addDressButton;

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
    //self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"cog"] style:UIBarButtonItemStylePlain target:self action:nil];
    //UIImageView *title = [[UIImageView alloc] initWithFrame:CGRectMake(0, -64, 245, 44)];
    //title.image = [UIImage imageNamed:@"WhiteNavTitle"];
    //self.navigationItem.titleView = title;
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
- (IBAction)showAddOptionPane:(id)sender {
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:nil
                                 message:nil
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* addDressAction = [UIAlertAction
                         actionWithTitle:@"Add Dress"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             //Do some thing here
                             [view dismissViewControllerAnimated:YES completion:nil];
                             [self performSegueWithIdentifier:@"NewDress" sender:self];
                             //SKAddDressViewController *newDress = [[SKAddDressViewController alloc] initForCreation];
                             //[newDress setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                             //[self presentViewController:newDress animated:YES completion:nil];
                         }];
    UIAlertAction* findPromAction = [UIAlertAction
                                     actionWithTitle:@"Find a Prom"
                                     style:UIAlertActionStyleDefault
                                     handler:^(UIAlertAction * action)
                                     {
                                         //Do some thing here
                                         NSLog(@"Would have searched for prom.");
                                         [view dismissViewControllerAnimated:YES completion:nil];
                                         SKAddPromViewController *newProm = [[SKAddPromViewController alloc] initForCreation];
                                         [newProm setModalTransitionStyle:UIModalTransitionStyleFlipHorizontal];
                                         [self presentViewController:newProm animated:YES completion:nil];
                                         
                                     }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    
    [view addAction:addDressAction];
    [view addAction:findPromAction];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (IBAction) unwindFromLogin:(UIStoryboardSegue *)segue
{
    ProfileController *profile = (ProfileController *)self.viewControllers[0];
    [profile updateUserData:[PFUser currentUser]];
}

- (IBAction) unwindFromAddProm:(UIStoryboardSegue *)segue
{
    
}

/*
#pragma mark Utility Methods
+ (UIImage *)navBackgroundWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 640.f, 88.f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}*/

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
