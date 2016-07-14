//
//  Menu.m
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "Menu.h"


@implementation Menu

- (id)copyWithZone:(NSZone*)zone
{
    // 複製を保存するためのインスタンスを生成します。
    Menu* result = [[[self class] allocWithZone:zone] init];
    
    if (result)
    {
        result->_PatternCD = [_PatternCD copyWithZone:zone];
        result->_CateCD = [_CateCD copyWithZone:zone];
        result->_DispOrder = [_DispOrder copyWithZone:zone];
        result->_SyohinCD = [_SyohinCD copyWithZone:zone];
        result->_BNGFLG = [_BNGFLG copyWithZone:zone];
        
        result->_PageNo = [_SyohinCD copyWithZone:zone];
        result->_BNGFLG = [_BNGFLG copyWithZone:zone];
        
        result->_MstSyohinCD = [_MstSyohinCD copyWithZone:zone];
        result->_HTDispNMU = [_HTDispNMU copyWithZone:zone];
        result->_HTDispNMM = [_HTDispNMM copyWithZone:zone];
        result->_HTDispNML = [_HTDispNML copyWithZone:zone];
        result->_JikaFLG = [_JikaFLG copyWithZone:zone];
        result->_SG1FLG = [_SG1FLG copyWithZone:zone];
        result->_TrayStyle = [_TrayStyle copyWithZone:zone];
        result->_Tanka = [_Tanka copyWithZone:zone];
        result->_BNGTanka = [_BNGTanka copyWithZone:zone];
        result->_KakeFLG = [_KakeFLG copyWithZone:zone];
        result->_KakeRate = [_KakeRate copyWithZone:zone];
        result->_BFLG = [_BFLG copyWithZone:zone];
        result->_CateNM = [_CateNM copyWithZone:zone];
        result->_InfoFLG = [_InfoFLG copyWithZone:zone];
        result->_Info = [_Info copyWithZone:zone];
        
        result->_count = [_count copyWithZone:zone];
        result->_countDivide = [_countDivide copyWithZone:zone];
    }
    
    return result;
}

// 初期化用メソッド（NSData からの変換で使用）
- (id)initWithCoder:(NSCoder*)aDecoder
{
    self = [super init];
    
    if (self)
    {
        self.PatternCD = [aDecoder decodeObjectForKey:@"PatternCD"];
        self.CateCD = [aDecoder decodeObjectForKey:@"CateCD"];
        self.DispOrder = [aDecoder decodeObjectForKey:@"DispOrder"];
        self.SyohinCD = [aDecoder decodeObjectForKey:@"SyohinCD"];
        self.BNGFLG = [aDecoder decodeObjectForKey:@"BNGFLG"];
        self.PageNo = [aDecoder decodeObjectForKey:@"PageNo"];
        self.B1CateCD = [aDecoder decodeObjectForKey:@"B1CateCD"];
        self.MstSyohinCD = [aDecoder decodeObjectForKey:@"MstSyohinCD"];
        self.HTDispNMU = [aDecoder decodeObjectForKey:@"HTDispNMU"];
        self.HTDispNMM = [aDecoder decodeObjectForKey:@"HTDispNMM"];
        self.HTDispNML = [aDecoder decodeObjectForKey:@"HTDispNML"];
        self.JikaFLG = [aDecoder decodeObjectForKey:@"JikaFLG"];
        self.SG1FLG = [aDecoder decodeObjectForKey:@"SG1FLG"];
        self.TrayStyle = [aDecoder decodeObjectForKey:@"TrayStyle"];
        self.Tanka = [aDecoder decodeObjectForKey:@"Tanka"];
        self.BNGTanka = [aDecoder decodeObjectForKey:@"BNGTanka"];
        self.KakeFLG = [aDecoder decodeObjectForKey:@"KakeFLG"];
        self.KakeRate = [aDecoder decodeObjectForKey:@"KakeRate"];
        self.BFLG = [aDecoder decodeObjectForKey:@"BFLG"];
        self.CateNM = [aDecoder decodeObjectForKey:@"CateNM"];
        self.InfoFLG = [aDecoder decodeObjectForKey:@"InfoFLG"];
        self.Info = [aDecoder decodeObjectForKey:@"Info"];
        self.count = [aDecoder decodeObjectForKey:@"count"];
        self.countDivide = [aDecoder decodeObjectForKey:@"countDivide"];
    }
    
    return self;
}

// 変換用メソッド（NSData への変換で使用）
- (void)encodeWithCoder:(NSCoder*)aCoder
{
    [aCoder encodeObject:self.PatternCD forKey:@"PatternCD"];
    [aCoder encodeObject:self.CateCD forKey:@"CateCD"];
    [aCoder encodeObject:self.DispOrder forKey:@"DispOrder"];
    [aCoder encodeObject:self.SyohinCD forKey:@"SyohinCD"];
    [aCoder encodeObject:self.BNGFLG forKey:@"BNGFLG"];
    [aCoder encodeObject:self.PageNo forKey:@"PageNo"];
    [aCoder encodeObject:self.B1CateCD forKey:@"B1CateCD"];
    [aCoder encodeObject:self.MstSyohinCD forKey:@"MstSyohinCD"];
    [aCoder encodeObject:self.HTDispNMU forKey:@"HTDispNMU"];
    [aCoder encodeObject:self.HTDispNMM forKey:@"HTDispNMM"];
    [aCoder encodeObject:self.HTDispNML forKey:@"HTDispNML"];
    [aCoder encodeObject:self.JikaFLG forKey:@"JikaFLG"];
    [aCoder encodeObject:self.SG1FLG forKey:@"SG1FLG"];
    [aCoder encodeObject:self.TrayStyle forKey:@"TrayStyle"];
    [aCoder encodeObject:self.Tanka forKey:@"Tanka"];
    [aCoder encodeObject:self.BNGTanka forKey:@"BNGTanka"];
    [aCoder encodeObject:self.KakeFLG forKey:@"KakeFLG"];
    [aCoder encodeObject:self.KakeRate forKey:@"KakeRate"];
    [aCoder encodeObject:self.BFLG forKey:@"BFLG"];
    [aCoder encodeObject:self.CateNM forKey:@"CateNM"];
    [aCoder encodeObject:self.InfoFLG forKey:@"InfoFLG"];
    [aCoder encodeObject:self.Info forKey:@"Info"];
    [aCoder encodeObject:self.count forKey:@"count"];
    [aCoder encodeObject:self.countDivide forKey:@"countDivide"];
}

@end
