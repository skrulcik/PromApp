//
//  SKAddDressViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
#import "SKDress.h"
#import "SKProm.h"

@interface SKAddDressViewController : UITableViewController <UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextFieldDelegate>//, UITableViewDataSource, UITableViewDelegate>

//@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *cancelButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *doneButton;
@property (weak, nonatomic, getter=dressImageView) UIImageView *dressImageView;
@property SKDress *dress;

- (void) setupForCreation;
- (void) setupWithDress:(SKDress *)dressObject;
- (IBAction)addImage:(id)sender;
- (IBAction)showImagePickerForCamera:(id)sender;
- (IBAction)showImagePickerForPhotoPicker:(id)sender;
- (IBAction)unwindFromSelectProm:(UIStoryboardSegue *)segue;
@end
