//
//  UITPromFinderViewController.m
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromFinderViewController.h"


@interface UITPromFinderViewController ()

@end

@implementation UITPromFinderViewController

@synthesize map;

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
    self.map.delegate = self;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillAppear:(BOOL)animated
{
    CLLocationCoordinate2D toga = CLLocationCoordinate2DMake(43.080725, -73.785757);
    
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(toga, 800, 800);
    [self.map setRegion:[self.map regionThatFits:region] animated:YES];
    
    MKPointAnnotation *point = [[MKPointAnnotation alloc] init];
    point.coordinate = toga;
    point.title = @"The Shoppe";
    point.subtitle = @"I'm here!!!";
    
    [self.map addAnnotation:point];
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
