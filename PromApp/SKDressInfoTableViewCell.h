//
//  SKDressInfoTableViewCell.h
//  PromApp
//
//  Created by Scott Krulcik on 7/2/14.
//  Copyright (c) 2014 Scott Krulcik. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ParseUI/ParseUI.h>

@interface SKDressInfoTableViewCell : PFTableViewCell

@property (weak, nonatomic) IBOutlet UILabel *styleNumberLabel;
@property (weak, nonatomic) IBOutlet UIImageView *dressPicView;
@property (weak, nonatomic) IBOutlet UILabel *designerLabel;
@end
