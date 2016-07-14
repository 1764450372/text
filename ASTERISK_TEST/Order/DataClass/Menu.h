//
//  Menu.h
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Menu : NSObject


//Menu1
@property (nonatomic, strong) NSString *PatternCD;
@property (nonatomic, strong) NSString *CateCD;
@property (nonatomic, strong) NSNumber *DispOrder;
@property (nonatomic, strong) NSString *SyohinCD;
@property (nonatomic, strong) NSString *BNGFLG;

//Menu2
@property (nonatomic, strong) NSString *PageNo;
@property (nonatomic, strong) NSString *B1CateCD;

@property (nonatomic, strong) NSString *MstSyohinCD;
@property (nonatomic, strong) NSString *HTDispNMU;
@property (nonatomic, strong) NSString *HTDispNMM;
@property (nonatomic, strong) NSString *HTDispNML;
@property (nonatomic, strong) NSString *JikaFLG;
@property (nonatomic, strong) NSString *SG1FLG;
@property (nonatomic, strong) NSString *TrayStyle;
@property (nonatomic, strong) NSString *Tanka;
@property (nonatomic, strong) NSString *BNGTanka;//
@property (nonatomic, strong) NSString *KakeFLG;
@property (nonatomic, strong) NSString *KakeRate;//
@property (nonatomic, strong) NSString *BFLG;
@property (nonatomic, strong) NSString *CateNM;
@property (nonatomic, strong) NSString *InfoFLG;
@property (nonatomic, strong) NSString *Info;

@property (nonatomic, strong) NSString *count;
@property (nonatomic, strong) NSString *countDivide;


@end
