//
//  SKTableViewCell.m
//  PromApp
//
//  Created by Scott Krulcik on 8/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKStringEntryCell.h"

@implementation SKStringEntryCell
@synthesize key;
@synthesize field;

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
    self.field.autocapitalizationType = UITextAutocapitalizationTypeWords;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
