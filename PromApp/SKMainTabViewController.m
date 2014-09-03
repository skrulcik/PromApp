//
//  SKMainTabViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKMainTabViewController.h"
#import "SKDressListViewController.h"
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction) unwindFromLogin:(UIStoryboardSegue *)segue
{
    SKProfileViewController *profile = (SKProfileViewController *)self.viewControllers[0];
    [profile updateData];
}

- (IBAction) unwindFromAddDress:(UIStoryboardSegue *)segue
{
    SKDressListViewController *dressList = (SKDressListViewController *)self.viewControllers[1];
    [dressList loadDressInfo];
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
