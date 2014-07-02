//
//  UITPromFinderViewController.h
//  UITester
//
//  Created by Scott Krulcik on 6/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface UITPromFinderViewController : UIViewController <MKMapViewDelegate>

@property (nonatomic, strong) IBOutlet MKMapView *map;

- (void)viewWillAppear:(BOOL)animated;

@end
