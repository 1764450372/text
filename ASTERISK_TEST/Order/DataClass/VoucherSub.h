//
//  VoucherSub.h
//  Order
//
//  Created by koji kodama on 13/03/27.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface VoucherSub : NSObject

@property (nonatomic, strong) NSString *subNo;
@property int shohinCD;
@property int count;
@property int price;
@property (nonatomic, retain) NSMutableArray* menuList;

@end
