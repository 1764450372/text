//
//  CategoryCell.m
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "CategoryCell.h"

@implementation CategoryCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.selectionStyle = UITableViewCellSelectionStyleNone;
        //self.backgroundColor = [UIColor clearColor];
        self.titleLabel.textColor = [UIColor whiteColor];
        self.titleLabel.backgroundColor = [UIColor clearColor];
        self.titleLabel.frame = CGRectMake(-10, 0, self.bounds.size.width+20, self.bounds.size.height);
    }
    return self;
}


- (void)setSelected:(BOOL)selected animated:(BOOL)animated{
    if (selected)
    {
        self.backgroundColor = [UIColor orangeColor];
    }
    else
    {
        self.backgroundColor = [UIColor clearColor];
    }
}


@end