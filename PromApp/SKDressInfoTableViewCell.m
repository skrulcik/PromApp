//
//  SKDressInfoTableViewCell.m
//  PromApp
//
//  Created by Scott Krulcik on 7/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKDressInfoTableViewCell.h"

@implementation SKDressInfoTableViewCell
@synthesize designerLabel;
@synthesize styleNumberLabel;
@synthesize dressPicView;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib
{
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
