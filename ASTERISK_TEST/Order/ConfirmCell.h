//
//  ConfirmCell.h
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ConfirmCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *title;
@property (weak, nonatomic) IBOutlet UILabel *titleSub;
@property (weak, nonatomic) IBOutlet UILabel *titleSub2;

@property (weak, nonatomic) IBOutlet UILabel *count;
@property (weak, nonatomic) IBOutlet UILabel *countSub;
@property (weak, nonatomic) IBOutlet UIButton *bt_left;
@property (weak, nonatomic) IBOutlet UIButton *bt_right;

@end
