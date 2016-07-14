//
//  DivideCell.m
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "DivideCell.h"

@implementation DivideCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
        self.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
    if (selected)
    {
        self.backgroundColor = [UIColor orangeColor];
    }
    else
    {
        self.backgroundColor = [UIColor whiteColor];
    }
}

@end
