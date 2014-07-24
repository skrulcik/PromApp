//
//  SKPromTableViewCell.m
//  PromApp
//
//  Created by Scott Krulcik on 7/24/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKPromTableViewCell.h"

@implementation SKPromTableViewCell

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

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
