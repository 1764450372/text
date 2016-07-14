//
//  DataList.h
//  Order
//
//  Created by koji kodama on 13/04/09.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataClass.h"

@interface DataList : NSObject

@property (nonatomic, strong) NSMutableDictionary *currentTable;//選択中のテーブル
@property (nonatomic, strong) NSMutableArray *moveToTable;//移動先のテーブル
@property (nonatomic, strong) NSMutableArray *selectTable;//選択中のテーブル（新規）
@property (nonatomic, strong) NSDictionary *currentVoucher;//選択中の伝票

@property (nonatomic, strong) NSString *currentKyakusoID;
@property (nonatomic, strong) NSString *currentKokyakuCD;
@property (nonatomic, strong) NSString *currentNoteID;

@property (nonatomic, strong) NSString *printMax;
@property (nonatomic, strong) NSString *printDefault;

@property (nonatomic, strong) NSMutableArray *keppinList;//欠品リスト

@property NSInteger manCount;
@property NSInteger womanCount;
//2014-10-23 ueda
@property NSInteger childCount;

@property NSInteger divideCount;
@property NSInteger dividePage;//分割時に使用する


//OrderEntryView
@property NSInteger menuPage;
@property NSInteger Sub1MenuPage;
@property NSInteger Sub2MenuPage;
@property NSInteger Folder1MenuPage;
@property NSInteger Folder2MenuPage;
@property NSInteger ArrangeMenuPage;
@property NSInteger ArrangeMenuPageNo;//アレンジの各個ページ
@property NSInteger TrayMenuPageNo;//トレイ商品の各個ページ
@property (nonatomic, strong) NSString *TrayNo;//トレイ商品の各個ページ
@property (nonatomic, strong) NSString *orderMessage;

@property BOOL isMove;
@property NSInteger typeOrder;


@property (nonatomic, strong) NSMutableArray *tableIDList;
@property (nonatomic, strong) NSMutableArray *tantoList;
@property (nonatomic, strong) NSMutableArray *tableStatusList;
@property (nonatomic, strong) NSMutableArray *syohinStatusList;

+ (DataList *)sharedInstance;
- (void)reloadTantoList;
- (void)clearData;
- (BOOL)tableCheck:(id)delegate
              type:(int)type;
+(NSString*)appendComma:(NSString*)price;
+(int)intValue:(NSString*)price;

//2014-09-05 ueda
@property (nonatomic, strong) NSMutableArray *typeCseatSelect;      //入力タイプＣの選択した席番
//2014-09-10 ueda
@property (nonatomic, strong) NSMutableDictionary *typeCeditSyohin; //入力タイプＣの選択した（修正する）商品
//2015-03-24 ueda
@property NSInteger Pay_Total;                          //（宿掛専用）ポケレジ　注文合計
@property (nonatomic, strong) NSString *Pay_DenNo;      //（宿掛専用）ポケレジ　伝票番号


@end
