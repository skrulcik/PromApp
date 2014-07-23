//
//  SKAddPromViewController.h
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
//  Datepicker code based on StackOverflow answers from tomi2711 and adamdehaven
//

#import <UIKit/UIKit.h>
#import "AbstractActionSheetPicker.h"
#import <CoreLocation/CoreLocation.h>

@class AbstractActionSheetPicker;
@interface SKAddPromViewController : UIViewController <UITextFieldDelegate, UIActionSheetDelegate>

@property (weak, nonatomic) IBOutlet UITextField *schoolField;
@property (weak, nonatomic) IBOutlet UITextField *addressField;
@property (weak, nonatomic) IBOutlet UITextField *addressField2;
@property (weak, nonatomic) IBOutlet UITextField *locationField;
@property (weak, nonatomic) IBOutlet UITextField *whenField;
@property (weak, nonatomic) IBOutlet UITextField *themeField;
@property (weak, nonatomic) NSDate *promTime;
- (void) editDate;
- (void) savePromWithCompletion:(void (^)(BOOL success))completion;
- (void) dateChanged;
@end
