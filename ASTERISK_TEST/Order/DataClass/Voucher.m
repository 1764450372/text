//
//  Voucher.m
//  Order
//
//  Created by koji kodama on 13/03/25.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "Voucher.h"

@implementation Voucher

- (id)init{
    self = [super init];
    if (self) {
        // Initialization code
        self.subList = [[NSMutableArray alloc]init];
    }
    return self;
}

@end
