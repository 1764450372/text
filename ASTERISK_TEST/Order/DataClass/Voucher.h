//
//  Voucher.h
//  Order
//
//  Created by koji kodama on 13/03/25.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Voucher : NSObject

@property (nonatomic, strong) NSString *voucherNo;
@property int tableID;
@property int manCount;
@property int womanCount;
@property int menuCount;
@property (nonatomic, strong) NSMutableArray* subList;

@end
