//
//  SKAddDressViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/1/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKAddDressViewController.h"
#import "SKDress.h"
#import "SKMainTabViewController.h"

@interface SKAddDressViewController ()

@property (nonatomic) UIImagePickerController *imagePickerController;
@property (nonatomic) NSMutableArray *capturedImages;

@end

@implementation SKAddDressViewController

@synthesize designerField;
@synthesize styleNumberField;
@synthesize imageButton;
@synthesize dressImageView;
@synthesize cancelButton;
@synthesize verifyButton;
@synthesize doneButton;

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
    self.capturedImages = [[NSMutableArray alloc] init];
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

- (void)saveDress{
    PFUser *current = [PFUser currentUser];
    SKDress *dress = [[SKDress alloc] init];
    dress.designer = self.designerField.text;
    dress.styleNumber = self.styleNumberField.text;
    dress.owner = current;
    //Save Image of dress as PFFile
    NSData *imageData = UIImagePNGRepresentation(self.dressImageView.image);
    NSString *filename = [NSString stringWithFormat:@"%@%@Picture.png",dress.designer, dress.styleNumber];
    PFFile *imageFile = [PFFile fileWithName:filename data:imageData];
    dress.image = imageFile;
    
    [dress saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error){
        if (succeeded){
            NSLog(@"Succeeded in saving %@ dress", dress.designer);
            NSLog(@"DressID: %@", dress.objectId);
            [current addObject:dress.objectId forKey:@"dressIDs"];
            [current saveInBackground];

        } else {
            NSLog(@"Failed in saving %@ dress", dress.designer);
        }
    }];
}

- (void)populateImage
{
    [self dismissViewControllerAnimated:YES completion:NULL];
    
    if ([self.capturedImages count] > 0)
    {
        if ([self.capturedImages count] == 1)
        {
            // Camera took a single picture.
            [self.dressImageView setImage:[self.capturedImages objectAtIndex:0]];
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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.destinationViewController isKindOfClass:[SKMainTabViewController class]]) {
        [self saveDress];
    }
}


#pragma mark - UIImagePickerControllerDelegate

// This method is called when an image has been chosen from the library or taken from the camera.
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    
    [self.capturedImages addObject:image];
    
    [self populateImage];
}


- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:NULL];
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
