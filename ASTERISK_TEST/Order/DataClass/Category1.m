//
//  Category.m
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "Category1.h"

@implementation Category1

// 初期化用メソッド（NSData からの変換で使用）
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.PatternCD = [aDecoder decodeObjectForKey:@"PatternCD"];
        self.MstCateCD = [aDecoder decodeObjectForKey:@"MstCateCD"];
        self.CateNM = [aDecoder decodeObjectForKey:@"CateNM"];
    }
    
    return self;
}

// 変換用メソッド（NSData への変換で使用）
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.PatternCD forKey:@"PatternCD"];
    [aCoder encodeObject:self.MstCateCD forKey:@"MstCateCD"];
    [aCoder encodeObject:self.CateNM forKey:@"CateNM"];
}

@end
