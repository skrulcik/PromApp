//
//  SKImageEditorCell.m
//  PromApp
//
//  Created by Scott Krulcik on 8/3/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import "SKImageEditorCell.h"

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@implementation SKImageEditorCell
@synthesize key;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.pfimage = (PFImageView *)self.basicImage;
        
    }
    return self;
}

- (void)awakeFromNib
{
    //self.imageView = (PFImageView *)self.basicImage;
    self.editButton.tintColor = UIColorFromRGB(0xFF7094);
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
