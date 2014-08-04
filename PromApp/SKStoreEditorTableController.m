//
//  SKStoreEditorTableController.m
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKStoreEditorTableController.h"
#import "SKStringEntryCell.h"

@interface SKStoreEditorTableController ()
@property NSArray *accountInfo;
@property NSString *accountInfoName;
@property NSArray *storeInfo;
@property NSString *storeInfoName;

@end

@implementation SKStoreEditorTableController{
    BOOL _isNewStore;
}
static NSDictionary *readableNames;
@synthesize accountInfo, storeInfo;
@synthesize accountInfoName, storeInfoName;
@synthesize store;

- (id)initForCreation
{
    self = [self initForStore:[[SKStore alloc] init]];
    _isNewStore = YES;
    return self;
}

- (id)initForStore:(SKStore *)storeObject
{
    self = [super initWithNibName:@"EditStore" bundle:nil];
    if(!readableNames){
        readableNames = @{@"username":@"Store Name",
                          @"email":@"Email",
                          @"password":@"Password",
                          @"address":@"Address",
                          @"description":@"Description",
                          @"hours":@"Hours"};
    }
    if (self) {
        self.store = storeObject;
        self.accountInfo = [NSArray arrayWithObjects:@"username", @"email", @"password", nil];
        self.storeInfo = [NSArray arrayWithObjects:@"address", @"description", @"hours", nil];
        self.accountInfoName = @"Account Information:";
        self.storeInfoName = @"Store Information:";
        _isNewStore = NO;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.tableView registerNib:[UINib nibWithNibName:@"StringEntryCell" bundle:nil] forCellReuseIdentifier:@"StringEntry"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if(section == 0){
        return [self.accountInfo count];
    } else {
        return [self.storeInfo count];
    }
}

- (NSString *) tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if(section ==0 ){
        return self.accountInfoName;
    } else {
        return self.storeInfoName;
    }
}

- (UITableViewCell*) tableView:(UITableView *) tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *key;
    if([indexPath section]==0){
        //index refers to a cell in account info
        key = self.accountInfo[[indexPath row]];
    }else if([indexPath section] ==1){
        //index refers to a cell in store info
        key = self.storeInfo[[indexPath row]];
    }
    //return a text editing cell
    SKStringEntryCell *cell = [self.tableView dequeueReusableCellWithIdentifier:@"StringEntry"];
    cell.field.delegate = self;
    cell.key = key;
    NSString *currentVal = [self.store objectForKey:key];
    if(!_isNewStore && !([currentVal isEqualToString:@""] || [currentVal isEqual:nil])){
        cell.field.text = [self.store objectForKey:key];
    }else{
        cell.field.placeholder = [SKStoreEditorTableController readableNameForKey:key];
    }
    return cell;
}


#pragma mark - 'Form Backing Object' Management
typedef void(^voidCompletion)(void);
- (void) saveStore:(SKStore *)store withCompletion:(voidCompletion)block
{
    for(SKStringEntryCell *cell in [self.tableView visibleCells]){
        NSString *val = cell.field.text;
        if(val && ![val isEqualToString:@""]){
            if([cell.key isEqualToString:@"password"]){
                //Cannot set pwd with setObject forKey
                self.store.password = val;
            }else{
                [self.store setObject:val forKey:cell.key];
            }
            NSLog(@"Set key %@ to value %@.", cell.key, val);
        }
    }
    [self.store readableStoreInformation];
    if(_isNewStore)
        [self.store signUp];
    [self.store saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if(succeeded){
            NSLog(@"Succeeded in saving %@ store with ID %@.", self.store.username, self.store.objectId);
            block();
        }else{
            NSLog(@"Failed in saving %@ (a store) for reason: %@", self.store.username, error);
            UIAlertView *fail = [[UIAlertView alloc] initWithTitle:@"Internal Error" message:@"We are sorry, your changes could not be saved." delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: nil];
            [fail show];
        }
    }];
}

#pragma mark - Text Field Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - UI Actions

- (IBAction)cancelPressed:(id)sender {
    [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)savePressed:(id)sender {
    [self saveStore:self.store withCompletion:^(void){
        [self.presentingViewController performSegueWithIdentifier:@"finishLogin" sender:self.presentingViewController];//removes both this page and login page from stack
    }];
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [self.view endEditing:YES];
}

#pragma mark - Static Methods
+(NSString *)readableNameForKey:(NSString *)key{
    return readableNames[key];
}
@end
