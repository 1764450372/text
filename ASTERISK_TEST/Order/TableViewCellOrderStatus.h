//
//  TableViewCellOrderStatus.h
//  Order
//
//  Created by mac-sper on 2015/04/28.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellOrderStatus : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelMinStr;
@property (weak, nonatomic) IBOutlet UILabel *labelDenpyo;
@property (weak, nonatomic) IBOutlet UILabel *labelNinzu;
@property (weak, nonatomic) IBOutlet UILabel *labelTotal;
@property (weak, nonatomic) IBOutlet UILabel *labelTblStr;
@property (weak, nonatomic) IBOutlet UILabel *labelTable;

@end
