//
//  System.m
//  Order
//
//  Created by koji kodama on 13/04/09.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "System.h"
#import <AudioToolbox/AudioToolbox.h>

//2016-04-08 ueda
#import "CustomWindow.h"

@implementation System

#define SharedInstanceImplementation

static NSString * const kCasheAccount = @"chacheSystem";
//static System* sharedInstance = nil;


/**
 *  共有インスタンスを返す
 */
+ (System *)sharedInstance
{
    static System *_sharedInstance = nil;
    //static dispatch_once_t onceToken;
    //dispatch_once(&onceToken, ^{
        
        NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
        NSData *getData = (NSData*)[ud objectForKey:kCasheAccount];
        if (getData) {
            _sharedInstance = (System *)[NSKeyedUnarchiver
                                               unarchiveObjectWithData:getData];
            //LOG(@"Data is enable:%@",_sharedInstance.hostIP);
        }
        else {
            //LOG(@"Data is unenable");
            _sharedInstance = [[System alloc] init];
        }
    //});
    
    return _sharedInstance;
}

+ (BOOL)is568h
{
    static BOOL is568h;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        CGFloat height = [UIScreen mainScreen].bounds.size.height;
        is568h = height == 568.f;
    });
    return is568h;
}


/**
 *  アカウント情報がキャッシュされているかどうかをチェックする
 *  @return アカウント情報の有無
 */
+ (BOOL)existCacheAccount
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *getData = (NSData*)[ud
                                objectForKey:kCasheAccount];
    if (getData) {
        System *_sharedInstance = (System *)[NSKeyedUnarchiver
                                                         unarchiveObjectWithData:getData];
        LOG(@"masterVer =    %@", _sharedInstance.masterVer);
        LOG(@"masterVer =    %@", _sharedInstance.hostIP);

        if (_sharedInstance.masterVer && _sharedInstance.menuPattern) {
            return YES;
        }
    }
    
    return NO;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (id)init{
    self = [super init];
    if (self != nil)
    {
        //InitialSetting
        self.masterVer = @"00";
        self.menuPattern = @"0";
        self.aiseki = @"0";
        self.ninzu = @"1";
        self.zeronin = @"1";
        self.orderType = @"0";
        self.getMaster = @"0";
        
        self.currentTanto = nil;
        self.currentCategory = @"0";
        
        
        //1111
        self.tanmatsuID = @"0030";
        self.hostIP = @"192.168.1.1";
        //self.hostIP = @"192.168.0.222";//HayashiCom様
        //self.hostIP = @"192.168.11.14";//HayashiCom様2
        ///self.hostIP = @"192.168.11.26";//Local Test
        self.port = @"1111";
        self.timeout = @"10";
        self.entryType = @"0";
        //2014-11-20 ueda
        self.voucherType = @"0";
        self.nonselect = @"1";
        self.sound = @"0";
        self.transceiver = @"1";
        
        //2222
        //2015-04-14 ueda
        self.tableMultiSelect = @"0";   //テーブル選択 複数／単一
        //2015-06-26 ueda
        self.printOut1 = @"1";//出力先の固定
        self.printOut2 = @"1";//出力先の設定
        //2015-06-01 ueda
        self.useOrderStatus = @"0";
        //2015-09-17 ueda
        self.useOrderConfirm = @"1";

        //3333
        self.tableType = @"0";
        self.codeType = @"0";
        self.kakucho1Type = @"1";
        //2015-03-24 ueda
        self.RegisterType = @"0";
        self.PaymentType = @"0";
        self.searchType = @"1";
        self.regularCategory = @"0";
        //2014-08-19 ueda
        self.useBarcode = @"1";
        
        //4444
        self.menuPatternEnable = @"1";
        self.menuPatternType = @"";
        self.sectionCD = @"";
        //2014-12-12 ueda
        self.childInputOnOff = @"0";
        //2015-04-20 ueda
        self.staffCodeInputOnOff = @"0";
        //2015-06-17 ueda
        self.staffCodeKetaKbn = @"0";
        self.staffCodeKetaStr = @"2";
        
        //6666
        self.bunkatsuType = @"1";
        self.kakucho2Type = @"1";
        //2014-11-20 ueda
        self.choriType = @"1";
        
        //8888
        self.training = @"0";
        
        //9999
        self.lang = @"0";
        self.money = @"0";
        //2014-09-05 ueda
        self.typeCseatCaptionType = @"0";
        
        //0000
        self.demo = @"0";
        
        self.ftp_user = @"ftp_user";
        self.ftp_password = @"ftp5678";
        //self.ftp_user = @"kodama";
        //self.ftp_password = @"kodama";
        
        //2014-10-30 ueda
        //9061
        self.transitionOnOff = @"0";
        self.scrollOnOff     = @"0";
        self.home_back       = @"";
        
        //2015-11-18 ueda ASTERISK_TEST
        self.categoryCount = @"10";
        
        //2016-04-08 ueda
        self.notSleepOnOff     = @"0";
        self.notOpeCheckOnOff  = @"1";
        self.notOpeCheckSecNormal = @"120";
        self.notOpeCheckSound  = @"1";
        self.notOpeCheckVib    = @"1";
        self.notOpeCheckSecAlert = @"15";
        
        //2016-01-05 ueda ASTERISK
        if (YES) {
            //初期値変更
            self.tableType           = @"1";    //テーブルコード入力
            self.kakucho1Type        = @"0";    //拡張設定：アレンジ
            self.staffCodeInputOnOff = @"1";    //担当者コード入力
            self.kakucho2Type        = @"0";    //拡張入力２：客層
            self.categoryCount       = @"7";    //カテゴリー表示数
            self.scrollOnOff         = @"1";    //スクロール
        }
    }
    
    return self;
}

/**
 *  NSCodeDelegate
 */
- (void)encodeWithCoder:(NSCoder *)coder
{
    [coder encodeObject:self.masterVer forKey:@"masterVer"];
    [coder encodeObject:self.menuPattern forKey:@"menuPattern"];
    [coder encodeObject:self.aiseki forKey:@"aiseki"];
    [coder encodeObject:self.ninzu forKey:@"ninzu"];
    [coder encodeObject:self.zeronin forKey:@"zeronin"];
    [coder encodeObject:self.orderType forKey:@"orderType"];
    [coder encodeObject:self.getMaster forKey:@"getMaster"];
    
    [coder encodeObject:self.currentTanto forKey:@"currentTanto"];
    [coder encodeObject:self.currentCategory forKey:@"currentCategory"];
    
    //1111
    [coder encodeObject:self.tanmatsuID forKey:@"tanmatsuID"];
    [coder encodeObject:self.hostIP forKey:@"hostIP"];
    [coder encodeObject:self.port forKey:@"port"];
    [coder encodeObject:self.timeout forKey:@"timeout"];
    [coder encodeObject:self.entryType forKey:@"entryType"];
    [coder encodeObject:self.voucherType forKey:@"voucherType"];
    [coder encodeObject:self.nonselect forKey:@"nonselect"];
    [coder encodeObject:self.sound forKey:@"sound"];
    [coder encodeObject:self.transceiver forKey:@"transceiver"];
    
    //2222
    //2015-04-14 ueda
    [coder encodeObject:self.tableMultiSelect forKey:@"tableMultiSelect"];
    [coder encodeObject:self.printOut1 forKey:@"printOut1"];
    [coder encodeObject:self.printOut2 forKey:@"printOut2"];
    //2015-06-01 ueda
    [coder encodeObject:self.useOrderStatus forKey:@"useOrderStatus"];
    //2015-09-17 ueda
    [coder encodeObject:self.useOrderConfirm forKey:@"useOrderConfirm"];
    
    //3333
    [coder encodeObject:self.tableType forKey:@"tableType"];
    [coder encodeObject:self.codeType forKey:@"codeType"];
    [coder encodeObject:self.kakucho1Type forKey:@"kakucho1Type"];
    //2015-03-24 ueda
    [coder encodeObject:self.RegisterType forKey:@"RegisterType"];
    [coder encodeObject:self.PaymentType forKey:@"PaymentType"];
    [coder encodeObject:self.searchType forKey:@"searchType"];
    [coder encodeObject:self.regularCategory forKey:@"regularCategory"];
    //2014-08-19 ueda
    [coder encodeObject:self.useBarcode forKey:@"useBarcode"];
    
    
    [coder encodeObject:self.menuPatternEnable forKey:@"menuPatternEnable"];
    [coder encodeObject:self.menuPatternType forKey:@"menuPatternType"];
    [coder encodeObject:self.sectionCD forKey:@"sectionCD"];
    //2014-12-12 ueda
    [coder encodeObject:self.childInputOnOff forKey:@"childInputOnOff"];
    //2015-04-20 ueda
    [coder encodeObject:self.staffCodeInputOnOff forKey:@"staffCodeInputOnOff"];
    //2015-06-17 ueda
    [coder encodeObject:self.staffCodeKetaKbn forKey:@"staffCodeKetaKbn"];
    if ([self.staffCodeKetaKbn isEqualToString:@"1"]) {
        self.staffCodeKetaStr = @"6";
    } else {
        self.staffCodeKetaStr = @"2";
    }
    [coder encodeObject:self.staffCodeKetaStr forKey:@"staffCodeKetaStr"];
    
    //6666
    [coder encodeObject:self.bunkatsuType forKey:@"bunkatsuType"];
    [coder encodeObject:self.kakucho2Type forKey:@"kakucho2Type"];
    [coder encodeObject:self.choriType forKey:@"choriType"];
    
    //8888
    [coder encodeObject:self.training forKey:@"training"];
    
    //9999
    [coder encodeObject:self.lang forKey:@"lang"];
    [coder encodeObject:self.money forKey:@"money"];
    //2014-09-05 ueda
    [coder encodeObject:self.typeCseatCaptionType forKey:@"typeCseatCaptionType"];
    
    //0000
    [coder encodeObject:self.demo forKey:@"demo"];
    
    [coder encodeObject:self.ftp_user forKey:@"ftp_user"];
    [coder encodeObject:self.ftp_password forKey:@"ftp_password"];

    //9061
    //2014-10-28 ueda
    [coder encodeObject:self.transitionOnOff forKey:@"transitionOnOff"];
    [coder encodeObject:self.scrollOnOff forKey:@"scrollOnOff"];
    //2014-10-30 ueda
    [coder encodeObject:self.home_back forKey:@"home_back"];
    //2015-11-18 ueda ASTERISK_TEST
    [coder encodeObject:self.categoryCount forKey:@"categoryCount"];
    
    //2016-04-08 ueda
    [coder encodeObject:self.notSleepOnOff     forKey:@"notSleepOnOff"];
    [coder encodeObject:self.notOpeCheckOnOff  forKey:@"notOpeCheckOnOff"];
    [coder encodeObject:self.notOpeCheckSecNormal forKey:@"notOpeCheckSecNormal"];
    [coder encodeObject:self.notOpeCheckSound  forKey:@"notOpeCheckSound"];
    [coder encodeObject:self.notOpeCheckVib    forKey:@"notOpeCheckVib"];
    [coder encodeObject:self.notOpeCheckSecAlert forKey:@"notOpeCheckSecAlert"];
}


/**
 *  NSCodeDelegate
 */
- (id)initWithCoder:(NSCoder *)coder
{
    self = [super init];
    
    if (self != nil)
    {
        self.masterVer = [coder decodeObjectForKey:@"masterVer"];
        self.menuPattern = [coder decodeObjectForKey:@"menuPattern"];
        self.aiseki = [coder decodeObjectForKey:@"aiseki"];
        self.ninzu = [coder decodeObjectForKey:@"ninzu"];
        self.zeronin = [coder decodeObjectForKey:@"zeronin"];
        self.orderType = [coder decodeObjectForKey:@"orderType"];
        self.getMaster = [coder decodeObjectForKey:@"getMaster"];
        
        self.currentTanto = [coder decodeObjectForKey:@"currentTanto"];
        self.currentCategory = [coder decodeObjectForKey:@"currentCategory"];
        //2016-03-16 ueda
        if (YES) {
            NSInteger index = [self.currentCategory intValue];
            if ((index >= 0) && (index <= 19)) {
                //正常な場合
            } else {
                self.currentCategory = @"0";
            }
        }

        //1111
        self.tanmatsuID = [coder decodeObjectForKey:@"tanmatsuID"];
        self.hostIP = [coder decodeObjectForKey:@"hostIP"];
        self.port = [coder decodeObjectForKey:@"port"];
        self.timeout = [coder decodeObjectForKey:@"timeout"];
        self.entryType = [coder decodeObjectForKey:@"entryType"];
        self.voucherType = [coder decodeObjectForKey:@"voucherType"];
        self.nonselect = [coder decodeObjectForKey:@"nonselect"];
        self.sound = [coder decodeObjectForKey:@"sound"];
        self.transceiver = [coder decodeObjectForKey:@"transceiver"];
        
        
        //2222
        //2015-04-14 ueda
        self.tableMultiSelect = [coder decodeObjectForKey:@"tableMultiSelect"];
        self.printOut1 = [coder decodeObjectForKey:@"printOut1"];
        self.printOut2 = [coder decodeObjectForKey:@"printOut2"];
        //2015-06-01 ueda
        self.useOrderStatus = [coder decodeObjectForKey:@"useOrderStatus"];
        //2015-09-17 ueda
        self.useOrderConfirm = [coder decodeObjectForKey:@"useOrderConfirm"];
        
        //3333
        self.tableType = [coder decodeObjectForKey:@"tableType"];
        self.codeType = [coder decodeObjectForKey:@"codeType"];
        self.kakucho1Type = [coder decodeObjectForKey:@"kakucho1Type"];
        //2015-03-24 ueda
        self.RegisterType = [coder decodeObjectForKey:@"RegisterType"];
        self.PaymentType = [coder decodeObjectForKey:@"PaymentType"];
        self.searchType = [coder decodeObjectForKey:@"searchType"];
        self.regularCategory = [coder decodeObjectForKey:@"regularCategory"];
        //2014-08-19 ueda
        self.useBarcode = [coder decodeObjectForKey:@"useBarcode"];
        
        //4444
        self.menuPatternEnable = [coder decodeObjectForKey:@"menuPatternEnable"];
        self.menuPatternType = [coder decodeObjectForKey:@"menuPatternType"];
        self.sectionCD = [coder decodeObjectForKey:@"sectionCD"];
        //2014-12-12 ueda
        self.childInputOnOff = [coder decodeObjectForKey:@"childInputOnOff"];
        //2015-04-20 ueda
        self.staffCodeInputOnOff = [coder decodeObjectForKey:@"staffCodeInputOnOff"];
        //2015-06-17 ueda
        self.staffCodeKetaKbn = [coder decodeObjectForKey:@"staffCodeKetaKbn"];
        self.staffCodeKetaStr = [coder decodeObjectForKey:@"staffCodeKetaStr"];
        if ([self.staffCodeKetaStr isEqualToString:@"6"]) {
            //NOP
        } else {
            //nilの場合もある
            self.staffCodeKetaStr = @"2";
        }

        //6666
        self.bunkatsuType = [coder decodeObjectForKey:@"bunkatsuType"];
        self.kakucho2Type = [coder decodeObjectForKey:@"kakucho2Type"];
        self.choriType = [coder decodeObjectForKey:@"choriType"];
        
        //8888
        self.training = [coder decodeObjectForKey:@"training"];
        
        //9999
        self.lang = [coder decodeObjectForKey:@"lang"];
        self.money = [coder decodeObjectForKey:@"money"];
        //2014-09-05 ueda
        self.typeCseatCaptionType  = [coder decodeObjectForKey:@"typeCseatCaptionType"];
        
        //0000
        self.demo = [coder decodeObjectForKey:@"demo"];
        
        self.ftp_user = [coder decodeObjectForKey:@"ftp_user"];
        self.ftp_password = [coder decodeObjectForKey:@"ftp_password"];
        
        //9061
        //2014-10-28 ueda
        self.transitionOnOff = [coder decodeObjectForKey:@"transitionOnOff"];
        self.scrollOnOff = [coder decodeObjectForKey:@"scrollOnOff"];
        //2014-10-30 ueda
        self.home_back = [coder decodeObjectForKey:@"home_back"];
        //2015-11-18 ueda ASTERISK_TEST
        self.categoryCount = [coder decodeObjectForKey:@"categoryCount"];
        
        //2016-04-08 ueda
        if (YES) {
            self.notSleepOnOff     = [coder decodeObjectForKey:@"notSleepOnOff"];
            self.notOpeCheckOnOff  = [coder decodeObjectForKey:@"notOpeCheckOnOff"];
            self.notOpeCheckSecNormal = [coder decodeObjectForKey:@"notOpeCheckSecNormal"];
            self.notOpeCheckSound  = [coder decodeObjectForKey:@"notOpeCheckSound"];
            self.notOpeCheckVib    = [coder decodeObjectForKey:@"notOpeCheckVib"];
            if (self.notSleepOnOff.length ==0) {
                self.notSleepOnOff     = @"0";
                self.notOpeCheckOnOff  = @"1";
                self.notOpeCheckSecNormal = @"120";
                self.notOpeCheckSound  = @"1";
                self.notOpeCheckVib    = @"1";
            }
            self.notOpeCheckSecAlert = [coder decodeObjectForKey:@"notOpeCheckSecAlert"];
            if (self.notOpeCheckSecAlert.length ==0) {
                self.notOpeCheckSecAlert = @"15";
            }
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            CustomWindow *cw = (CustomWindow*)appDelegate.window;
            float timerSecond;
            if (appDelegate.isDisplayAlert) {
                timerSecond = [self.notOpeCheckSecAlert floatValue];
            } else {
                timerSecond = [self.notOpeCheckSecNormal floatValue];
            }
            [cw setExpireTimerSecond:timerSecond];
        }
    }
    
    return self;
}

/**
 *  アカウントデータをキャッシュする。
 */
- (void)saveChacheAccount
{
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:self];
    [ud setObject:data forKey:kCasheAccount];
    [ud synchronize];
}


+ (System *)loadInstance
{
    static System *_sharedInstance = nil;
    NSUserDefaults *ud = [NSUserDefaults standardUserDefaults];
    NSData *getData = (NSData*)[ud objectForKey:kCasheAccount];
    if (getData) {
        _sharedInstance = (System *)[NSKeyedUnarchiver
                                     unarchiveObjectWithData:getData];
        
    } else {
        _sharedInstance = [[System alloc] init];
    }
    
    return _sharedInstance;
}


static void onSoundFinished(SystemSoundID sndId, void *info) {
    
    //サウンドIDの割り当てを解除
    //NSLog(@"システムサウンド割り当て解除");
    AudioServicesDisposeSystemSoundID(sndId);
    
}

+ (void)tapSound{
    //2014-02-18 ueda
    if ([[System sharedInstance].sound isEqualToString:@"0"]) {
        //SystemSoundID beepSoundId;
        NSBundle *mainBundle = [NSBundle mainBundle];
        //NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"beep-shinymetal" ofType:@"aif"] isDirectory:NO];
        //NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"b_001" ofType:@"mp3"] isDirectory:NO];
        NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"TouchSound" ofType:@"mp3"] isDirectory:NO];
        
        //システムサウンドIDの割り当て
        SystemSoundID sndId;
        OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)beepWavURL, &sndId);
        if (!err) {
            AudioServicesAddSystemSoundCompletion(sndId, NULL, NULL, onSoundFinished, NULL);
            AudioServicesPlaySystemSound(sndId);
        }
    }
}

+ (void)adjustStatusBarSpace:(UIView*)view{
    
    if ([[[[UIDevice currentDevice] systemVersion]
          componentsSeparatedByString:@"."][0] intValue] >= 7) //iOS7 later
    {
        
        //LOG(@"%d",self.bt_1.autoresizingMask);
        //LOG(@"%d",self.bt_original.autoresizingMask);
        //LOG(@"%d",self.bt_add.autoresizingMask);
        
        for (int ct = 0; ct < view.subviews.count; ct++) {
            
            UIView *subView = view.subviews[ct];
            
            if ([subView isKindOfClass:[UITableView class]]) {
                UITableView *tableView = (UITableView*)subView;
                [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
            }
            
            
            //位置調整
            if (subView.autoresizingMask!=10&&subView.autoresizingMask!=8) {
                
                //LOG(@"%d:%@",subView.autoresizingMask,subView);
                
                float topPadding = 0;
                float bottomPadding = 0;
                
                if (subView.autoresizingMask!=32&&subView.autoresizingMask!=34&&subView.autoresizingMask!=36) {
                    
                    if(subView.autoresizingMask==58){
                        topPadding = StatusBarHeight/2;
                        bottomPadding = StatusBarHeight/2;
                    }
                    else{
                        topPadding = StatusBarHeight;
                        bottomPadding = StatusBarHeight;
                    }
                }
                else{
                    topPadding = StatusBarHeight;
                }
                
                CGRect original = subView.frame;
                CGRect new = CGRectMake(original.origin.x,  original.origin.y + topPadding,
                                        original.size.width,  original.size.height - bottomPadding);
                subView.frame = new;
            }
        }
        
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        view.backgroundColor = [UIColor blackColor];
    }
}


/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

/****************************************************************
 UIColorでCGRectの大きさを塗り潰したUIImageを返す
 例）
 UIImage* System = [self imageWithColor:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1]];
 [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:temp]];
 ****************************************************************/
+ (UIImage *)imageWithColor:(UIColor *)color {
     CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
     UIGraphicsBeginImageContext(rect.size);
     CGContextRef context = UIGraphicsGetCurrentContext();
     
     CGContextSetFillColorWithColor(context, [color CGColor]);
     CGContextFillRect(context, rect);
     
     UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
     UIGraphicsEndImageContext();
     
     return image;
}

/****************************************************************
 UIColorと白のグラーデーションでCGRectのUIImageを返す
 例）
 UIImage* temp = [System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1] bounds:cell.contentView.frame];
 [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:temp]];
 ****************************************************************/
+ (UIImage *)imageWithColorAndRect:(UIColor *)color bounds:(CGRect)rect {
    //rect = CGRectMake(0,0,100,100);
    if (([color isEqual:TITLE_BLUE]) || ([color isEqual:[UIColor redColor]])) {
        //2016-02-03 ueda ASTERISK
        //画面上部のタイトルはそのままの色とする
        return [self imageWithColor:color];
    }
    if (rect.size.width == 0 || rect.size.height == 0) {
        return [self imageWithColor:color];
    } else {
        if (rect.size.width > 16) {
            rect.size.width = 16;
        }
        return [self imageWithColorAndRectFullSize:color bounds:rect];
    }
}

//2014-10-16 ueda
+ (UIImage *)imageWithColorAndRectFullSize:(UIColor *)color bounds:(CGRect)rect {
    //rect = CGRectMake(0,0,100,100);
    if (rect.size.width == 0 || rect.size.height == 0) {
        return [self imageWithColor:color];
    } else {
        UIGraphicsBeginImageContext(rect.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        
        UIColor * whiteColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0];
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGFloat locations[] = { 0.0, 1.0 };
        UIColor *dstColor = nil;
        if (color == [UIColor whiteColor]) {
            dstColor = [UIColor colorWithRed:230.0/255.0 green:230.0/255.0 blue:230.0/255.0 alpha:1.0];
        } else {
            dstColor = color;
        }
        NSArray *colors = @[(__bridge id) whiteColor.CGColor, (__bridge id) dstColor.CGColor];
        
        CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
        CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
        CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
        
        CGContextSaveGState(context);
        CGContextAddRect(context, rect);
        CGContextClip(context);
        CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
        CGContextRestoreGState(context);
        
        CGGradientRelease(gradient);
        CGColorSpaceRelease(colorSpace);
        
        UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        
        return image;
    }
}

//2014-08-05 ueda
//「tapSound」のパクリ
+ (void)barcodeScanSound {
    //SystemSoundID beepSoundId;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"b_015" ofType:@"mp3"] isDirectory:NO];
    
    //システムサウンドIDの割り当て
    SystemSoundID sndId;
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)beepWavURL, &sndId);
    if (!err) {
        AudioServicesAddSystemSoundCompletion(sndId, NULL, NULL, onSoundFinished, NULL);
        AudioServicesPlaySystemSound(sndId);
    }
}

//「tapSound」のパクリ
+ (void)soundPlayFile:(NSString *)fileName {
    //SystemSoundID beepSoundId;
    NSBundle *mainBundle = [NSBundle mainBundle];
    NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:fileName ofType:@"mp3"] isDirectory:NO];
    
    //システムサウンドIDの割り当て
    SystemSoundID sndId;
    OSStatus err = AudioServicesCreateSystemSoundID((__bridge CFURLRef)beepWavURL, &sndId);
    if (!err) {
        AudioServicesAddSystemSoundCompletion(sndId, NULL, NULL, onSoundFinished, NULL);
        AudioServicesPlaySystemSound(sndId);
    }
}

//2014-09-18 ueda
+ (NSString*)getByteText:(NSString*)orgStr length:(NSInteger)byteLength {
    NSMutableString *tmpText = [[NSMutableString alloc]init];
    [tmpText appendString:orgStr];
    [tmpText appendString:[@"" stringByPaddingToLength:byteLength withString:@" " startingAtIndex:0]];
    NSMutableString *returnText = [[NSMutableString alloc]init];
    BOOL canLoop = YES;
    for (int ptr = 0; canLoop && ptr < [tmpText length]; ptr++) {
        NSString *subText = [tmpText substringWithRange:NSMakeRange(0, ptr + 1)];
        NSInteger lenByte = [subText lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
        if (lenByte <= byteLength) {
            returnText = [[NSMutableString alloc]init];
            [returnText appendString:subText];
        } else {
            canLoop   = NO;
        }
    }
    return returnText;
}

//2014-09-19 ueda
+ (NSString*)convertOnlyShiftjisText:(NSString*)orgStr {
    NSMutableString *returnText = [[NSMutableString alloc]init];
    for (int ct = 0; ct < [orgStr length]; ct++) {
        NSString *subText = [orgStr substringWithRange:NSMakeRange(ct, 1)];
        NSInteger lenByte = [subText lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
        if (lenByte == 0) {
            //使用しない
        } else {
            [returnText appendString:subText];
        }
    }
    return returnText;
}
@end
