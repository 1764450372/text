//
//  NetWorkManager.h
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"


#include <stdio.h>
#include <string.h>

@class GCDAsyncSocket;


typedef enum
{
    //システム
    RequestTypeSystem,//[N0101]
    RequestTypeSystemMt,//[N0101]
    
    //2015-03-24 ueda
    RequestTypeRegiMt,//[N0102]
    
    //テーブルID
    RequestTypeTableID,//[N0103]
    
    //担当
    RequestTypeTanto,//[N0104]
    
    //メニュー
    RequestTypeCategoryGet,//[N0105]
    RequestTypeMenuGet,//[N0106]
    RequestTypeMenuGet1,//[N0107]
    RequestTypeMenuGet2,//[N0108]
    
    RequestTypeMenuInfoGet,//[N0109]
    RequestTypeMenuInfoGet1,//[N0110]
    RequestTypeMenuInfoGet2,//[N0111]
    
    RequestTypeCondimentGet,//[N0112]
    RequestTypeCommentGDGet,//[N0113]
    RequestTypeCommentGet,//[N0114]
    RequestTypeOfferGDGet,//[N0115]
    RequestTypeOfferGet,//[N0116]
    RequestTypeNoteGet,//[N0117]
    //2014-07-16 ueda
    RequestTypeColorGet,//[N0119]
    RequestTypeKyakusoGet,//[N0123]
    RequestTypePatternGet,//[N0124]
    
    RequestTypeKokyakuInfoGet,//[N65]
    
    //テーブル
    RequestTypeTableStatus,//[N11]
    RequestTypeTableReadyFinish,//[N12]
    RequestTypeTableMove,//[N13]
    RequestTypeTableReserve,//[N14]
    RequestTypeTableSyohin,//[N15]
    RequestTypeTableTaiki,//[N16]
    RequestTypeTableInShow,//[N17]
    RequestTypeTableInShow2,//[N17]その2
    RequestTypeTableEmpty,//[N18]
    RequestTypeTableKeyID,//[N23]
    RequestTypeTableExtension,//[N24]

    //注文
    RequestTypeOrderRequest,//[N31]
    RequestTypeOrderDirection,//[C31]
    RequestTypeOrderKeppin,//[N31]
    //RequestTypeOrderAdd,//[N31]
    //RequestTypeOrderGetForCancel,//[N32]
    //RequestTypeOrderCancel,//[N31]
    
    //伝票関係
    RequestTypeVoucherList,//[N21]
    RequestTypeVoucherNo,//[N21]番号以外
    RequestTypeVoucherTable,
    RequestTypeTableReadyDirection,//[C12]
    RequestTypeVoucherDirection,//[C21]
    RequestTypeVoucherDetail,//[N32]
    RequestTypeVoucherDividePrint, //[N22]
    RequestTypeVoucherDivideNotPrint, //[N22]
    RequestTypeVoucherCheck, //[N41]
    RequestTypeVoucherPrint, //[N43]
    RequestTypeVoucherPush, //[N42]
    
    RequestTypeVoucherSearch, //[P21]
    
    RequestTypeSendVoice,
    
    //2014-09-12 ueda
/*
    //2014-09-08 ueda
    RequestTypeOrderRequestTypeC,//[X31]
*/
    //2014-09-12 ueda
    RequestTypeVoucherListTypeC,//[X21]
    RequestTypeVoucherDetailTypeC,//[X32]
    
    //2015-03-24 ueda
    RequestTypePokeRegiStart,   //[N61]
    RequestTypePokeRegiFinish,  //[N66]
    RequestTypePokeRegiCancel,  //[N68]
    
    //2015-05-12 ueda
    RequestTypeClearMessage,    //N72
    
    //2015-06-01 ueda
    RequestTypeOrderStat,       //N45
    RequestTypeReserveList,     //N46
    
    //2016-01-05 ueda ASTERISK
    RequestTypeOrderNinzu,      //A27
    
    RequestTypeDummyLast
    
} RequestType;


@protocol NetWorkManagerDelegate <NSObject>
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(NSInteger)type;
-(void)didFinishReadWithError:(NSError*)_error
                     msg:(NSString*)_msg
                         type:(NSInteger)type;
@optional
-(void)setStatusText:(NSString*)text stepCount:(NSInteger)_count;
@end

@interface NetWorkManager : NSObject<NSStreamDelegate>{
    GCDAsyncSocket *asyncSocket;
    NSMutableDictionary *socketList;
    
    NSString *voucherSection;
    
    BOOL isMaster;
    BOOL isOpen;
    
    NSInteger seqNum;
    RequestType currentType;
    
    NSMutableString *appendData;
    //2015-12-25 ueda
    NSMutableData *recvDataAll;
    
    NSInteger maxLength;
    
    System *sys;
    GCDAsyncUdpSocket *usocket;
    
    NSString *lastRecieveData;
    
    //2014-10-29 ueda
    NSMutableString *preDateString;
}

@property (strong, nonatomic) FMDatabase* db;
@property (strong, nonatomic) NSString *orderResultMsg;
@property (strong, nonatomic) id voiceDelegate;
@property (strong, nonatomic) NSMutableArray *voiceList;

+ (id)allocWithZone:(NSZone *)zone;
//+ (id)sharedInstance;
+ (NetWorkManager *)sharedInstance;

- (void)openDb;
- (void)closeDb;
- (void)clearCacheData;

- (void)createDateBase;
- (void)deleteAllData;
//- (void)socketOpen;
- (void)writeAndRead:(NSString*)_request
         requestType:(RequestType)_requestType
            delegate:(id)_delegate;
//2014-10-29 ueda
- (void)writeAndReadRetry:(NSString*)_request
              requestType:(RequestType)_requestType
                 delegate:(id)_delegate
                retryFlag:(BOOL)_retryFlag;
//- (NSMutableDictionary*)dictionaryWithSock:(GCDAsyncSocket *)sock;


//ブロードキャストテスト
- (void)readyForBroadCastReceive;
- (void)finishForBroadCastReceive;


//Request Method
//システム
- (void)getSystemSetting:(id)delegate
                   count:(NSInteger)_count;

- (void)getMasterData:(id)delegate
                   count:(NSInteger)_count;

//テーブルID
- (void)getTableID:(id)delegate
             count:(NSInteger)_count;

//担当
- (void)getTanto:(id)delegate
           count:(NSInteger)_count;


//メニュー
- (void)getCategory:(id)delegate
              count:(NSInteger)_count;
- (void)getMenu:(id)delegate
          count:(NSInteger)_count;
- (void)getMenu1:(id)delegate
           count:(NSInteger)_count;
- (void)getMenu2:(id)delegate
           count:(NSInteger)_count;

- (void)getMenuInfo:(id)delegate
           count:(NSInteger)_count;
- (void)getMenuInfo1:(id)delegate
              count:(NSInteger)_count;
- (void)getMenuInfo2:(id)delegate
              count:(NSInteger)_count;
- (void)getCondiment:(id)delegate
               count:(NSInteger)_count;
- (void)getCommentGD:(id)delegate
               count:(NSInteger)_count;
- (void)getComment:(id)delegate
               count:(NSInteger)_count;

- (void)getOffer:(id)delegate
               count:(NSInteger)_count;
- (void)getNote:(id)delegate
          count:(NSInteger)_count;
- (void)getKyakuso:(id)delegate
             count:(NSInteger)_count;
- (void)getPattern:(id)delegate
             count:(NSInteger)_count;
//2014-07-16 ueda
- (void)getColor:(id)delegate
           count:(NSInteger)_count;
//2015-03-24 ueda
- (void)getRegiMt:(id)delegate
           count:(NSInteger)_count;

//その他
- (void)getKokyaku:(id)delegate
             count:(NSInteger)_count;

//テーブル
- (void)getTableStatus:(id)delegate;//[N11]
- (void)getTableStatusDirection:(id)delegate;//[C11]
- (void)sendTableReadyFinish:(id)delegate;//[N12]
- (void)sendTableReadyDirection:(id)delegate;//[C12]
- (void)sendTableMove:(id)delegate;//[N13]
- (void)getTableReserve:(id)delegate;//[N14]
- (void)getTableSyohin:(id)delegate;//[N15]
- (void)sendTableTaiki:(id)delegate;//[N16]
- (void)sendTableInShow:(id)delegate;//[N17]
- (void)sendTableInShow2:(id)delegate;//[N17]その2
- (void)sendTableEmpty:(id)delegate;//[N18]
- (void)getTableKeyID:(id)delegate;//[N23]
- (void)sendTableExtension:(NSString*)time
                     KeyID:(NSString*)KeyID
                  delegate:(id)delegate;//[N24]

//注文
//2014-10-29 ueda
//- (void)sendOrderRequest:(id)delegate;
- (void)sendOrderRequest:(id)delegate
               retryFlag:(BOOL)_retryFlag;
//2014-09-08 ueda
//2014-10-29 ueda
//- (void)sendOrderRequestTypeC:(id)delegate;
- (void)sendOrderRequestTypeC:(id)delegate
                    retryFlag:(BOOL)_retryFlag;
//2014-10-29 ueda
//- (void)sendOrderAdd:(id)delegate;
- (void)sendOrderAdd:(id)delegate
           retryFlag:(BOOL)_retryFlag;
//- (void)getOrderForCancel:(id)delegate;
//2014-09-11 ueda
//2014-10-29 ueda
//- (void)sendOrderAddTypeC:(id)delegate;
- (void)sendOrderAddTypeC:(id)delegate
                retryFlag:(BOOL)_retryFlag;
//2014-10-29 ueda
//- (void)sendOrderCancel:(id)delegate;
- (void)sendOrderCancel:(id)delegate
              retryFlag:(BOOL)_retryFlag;
//2014-09-12 ueda
//2014-10-29 ueda
//- (void)sendOrderCancelTypeC:(id)delegate;
- (void)sendOrderCancelTypeC:(id)delegate
                   retryFlag:(BOOL)_retryFlag;
- (void)sendOrderDirection:(id)delegate
                      list:(NSArray*)_list;

//伝票関係
- (void)getVoucherList:(id)delegate;
//2014-09-11 ueda
- (void)getVoucherListTypeC:(id)delegate;
- (void)getVoucherDirection:(id)delegate;
- (void)getVoucherDetail:(id)delegate;
//2014-09-11 ueda
- (void)getVoucherDetailTypeC:(id)delegate;
//2014-10-30 ueda
//- (void)sendVoucherDivide:(id)delegate
//                     type:(NSString*)type;
- (void)sendVoucherDivide:(id)delegate
                     type:(NSString*)type
                retryFlag:(BOOL)_retryFlag;
- (void)getVoucherCheck:(id)delegate;
- (void)sendVoucherPrint:(id)delegate;
- (void)sendVoucherPush:(id)delegate
                  edaNo:(NSInteger)edaNo
                choice1:(NSInteger)choice1
                choice2:(NSInteger)choice2;
- (void)getVoucherSearch:(id)delegate
                    word:(NSString*)word;


- (void)sendVoice:(id)delegate
           urlStr:(NSString*)urlStr;



-(NSString*)appendSpace:(NSString*)str
            totalLength:(NSInteger)length;

#pragma mark Socket Data Convert to class
- (BOOL)convertForSystemSettingMaster:(NSString*)_msg;
- (BOOL)convertForSystemSetting:(NSString*)_msg;
- (void)convertFotTableID:(NSString*)_msg;
- (NSArray*)convertFotTanto:(NSString*)_msg;
- (void)convertForCategoty:(NSString*)_msg;
- (void)convertForMenu:(NSString*)_msg;
- (void)convertForMenu1:(NSString*)_msg;
- (void)convertForMenu2:(NSString*)_msg;
- (void)convertForMenuInfo:(NSString*)_msg;
- (void)convertForMenuInfo1:(NSString*)_msg;
- (void)convertForMenuInfo2:(NSString*)_msg;
- (void)convertForCondiment:(NSString*)_msg;
- (void)convertForCommentGD:(NSString*)_msg;
- (void)convertForComment:(NSString*)_msg;
- (void)convertForOfferGD:(NSString*)_msg;
- (void)convertForOffer:(NSString*)_msg;

- (void)convertForNote:(NSString*)_msg;
- (void)convertForKyakuso:(NSString*)_msg;
- (void)convertForPattern:(NSString*)_msg;
//2014-07-16 ueda
- (void)convertForColor:(NSString*)_msg;
//2015-03-24 ueda
- (void)convertForRegiMt:(NSString*)_msg;


- (NSArray*)convertDataForTable:(NSString*)_msg;
- (NSString*)convertDataKeppin:(NSString*)_msg;
- (NSMutableArray*)convertTableMenu:(NSString*)_msg;
- (NSDictionary*)convertForTableReserve:(NSString*)_msg;

- (NSString*)convertForOrderRequest:(NSMutableArray*)_array
                               type:(NSString*)type; //1=新規 2=追加　3=取消
//2014-09-11 ueda
- (NSString*)convertForOrderRequestTypeC_Header:(NSString*)type; //1=新規 2=追加　3=取消
//2014-09-11 ueda
- (NSString*)convertForOrderRequestTypeC_Detail:(NSMutableArray*)_array
                                           type:(NSString*)type; //1=新規 2=追加　3=取消

- (NSString*)convertForOrderDirection:(NSArray*)_array;//調理指示POST

- (NSArray*)convertVoucherList:(NSString*)_msg;
//2014-10-23 ueda
- (NSArray*)convertVoucherListTypeC:(NSString*)_msg;
- (NSArray*)convertVoucherDirection:(NSString*)_msg;//調理指示GET
- (void)convertVoucherDetail:(NSString*)_msg;
//2014-09-12 ueda
- (void)convertVoucherDetailTypeC:(NSString*)_msg;
- (NSArray*)convertForVoucherDivideResult:(NSString*)_msg;
- (NSDictionary*)convertVoucherCheck:(NSString*)_msg;


#pragma mark Ftp Request client
- (NSURL *)smartURLForString:(NSString *)str;
- (BOOL)isImageURL:(NSURL *)url;
- (NSString *)pathForTestImage:(NSUInteger)imageNumber;
- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix;
@property (nonatomic, assign ,readwrite) NSUInteger     networkOperationCount;  // observable
- (void)didStartNetworkOperation;
- (void)didStopNetworkOperation;

//2015-02-04 ueda
- (void)sendTableDeleteCalled:(id)delegate;//[F02]

//2015-03-24 ueda
- (void)pokeRegiStart:(id)delegate retryFlag:(BOOL)_retryFlag;      //[N61]
- (void)pokeRegiFinish:(id)delegate retryFlag:(BOOL)_retryFlag;     //[N66]
- (void)pokeRegiCancel:(id)delegate retryFlag:(BOOL)_retryFlag;     //[N68]
- (void)convertPokeRegiStart:(NSString*)_msg;

//2014-03-18 ueda for 漢字
- (NSString*)getShiftJisMid:(NSString*)orgStr
                   startPos:(NSInteger)sp
                     length:(NSInteger)lg;
//2015-05-12 ueda
- (void)clearMessage:(id)delegate;      //N72

//2015-06-05 ueda
- (void)getOrderStat:(id)delegate count:(NSInteger)_count;
- (int)convertAndSaveOrderStat:(NSString*)_msg count:(NSInteger)_count;
- (void)getReserveList:(id)delegate count:(NSInteger)_count;
- (int)convertAndSaveReserveList:(NSString*)_msg count:(NSInteger)_count;

//2016-01-05 ueda ASTERISK
- (void)sendOrderNinzu:(id)delegate;

@end
