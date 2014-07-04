//
//  SKDressListTableViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKDressListTableViewController.h"
#import <Parse/Parse.h>
#import "SKDress.h"
#import "SKDressInfoTableViewCell.h"

@interface SKDressListTableViewController ()

@end


@implementation SKDressListTableViewController{
    NSArray *dressIDs;
    enum cellTags {designLabel=101, styleLabel=102, imageView=103};//defined in storyboard, enum for readability
}

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
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
    PFUser *current = [PFUser currentUser];
    dressIDs = [current objectForKey:@"dressIDs"];
    if(dressIDs == nil || [dressIDs count] == 0){
        return 0;
    }else{
        return [dressIDs count];
    }
}

-(void) viewDidAppear:(BOOL)animated{
    // Do stuff like reload the tableview data...
    [self.tableView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKDressInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DressCell"];
    
    NSString *objID = dressIDs[indexPath.row];
    PFObject *dressInfo = [PFQuery getObjectOfClass:[SKDress parseClassName] objectId:objID];
    
    UILabel *designer = (UILabel *)[cell viewWithTag:designLabel];
    designer.text = [dressInfo objectForKey:@"designer"];
    
    UILabel *style = (UILabel *) [cell viewWithTag:styleLabel];
    style.text = [dressInfo objectForKey:@"styleNumber"];
    
    UIImageView *dressImageView = (UIImageView *)[cell viewWithTag:imageView];
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
