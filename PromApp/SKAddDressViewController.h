//
//  SKAddDressViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"

@interface SKAddDressViewController : UIViewController <UINavigationControllerDelegate, MBProgressHUDDelegate>
{
    //For loading symbols
    MBProgressHUD *HUD;
    MBProgressHUD *refreshHUD;
    UIImage *dressImage;
}

@property (weak, nonatomic) IBOutlet UITextField *designerField;
@property (weak, nonatomic) IBOutlet UITextField *styleNumberField;
@property (weak, nonatomic) IBOutlet UIButton *imageButton;
@property (weak, nonatomic) IBOutlet UIImageView *dressImageView;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *verifyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;

- (IBAction)addImage:(id)sender;
@end
