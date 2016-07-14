//
//  OrderManager.h
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface OrderManager : NSObject{
    int currentPage;
}

+ (id)allocWithZone:(NSZone *)zone;
+ (OrderManager *)sharedInstance;


//共通データ操作
- (void)zeroReset;
//2014-10-02 ueda
- (void)zeroReset2;

//メニュー情報の取得
- (NSArray*)getCategoryList;
- (NSArray*)getFolderCategoryList:(NSInteger)layer;
- (NSArray*)getArrangeCategoryList;
- (NSArray*)getSubCategoryList:(NSDictionary*)_dic;
- (NSArray*)getMenuList:(NSDictionary*)_dic;
- (NSArray*)getFolderMenuList:(NSString*)code
                       index1:(NSString*)index1
                       index2:(NSString*)index2
                        layer:(NSInteger)layer
                        page1:(NSInteger)page1
                        page2:(NSInteger)page2;
- (NSArray*)getSubMenuList:(NSDictionary*)_dic;

- (NSMutableDictionary*)getCategory:(NSString*)CateCD;
- (NSMutableDictionary*)getSubCategory:(NSString*)SyohinCD
                              CondiGDID:(NSString*)CondiGDID;
- (NSMutableDictionary*)getMenuForCancel:(NSString*)SyohinCD;

- (NSMutableDictionary*)getMenu:(NSString*)SyohinCD;//ﾁｪｯｸ表示用
- (NSMutableDictionary*)getCondi:(NSString*)CD;//ﾁｪｯｸ表示用
- (NSMutableDictionary*)getComment:(NSString*)CD;//ﾁｪｯｸ表示用
- (NSMutableDictionary*)getOffer:(NSString*)CD;//ﾁｪｯｸ表示用

- (NSMutableDictionary*)getSubMenu:(NSString*)TopSyohinCD //取り消し＆分割時の伝票通信取得時に使用
                          GroupType:(NSString*)GroupType
                            GroupCD:(NSString*)GroupCD
                          CondiGDID:(NSString*)CondiGDID
                                 SG:(int)SG;

- (NSMutableDictionary*)reloadMenu:(NSMutableDictionary*)_menu;
- (NSInteger)getTrayTotal:(NSString*)SyohinCD;
//2016-02-02 ueda
- (NSInteger)getTrayTotalTypeC:(NSString*)SyohinCD
                    SeatNumber:(NSString*)SeatNumber
                     OrderType:(NSString*)OrderType;
//2015-10-28 ueda
//- (NSInteger)getTrayTotalForCancel:(NSString*)SyohinCD;
- (NSInteger)getTrayTotalForCancel:(NSString*)SyohinCD
                             EdaNo:(NSString*)EdaNo;
- (NSArray*)getTrayList:(NSString*)SyohinCD;

//オーダーの追加
- (void)addTopMenu:(NSDictionary*)_menu;
- (void)addSubMenu:(NSDictionary*)_menu
                SG:(NSInteger)SG;
- (void)addArrangeMenu:(NSMutableDictionary*)_menu
                update:(BOOL)enable;
- (NSMutableArray*)getOrderList:(NSInteger)type; //0 = normal 1 = cancel&divide
//2015-02-16 ueda
- (NSMutableArray*)getOrderListForConfirm:(BOOL)isCancel
                               isSubGroup:(BOOL)isSubGroup
                                isArrange:(BOOL)isArrange
                              typeOrderNo:(int)typeOrderNo;
- (NSMutableArray*)getOrderListForDivide;//送信用

//2014-09-11 ueda
- (NSMutableArray*)getOrderListTypeC_Header:(int)type; //送信用ヘッダー
- (NSMutableArray*)getOrderListTypeC_Detail:(int)type  //送信用明細
                                 seatNumber:(NSString*)seatNumber
                                  orderType:(NSString*)orderType;
- (NSMutableArray*)getOrderListTypeCForSummary:(int)type; //オーダーサマリー表示用

//入力値判定
- (NSInteger)entryIsEnabled:(NSMutableDictionary*)_menu
                  key:(NSString*)key;
//2015-12-24 ueda ASTERISK
- (NSInteger)entryIsEnabled:(NSMutableDictionary*)_menu
                        key:(NSString*)key
                 checkCount:(NSInteger)_checkCount;
- (BOOL)checkArangeIsEnable:(NSString*)TopSyohinCD;
- (BOOL)checkArangeIsEnableForSub1:(NSString*)TopSyohinCD
                      Sub1SyohinCD:(NSString*)Sub1SyohinCD;
- (BOOL)checkArangeMenuIsExit;

- (BOOL)keppinCheck:(NSString*)SyohinCD;
//- (int)keppinRetainCount:(NSString*)SyohinCD;
-(NSString*)appendSpace:(NSString*)str
            totalLength:(int)length;
//2014-09-08 ueda
-(void)typeCcopyDB;
-(void)typeCclearDB;
//2014-09-09 ueda
-(NSMutableArray*)getSeatNumberData;
-(void)typeCrestoreDB:(NSInteger)orderIndex;
//2014-10-01 ueda
-(void)typeCrestoreDBall;
-(NSString*)getCategoryCode:(NSString*)syohinCode;
//2014-09-16 ueda
-(void)addMenuExtMt:(NSString*)arrangeText;
//2014-09-18 ueda
-(void)updateNoteMt:(NSString*)code
         modifyName:(NSString*)modifyName;
//2015-06-01 ueda
- (NSMutableArray*)loadOrderStatus:(NSInteger)type;
- (NSMutableArray*)loadReserveList:(NSInteger)type;

@end
