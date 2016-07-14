//
//  System.h
//  Order
//
//  Created by koji kodama on 13/04/09.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface System : NSObject


@property (nonatomic, strong) NSString* masterVer;
@property (nonatomic, strong) NSString* menuPattern;
@property (nonatomic, strong) NSString* aiseki;
@property (nonatomic, strong) NSString* ninzu;
@property (nonatomic, strong) NSString* zeronin;
@property (nonatomic, strong) NSString* orderType;
@property (nonatomic, strong) NSString* getMaster;

@property (nonatomic, strong) NSDictionary *currentTanto;
@property (nonatomic, strong) NSString *currentCategory;


//1111
@property (nonatomic, strong) NSString* tanmatsuID;
@property (nonatomic, strong) NSString* hostIP;
@property (nonatomic, strong) NSString* port;//設定では表示しない
@property (nonatomic, strong) NSString* timeout;
@property (nonatomic, strong) NSString* entryType;
@property (nonatomic, strong) NSString* voucherType;
@property (nonatomic, strong) NSString* nonselect;
@property (nonatomic, strong) NSString* sound;
@property (nonatomic, strong) NSString* transceiver;

//2222
//2015-04-14 ueda
@property (nonatomic, strong) NSString* tableMultiSelect    ;//テーブル選択 複数／単一
@property (nonatomic, strong) NSString* printOut1;//出力先の固定
@property (nonatomic, strong) NSString* printOut2;//出力先の設定
//2015-06-01 ueda
@property (nonatomic, strong) NSString* useOrderStatus;
//2015-09-17 ueda
@property (nonatomic, strong) NSString* useOrderConfirm;

//3333
@property (nonatomic, strong) NSString* tableType;
@property (nonatomic, strong) NSString* codeType;//コード注文
@property (nonatomic, strong) NSString* kakucho1Type;
//2015-03-24 ueda
@property (nonatomic, strong) NSString* RegisterType;
@property (nonatomic, strong) NSString* PaymentType;
@property (nonatomic, strong) NSString* searchType;
@property (nonatomic, strong) NSString* regularCategory;//既存カテゴリ移動
//2014-08-19 ueda
@property (nonatomic, strong) NSString* useBarcode;

//4444
@property (nonatomic, strong) NSString* menuPatternEnable;
@property (nonatomic, strong) NSString* menuPatternType;//設定したメニューパターン
@property (nonatomic, strong) NSString* sectionCD;
//2014-12-12 ueda
@property (nonatomic, strong) NSString* childInputOnOff;
//2015-04-20 ueda
@property (nonatomic, strong) NSString* staffCodeInputOnOff;
//2015-06-17 ueda
@property (nonatomic, strong) NSString* staffCodeKetaKbn;
@property (nonatomic, strong) NSString* staffCodeKetaStr;   // 6 or 2

//6666
@property (nonatomic, strong) NSString* bunkatsuType;
@property (nonatomic, strong) NSString* kakucho2Type;
@property (nonatomic, strong) NSString* choriType;

//8888
@property (nonatomic, strong) NSString* training;

//9999
@property (nonatomic, strong) NSString* lang;
@property (nonatomic, strong) NSString* money;
//2014-09-05 ueda
@property (nonatomic, strong) NSString* typeCseatCaptionType;//座席表示形式（０：英字、１：数字）

//0000
@property (nonatomic, strong) NSString* demo;


@property (nonatomic, strong) NSString* ftp_user;
@property (nonatomic, strong) NSString* ftp_password;


//9061
//2014-10-28 ueda
@property (nonatomic, strong) NSString* transitionOnOff;
@property (nonatomic, strong) NSString* scrollOnOff;
//2014-10-30 ueda
@property (nonatomic, strong) NSString* home_back;
//2015-11-18 ueda ASTERISK_TEST
@property (nonatomic, strong) NSString* categoryCount;

//2016-04-08 ueda
@property (nonatomic, strong) NSString* notSleepOnOff;
@property (nonatomic, strong) NSString* notOpeCheckOnOff;
@property (nonatomic, strong) NSString* notOpeCheckSecNormal;
@property (nonatomic, strong) NSString* notOpeCheckSound;
@property (nonatomic, strong) NSString* notOpeCheckVib;
@property (nonatomic, strong) NSString* notOpeCheckSecAlert;

+ (System *)sharedInstance;
+ (System *)loadInstance;

/**
 *  アカウントデータをキャッシュする。
 */
- (void)saveChacheAccount;

/**
 *  アカウント情報がキャッシュされているかどうかをチェックする
 *  @return アカウント情報の有無
 */
+ (BOOL)existCacheAccount;

+ (BOOL)is568h;
+ (void)tapSound;
+ (void)adjustStatusBarSpace:(UIView*)view;

+ (UIImage *)imageWithColor:(UIColor *)color;
+ (UIImage *)imageWithColorAndRect:(UIColor *)color bounds:(CGRect)rect;
+ (UIImage *)imageWithColorAndRectFullSize:(UIColor *)color bounds:(CGRect)rect;
+ (void)barcodeScanSound;
+ (void)soundPlayFile:(NSString *)fileName;
+ (NSString*)getByteText:(NSString*)orgStr length:(NSInteger)byteLength;
+ (NSString*)convertOnlyShiftjisText:(NSString*)orgStr;
@end
