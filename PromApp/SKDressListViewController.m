//
//  SKDressListViewController.m
//  PromApp
//
//  Created by Scott Krulcik on 7/10/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <Parse/Parse.h>

#import "SKDressListViewController.h"
#import "SKDressInfoTableViewCell.h"
#import "SKDress.h"

@interface SKDressListViewController ()

@end

@implementation SKDressListViewController{
    NSArray *dressIDs;
    enum cellTags {designLabel=101, styleLabel=102, imageView=103};//defined in storyboard, enum for readability
}
@synthesize dressListView;

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
    // Register cell list
    [self.dressListView registerNib:[UINib nibWithNibName:@"DressCell" bundle:nil]
         forCellReuseIdentifier:@"DressCell"];
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
    [self loadDressInfo];
}

-(void) loadDressInfo
{
    NSLog(@"Loaded info explicitly");
    [self.dressListView reloadData];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SKDressInfoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"DressCell"];
    /*if (cell == nil) {
        cell = [[SKDressInfoTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"DressCell"];
    }*/
    
    NSString *objID = dressIDs[indexPath.row];
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

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80;
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
