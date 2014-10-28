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
#import "SKImageEditorCell.h"
#import "SKStringEntryCell.h"
#import "SKMainTabViewController.h"
#import "SKPromQueryController.h"


@interface SKAddPromViewController ()
@property PFGeoPoint *currentPoint;

// keep track which indexPath points to the cell with UIDatePicker
@property (nonatomic, strong) NSIndexPath *datePickerIndexPath;
@property (assign) NSInteger pickerCellRowHeight;
@property (nonatomic, strong) IBOutlet UIDatePicker *pickerView;
@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@end

@implementation SKAddPromViewController{
    BOOL _isNewProm;       //So we know whether we are creating or editing
    BOOL _imageChanged;     //No need to take up bandwith with images if they aren't changed
    NSMutableDictionary *promData;
}

@synthesize currentPoint;
@synthesize cancelButton;
@synthesize doneButton;
@synthesize promImageView;
@synthesize tableView;

static NSArray *keyForRowIndex;
static NSDictionary *readableNames;

- (id) initForCreation{
    self = [self initForProm:[[SKProm alloc] init]];
    _isNewProm = YES;
    return self;
}

- (id)initForProm:(SKProm *)prom
{
    self = [super initWithNibName:@"EditProm" bundle:nil];
    keyForRowIndex = @[@"image",
                       @"schoolName",
                       @"address",
                       @"locationDescription",
                       @"theme",
                       @"time"];
    if(!readableNames){
        readableNames = @{@"image":@"",
                          @"schoolName":@"School Name",
                          @"address":@"School Address",
                          @"locationDescription":@"Prom Venue",
                          @"theme":@"Theme",
                          @"time":@"Time"};
    }
    if(self){
        _isNewProm = NO;
        _imageChanged = NO;
        promData = [[NSMutableDictionary alloc] init];
        self.prom = prom;
    }
    return self;
}

- (id) init
{
    self = [super init];
    return self;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.capturedImages = [[NSMutableArray alloc] init];
    [self.tableView registerNib:[UINib nibWithNibName:@"StringEntryCell" bundle:nil] forCellReuseIdentifier:@"StringEntry"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageEditorCell" bundle:nil] forCellReuseIdentifier:@"ImageEditor"];
}

- (void) alertForRequiredField:(NSString *) fieldName
{
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"Missing Required Field"
                                 message:[NSString stringWithFormat:@"Please enter a value for %@.", [SKAddPromViewController readableNameForKey:fieldName]]
                                 preferredStyle:UIAlertControllerStyleAlert];

    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Okay"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                             }];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
}

- (void) savePromWithCompletion:(void (^)(BOOL success))completion{
    NSArray *cells = [self.tableView visibleCells];
    for (int i=0; i<[cells count]; i++){
        if([@"image" isEqualToString:[SKAddPromViewController keyForRowIndex:i]]){
            //Is image cell
            SKImageEditorCell *imgCell = cells[i];
            UIImage *currentPic = imgCell.imageView.image;
            if(currentPic){
                [promData setObject:currentPic forKey:[SKAddPromViewController keyForRowIndex:i]];
            }
        }else{
            //Is text entry cell
            SKStringEntryCell *txtCell = cells[i];
            NSString *val = txtCell.field.text;
            if([val isEqualToString:@""] || val == nil){
                val = [self.prom objectForKey:[SKAddPromViewController keyForRowIndex:i]];
            }
            if(val)
                [promData setObject:val forKey:[SKAddPromViewController keyForRowIndex:i]];
        }
    }
    
    
    //Before parsing address, make sure required fields are filled out
    if([promData[@"schoolName"]  isEqual:@""]){
        //Notify user that a school name is required
        [self alertForRequiredField:@"schoolName"];
    }else if([promData[@"address"]  isEqual:@""]){
        //Notify user that address field must be complete
        [self alertForRequiredField:@"address"];
    }else{
        //All required fields are filled in
        self.currentPoint = nil;//Clear so if addressfield has changed but cannot be decoded, we don't save last address
        CLGeocoder *gcoder = [[CLGeocoder alloc] init];
        [gcoder geocodeAddressString:promData[@"address"]   completionHandler:^(NSArray *placemarks, NSError *error){
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
                prom.schoolName = promData[@"schoolName"];
                prom.address = promData[@"address"];
                prom.locationDescription = promData[@"locationDescription"];
                prom.theme = promData[@"theme"];
                prom.time = promData[@"time"];
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

#pragma mark - Custom Image Implementation
- (void)populateImage
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            self.promImageView.image = [self.capturedImages objectAtIndex:0];
            NSLog(@"%@", self.promImageView);
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            self.promImageView.animationImages = self.capturedImages;
            self.promImageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.promImageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.promImageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
}

#pragma mark - ImagePicker
- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

- (void) showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.promImageView.isAnimating)
    {
        [self.promImageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self;
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)addImage:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForPhotoPicker:sender];
    } else {
        [self showImagePickerForCamera:sender];
    }
}

#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    NSLog(@"finished picking media");
    [self.capturedImages addObject:image];
    [self populateImage];
    _imageChanged = YES;
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    NSLog(@"Picker cancelled");
    [self dismissViewControllerAnimated:YES completion:NULL];
}



#pragma mark - Button Handlers
- (IBAction)cancelPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender {
    [self savePromWithCompletion:^(BOOL success){
        if(success){
            [self performSegueWithIdentifier:@"finishedAddingProm" sender:self];
            //[self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
        }
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];// this will do the trick
}

#pragma mark - UITextFieldDelegate
- (BOOL) textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL) textFieldShouldBeginEditing:(UITextField *)textField
{
    return YES;
}

#pragma mark - Date Management
/*! Determines if the given indexPath has a cell below it with a UIDatePicker.
 
 @param indexPath The indexPath to check if its cell has a UIDatePicker below it.
 */
/*
- (BOOL)hasPickerForIndexPath:(NSIndexPath *)indexPath
{
    BOOL hasDatePicker = NO;
    
    NSInteger targetedRow = indexPath.row;
    targetedRow++;
    
    UITableViewCell *checkDatePickerCell =
    [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:targetedRow inSection:0]];
    UIDatePicker *checkDatePicker = (UIDatePicker *)[checkDatePickerCell viewWithTag:kDatePickerID];
    
    hasDatePicker = (checkDatePicker != nil);
    return hasDatePicker;
}
*/
#pragma mark - Table view

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [keyForRowIndex count];//How many keys (and corresponding editable properties) are there
}

- (UITableViewCell*) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [SKAddPromViewController keyForRowIndex:[indexPath row]];
    NSLog(@"Tried creating cell for key %@", key);
    if([key isEqualToString:@"image"]){
        SKImageEditorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ImageEditor"];
        [cell.editButton addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
        cell.key = key;
        cell.imageView.image = [UIImage imageNamed:@"EmptyDress"];
        if(!_isNewProm){
            [(PFImageView *)cell.imageView setFile:self.prom.image]; //placeholder (should already be there anyways)
            [(PFImageView *)cell.imageView loadInBackground]; //Loads existing image from Parse
        }
        return cell;
    }else{
        SKStringEntryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StringEntry"];
        cell.field.delegate = self;
        cell.key = key;
        NSString *currentVal = [self.prom objectForKey:key];
        if(!_isNewProm && !(([currentVal class]==[NSString class] && [currentVal isEqualToString:@""]) || [currentVal isEqual:nil])){
            cell.field.text = [self.prom objectForKey:key];
        }else{
            cell.field.placeholder = [SKAddPromViewController readableNameForKey:key];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row]==0){
        //Is image editing cell
        return 200;
    }else{
        //Is text entry cell
        return 43;
    }
}

#pragma mark - Getters and Setters

- (UIImageView *) promImageView
{
    SKImageEditorCell *cell = [self.tableView visibleCells][0];
    return [cell imageView];
}

#pragma mark - Statics
+(NSString *)readableNameForKey:(NSString *)key{
    return readableNames[key];
}
+(NSString *)keyForRowIndex:(long)num{
    return keyForRowIndex[num];
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
