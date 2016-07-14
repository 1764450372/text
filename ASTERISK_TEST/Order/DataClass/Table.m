//
//  Table.m
//  Order
//
//  Created by koji kodama on 13/03/25.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "Table.h"

@implementation Table

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    Table* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->_tableID = [_tableID copyWithZone:zone];
        result->_tableNo = [_tableNo copyWithZone:zone];
    }
    return result;
}

@end
