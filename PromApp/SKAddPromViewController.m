//
//  SKAddPromViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/11/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//
//  Thanks to http://stackoverflow.com/users/1397171/mimc for help with displaying datepicker in action sheet
//  and to http://stackoverflow.com/users/1050170/jeremy-fox for providing solution to showing actionsheet in modal window

#import "SKAddPromViewController.h"
#import "ActionSheetDatePicker.h"
#import "SKProm.h"

@interface SKAddPromViewController ()
@property UIActionSheet *pickerSheet;
@property UIDatePicker *datePicker;
@property PFGeoPoint *currentPoint;
@end

@implementation SKAddPromViewController
@synthesize schoolField;
@synthesize addressField;
@synthesize addressField2;
@synthesize locationField;
@synthesize whenField;
@synthesize themeField;
@synthesize promTime;
@synthesize pickerSheet;
@synthesize datePicker;
@synthesize currentPoint;

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

- (void)editDate
{
    self.datePicker = [[UIDatePicker alloc] init];
    UIActionSheet *aac = [[UIActionSheet alloc] initWithTitle:nil
                                                     delegate:self
                                            cancelButtonTitle:nil
                                       destructiveButtonTitle:@"Done"
                                            otherButtonTitles:nil];
    
    
    [datePicker addTarget:self action:@selector(dateChanged) forControlEvents:UIControlEventValueChanged];
    [aac addSubview:datePicker];
    
    UIView *viewBox = nil;
    UIWindow* window = [[[[UIApplication sharedApplication] keyWindow] subviews] lastObject];
    if ([window.subviews containsObject:self.view]) {
        viewBox = self.view;
    } else {
        viewBox = window;
    }
    
    CGFloat wideth = viewBox.frame.size.width;
    CGRect rect = CGRectMake(0,0, wideth, 470);
    [aac showFromRect:rect inView:viewBox animated:YES];
    [aac setBounds:rect];
    [datePicker setBounds:CGRectMake(0,-30, wideth, 400)];
    self.pickerSheet = aac;
    [self dateChanged]; //Fills text box with initial date
    
}

- (void) dateChanged
{
    self.promTime = [self.datePicker date];
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd 'at' HH:mm"];
    self.whenField.text = [dateFormatter stringFromDate:self.promTime];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) savePromWithCompletion:(void (^)(BOOL success))completion{
    //Retrieve information
    NSString *school = self.schoolField.text;
    NSString *address = [NSString stringWithFormat:@"%@ %@", self.addressField.text, self.addressField2.text];
    NSString *location = self.locationField.text;
    NSString *time = self.whenField.text;
    NSString *theme = self.themeField.text;
    
    //Before parsing address, make sure required fields are filled out
    if([school  isEqual:@""]){
        //Notify user that a school name is required
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete" message:@"Please enter a school name." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        completion(NO);
    }else if([address  isEqual:@""]){
        //Notify user that address field must be complete
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Incomplete" message:@"Please enter a valid address." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
        [alert show];
        completion(NO);
    }else{
        //All required fields are filled in
        self.currentPoint = nil;//Clear so if addressfield has changed but cannot be decoded, we don't save last address
        CLGeocoder *gcoder = [[CLGeocoder alloc] init];
        [gcoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error){
            //Keep entire save sequence in block, otherwise it will run before address is parsed
            if(error || [placemarks count]==0){
                NSLog(@"Error parsing address:\n %@", error);
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error Retrieving Address" message:@"Verify address information and check network connection." delegate:nil cancelButtonTitle:@"Okay" otherButtonTitles:nil, nil];
                [alert show];
                completion(NO);
            } else {
                CLPlacemark *placemark = [placemarks lastObject];
                self.currentPoint = [PFGeoPoint geoPointWithLatitude:placemark.location.coordinate.latitude
                                                           longitude:placemark.location.coordinate.longitude];
                SKProm *prom = [[SKProm alloc] init];
                prom.schoolName = school;
                prom.address = address;
                prom.locationDescription = location;
                prom.theme = theme;
                prom.time = time;
                prom.preciseLocation = self.currentPoint;
                
                [prom saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
                    if (succeeded){
                        NSLog(@"Succeeded in saving %@ prom", prom.schoolName);
                        NSLog(@"PromID: %@", prom.objectId);
                        completion(YES);
                    } else {
                        NSLog(@"Failed in saving %@ dress", prom.schoolName);
                        completion(NO);
                    }
                }];
            }
        }];
    }
}

- (IBAction)doneButtonPressed:(id)sender
{
    [self savePromWithCompletion:^(BOOL success){
        if(success){
            [self performSegueWithIdentifier:@"finishedAddingProm" sender:self];
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

#pragma mark UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    if(textField == self.whenField){
        for (UIView *subView in self.view.subviews) {
            if ([subView isFirstResponder]) {
                //Without this, last open keyboard remains open
                [subView resignFirstResponder];
            }
        }
        [self editDate];
        return NO;
    }else{
        return YES;
    }
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
