//
//  SKAddDressViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//  Some code adapted from http://stackoverflow.com/questions/18880364/uiimagepickercontroller-breaks-status-bar-appearance
//

#define MAX_IMG_WIDTH 400
#define MAX_IMG_HEIGHT 600

#import "SKAddDressViewController.h"
#import "SKImageEditorCell.h"
#import "SKMainTabViewController.h"
#import "SKPromQueryController.h"
#import "SKStore.h"
#import "SKStringEntryCell.h"



@interface SKAddDressViewController ()
@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;
@property (weak, nonatomic) IBOutlet UINavigationItem *navTitle;

@end

@implementation SKAddDressViewController{
    BOOL _isNewDress;       //So we know whether we are creating or editing
    BOOL _imageChanged;     //No need to take up bandwith with images if they aren't changed
    BOOL _promChanged;      //Stores if the prom has been changed
    NSMutableDictionary *dressData;
}
@synthesize cancelButton;
@synthesize doneButton;
@synthesize dressImageView;
//@synthesize tableView;

static NSArray *keyForRowIndex;
static NSDictionary *readableNames;

- (void) setupForCreation{
    //self = [self initForDress:[[SKDress alloc] init]];
    [self loadDressInfo:[[SKDress alloc] init]];
    _isNewDress = YES;
}

- (void) setupWithDress:(SKDress *)dressObject
{
    [self loadDressInfo:dressObject];
    _isNewDress = NO;
}

- (void) loadDressInfo:(SKDress *)dressObject
{
    //self = [super initWithNibName:@"EditDress" bundle:nil];
    keyForRowIndex = @[@"image", @"designer", @"styleNumber", @"dressColor", @"prom"];
    if(!readableNames){
        readableNames = @{@"image":@"Dress Image",
                          @"designer":@"Designer",
                          @"styleNumber":@"Style ID Number",
                          @"dressColor":@"Color",
                          @"owner":@"Dress Owner",
                          @"store":@"Store",
                          @"prom":@"Prom"};
    }
    _imageChanged = NO;
    _promChanged = NO;
    dressData = [[NSMutableDictionary alloc] init];
    self.dress = dressObject;
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _isNewDress = YES;
    [self setupForCreation];
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.capturedImages = [[NSMutableArray alloc] init];
    
    [self.tableView registerNib:[UINib nibWithNibName:@"StringEntryCell" bundle:nil] forCellReuseIdentifier:@"StringEntry"];
    [self.tableView registerNib:[UINib nibWithNibName:@"ImageEditorCell" bundle:nil] forCellReuseIdentifier:@"ImageEditor"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)showImagePickerForCamera:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypeCamera];
}


- (IBAction)showImagePickerForPhotoPicker:(id)sender
{
    [self showImagePickerForSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void)navigationController:(UINavigationController *)navigationController
     willShowViewController:(UIViewController *)viewController
                   animated:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
}

- (IBAction)savePressed:(id)sender {
    [self saveDress:self.dress withCompletion:^(void){
        NSLog(@"Right before segue: %@", [[PFUser currentUser] objectForKey:@"dresses"]);
        [self performSegueWithIdentifier:@"SaveDress" sender:self];
    }];
}


- (void)showImagePickerForSourceType:(UIImagePickerControllerSourceType)sourceType
{
    if (self.dressImageView.isAnimating)
    {
        [self.dressImageView stopAnimating];
    }
    
    if (self.capturedImages.count > 0)
    {
        [self.capturedImages removeAllObjects];
    }
    
    UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
    imagePickerController.modalPresentationStyle = UIModalPresentationCurrentContext;
    imagePickerController.sourceType = sourceType;
    imagePickerController.delegate = self; //Needed to preserve status bar state
    
    self.imagePickerController = imagePickerController;
    [self presentViewController:self.imagePickerController animated:YES completion:nil];
}

- (IBAction)addImage:(id)sender
{
    if (![UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera])
    {
        [self showImagePickerForPhotoPicker:sender];
    } else {
        UIAlertController *chooser = [UIAlertController
                                      alertControllerWithTitle:nil
                                      message:nil
                                      preferredStyle:UIAlertControllerStyleActionSheet];
        
        UIAlertAction *cancel = [UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action){
            //Dismiss window - do nothing
        }];
        UIAlertAction *picker = [UIAlertAction actionWithTitle:@"Choose Existing" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self showImagePickerForPhotoPicker:sender]; //Show picker
        }];
        UIAlertAction *camera = [UIAlertAction actionWithTitle:@"Open Camera" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action){
            [self showImagePickerForCamera:sender]; //Open camera
        }];
        [chooser addAction:cancel];
        [chooser addAction:camera];
        [chooser addAction:picker];
        [self presentViewController:chooser animated:YES completion:nil];
    }
}

- (void) performPromAssociation:(SKProm *) prom
{
    [self storeDressData:self.dress];
    NSString *designer = [dressData objectForKey:@"designer"];
    NSString *styleNumber = [dressData objectForKey:@"styleNumber"];
    if(designer == NULL || styleNumber == NULL){
        //Put up some alert
        return;
    }
    BOOL is_available = [prom verifyDesigner:designer withStyle:styleNumber];
    if(is_available){
        [dressData setObject:prom forKey:@"prom"];
        _promChanged = YES;
        NSArray *cells = [self.tableView visibleCells];
        for (int i=0; i<[cells count]; i++){
            if([@"prom" isEqualToString:[SKAddDressViewController keyForRowIndex:i]]){
                //Is prom cell
                SKStringEntryCell *pcell = cells[i];
                pcell.field.text = [dressData[@"prom"] schoolName];
            }
        }
    } else {
        //Make dialog pop up
        UIAlertView * popup = [[UIAlertView alloc] initWithTitle:@"Don't be that girl!" message:@"This dress has already been registered for this prom. Please select a different prom, or choose a different dress." delegate:self cancelButtonTitle:@"Okay" otherButtonTitles:nil];
        [popup show];
    }
}

- (void) storeDressData:(SKDress *)dress
{
    NSArray *cells = [self.tableView visibleCells];
    for (int i=0; i<[cells count]; i++){
        if([@"image" isEqualToString:[SKAddDressViewController keyForRowIndex:i]]){
            //Is image cell
            SKImageEditorCell *imgCell = cells[i];
            UIImage *currentPic = imgCell.basicImage.image;
            if(currentPic){
                [dressData setObject:currentPic forKey:[SKAddDressViewController keyForRowIndex:i]];
            }
        }else if(![@"prom" isEqualToString:[SKAddDressViewController keyForRowIndex:i]]){
            //Is text entry cell
            SKStringEntryCell *txtCell = cells[i];
            NSString *val = txtCell.field.text;
            if([val isEqualToString:@""] || val == nil){
                val = [dress objectForKey:[SKAddDressViewController keyForRowIndex:i]];
            }
            if(val)
                [dressData setObject:val forKey:[SKAddDressViewController keyForRowIndex:i]];
        }
    }
}

- (UIImage *) constrainedCopyOf:(UIImage *)image withWidth:(int)width height:(int)height
{
    int goal_w = width;
    int goal_h = height;
    if(image.size.height > image.size.width){
        //Most dress pics will be in portrait format
        goal_w = (int)((float)width/(float)height * goal_h);
    }else{
        //Picture is landscape
        goal_h = (int)((float)height/(float)width * goal_w);
    }
    assert(goal_w<=width && goal_h <= height);
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(goal_w, goal_h), NO, 0.0);
    CGRect scaledImageRect = CGRectMake(0.0, 0.0, goal_w, goal_h);
    [image drawInRect:scaledImageRect];
    UIImage* constrainedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return constrainedImage;
}

typedef void(^voidCompletion)(void);
- (void) saveDress:(SKDress *)dress withCompletion:(voidCompletion)block
{
    [self storeDressData:dress];
    if(dressData[@"designer"] != nil && dressData[@"styleNumber"] != nil){
        PFUser *current = [PFUser currentUser];
        for(NSString *key in dressData){
            if(dressData[key]){
                if(![key isEqualToString:@"image"]){
                    //don't save the image until the end, other data is used for filename
                    [dress setObject:dressData[key] forKey:key];
                }
            }
        }
        //Save Image of dress as PFFile
        UIImage *constrained = [self constrainedCopyOf:self.dressImageView.image withWidth:MAX_IMG_WIDTH height:MAX_IMG_HEIGHT];
        NSData *imageData = UIImageJPEGRepresentation(constrained, 0.6); //Compress to save space
        NSString *filename = [NSString stringWithFormat:@"%@%@Picture.jpg",dress.designer, dress.styleNumber];
        PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
        dress.image = imageFile;
        [dress.image save]; //Synchronously save dress before attempting to save dress
        //self.dress.owner = current; //FIXME: causes recursion problems
        
        //If dress is not an existing dress, add it to the array
        NSMutableArray *dresses = (NSMutableArray *)[current objectForKey:@"dresses"];
        if(![dresses containsObject:dress]){
            [current addObject:dress forKey:@"dresses"];
        }
        NSLog(@"Added dress %@ to user's list of dresses", dress);
        [current saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
            if(!error){
                NSLog(@"Saved changes to dress list.");
                block();
            } else {
                NSLog(@"Failed to save changes to dress list: %@", error);
                UIAlertView *errorMessage = [[UIAlertView alloc] initWithTitle:@"Could Not Save Dress" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [errorMessage show];
            }
        }];
    }else{
        UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Missing Required Fields" message:@"You must enter a designer and style number." delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [fail show];
    }
}

- (void)populateImage
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            self.dressImageView.image = [self.capturedImages objectAtIndex:0];
            NSLog(@"%@", self.dressImageView);
        }
        else
        {
            // Camera took multiple pictures; use the list of images for animation.
            self.dressImageView.animationImages = self.capturedImages;
            self.dressImageView.animationDuration = 5.0;    // Show each captured photo for 5 seconds.
            self.dressImageView.animationRepeatCount = 0;   // Animate forever (show all photos).
            [self.dressImageView startAnimating];
        }
        
        // To be ready to start again, clear the captured images array.
        [self.capturedImages removeAllObjects];
    }
    
    self.imagePickerController = nil;
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

- (BOOL) textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [keyForRowIndex count];//How many keys (and corresponding editable properties) are there
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([[SKAddDressViewController keyForRowIndex:[indexPath row]] isEqualToString:@"prom"]){
        [self performSegueWithIdentifier:@"SelectProm" sender:self];
    }
}

- (UITableViewCell*) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key = [SKAddDressViewController keyForRowIndex:[indexPath row]];
    //NSLog(@"Tried creating cell for key %@", key);
    
    if([key isEqualToString:@"image"]){
        SKImageEditorCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"ImageEditor"];
        if (cell == nil){
            cell = [[SKImageEditorCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"ImageEditor" ];
        }
        [cell.editButton addTarget:self action:@selector(addImage:) forControlEvents:UIControlEventTouchUpInside];
        cell.key = key;
        cell.basicImage.image = [UIImage imageNamed:@"placeholder"];//placeholder (should already be there anyways)
        self.dress.image = [self.dress objectForKey:@"image"];
        if(!_isNewDress && self.dress.image != nil){
            [(PFImageView *)cell.basicImage setFile:self.dress.image];
            [(PFImageView *)cell.basicImage loadInBackground]; //Loads existing image from Parse
        }
        return cell;
    }else{
        SKStringEntryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StringEntry"];
        if (cell == nil){
            cell = [[SKStringEntryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"StringEntry" ];
        }
        cell.field.delegate = self;
        cell.key = key;
        
        //Fill in generic information first
        cell.field.text = @"";
        cell.field.placeholder = [SKAddDressViewController readableNameForKey:key];
        
        if(!_isNewDress){
            if([key isEqualToString:@"prom"]){
                SKProm *prom =[self.dress objectForKey:key];
                [prom fetchIfNeeded];
                if(prom != nil){
                    cell.field.text = [prom schoolName];
                }
            } else if ([key isEqualToString:@"owner"]){
                PFUser *user = [self.dress objectForKey:key];
                if(user != nil){
                    [user fetchIfNeeded];
                    NSString *displayName = [user objectForKey:@"username"];
                    cell.field.text = displayName;
                }
            }else if ([key isEqualToString:@"store"]){
                SKStore *store = [self.dress objectForKey:key];
                if(store != nil){
                    NSString *displayName = [store objectForKey:@"username"];
                    cell.field.text = displayName;
                }
            }else{
                NSString *current = [self.dress objectForKey:key];
                if(current != nil && ![current isEqualToString:@"" ]){
                    cell.field.text = current;
                }
            }
        }
        if([key isEqualToString:@"prom"]){
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.field.enabled = NO;
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
        return 43;
    }
}

#pragma mark - Getters and Setters

- (UIImageView *) dressImageView
{
    SKImageEditorCell *cell = [self.tableView visibleCells][0];
    return [cell basicImage];
}

#pragma mark - Statics
+(NSString *)readableNameForKey:(NSString *)key{
    return readableNames[key];
}
+(NSString *)keyForRowIndex:(long)num{
    return keyForRowIndex[num];
}


#pragma mark - Navigation
- (IBAction) unwindFromSelectProm:(UIStoryboardSegue *)segue
{
    if ([segue.sourceViewController isKindOfClass:[SKPromQueryController class]]) {
        SKPromQueryController *promController = segue.sourceViewController;
        // if the user clicked Cancel, we don't want to change the color
        if (promController.selectedProm) {
            [self performPromAssociation:promController.selectedProm];
        }
    }
}

- (IBAction) unwindFromSelectPromCancel:(UIStoryboardSegue *)segue
{
}

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"SelectProm"]){
        SKProm *currentProm = [self.dress objectForKey:@"prom"];
        if(currentProm != NULL){
            //If there is an existing dress already registered, set it to be the current selection
            SKPromQueryController *queryTable = [segue destinationViewController];
            if(queryTable != NULL){
                
            } else {
                NSLog(@"Could not locate destination view controller for SelectPromSegue");
            }
        }
        
    }
}

@end
