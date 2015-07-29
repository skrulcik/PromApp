//
//  SKAppDelegate.m
//  PromApp
//
//  Created by Scott Krulcik on 6/30/14.
//  Copyright (c) 2014 ___FULLUSERNAME___. All rights reserved.
//

#import "SKAppDelegate.h"
#import "PromApp-Swift.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <Parse/Parse.h>
#import <ParseFacebookUtilsV4/PFFacebookUtils.h>

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation SKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Parse initialization
    [SKDress registerSubclass];
    [SKProm registerSubclass];
    [SKStore registerSubclass];
	[Parse setApplicationId:@"PJq63qVW5giu8JBkupPxHADBgSpMEEX87QlZjDlg"
                  clientKey:@"cxqrUMU3wX4UA67IvLgqv0aT78dhVY1DT3w8LWIt"];
    // Facebook initialization
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    //Navigation Bar
    // Set the global tint on the navigation bar
    UIColor *navBarColor = [SKColor NavBar];//UIColorFromRGB(0xFF7094); //UIColorFromRGB(0xFF8BE2);
    UIColor *buttonColor = [SKColor white];
	[[UINavigationBar appearance] setTintColor:buttonColor];
    [[UINavigationBar appearance] setBarTintColor:navBarColor];
    [[UINavigationBar appearance] setTranslucent:NO];
    NSShadow* shadow = [NSShadow new];
    UIFont *titlefont = [UIFont fontWithName:@"Rochester" size:32.0f];
    [[UINavigationBar appearance] setTitleTextAttributes: @{
                                                            NSForegroundColorAttributeName: buttonColor,
                                                            NSFontAttributeName: titlefont,
                                                            NSShadowAttributeName: shadow
                                                            }];
    [[UITabBar appearance] setTintColor:[SKColor TabBarHighlight]];
    [self.window setTintColor:navBarColor];
    
    // Set global fonts
    [[UIButton appearance] setFont:[UIFont smallFont]];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    //attempt to retrieve previous facebook session (stored by Parse)
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
