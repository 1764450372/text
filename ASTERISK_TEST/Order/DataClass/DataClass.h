//
//  DataClass.h
//  Order
//
//  Created by koji kodama on 13/03/07.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "System.h"
#import "DataList.h"
#import "Category1.h"
#import "Menu.h"
#import "Voucher.h"
#import "VoucherSub.h"
#import "OrderManager.h"
#import "System.h"

typedef enum
{
    TableStatusNone,
    TableStatusEmpty,
    TableStatusReserve,
    TableStatusInReady,
    TableStatusInShow,
    TableStatusNormal,
    TableStatusTimely,
    TableStatusControl,
    TableStatusNotice,
    TableStatusTimeOver,
    TableStatusInShow1,
    TableStatusInShow2,
    //2015-02-04 ueda
    TableStatusCall
} TableStatus;

enum {
    TypeOrderNone,
    TypeOrderOriginal,
    TypeOrderAdd,
    TypeOrderCancel,
    TypeOrderCheck,
    TypeOrderDivide,
    TypeOrderMove,
    TypeOrderDirection,
};
typedef int TypeOrder;

@interface DataClass : NSObject

@end
