//
//  SKPromDetailViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromDetailViewController.h"
#import "SKPromFinderViewController.h"
#import "SKPromTableViewCell.h"
#import "SKDressInfoTableViewCell.h"
#import "SKDress.h"

@interface SKPromDetailViewController ()

@end

@implementation SKPromDetailViewController
@synthesize table;
@synthesize prom;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Register cell list
    [self.table registerNib:[UINib nibWithNibName:@"DressCell" bundle:nil]
             forCellReuseIdentifier:@"DressCell"];
    [self.table registerNib:[UINib nibWithNibName:@"PromCell" bundle:nil]
     forCellReuseIdentifier:@"PromCell"];
    
    // If user has rights, allow to edit prom
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
#warning Potentially incomplete method implementation.
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
#warning Incomplete method implementation.
    // Return the number of rows in the section.
    return 1+[self.prom.dresses count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row]==0){
        SKPromTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"PromCell"];
        cell.school.text = self.prom.schoolName;
        NSLog(@"name test    %@", self.prom.schoolName);
        cell.theme.text = self.prom.theme;
        cell.date.text = self.prom.time;
        cell.locationDescription.text = self.prom.locationDescription;
        cell.address.text = self.prom.address;
        CLLocationCoordinate2D center = CLLocationCoordinate2DMake(self.prom.preciseLocation.latitude, self.prom.preciseLocation.longitude);
        MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, 250, 250);
        [cell.map setRegion:[cell.map regionThatFits:region] animated:YES];
        MKPointAnnotation *pin = [[MKPointAnnotation alloc] init];
        pin.coordinate = center;
        [cell.map addAnnotation:pin];
        return cell;
    }else{
        SKDressInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DressCell"];
        /*if (cell == nil) {
         cell = [[SKDressInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DressCell"];
         }*/
        
        NSString *objID = prom.dresses[indexPath.row-1];
        PFObject *dressInfo = [PFQuery getObjectOfClass:[SKDress parseClassName] objectId:objID];
        
        UILabel *designer = cell.designerLabel;
        designer.text = [dressInfo objectForKey:@"designer"];
        
        UILabel *style = cell.styleNumberLabel;
        style.text = [dressInfo objectForKey:@"styleNumber"];
        
        UIImageView *dressImageView = cell.dressPicView;
        //retrieve image
        PFFile *dressPicFile = [dressInfo objectForKey:@"image"];
        [dressPicFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
            if (!error) {
                UIImage *dressImage = [UIImage imageWithData:imageData];
                dressImageView.image = dressImage;
            }
        }];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([indexPath row]==0){
        return 170;
    }else{
        return 80;
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Navigation
/*
// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"showPromDetail"]){
        SKPromFinderViewController *controller = (SKPromFinderViewController*)sender;
        self.prom = controller.currentProm;
        [self.prom readableInfo];
    }
}
 */

@end
