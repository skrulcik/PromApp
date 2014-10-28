//
//  SKAddPromViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
//  Datepicker code based on Apple DateCell Tutorial
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "SKProm.h"

@class AbstractActionSheetPicker;
@interface SKAddPromViewController : UIViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate, UITableViewDataSource, UITableViewDelegate>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic, getter=promImageView) UIImageView *promImageView;
@property (weak, nonatomic) NSDate *promTime;
@property SKProm *prom;

- (id) initForCreation;
- (id) initForProm:(SKProm *) prom;
- (void) populateImage;
- (IBAction)addImage:(id)sender;
- (IBAction)showImagePickerForCamera:(id)sender;
- (IBAction)showImagePickerForPhotoPicker:(id)sender;
- (void) savePromWithCompletion:(void (^)(BOOL success))completion;
@end
