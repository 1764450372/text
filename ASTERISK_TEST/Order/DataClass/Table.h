//
//  Table.h
//  Order
//
//  Created by koji kodama on 13/03/25.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Table : NSObject

@property (nonatomic, strong) NSNumber* tableID;
@property (nonatomic, strong) NSString* tableNo;
@property TableStatus status;

@end
