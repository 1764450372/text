//
//  TableViewCellReserveList.h
//  Order
//
//  Created by mac-sper on 2015/04/28.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableViewCellReserveList : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *labelTime;
@property (weak, nonatomic) IBOutlet UILabel *labelKokyaku;
@property (weak, nonatomic) IBOutlet UILabel *labelTelNo;
@property (weak, nonatomic) IBOutlet UILabel *labelTblStr;
@property (weak, nonatomic) IBOutlet UILabel *labelTable;

@end
