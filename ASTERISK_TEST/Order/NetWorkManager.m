
//
//  NetWorkManager.m
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "NetWorkManager.h"
#import "DataList.h"
#import "HomeViewController.h"
#import "TableViewController.h"
#import "CustomFunction.h"

@implementation NetWorkManager


//#define SharedInstanceImplementation
#define READ_HEADER_LINE_BY_LINE 0


#define kCharaSize 250

static NetWorkManager* sharedInstance = nil;
/*
+ (id)sharedInstance {
    @synchronized(self) {
        [[self alloc] init];
    }
    return sharedInstance;
}
*/
+ (NetWorkManager *)sharedInstance
{
    static NetWorkManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[NetWorkManager alloc] init];
    });
    return sharedInstance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (! sharedInstance) {
            sharedInstance = [super allocWithZone:zone];
        }
    }
    return sharedInstance;
}

- (id)copyWithZone:(NSZone *)zone {
    
    return self;
}

- (void)openDb{
    //if (!isOpen) {
        [self.db open];
        isOpen = YES;
    //}
}
- (void)closeDb{
    if (isOpen) {
        [self.db close];
        isOpen = NO;
    }
}

- (void)createDateBase{
    
    //2014-09-18 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.getMasterSetFg = 0;
    
    sys = [System sharedInstance];
    
    //起動と同時にDBファイル作成
    isOpen = NO;
    self.db  = [self dbConnect];
    [self openDb];

    NSString*   Tanto_MT = @"CREATE TABLE IF NOT EXISTS Tanto_MT (MstTantoCD text,TantoNM text,CancelFLG text,CheckFLG text,Password text,Special text,OriginalFLG text,AddFLG text,DivideFLG text,MoveFLG text,VoidFLG text,SectionCD text);";
    
    NSString*   Table_MT = @"CREATE TABLE IF NOT EXISTS Table_MT (TableID text,TableNo text,status text);";
    
    NSString*   Cate_MT = @"CREATE TABLE IF NOT EXISTS Cate_MT (PatternCD text,MstCateCD text,CateNM text);";
    
    NSString*   Menu_MT = @"CREATE TABLE IF NOT EXISTS Menu_MT (PatternCD text,CateCD text,DispOrder text,SyohinCD text,BNGFLG text);";
    
    NSString*   Menu_B1MT = @"CREATE TABLE IF NOT EXISTS Menu_B1MT (PatternCD text,CateCD text,PageNo text,B1CateCD text,DispOrder text,SyohinCD text,BNGFLG text);";
    
    NSString*   Menu_B2MT = @"CREATE TABLE IF NOT EXISTS Menu_B2MT (PatternCD text,CateCD text,PageNo text,B1CateCD text,B1PageNo text,B2CateCD text,DispOrder text,SyohinCD text);";

    NSString*   Syohin_MT = @"CREATE TABLE IF NOT EXISTS Syohin_MT (MstSyohinCD text,HTDispNMU text,HTDispNMM text,HTDispNML text,JikaFLG text,SG1FLG text,TrayStyle text,Tanka text,BNGTanka text,KakeFLG text,Kakeritsu text,BFLG text,CateNM text,InfoFLG text,Info text);";
    
    NSString*   SG1_MT = @"CREATE TABLE IF NOT EXISTS SG1_MT (SyohinCD text,SG1ID text,DispOrder text,HTDispNM text,GroupType text,GroupCD text,LimitCount text);";
    
    NSString*   SG2_MT = @"CREATE TABLE IF NOT EXISTS SG2_MT (SyohinCD text,CondiGCD text,CondiGDID text,SG2ID text,DispOrder text,HTDispNM text,GroupType text,GroupCD text,LimitCount text);";//Limit>LimitCount 使用不可のため
    
    
    NSString*   CondiGD_MT = @"CREATE TABLE IF NOT EXISTS CondiGD_MT (TopSyohinCD text,CondiGCD text,CondiGDID text,DispOrder text,SyohinCD text,Multiple text,SG2FLG text);";

    NSString*   CommentGD_MT = @"CREATE TABLE IF NOT EXISTS CommentGD_MT (CommentGCD text,CommentGDID text,DispOrder text,CommentCD text);";
    
    NSString*   Comment_MT = @"CREATE TABLE IF NOT EXISTS Comment_MT (MstCommentCD text,HTDispNMU text,HTDispNMM text,HTDispNML text);";
    
    NSString*   OfferGD_MT = @"CREATE TABLE IF NOT EXISTS OfferGD_MT (OfferGCD text,OfferCD text);";
    
    NSString*   Offer_MT = @"CREATE TABLE IF NOT EXISTS Offer_MT (MstOfferCD text,DispOrder text,HTDispNMU text,HTDispNMM text,HTDispNML text);";
    
    NSString*   Note_MT = @"CREATE TABLE IF NOT EXISTS Note_MT (NoteID text,HTDispNM text);";
    
    NSString*   Kyakuso_MT = @"CREATE TABLE IF NOT EXISTS Kyakuso_MT (KyakusoID text,HTDispNM text);";
    
    NSString*   Pattern_MT = @"CREATE TABLE IF NOT EXISTS Pattern_MT (PatternID text,HTDispNM text);";
    
    //2014-07-16 ueda
    NSString*   Color_MT = @"CREATE TABLE IF NOT EXISTS Color_MT (ColorID text,ColorCD text);";
    
    NSString*   VoucherTop = @"CREATE TABLE IF NOT EXISTS VoucherTop (id integer primary key autoincrement, PatternCD text,CateCD text,EdaNo text, SyohinCD text,count integer,countDivide text,Jika text,trayNo text);";
    
    NSString*   Voucher1 = @"CREATE TABLE IF NOT EXISTS Voucher1 (id integer,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);";
    
    NSString*   Voucher2 = @"CREATE TABLE IF NOT EXISTS Voucher2 (id integer,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);";
    
    NSString*   Arrange = @"CREATE TABLE IF NOT EXISTS Arrange (id integer,TopSyohinCD text,Sub1SyohinCD text, SyohinCD text, count integer,countDivide text,Jika text,PageNo text,Layer text,trayNo text);";
    
    [self.db executeUpdate:Tanto_MT];
    [self.db executeUpdate:Table_MT];
    [self.db executeUpdate:Cate_MT];
    [self.db executeUpdate:Menu_MT];
    [self.db executeUpdate:Menu_B1MT];
    [self.db executeUpdate:Menu_B2MT];
    [self.db executeUpdate:Syohin_MT];
    [self.db executeUpdate:SG1_MT];
    [self.db executeUpdate:SG2_MT];
    [self.db executeUpdate:CondiGD_MT];
    
    [self.db executeUpdate:CommentGD_MT];
    [self.db executeUpdate:Comment_MT];
    [self.db executeUpdate:OfferGD_MT];
    [self.db executeUpdate:Offer_MT];
    [self.db executeUpdate:Note_MT];
    [self.db executeUpdate:Kyakuso_MT];
    [self.db executeUpdate:Pattern_MT];
    //2014-07-16 ueda
    [self.db executeUpdate:Color_MT];
    
    [self.db executeUpdate:VoucherTop];
    [self.db executeUpdate:Voucher1];
    [self.db executeUpdate:Voucher2];
    
    //2014-08-19 ueda
    if (YES) {
        NSUInteger count = [self.db intForQuery:@"select count(EdaNo) from Voucher1"];
        if ([self.db hadError]) {
            [self.db executeUpdate:@"drop table Voucher1"];
            [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS Voucher1 (id integer,EdaNo text,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);"];
        }
        count = [self.db intForQuery:@"select count(EdaNo) from Voucher2"];
        if ([self.db hadError]) {
            [self.db executeUpdate:@"drop table Voucher2"];
            [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS Voucher2 (id integer,EdaNo text,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);"];
        }
        count = [self.db intForQuery:@"select count(EdaNo) from Arrange"];
        if ([self.db hadError]) {
            [self.db executeUpdate:@"drop table Arrange"];
            [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS Arrange (id integer,EdaNo text,TopSyohinCD text,Sub1SyohinCD text, SyohinCD text, count integer,countDivide text,Jika text,PageNo text,Layer text,trayNo text);"];
        }
    }
    //2014-09-13 ueda
    if (YES) {
        //入力タイプＣのテーブル
        NSString* CtypeVoucherTop = @"CREATE TABLE IF NOT EXISTS VoucherTopTypeC (id integer,OrderIndex integer,SeatNumber text,OrderType text, PatternCD text,CateCD text,EdaNo text, SyohinCD text,count integer,countDivide text,Jika text,trayNo text);";
        
        NSString* CtypeVoucher1 = @"CREATE TABLE IF NOT EXISTS Voucher1TypeC (id integer,OrderIndex integer,SeatNumber text,OrderType text,EdaNo text,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);";
        
        NSString* CtypeVoucher2 = @"CREATE TABLE IF NOT EXISTS Voucher2TypeC (id integer,OrderIndex integer,SeatNumber text,OrderType text,EdaNo text,TopSyohinCD text, Sub1SyohinCD text, CondiGCD text, CondiGDID text,GCD text,CD text, count integer,countDivide text,Jika text,trayNo text);";
        
        NSString* CtypeArrange = @"CREATE TABLE IF NOT EXISTS ArrangeTypeC (id integer,OrderIndex integer,SeatNumber text,OrderType text,EdaNo text,TopSyohinCD text,Sub1SyohinCD text, SyohinCD text, count integer,countDivide text,Jika text,PageNo text,Layer text,trayNo text);";
        [self.db executeUpdate:CtypeVoucherTop];
        [self.db executeUpdate:CtypeVoucher1];
        [self.db executeUpdate:CtypeVoucher2];
        [self.db executeUpdate:CtypeArrange];
    }
    
    //2014-09-16 ueda
    if (YES) {
        NSString *menuExt = @"CREATE TABLE IF NOT EXISTS MenuExt_MT (PatternCD text,CateCD text,DispOrder text,SyohinCD text,BNGFLG text,HTDispNMU text,HTDispNMM text,HTDispNML text);";
        [self.db executeUpdate:menuExt];
    }
    //2014-09-18 ueda
    if (YES) {
        NSUInteger count = [self.db intForQuery:@"select count(ModifyName) from Note_MT"];
        if ([self.db hadError]) {
            [self.db executeUpdate:@"drop table Note_MT"];
            [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS Note_MT (NoteID text,HTDispNM text,ModifyName text);"];
            appDelegate.getMasterSetFg = 1;
        }
        count = 0;
    }
    
    [self.db executeUpdate:Arrange];

    //2015-03-24 ueda
    if (YES) {
        NSUInteger count = [self.db intForQuery:@"select count(*) from Regi_MT"];
        if ([self.db hadError]) {
            NSString *regiMt = @"CREATE TABLE IF NOT EXISTS Regi_MT (SameTimeFLG text, CardFLG text, MemberFLG text, ReceiveKBN text, PayKBN1 text, UrikakeFLG1 text, PayKBN2 text, UrikakeFLG2 text, RegiSyohinCD1 text, RegiSyohinCD2 text, RegiSyohinCD3 text, RegiSyohinCD4 text, USE_ANNAI_2 text, ANNAI_2_STRING text, KAIKEIBAR text);";
            [self.db executeUpdate:regiMt];
            appDelegate.getMasterSetFg = 1;
        }
        count = 0;
    }
    
    //2015-06-01 ueda
    if (YES) {
        NSUInteger count = [self.db intForQuery:@"select count(*) from OrderStat_DT"];
        if ([self.db hadError]) {
            NSString *orderStatDt = @"CREATE TABLE IF NOT EXISTS OrderStat_DT (DenpyoNo text,TableName text,ManCount integer,WomanCount integer,ChildCount integer,Kingaku integer,LastDate text);";
            [self.db executeUpdate:orderStatDt];
        }
        count = [self.db intForQuery:@"select count(*) from Reserve_DT"];
        if ([self.db hadError]) {
            NSString *reserveDt = @"CREATE TABLE IF NOT EXISTS Reserve_DT (ReserveID text,ReserveDate text,ReserveTime text,ReserveName text,ReserveTel text,ReserveTable text);";
            [self.db executeUpdate:reserveDt];
        }
    }
    
    //2015-12-10 ueda ASTERISK
    if (YES) {
        NSUInteger count = [self.db intForQuery:@"select count(DispOrder) from Kyakuso_MT"];
        if ([self.db hadError]) {
            [self.db executeUpdate:@"drop table Kyakuso_MT"];
            [self.db executeUpdate:@"CREATE TABLE IF NOT EXISTS Kyakuso_MT (KyakusoID text,HTDispNM text,DispOrder text)"];
            appDelegate.getMasterSetFg = 1;
        }
        count = 0;
    }
    
    [self createIndex:@"Tanto_MT" index:@"MstTantoCD"];
    [self createIndex:@"Table_MT" index:@"TableID"];
    [self createIndex:@"Cate_MT" index:@"PatternCD"];
    [self createIndex:@"Cate_MT" index:@"MstCateCD"];
    
    [self createIndex:@"Menu_MT" index:@"PatternCD"];
    [self createIndex:@"Menu_MT" index:@"CateCD"];
    [self createIndex:@"Menu_MT" index:@"SyohinCD"];
    
    [self createIndex:@"Menu_B1MT" index:@"PatternCD"];
    [self createIndex:@"Menu_B1MT" index:@"CateCD"];
    
    [self createIndex:@"Menu_B2MT" index:@"PatternCD"];
    [self createIndex:@"Menu_B2MT" index:@"CateCD"];
    
    
    [self createIndex:@"Syohin_MT" index:@"MstSyohinCD"];
    
    [self createIndex:@"SG1_MT" index:@"SyohinCD"];
    [self createIndex:@"SG2_MT" index:@"SyohinCD"];

    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [self closeDb];
}

- (void)createIndex:(NSString*)tableName
              index:(NSString*)index
{
	NSString *sql = [NSString stringWithFormat:@"create index if not exists idx2 on %@(%@)",tableName,index];
	[self.db executeUpdate:sql];
}

- (void)deleteAllData{
    
    [self openDb];
    [self.db executeUpdate:@"delete from Tanto_MT"];
    [self.db executeUpdate:@"delete from Table_MT"];
    [self.db executeUpdate:@"delete from Menu_MT"];
    [self.db executeUpdate:@"delete from Syohin_MT"];
	[self.db executeUpdate:@"delete from Menu_B1MT"];
    [self.db executeUpdate:@"delete from Menu_B2MT"];
    [self.db executeUpdate:@"delete from SG1_MT"];
    [self.db executeUpdate:@"delete from SG2_MT"];
    [self.db executeUpdate:@"delete from Cate_MT"];
    [self.db executeUpdate:@"delete from CondiGD_MT"];
    
    [self.db executeUpdate:@"delete from CommentGD_MT"];
    [self.db executeUpdate:@"delete from Comment_MT"];
    [self.db executeUpdate:@"delete from OfferGD_MT"];
    [self.db executeUpdate:@"delete from Offer_MT"];
    [self.db executeUpdate:@"delete from Note_MT"];
    [self.db executeUpdate:@"delete from Kyakuso_MT"];
    [self.db executeUpdate:@"delete from Pattern_MT"];
    //2014-07-16 ueda
    [self.db executeUpdate:@"delete from Color_MT"];
    //2015-03-24 ueda
    [self.db executeUpdate:@"delete from Regi_MT"];
    
    [self.db executeUpdate:@"delete from VoucherTop"];
    [self.db executeUpdate:@"delete from Voucher1"];
    [self.db executeUpdate:@"delete from Voucher2"];
    [self.db executeUpdate:@"delete from Arrange"];
    
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    [self closeDb];
    
    //フラグを変更する
    if ([System existCacheAccount]) {
        sys = [System sharedInstance];
        sys.getMaster = @"0";
        sys.currentCategory = @"0";
        [sys saveChacheAccount];
    }
}


//DBへ接続する
-(id) dbConnect{
    /*
	NSArray*    paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES );
	NSString*   dir   = [paths objectAtIndex:0];
	return [FMDatabase databaseWithPath:[dir stringByAppendingPathComponent:@"orderdb.db"]];
     
     */
    
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error = nil;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
        if (![[NSFileManager defaultManager]
              createDirectoryAtPath:applicationSupportDirectory
              withIntermediateDirectories:NO
              attributes:nil
              error:&error]) {
            //NSAssert(NO, ([NSString stringWithFormat:@"Failed to create App Support directory %@ : %@", applicationSupportDirectory,error]));
           // NSLog(@”Error creating application support directory at %@ : %@”,applicationSupportDirectory,error);
            return nil;
        }
    }
    return [FMDatabase databaseWithPath:[applicationSupportDirectory stringByAppendingPathComponent:@"orderdb.db"]];
}

- (void)clearCacheData{
    [socketList removeAllObjects];
    socketList = nil;
    appendData = nil;
    //2015-12-25 ueda
    recvDataAll = nil;
}

- (void)readyForBroadCastReceive{

    if (!usocket) {
        usocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self  delegateQueue:dispatch_get_main_queue()];
    }
    
    if (usocket.isClosed) {
        LOG(@"Open udp port");
        
        NSError *err = nil;
        [usocket bindToPort:10000 error:&err];
        [usocket joinMulticastGroup:@"0.0.0.0" error:&err];
        [usocket beginReceiving:&err];
    }
}

- (void)finishForBroadCastReceive{
    
    if (usocket) {
        if (!usocket.isClosed) {
            [usocket close];
            usocket = nil;
        }
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext
{
    
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSLog(@"Did Receive Data:%@",msg);
    
    if (msg)
    {
        
        NSURL *url = [NSURL URLWithString:msg];
        NSString *last = [url lastPathComponent];
        //2014-02-14 ueda
        if (last.length < 21) {
        } else {
            //NSString *tanmatsu = [last substringWithRange:NSMakeRange(6, 4)];
            //if ([tanmatsu intValue]==[[System sharedInstance].tanmatsuID intValue]) {
            //    return;
            //}
            NSString *tanmatsu = [last substringWithRange:NSMakeRange(19, 4)];
            if ([tanmatsu isEqualToString:[System sharedInstance].tanmatsuID]) {
                return;
            }
        }
        
        
        if (!self.voiceList) {
            self.voiceList = [[NSMutableArray alloc]init];
        }
        
        
        //if (![self.voiceList containsObject:msg]&&![lastRecieveData isEqualToString:msg]) {
        if (![lastRecieveData isEqualToString:msg]) {
            
            //2014-04-08 wakako
            //最初は2回繰り返す
            //[self.voiceList addObject:msg];
            //↑2014-04-30 ueda PressToTalkでエラーになりやすい（？）ので１回に戻す
            [self.voiceList addObject:msg];
            
            lastRecieveData = msg;
            
            NSString *str = [msg substringFromIndex:6];
            HomeViewController *hv = (HomeViewController*)self.voiceDelegate;
            [hv download:str];
            
            [self performSelector:@selector(setLastRecieve) withObject:nil afterDelay:1.0f];
        }
    }
    else{
        NSString *host = nil;
        uint16_t port = 0;
        [GCDAsyncUdpSocket getHost:&host port:&port fromAddress:address];
        
        NSLog(@"Unknown Message: %@:%hu", host, port);
    }
}

- (void)setLastRecieve{
    lastRecieveData = @"none";
}


//Request Method
//システム
- (void)getSystemSetting:(id)delegate
                   count:(NSInteger)_count{
    LOG(@"2.1.2システム設定:N01101");
    sys = [System sharedInstance];
    isMaster = NO;
    [self writeAndRead:@"N01101000001"
           requestType:RequestTypeSystem
              delegate:delegate];
    //2014-07-10 ueda
    //[delegate setStatusText:@"システム設定"];
}

- (void)getMasterData:(id)delegate
                count:(NSInteger)_count{
    LOG(@"2.1.2システム設定:N01101");
    sys = [System sharedInstance];
    isMaster = YES;
    [self writeAndRead:@"N01101000001"
           requestType:RequestTypeSystemMt
              delegate:delegate];
    [delegate setStatusText:@"システム設定" stepCount:1];
}


//テーブルID
- (void)getTableID:(id)delegate
             count:(NSInteger)_count{
    LOG(@"2.1.4テーブル:N0113");    

    //2014-08-08 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.tableViewCurrentPageNo = 0;
    
    [self writeAndRead:[NSString stringWithFormat:@"N01103%06zd",_count]
           requestType:RequestTypeTableID
              delegate:delegate];
    [delegate setStatusText:@"テーブル" stepCount:2];
}

//担当
- (void)getTanto:(id)delegate
           count:(NSInteger)_count{
    LOG(@"2.1.5担当者:N0114");
    [self writeAndRead:[NSString stringWithFormat:@"N01104%06zd",_count]
           requestType:RequestTypeTanto
              delegate:delegate];
    [delegate setStatusText:@"担当者" stepCount:3];
}

//メニュー
- (void)getCategory:(id)delegate
          count:(NSInteger)_count{
    LOG(@"2.1.1カテゴリー:N01105");
    [self writeAndRead:[NSString stringWithFormat:@"N01105%06zd",_count]
           requestType:RequestTypeCategoryGet
              delegate:delegate];
    [delegate setStatusText:@"カテゴリー" stepCount:4];
}

- (void)getMenu:(id)delegate
          count:(NSInteger)_count{
    LOG(@"2.1.1メニュー:N01106");
    [self writeAndRead:[NSString stringWithFormat:@"N01106%06zd",_count]
           requestType:RequestTypeMenuGet
              delegate:delegate];
    [delegate setStatusText:@"メニュー" stepCount:5];
}

- (void)getMenu1:(id)delegate
          count:(NSInteger)_count{
    LOG(@"2.1.1メニュー階層1:N01107");
    [self writeAndRead:[NSString stringWithFormat:@"N01107%06zd",_count]
           requestType:RequestTypeMenuGet1
              delegate:delegate];
    [delegate setStatusText:@"メニュー階層1" stepCount:6];
}

- (void)getMenu2:(id)delegate
          count:(NSInteger)_count{
    LOG(@"2.1.1メニュー階層2:N01108");
    [self writeAndRead:[NSString stringWithFormat:@"N01108%06zd",_count]
           requestType:RequestTypeMenuGet2
              delegate:delegate];
    [delegate setStatusText:@"メニュー階層2" stepCount:7];
}

- (void)getMenuInfo:(id)delegate
               count:(NSInteger)_count{
    LOG(@"2.1.1商品:N01109");
    [self writeAndRead:[NSString stringWithFormat:@"N01109%06zd",_count]
           requestType:RequestTypeMenuInfoGet
              delegate:delegate];
    [delegate setStatusText:@"商品" stepCount:8];
}

- (void)getMenuInfo1:(id)delegate
              count:(NSInteger)_count{
    LOG(@"2.1.11第１階層サブグループ:N01110");
    [self writeAndRead:[NSString stringWithFormat:@"N01110%06zd",_count]
           requestType:RequestTypeMenuInfoGet1
              delegate:delegate];
    [delegate setStatusText:@"第1階層サブグループ" stepCount:9];
}

- (void)getMenuInfo2:(id)delegate
               count:(NSInteger)_count{
    LOG(@"2.1.12第2階層サブグループ:N01111");
    [self writeAndRead:[NSString stringWithFormat:@"N01111%06zd",_count]
           requestType:RequestTypeMenuInfoGet2
              delegate:delegate];
    [delegate setStatusText:@"第2階層サブグループ" stepCount:10];
}

- (void)getCondiment:(id)delegate
               count:(NSInteger)_count{
    LOG(@"2.1.13コンディメントグループ明細:N01112");
    [self writeAndRead:[NSString stringWithFormat:@"N01112%06zd",_count]
           requestType:RequestTypeCondimentGet
              delegate:delegate];
    [delegate setStatusText:@"階層グループ明細" stepCount:11];
}

- (void)getCommentGD:(id)delegate
                  count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01113%06zd",_count]
           requestType:RequestTypeCommentGDGet
              delegate:delegate];
    [delegate setStatusText:@"指示コメントグループ明細" stepCount:12];
}
- (void)getComment:(id)delegate
                count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01114%06zd",_count]
           requestType:RequestTypeCommentGet
              delegate:delegate];
    [delegate setStatusText:@"指示コメント" stepCount:13];
    
}
- (void)getOfferGD:(id)delegate
                count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01115%06zd",_count]
           requestType:RequestTypeOfferGDGet
              delegate:delegate];
    [delegate setStatusText:@"提供時期グループ明細" stepCount:14];
}
- (void)getOffer:(id)delegate
              count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01116%06zd",_count]
           requestType:RequestTypeOfferGet
              delegate:delegate];
    [delegate setStatusText:@"提供時期" stepCount:15];
}

- (void)getNote:(id)delegate
           count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01117%06zd",_count]
           requestType:RequestTypeNoteGet
              delegate:delegate];
    [delegate setStatusText:@"オーダー種類" stepCount:16];
}
- (void)getKyakuso:(id)delegate
           count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01123%06zd",_count]
           requestType:RequestTypeKyakusoGet
              delegate:delegate];
    [delegate setStatusText:@"客層" stepCount:17];
}
- (void)getPattern:(id)delegate
           count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01124%06zd",_count]
           requestType:RequestTypePatternGet
              delegate:delegate];
    [delegate setStatusText:@"パターン" stepCount:18];
}
//2014-07-16 ueda
- (void)getColor:(id)delegate
             count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01119%06zd",_count]
           requestType:RequestTypeColorGet
              delegate:delegate];
    [delegate setStatusText:@"色情報" stepCount:19];
}
//2015-03-24 ueda
- (void)getRegiMt:(id)delegate
           count:(NSInteger)_count{
    [self writeAndRead:[NSString stringWithFormat:@"N01102%06zd",_count]
           requestType:RequestTypeRegiMt
              delegate:delegate];
    [delegate setStatusText:@"レジ設定" stepCount:20];
}

//その他
- (void)getKokyaku:(id)delegate
             count:(NSInteger)_count{
    //2015-03-24 ueda
/*
    [self writeAndRead:[NSString stringWithFormat:@"K65%@",
                        [self appendSpace:[NSString stringWithFormat:@"%d",[[DataList sharedInstance].currentKokyakuCD intValue]] totalLength:10]]
           requestType:RequestTypeKokyakuInfoGet
              delegate:delegate];
 */
    [self writeAndRead:[NSString stringWithFormat:@"K65%@",
                        [self appendSpace:[DataList sharedInstance].currentKokyakuCD totalLength:10]]
                                      requestType:RequestTypeKokyakuInfoGet
                                         delegate:delegate];
}


//テーブル
- (void)getTableStatus:(id)delegate{
    LOG(@"2.2.1テーブル状況 取得:N11");
    [self openDb];
    [self.db executeUpdate:@"update Table_MT set status = ?",@""];
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        NSString *_N11 = [NSString stringWithFormat:@"N11%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training];
        [self writeAndRead:_N11
               requestType:RequestTypeTableStatus
                  delegate:delegate];
    }
    else{
        [delegate didFinishRead:[self convertDataForTable:nil] readList:nil type:RequestTypeTableStatus];
    }
}

- (void)getTableStatusDirection:(id)delegate{
    LOG(@"2.2.1テーブル状況 取得:C11");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        [self openDb];
        [self.db executeUpdate:@"update Table_MT set status = ?",@""];
        NSString *_N11 = [NSString stringWithFormat:@"C11%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training];
        [self writeAndRead:_N11
               requestType:RequestTypeTableStatus
                  delegate:delegate];
    }
    else{
        [delegate didFinishRead:[self convertDataForTable:nil] readList:nil type:RequestTypeTableStatus];
    }
}

- (void)sendTableReadyFinish:(id)delegate{
    LOG(@"2.3.1テーブル状況　更新（準備完了通知）:N12");
    //@"N12010+テーブルID4桁"
    DataList *dat = [DataList sharedInstance];
    NSString *_N12 = [NSString stringWithFormat:@"N12%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N12
           requestType:RequestTypeTableEmpty
              delegate:delegate];
}

- (void)sendTableMove:(id)delegate{
    LOG(@"2.4.1テーブル移動 更新:N13");
    //@"N13010+伝票番号4桁+グループテーブル件数4桁+テーブルID4桁*件数分"
    DataList *dat = [DataList sharedInstance];
    NSMutableString *_msg = [[NSMutableString alloc]init];
    
    LOG(@"%@",dat.currentVoucher);
    
    [_msg appendString:[NSString stringWithFormat:@"N13%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]]];
    [_msg appendString:[NSString stringWithFormat:@"%04zd",[dat.moveToTable count]]];
    
    for (int ct = 0; ct<[dat.moveToTable count]; ct++) {
        NSDictionary *_dic = dat.moveToTable[ct];
        [_msg appendString:_dic[@"TableID"]];
    }
    
    NSString *_N13 = _msg;
    [self writeAndRead:_N13
           requestType:RequestTypeTableMove
              delegate:delegate];
}

- (void)getTableReserve:(id)delegate{
    LOG(@"2.5.1予約情報 取得:N14");
    //@"N14010+テーブルID4桁"
    DataList *dat = [DataList sharedInstance];
    NSString *_N14 = [NSString stringWithFormat:@"N14%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N14
           requestType:RequestTypeTableReserve
              delegate:delegate];
}

- (void)getTableSyohin:(id)delegate{
    LOG(@"2.6.1提供商品情報 取得:N15");
    //@"N15010+テーブルID4桁"
    DataList *dat = [DataList sharedInstance];
    NSString *_N15 = [NSString stringWithFormat:@"N15%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N15
           requestType:RequestTypeTableSyohin
              delegate:delegate];
}

- (void)sendTableTaiki:(id)delegate{
    LOG(@"2.7.1提供待機解除通知:N16");
    DataList *dat = [DataList sharedInstance];
    NSString *_N16 = [NSString stringWithFormat:@"N16%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N16
           requestType:RequestTypeTableTaiki
              delegate:delegate];
}

- (void)sendTableInShow:(id)delegate{
    LOG(@"2.8.1案内中通知:N17");
    DataList *dat = [DataList sharedInstance];
    NSString *_N17 = [NSString stringWithFormat:@"N17%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N17
           requestType:RequestTypeTableInShow
              delegate:delegate];
}

- (void)sendTableInShow2:(id)delegate{
    LOG(@"2.8.1案内中通知:N17 その２");
    DataList *dat = [DataList sharedInstance];
    NSString *_N172 = [NSString stringWithFormat:@"N17%@%@%@2",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N172
           requestType:RequestTypeTableInShow2
              delegate:delegate];
}

- (void)sendTableEmpty:(id)delegate{
    LOG(@"2.9.1空席通知:N18");
    DataList *dat = [DataList sharedInstance];
    NSString *_N18 = [NSString stringWithFormat:@"N18%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N18
           requestType:RequestTypeTableEmpty
              delegate:delegate];
}

- (void)getTableKeyID:(id)delegate{//[N23]
    LOG(@"2.13 KeyID 取得:N23");
    DataList *dat = [DataList sharedInstance];
    NSString *_N23 = [NSString stringWithFormat:@"N23%@%@%@6",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N23
           requestType:RequestTypeTableKeyID
              delegate:delegate];
}

- (void)sendTableExtension:(NSString*)time
                     KeyID:(NSString*)KeyID
                  delegate:(id)delegate{//[N24]
    LOG(@"2.14 延長時間 更新:N24");
    DataList *dat = [DataList sharedInstance];
    NSString *_N24 = [NSString stringWithFormat:@"N24%@%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"],KeyID,time];
    [self writeAndRead:_N24
           requestType:RequestTypeTableExtension
              delegate:delegate];
}


//注文
//2014-10-29 ueda
- (void)sendOrderRequest:(id)delegate
               retryFlag:(BOOL)_retryFlag {
    LOG(@"2.16.1注文情報　更新:N31（新規）");
    
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSString *_N31 = [self convertForOrderRequest:[orderManager getOrderList:0]
                                                 type:@"1"];
        [self writeAndReadRetry:_N31
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

//2014-09-08 ueda
//2014-10-29 ueda
- (void)sendOrderRequestTypeC:(id)delegate
                    retryFlag:(BOOL)_retryFlag {
    LOG(@"X31（新規）");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        NSMutableString *sendString = [NSMutableString string];
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSMutableArray *topGroup = [orderManager getOrderListTypeC_Header:0];
        [sendString appendString:[self convertForOrderRequestTypeC_Header:@"1"]];
        [sendString appendString:[NSString stringWithFormat:@"%03zd",topGroup.count]];
        for (int ct = 0; ct < [topGroup count]; ct++) {
            NSMutableArray *detailGroup = [orderManager getOrderListTypeC_Detail:0 seatNumber:topGroup[ct][@"SeatNumber"] orderType:topGroup[ct][@"OrderType"]];
            NSString *detailString = [self convertForOrderRequestTypeC_Detail:detailGroup type:@"1"];
            [sendString appendString:detailString];
        }
        [self writeAndReadRetry:sendString
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

//2014-10-29 ueda
- (void)sendOrderAdd:(id)delegate
           retryFlag:(BOOL)_retryFlag {
    LOG(@"2.16.1注文情報　更新:N31（追加）");

    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSString *_N31 = [self convertForOrderRequest:[orderManager getOrderList:0]
                                                 type:@"2"];
        [self writeAndReadRetry:_N31
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

//2014-09-11 ueda
//2014-10-29 ueda
- (void)sendOrderAddTypeC:(id)delegate
                retryFlag:(BOOL)_retryFlag {
    LOG(@"X31（追加）");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        NSMutableString *sendString = [NSMutableString string];
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSMutableArray *topGroup = [orderManager getOrderListTypeC_Header:0];
        [sendString appendString:[self convertForOrderRequestTypeC_Header:@"2"]];
        [sendString appendString:[NSString stringWithFormat:@"%03zd",topGroup.count]];
        for (int ct = 0; ct < [topGroup count]; ct++) {
            NSMutableArray *detailGroup = [orderManager getOrderListTypeC_Detail:0 seatNumber:topGroup[ct][@"SeatNumber"] orderType:topGroup[ct][@"OrderType"]];
            NSString *detailString = [self convertForOrderRequestTypeC_Detail:detailGroup type:@"2"];
            [sendString appendString:detailString];
        }
        [self writeAndReadRetry:sendString
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

//2014-10-29 ueda
- (void)sendOrderCancel:(id)delegate
              retryFlag:(BOOL)_retryFlag {
    LOG(@"2.16.1注文情報　更新:N31（削除）");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSString *_N31 = [self convertForOrderRequest:[orderManager getOrderList:1]
                                                 type:@"3"];
        [self writeAndReadRetry:_N31
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

//2014-09-12 ueda
//2014-10-29 ueda
- (void)sendOrderCancelTypeC:(id)delegate
                   retryFlag:(BOOL)_retryFlag {
    LOG(@"X31（削除）");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        NSMutableString *sendString = [NSMutableString string];
        OrderManager *orderManager = [OrderManager sharedInstance];
        NSMutableArray *topGroup = [orderManager getOrderListTypeC_Header:1];
        [sendString appendString:[self convertForOrderRequestTypeC_Header:@"3"]];
        [sendString appendString:[NSString stringWithFormat:@"%03zd",topGroup.count]];
        for (int ct = 0; ct < [topGroup count]; ct++) {
            NSMutableArray *detailGroup = [orderManager getOrderListTypeC_Detail:1 seatNumber:topGroup[ct][@"SeatNumber"] orderType:topGroup[ct][@"OrderType"]];
            NSString *detailString = [self convertForOrderRequestTypeC_Detail:detailGroup type:@"3"];
            [sendString appendString:detailString];
        }
        [self writeAndReadRetry:sendString
                    requestType:RequestTypeOrderRequest
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderRequest];
    }
}

- (void)sendOrderDirection:(id)delegate
                      list:(NSArray*)_list{

    LOG(@"2.16.1注文情報　更新:C31（調理指示）");
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        NSString *_C31 = [self convertForOrderDirection:_list];
        [self writeAndRead:_C31
               requestType:RequestTypeOrderDirection
                  delegate:delegate];
    }
    else{
        [delegate didFinishRead:@"Demo mode" readList:nil type:RequestTypeOrderDirection];
    }
}

//伝票関係
- (void)getVoucherList:(id)delegate{
    LOG(@"2.11.1伝票番号　取得:N21");

    voucherSection = [self getSection:[(TableViewController*)delegate type]];
    DataList *dat = [DataList sharedInstance];

    NSString *_N21 = [NSString stringWithFormat:@"N21%@%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"],voucherSection,sys.voucherType];
    [self writeAndRead:_N21
           requestType:RequestTypeVoucherList
              delegate:delegate];
}

//2014-09-11 ueda
- (void)getVoucherListTypeC:(id)delegate{
    LOG(@"X21");
    
    voucherSection = [self getSection:[(TableViewController*)delegate type]];
    DataList *dat = [DataList sharedInstance];
    
    NSString *_X21 = [NSString stringWithFormat:@"X21%@%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"],voucherSection,sys.voucherType];
    [self writeAndRead:_X21
           requestType:RequestTypeVoucherListTypeC
              delegate:delegate];
}

- (NSString*)getSection:(TypeOrder)type{
    //TypeOrder type = [(TableViewController*)delegate type];
    NSString *section = @"2";//処理区分
    if (type==TypeOrderAdd) {
        section = @"2";
    }
    else if (type==TypeOrderCancel) {
        section = @"3";
    }
    else if (type==TypeOrderCheck) {
        section = @"4";
    }
    else if (type==TypeOrderDivide) {
        section = @"5";
    }
    else if (type==TypeOrderMove) {
        section = @"6";
    }
    
    return section;
}

- (void)sendTableReadyDirection:(id)delegate{
    LOG(@"2.3.1テーブル状況　更新（準備完了通知）:C12");
    //@"N12010+テーブルID4桁"
    DataList *dat = [DataList sharedInstance];
    NSString *_N12 = [NSString stringWithFormat:@"C12%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_N12
           requestType:RequestTypeTableReadyDirection
              delegate:delegate];
}

- (void)getVoucherDirection:(id)delegate{
    LOG(@"2.11.1伝票番号　取得:C21");
    DataList *dat = [DataList sharedInstance];
    NSString *_N21 = [NSString stringWithFormat:@"C21%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndRead:_N21
           requestType:RequestTypeVoucherDirection
              delegate:delegate];
}

- (void)getVoucherDetail:(id)delegate{
    LOG(@"2.17.1注文情報　取得（取消・分割時）:N32");
    //@"N32010+伝票番号"
    DataList *dat = [DataList sharedInstance];
    NSString *_N32 = [NSString stringWithFormat:@"N32%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndRead:_N32
           requestType:RequestTypeVoucherDetail
              delegate:delegate];
    
}

//2014-09-11 ueda
- (void)getVoucherDetailTypeC:(id)delegate{
    LOG(@"X32");
    DataList *dat = [DataList sharedInstance];
    NSString *_X32 = [NSString stringWithFormat:@"X32%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndRead:_X32
           requestType:RequestTypeVoucherDetailTypeC
              delegate:delegate];
    
}

//2014-10-30 ueda
- (void)sendVoucherDivide:(id)delegate
                     type:(NSString*)type
                retryFlag:(BOOL)_retryFlag {
    
    LOG(@"2.12.1伝票分割　更新:N22");
    OrderManager *orderManager = [OrderManager sharedInstance];
    NSString *_N22 = [self convertForVoucherDivide:[orderManager getOrderListForDivide]
                                              type:type];
    
    if ([type isEqualToString:@"1"]) {
        [self writeAndReadRetry:_N22
                    requestType:RequestTypeVoucherDividePrint
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
    else if ([type isEqualToString:@"2"]){
        [self writeAndReadRetry:_N22
                    requestType:RequestTypeVoucherDivideNotPrint
                       delegate:delegate
                      retryFlag:_retryFlag];
    }
}

- (void)getVoucherCheck:(id)delegate{
    LOG(@"2.18.1伝票確認情報　取得:N41");
    DataList *dat = [DataList sharedInstance];
    NSString *_N41 = [NSString stringWithFormat:@"N41%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndRead:_N41
           requestType:RequestTypeVoucherCheck
              delegate:delegate];
}


- (void)sendVoucherPrint:(id)delegate{
    LOG(@"2.18.1伝票確認情報　取得:N43");
    DataList *dat = [DataList sharedInstance];
    //2014-07-28 ueda
    //NSString *_N41 = [NSString stringWithFormat:@"N43%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"],[System sharedInstance].printOut2];
    NSString *_N41 = nil;
    if ([[System sharedInstance].printOut1 isEqualToString:@"0"]) {
        _N41 = [NSString stringWithFormat:@"N43%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"],[System sharedInstance].printOut2];
    } else {
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        _N41 = [NSString stringWithFormat:@"N43%@%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"],[NSString stringWithFormat:@"%zd",appDelegate.printerNumberOfCheckoutSlip]];
    }
    
    [self writeAndRead:_N41
           requestType:RequestTypeVoucherPrint
              delegate:delegate];
}

- (void)sendVoucherPush:(id)delegate
                  edaNo:(NSInteger)edaNo
                choice1:(NSInteger)choice1
                choice2:(NSInteger)choice2{
    LOG(@"2.19再発行要求:N42");
    DataList *dat = [DataList sharedInstance];
    
    NSString *edaStr = @"";
    if (choice1==0) {
        edaStr = @"  ";
    }
    else{
        edaStr = [NSString stringWithFormat:@"%02zd",edaNo];
    }
    
    NSString *_N42 = [NSString stringWithFormat:@"N42%@%@%@%zd%@%zd",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"],choice1,edaStr,choice2];
    [self writeAndRead:_N42
           requestType:RequestTypeVoucherPush
              delegate:delegate];
}

- (void)getVoucherSearch:(id)delegate
                    word:(NSString*)word{
    LOG(@"2.58 伝票番号　検索:P21");
    
    
    //Test
    //[delegate didFinishRead:@"dksoadksoakdosakdosa" readList:nil type:RequestTypeVoucherSearch];
    //return;
    
    
    
    NSString *type = @"";
    NSString *str = @"";
    if ([[System sharedInstance].kakucho2Type intValue]==0) {
        if (word.length>4) {
            word = [word substringFromIndex:word.length-4];
        }
        type = @"P21";
        str = [NSString stringWithFormat:@"%04d",[word intValue]];
    }
    else if ([[System sharedInstance].kakucho2Type intValue]==1){
        if (word.length>4) {
            word = [word substringFromIndex:word.length-4];
        }
        type = @"P21";
        str = [NSString stringWithFormat:@"%04d",[word intValue]];
    }
    else if ([[System sharedInstance].kakucho2Type intValue]==2){
        type = @"P91";
        str = [NSString stringWithFormat:@"%08d",[word intValue]];
    }
    
    NSString *_P21 = [NSString stringWithFormat:@"%@%@%@%@",type,[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,str];
    [self writeAndRead:_P21
           requestType:RequestTypeVoucherSearch
              delegate:delegate];
}

- (void)sendVoice:(id)delegate
           urlStr:(NSString*)urlStr{
    LOG(@"トランシーバー送信:%@",urlStr);
    [self writeAndRead:urlStr
           requestType:RequestTypeSendVoice
              delegate:delegate];
}

- (void)writeAndRead:(NSString*)_request
         requestType:(RequestType)_requestType
            delegate:(id)_delegate{
    [self writeAndReadRetry:_request requestType:_requestType delegate:_delegate retryFlag:NO];
}

//2014-10-29 ueda
- (void)writeAndReadRetry:(NSString*)_request
              requestType:(RequestType)_requestType
                 delegate:(id)_delegate
                retryFlag:(BOOL)_retryFlag{

    if (!socketList) {
        socketList = [[NSMutableDictionary alloc]init];
    }
    
    dispatch_queue_t socketQueue = dispatch_queue_create("socketQueue", NULL);
    asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:socketQueue];
    asyncSocket.autoDisconnectOnClosedReadStream = NO;

    NSString *requestStr = nil;
    if (_requestType==RequestTypeSendVoice) {
        requestStr = [NSString stringWithFormat:@"voice_%@\r\n",_request];
    }
    else{
        NSString* _dateString;
        if (_retryFlag) {
            _dateString = preDateString;
        } else {
            NSDateFormatter *_outputFormatter = [[NSDateFormatter alloc] init];
            [_outputFormatter setDateFormat:@"yyMMddHHmm"];
            NSString* _date = [_outputFormatter stringFromDate:[NSDate date]];
            _dateString = [NSString stringWithFormat:@"%@%02zd",_date,seqNum];
            seqNum++;
            if (seqNum==100) seqNum=0;
            preDateString = [NSMutableString string];
            [preDateString appendString:_dateString];
        }
        
        NSString *entryType = @"";
        if ([[System sharedInstance].menuPatternEnable isEqualToString:@"1"]) {
            entryType = [System sharedInstance].menuPattern;
        }
        else{
            entryType = @"A";
        }
        
        
        //NSString *_common = [NSString stringWithFormat:@"%@%@%@%@%@%@%@%@%@",sys.tanmatsuID,_dateString,programVer,sys.masterVer,entryType,sys.aiseki,sys.ninzu,sys.zeronin,sys.orderType];
        //2014-12-12 ueda
        NSString *_common;
        //2015-06-17 ueda
        if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
            //担当者コード：６桁
            _common = [NSString stringWithFormat:@"%@%@%@%02d%@%@%@%@%@",sys.tanmatsuID,_dateString,programVer_89,[sys.masterVer intValue],entryType,sys.aiseki,sys.ninzu,sys.zeronin,sys.orderType];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                _common = [NSString stringWithFormat:@"%@%@%@%02d%@%@%@%@%@",sys.tanmatsuID,_dateString,programVer_90,[sys.masterVer intValue],entryType,sys.aiseki,sys.ninzu,sys.zeronin,sys.orderType];
            } else {
                //小人入力しない
                _common = [NSString stringWithFormat:@"%@%@%@%02d%@%@%@%@%@",sys.tanmatsuID,_dateString,programVer_91,[sys.masterVer intValue],entryType,sys.aiseki,sys.ninzu,sys.zeronin,sys.orderType];
            }
        }
        
        NSString *_denbun = [NSString stringWithFormat:@"%@%@",_common,_request];
        //2014-09-17 ueda
        //NSString *_denbunLength = _denbunLength = [NSString stringWithFormat:@"%04d",[_denbun length]];
        NSString *_denbunLength = _denbunLength = [NSString stringWithFormat:@"%04zd",[_denbun lengthOfBytesUsingEncoding:NSShiftJISStringEncoding]];
        requestStr = [NSString stringWithFormat:@"RCV %@,%@,%@=%@\r\n",[_common substringWithRange:NSMakeRange(0, 2)],[_common substringWithRange:NSMakeRange(2, 2)],_denbunLength,_denbun];
    }

    LOG(@"POST:%@",requestStr);
    
    currentType = _requestType;
    NSMutableDictionary *_dic = nil;
    if ([[socketList allKeys] containsObject:[NSString stringWithFormat:@"%d",currentType]]) {
        _dic = [socketList objectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [_dic setObject:asyncSocket forKey:@"socket"];
        [_dic setObject:_request forKey:@"requestNo"];
        [_dic setObject:requestStr forKey:@"request"];
        [_dic setObject:[NSNumber numberWithInt:_requestType] forKey:@"requestType"];
        [_dic setObject:_delegate forKey:@"delegate"];
        [socketList setObject:_dic forKey:[NSString stringWithFormat:@"%d",currentType]];
    }
    else{
        _dic = [[NSMutableDictionary alloc]initWithObjectsAndKeys:
                asyncSocket,@"socket",
                _request,@"requestNo",
                requestStr,@"request",
                [NSNumber numberWithInt:_requestType],@"requestType",
                _delegate,@"delegate",
                [[NSMutableArray alloc]init],@"messages",
                nil];
        [socketList setObject:_dic forKey:[NSString stringWithFormat:@"%d",currentType]];
    }

    appendData = [[NSMutableString alloc]init];
    //2015-12-25 ueda
    recvDataAll = [[NSMutableData alloc]init];
    
    //2014-12-04 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.communication_Step_Status = communication_Step_NotConnect;
    appDelegate.communication_Return_Status = communication_Return_OK;

    NSError *error = nil;
    if (![asyncSocket connectToHost:sys.hostIP onPort:[sys.port intValue] withTimeout:[sys.timeout floatValue] error:&error])
    {
        LOG(@"Error connecting: %@", error);
        id delegate = [_dic valueForKey:@"delegate"] ;
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:error
                                     msg:@"サーバーへの接続に失敗しました。"
                                    type:_requestType];
    }
}

////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	LOG(@"socket:didConnectToHost:%@ port:%hu", host, port);
    
    //2014-12-04 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.communication_Step_Status = communication_Step_Connected;
    
    NSMutableDictionary *_dic = [socketList objectForKey:[NSString stringWithFormat:@"%d",currentType]];
    NSString *requestStr = [_dic valueForKey:@"request"];
    NSData *requestData = [requestStr dataUsingEncoding:kEnc];
    
    //LOG(@"%d:%@",currentType,socketList);
    
    LOG(@"Sending HTTP Request:%@",requestStr);
    
	[asyncSocket writeData:requestData withTimeout:[sys.timeout floatValue] tag:seqNum];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
	// This method will be called if USE_SECURE_CONNECTION is set
	
	LOG(@"socketDidSecure:");
}

- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
	LOG(@"socket:didWriteDataWithTag:");
    
    //2014-12-04 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.communication_Step_Status = communication_Step_Sended;
    
    [asyncSocket readDataWithTimeout:[sys.timeout floatValue] tag:tag];
    //[asyncSocket readDataWithTimeout:[sys.timeout floatValue] buffer:nil bufferOffset:0 maxLength:200000 tag:tag];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    //2015-12-25 ueda
/*
	NSString *httpResponse = [[NSString alloc] initWithData:data encoding:kEnc];
	
    LOG(@"Full HTTP Response:\n%@", httpResponse);
 */

    //2014-12-04 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.communication_Step_Status = communication_Step_Recieved;
    
    //2015-12-25 ueda
/*
    if([httpResponse rangeOfString:@"RCV"].location != NSNotFound){
        maxLength = [[httpResponse substringWithRange:NSMakeRange(10, 4)]intValue];
    }
 */
    
    LOG(@"Full Bytes:%zd/%zd", [data length]-16,maxLength);

    //2015-12-25 ueda
    //[appendData appendString:httpResponse];
    //2015-12-25 ueda
    if (YES) {
        [recvDataAll appendData:data];
        NSString *recvStringAll = [[NSString alloc] initWithData:recvDataAll encoding:kEnc];
        appendData = [[NSMutableString alloc]init];
        [appendData appendString:recvStringAll];
    }
    
    
    NSMutableDictionary *_dic = [socketList objectForKey:[NSString stringWithFormat:@"%d",currentType]];
    id delegate = [_dic valueForKey:@"delegate"] ;
    NSMutableArray *_array = [_dic valueForKey:@"messages"];
    RequestType _type = [[_dic valueForKey:@"requestType"]intValue];
    
    

    //文字列が4以下の場合はエラーを返す
    if ([appendData length]<=4+15) {
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:nil msg:@"正常なデータを取得することが出来ませんでした。" type:_type];
        return;
    }
    
    //2015-12-25 ueda
    if (YES) {
        unichar c = [appendData characterAtIndex:[appendData length]-1];
        if (c != 0x0d) {
            //最後の文字がＣＲ以外は（分割されたパケットを）受信する
            [asyncSocket readDataWithTimeout:[sys.timeout floatValue] tag:tag];
            return;
        }
    }

    //2015-12-25 ueda
/*
     //上のチェックでＯＫなので以下をコメントアウト
     //補足 漢字が含まれる場合はlengthではＮＧではないのか？
    if (([appendData length]-16<maxLength)&&([data length]-16<maxLength)) {
        [asyncSocket readDataWithTimeout:[sys.timeout floatValue] tag:tag];
        return;
    }
    
    //2015-09-08 ueda
    if (maxLength == 0) {
        //長さ＝０
        unichar c = [appendData characterAtIndex:[appendData length]-1];
        if (c != 0x0d) {
            //最後の文字がＣＲ以外は（分割されたパケットを）受信する
            [asyncSocket readDataWithTimeout:[sys.timeout floatValue] tag:tag];
            return;
        }
    }
 */
    
    [sock disconnect];

    
    if (!_array) {
        _array = [[NSMutableArray alloc]init];
    }
    [_array addObject:appendData];
    [_dic setObject:_array forKey:@"messages"];
    
    //2014-12-04 ueda
    appDelegate.communication_Return_Status = [[appendData substringWithRange:NSMakeRange(18, 1)] integerValue];
/*
    //通信エラー判定
    //2014-10-30 ueda
    if (([appendData rangeOfString:@"マスターダウンロード"].location != NSNotFound) ||
        ([appendData rangeOfString:@"Execute Master download"].location != NSNotFound)) {
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        if ([[System sharedInstance].lang isEqualToString:@"1"]) {
            [delegate didFinishReadWithError:nil
                                         msg:@"Execute Master download."
                                        type:_type];
        } else {
            [delegate didFinishReadWithError:nil
                                         msg:@"マスターダウンロードを実行してください。"
                                        type:_type];
        }

        return;
    }
*/
    //2014-12-04 ueda
    if ((appDelegate.communication_Return_Status == communication_Return_NG) || (appDelegate.communication_Return_Status == communication_Return_MasterDownload)) {
        NSRange rng = [appendData rangeOfString:@"="];
        //2015-12-25 ueda
        //NSString *resultMsg = [httpResponse substringFromIndex:rng.location+5];
        NSString *resultMsg = [appendData substringFromIndex:rng.location+5];
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:nil
                                     msg:resultMsg
                                    type:_type];
        return;
    }
    //2014-12-25 ueda
    if (appDelegate.communication_Return_Status == communication_Return_8) {
        if (([[appendData substringWithRange:NSMakeRange(15, 3)] isEqualToString:@"N31"]) || ([[appendData substringWithRange:NSMakeRange(15, 3)] isEqualToString:@"X31"])) {
            NSString *resultMsg = [String Split_Table_for_New_Customer];
            [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
            [delegate didFinishReadWithError:nil
                                         msg:resultMsg
                                        type:_type];
            return;
        }
    }
    
    //エラーを取得した場合
    NSString *_requestNo = [_dic valueForKey:@"requestNo"];
    NSString *_successStr1 = [NSString stringWithFormat:@"%@%d",[_requestNo substringToIndex:3],1];
    NSString *_successStr2 = [appendData substringWithRange:NSMakeRange(15, 4)];
    LOG(@"if:%@:%@",_successStr1,_successStr2);
    if ([_successStr1 isEqualToString:_successStr2]) {
        LOG(@"error");
        NSRange rng = [appendData rangeOfString:@"="];
        //2015-12-25 ueda
        //NSString *resultMsg = [httpResponse substringFromIndex:rng.location+1];
        NSString *resultMsg = [appendData substringFromIndex:rng.location+1];
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:nil
                                     msg:resultMsg
                                    type:_type];

        return;
    }
    
    
    //注文時に欠品があった場合
    if ([_successStr2 isEqualToString:@"N312"]) {
        NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:0]];
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:nil
                                     msg:[self convertDataKeppin:_msg]
                                    type:_type];
        return;
    }
    //2014-10-30 ueda
    if ([_successStr2 isEqualToString:@"X312"]) {
        NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:0]];
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        [delegate didFinishReadWithError:nil
                                     msg:[self convertDataKeppin:_msg]
                                    type:_type];
        return;
    }
    
    
    BOOL isFinish = NO;
    int removeType = 0;
    
    //システム設定かの判定（不定期に呼ばれるため他の通信処理との混在を防ぐ）
    //2015-12-25 ueda
    //if ([httpResponse length]>21) {
    if ([appendData length]>21) {
        //2015-12-25 ueda
        //NSString *_head6 = [httpResponse substringWithRange:NSMakeRange(15, 6)];
        NSString *_head6 = [appendData substringWithRange:NSMakeRange(15, 6)];
        if ([_head6 isEqualToString:@"N01001"]&&_type!=RequestTypeSystemMt) {
            LOG(@"N01001システム設定");
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:0]];
                if ([self convertForSystemSettingMaster:_msg]) {
                    if (_type!=RequestTypeSystem) {
                        removeType = RequestTypeSystem;
                        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",removeType]];
                        if ([delegate isKindOfClass:[HomeViewController class]]) {
                            [delegate didFinishRead:@"0" readList:_array type:_type];
                        }
                        return;
                    }
                }
                else{
                    if (_type!=RequestTypeSystem) {
                        removeType = RequestTypeSystem;
                        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",removeType]];
                        if ([delegate isKindOfClass:[HomeViewController class]]) {
                        [delegate didFinishRead:@"1" readList:_array type:_type];
                        }
                        return;
                    }
                }
            }
        }
    }
    
    //取得したメッセージの配列を参照して次点行動を判定する
    switch (_type) {
        case RequestTypeSystem:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:0]];
                if ([self convertForSystemSettingMaster:_msg]) {
                    removeType = currentType;
                        isFinish = YES;
                    if ([delegate isKindOfClass:[HomeViewController class]]) {
                    [delegate didFinishRead:@"0" readList:_array type:_type];
                    }
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    if ([delegate isKindOfClass:[HomeViewController class]]) {
                    [delegate didFinishRead:@"1" readList:_array type:_type];
                    }
                }
            }
            break;
            
        case RequestTypeSystemMt:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:0]];
                [self convertForSystemSetting:_msg];
                
                removeType = currentType;
                isFinish = YES;
                
                [self getTableID:delegate
                           count:1];
            }
            break;
            
        case RequestTypeTableID:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertFotTableID:_msg];
                
                if ([self convertToRetainCount:_msg]>0) {
                    [self getTableID:delegate
                               count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getTanto:delegate
                               count:1];
                }
            }
            break;
            
        case RequestTypeTanto:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertFotTanto:_msg];
                
                if ([self convertToRetainCount:_msg]>0) {
                    [self getTanto:delegate
                               count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getCategory:delegate
                            count:1];
                }
            }
            break;
            
        case RequestTypeCategoryGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForCategoty:_msg];
                if ([self convertToRetainCount:_msg]>0) {
                    [self getCategory:delegate
                                count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenu:delegate
                            count:1];
                }
            }
            break;
            
        case RequestTypeMenuGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenu:_msg];
                
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenu:delegate
                             count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenu1:delegate
                             count:1];
                }
            }
            break; 
             
        case RequestTypeMenuGet1:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenu1:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenu1:delegate
                             count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuGet1 Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenu2:delegate
                            count:1];
                }
            }
            break;
            
        case RequestTypeMenuGet2:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenu2:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenu2:delegate
                             count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuGet2 Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenuInfo:delegate count:1];
                }
            }
            break;
            
        case RequestTypeMenuInfoGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenuInfo:_msg];
                //LOG(@"Syohin:%@",_array);
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenuInfo:delegate
                                 count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuInfoGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenuInfo1:delegate
                                 count:1];
                     
                }
            }
            break;
            
        case RequestTypeMenuInfoGet1:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenuInfo1:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenuInfo1:delegate
                                count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuInfoGet1 Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getMenuInfo2:delegate
                     count:1];
                }
            }
            break;
            
        case RequestTypeMenuInfoGet2:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForMenuInfo2:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getMenuInfo2:delegate
                                 count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeMenuInfoGet2 Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getCondiment:delegate
                                 count:1];
                }
            }
            break;
            
        case RequestTypeCondimentGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForCondiment:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getCondiment:delegate
                                 count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeCondimentGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getCommentGD:delegate
                                 count:1];
                }
            }
            break;

        case RequestTypeCommentGDGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForCommentGD:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getCommentGD:delegate
                                 count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeCommentGDGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getComment:delegate
                                 count:1];
                }
            }
            break;
            
        case RequestTypeCommentGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForComment:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getComment:delegate
                                    count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeCommentGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getOfferGD:delegate
                                  count:1];
                }
            }
            break;
            
        case RequestTypeOfferGDGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForOfferGD:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getOfferGD:delegate
                                  count:[_array count]+1];
                }
                else{
                    
                    LOG(@"RequestTypeCommentGet Finish");
                    removeType = currentType;
                    isFinish = YES;
                    [self getOffer:delegate
                                  count:1];
                }
            }
            break;
            
        case RequestTypeOfferGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForOffer:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getOffer:delegate
                                  count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getNote:delegate
                             count:1];
                }
            }
            break;
            
        case RequestTypeNoteGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForNote:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getNote:delegate
                             count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getKyakuso:delegate
                               count:1];
                }
            }
            break;
            
        case RequestTypeKyakusoGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForKyakuso:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getKyakuso:delegate
                             count:[_array count]+1];
                }
                else{
                    removeType = currentType;
                    isFinish = YES;
                    [self getPattern:delegate
                               count:1];
                }
            }
            break;
            
        case RequestTypePatternGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForPattern:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getPattern:delegate
                               count:[_array count]+1];
                }
                else{
                    //2014-07-16 ueda
                    removeType = currentType;
                    isFinish = YES;
                    [self getColor:delegate
                               count:1];
                }
            }
            break;
           
        case RequestTypeColorGet:
            //2014-07-16 ueda
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForColor:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getColor:delegate
                             count:[_array count]+1];
                }
                else{
                    //[sys saveChacheAccount];
                    removeType = currentType;
                        isFinish = YES;
                    //2015-03-24 ueda
                    //[delegate didFinishRead:_array readList:_array type:_type];
                    [self getRegiMt:delegate
                             count:1];
                }
            }
            break;
            
            
        case RequestTypeRegiMt:
            //2015-03-20 ueda
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertForRegiMt:_msg];
                LOG(@"retain:%zd now:%zd",[self convertToRetainCount:_msg],[_array count]);
                if ([self convertToRetainCount:_msg]>0) {
                    [self getColor:delegate
                             count:[_array count]+1];
                }
                else{
                    //マスタダウンロード完了
                    [sys saveChacheAccount];
                    removeType = currentType;
                    isFinish = YES;
                    [delegate didFinishRead:_array readList:_array type:_type];
                }
            }
            break;
            
        case RequestTypeKokyakuInfoGet:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertForKokyakuInfo:_msg] readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableStatus://[N11]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                //if ([_msg length]<21) {
                NSArray *_dataArray =  [self convertDataForTable:_msg];
                if ([_dataArray count]>0) {
                    removeType = currentType;
                    isFinish = YES;
                    [delegate didFinishRead:_dataArray readList:_array type:_type];
                }
                //}
            }
            break;
            
        case RequestTypeTableReadyFinish://[N12]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableMove://[N13]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableReserve://[N14]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertForTableReserve:_msg] readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableSyohin://[N15]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertTableMenu:_msg] readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableTaiki://[N16]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableInShow://[N17]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableInShow2://[N17]その２
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableEmpty://[N18]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableKeyID://[N23]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
                dic[@"KeyID"] = [_msg substringWithRange:NSMakeRange(4, 10)];
                dic[@"time"] = [_msg substringWithRange:NSMakeRange(14, 16)];
                [delegate didFinishRead:dic readList:_array type:_type];
            }
            break;
            
        case RequestTypeTableExtension://[N24]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeOrderRequest:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                self.orderResultMsg = @"";
                LOG(@"_msg:%@",_msg);
                if ([_msg length]>4) {
                    NSRange rng = [_msg rangeOfString:@"<"];
                    if (rng.location != NSNotFound) {
                        self.orderResultMsg = [_msg substringFromIndex:rng.location];
                    }
                }
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:self.orderResultMsg readList:_array type:_type];
            }
            break;
            
        case RequestTypeOrderDirection:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherList:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                
                NSString *section = [_msg substringWithRange:NSMakeRange(4, 1)];
                LOG(@"section:%@",section);
                
                if ([section intValue]==0) {
                    [delegate didFinishRead:[self convertVoucherList:_msg]
                                   readList:_array type:_type];
                }
                else if ([section intValue]==1) {
                    [self convertVoucherDetail:[_msg substringWithRange:NSMakeRange(5, [_msg length]-5)]];
                    //NSArray *array = [self convertVoucherNo1:_msg];
                    [delegate didFinishRead:_array
                                   readList:_array type:RequestTypeVoucherDetail];
                }
                else if ([section intValue]==2) {
                    //[self convertVoucherNo2:_msg];
                    
                    DataList *dat = [DataList sharedInstance];
                    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
                    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5,4)];
                    dat.currentVoucher = _dic;
                    dat.manCount = [[_msg substringWithRange:NSMakeRange(12,2)] intValue];
                    dat.womanCount = [[_msg substringWithRange:NSMakeRange(14,2)] intValue];
                    
                    //2015-06-17 ueda
                    if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
                        //担当者コード：６桁
                        dat.childCount = [[_msg substringWithRange:NSMakeRange(16,2)] intValue];
                    } else {
                        //2014-12-12 ueda
                        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                            //入力タイプＣ or 小人入力する
                            //2014-11-17 ueda
                            dat.childCount = [[_msg substringWithRange:NSMakeRange(16,2)] intValue];
                        } else {
                            //小人入力しない
                            dat.childCount = 0;
                        }
                    }
                    
                    [delegate didFinishRead:[self convertVoucherCheck:[_msg substringWithRange:NSMakeRange(5, [_msg length]-5)]]
                                   readList:_array type:RequestTypeVoucherNo];
                }
                else if ([section intValue]==3) {
                    NSMutableArray *array = [[NSMutableArray alloc]init];
                    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
                    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5, 4)];
                    _dic[@"disp"] = [NSNumber numberWithInt:[_dic[@"EdaNo"]intValue]];
                    [array addObject:_dic];
                    [delegate didFinishRead:array
                                   readList:_array type:RequestTypeVoucherTable];
                }

                removeType = currentType;
                isFinish = YES;
            }
            break;
            
        //2014-09-11 ueda
        case RequestTypeVoucherListTypeC:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                
                NSString *section = [_msg substringWithRange:NSMakeRange(4, 1)];
                LOG(@"section:%@",section);
                
                if ([section intValue]==0) {
                    //2014-10-23 ueda
                    [delegate didFinishRead:[self convertVoucherListTypeC:_msg]
                                   readList:_array type:_type];
                }
                else if ([section intValue]==1) {
                    [self convertVoucherDetailTypeC:[_msg substringWithRange:NSMakeRange(5, [_msg length]-5)]];
                    //NSArray *array = [self convertVoucherNo1:_msg];
                    [delegate didFinishRead:_array
                                   readList:_array type:RequestTypeVoucherDetailTypeC];
                }
                else if ([section intValue]==2) {
                    //[self convertVoucherNo2:_msg];
                    
                    DataList *dat = [DataList sharedInstance];
                    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
                    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5,4)];
                    dat.currentVoucher = _dic;
                    dat.manCount = [[_msg substringWithRange:NSMakeRange(12,2)] intValue];
                    dat.womanCount = [[_msg substringWithRange:NSMakeRange(14,2)] intValue];
                    //2014-11-17 ueda
                    dat.childCount = [[_msg substringWithRange:NSMakeRange(16,2)] intValue];
                    
                    [delegate didFinishRead:[self convertVoucherCheck:[_msg substringWithRange:NSMakeRange(5, [_msg length]-5)]]
                                   readList:_array type:RequestTypeVoucherNo];
                }
                else if ([section intValue]==3) {
                    NSMutableArray *array = [[NSMutableArray alloc]init];
                    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
                    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5, 4)];
                    _dic[@"disp"] = [NSNumber numberWithInt:[_dic[@"EdaNo"]intValue]];
                    [array addObject:_dic];
                    [delegate didFinishRead:array
                                   readList:_array type:RequestTypeVoucherTable];
                }
                
                removeType = currentType;
                isFinish = YES;
            }
            break;
            
        case RequestTypeTableReadyDirection://[C12]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertVoucherListDirection:_msg] readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherDirection:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertVoucherDirection:_msg] readList:_array type:_type];
            }
            break;
            

        case RequestTypeVoucherDetail:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertVoucherDetail:_msg];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            
            
            /*
            NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
            LOG(@"retain:%d now:%d",[self convertToRetainCount:_msg],[_array count]);
            if ([self convertToRetainCount:_msg]>0) {
                [self getOffer:delegate
                         count:[_array count]+1];
            }
            else{
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            */
            
            break;
            
        //2014-09-11 ueda
        case RequestTypeVoucherDetailTypeC:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                [self convertVoucherDetailTypeC:_msg];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherDivideNotPrint:{
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                LOG(@"%@",_msg);
                removeType = currentType;
                isFinish = YES;
                NSArray *array = [self convertForVoucherDivideResult:_msg];
                LOG(@"%@",array);
                [delegate didFinishRead:array readList:_array type:_type];
            }
            break;
        }
        case RequestTypeVoucherDividePrint:
            if ([_array count]>0) {
                //NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                //LOG(@"%@",_msg);
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:nil readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherCheck:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:[self convertVoucherCheck:_msg] readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherPrint:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        case RequestTypeVoucherPush:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;

        case RequestTypeVoucherSearch:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                        isFinish = YES;
                    [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        //2015-03-24 ueda
        case RequestTypePokeRegiStart:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [self convertPokeRegiStart:_msg];
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        //2015-03-24 ueda
        case RequestTypePokeRegiFinish:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        //2015-03-24 ueda
        case RequestTypePokeRegiCancel:
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        //2015-05-12 ueda
        case RequestTypeClearMessage://[N72]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;

        //2015-06-05 ueda
        case RequestTypeOrderStat:  //[N45]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                if ([self convertAndSaveOrderStat:_msg count:[_array count]] == 0) {
                    isFinish = YES;
                    [delegate didFinishRead:nil readList:_array type:_type];
                } else {
                    [self getOrderStat:delegate count:[_array count] + 1];
                }
            }
            break;

        //2015-06-05 ueda
        case RequestTypeReserveList:    //[N46]
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                if ([self convertAndSaveReserveList:_msg count:[_array count]] == 0) {
                    isFinish = YES;
                    [delegate didFinishRead:nil readList:_array type:_type];
                } else {
                    [self getReserveList:delegate count:[_array count] + 1];
                }
            }
            break;

        //2016-01-05 ueda ASTERISK
        case RequestTypeOrderNinzu:     //A27
            if ([_array count]>0) {
                NSString *_msg = [self convertToAfterEqual:[_array objectAtIndex:[_array count]-1]];
                removeType = currentType;
                isFinish = YES;
                [delegate didFinishRead:_msg readList:_array type:_type];
            }
            break;
            
        default:
            break;
    }
	
    
    if (isFinish) {
        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",removeType]];
    }
}


-(NSString*)appendSpace:(NSString*)str
            totalLength:(NSInteger)length{
    
    str = [str stringByTrimmingCharactersInSet:
             [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    NSMutableString *mutable = [[NSMutableString alloc]init];
    [mutable appendString:str];
    if ([mutable length]<length) {
        for (int ct1 = 0; ct1<length-[str length]; ct1++) {
            [mutable appendString:@" "];
        }
    }
    return [NSString stringWithFormat:@"%@",mutable];
}

-(NSString*)appendSpaceWithNum:(NSNumber*)num
            totalLength:(int)length{
    
    NSString *str = [NSString stringWithFormat:@"%d",[num intValue]];
    
    NSMutableString *mutable = [[NSMutableString alloc]init];
    [mutable appendString:str];
    if ([mutable length]<length) {
        for (int ct1 = 0; ct1<length-[str length]; ct1++) {
            [mutable appendString:@" "];
        }
    }
    return [NSString stringWithFormat:@"%@",mutable];
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	// Since we requested HTTP/1.0, we expect the server to close the connection as soon as it has sent the response.

	LOG(@"socketDidDisconnect:withError: \"%@\"", err);

    NSMutableDictionary *_dic = [socketList objectForKey:[NSString stringWithFormat:@"%d",currentType]];
    id delegate = [_dic valueForKey:@"delegate"] ;
    
    
    if(err){
        //2014-12-04 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.communication_Return_Status = communication_Return_NG;

        [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
        NSString *_errStr = [err localizedDescription];
        NSRange match1 = [_errStr rangeOfString:@"timed out" options:NSRegularExpressionSearch];
        NSRange match2 = [_errStr rangeOfString:@"No route to host" options:NSRegularExpressionSearch];
        if (match1.location != NSNotFound) {
            
            //Note:マスタ取得時のタイムアウト処理を追加する
            if (isMaster) {
                [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
                [delegate didFinishReadWithError:err
                                             msg:[String Plese_try_again]
                                            type:[[_dic valueForKey:@"requestType"]intValue]];
            }
            else{
                [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
                [delegate didFinishReadWithError:err
                                             msg:[String Plese_try_again]
                                            type:[[_dic valueForKey:@"requestType"]intValue]];
            }
        }
        else if (match2.location != NSNotFound){
            [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
            [delegate didFinishReadWithError:err
                                         msg:[String Network_is_disconnected]
                                        type:[[_dic valueForKey:@"requestType"]intValue]];
        }
        else{
            [socketList removeObjectForKey:[NSString stringWithFormat:@"%d",currentType]];
            if ([_errStr rangeOfString:@"Connection refused"].location != NSNotFound) {
                [delegate didFinishReadWithError:err
                                             msg:[String Cannot_connect]
                                            type:[[_dic valueForKey:@"requestType"]intValue]];
            } else {
                [delegate didFinishReadWithError:err
                                             msg:[err localizedDescription]
                                            type:[[_dic valueForKey:@"requestType"]intValue]];
            }
        }
    }
}


#pragma mark Socket Data Convert to class

//「=」以降の文字列を取得する
- (NSString*)convertToAfterEqual:(NSString*)_str{
    NSInteger loc = [_str rangeOfString:@"="].location+1;
    NSString *str = [_str substringWithRange:NSMakeRange(loc, [_str length]-loc)];
    return str;
}

//残処理件数を取得する
- (NSInteger)convertToRetainCount:(NSString*)_str{
    NSString *str = [_str substringWithRange:NSMakeRange(7,6)];
    LOG(@"Retain:%@",str);
    return [str intValue];
}


- (BOOL)convertForSystemSettingMaster:(NSString*)_msg{
    
    sys = [System sharedInstance];
    
    BOOL update = NO;
    
    LOG(@"%@:%@",sys.masterVer,[_msg substringWithRange:NSMakeRange(13, 2)]);
    
    if ([sys.masterVer isEqualToString:[_msg substringWithRange:NSMakeRange(13, 2)]]) {
        update = YES;
    }
    
    return update;
}

- (BOOL)convertForSystemSetting:(NSString*)_msg{
    
    sys = [System sharedInstance];
    
    BOOL update = NO;
    if ([sys.masterVer isEqualToString:[_msg substringWithRange:NSMakeRange(13, 2)]]) {
        update = YES;
    }
    
    sys.masterVer = [_msg substringWithRange:NSMakeRange(13, 2)];
    //LOG(@"sys.masterVer:%@",sys.masterVer);
    sys.menuPattern = [_msg substringWithRange:NSMakeRange(15, 1)];
    if ([[System sharedInstance].menuPatternEnable isEqualToString:@"1"]) {
        sys.menuPatternType = sys.menuPattern;
    }
    sys.aiseki = [_msg substringWithRange:NSMakeRange(16, 1)];
    sys.ninzu = [_msg substringWithRange:NSMakeRange(17, 1)];
    sys.zeronin = [_msg substringWithRange:NSMakeRange(18, 1)];
    sys.orderType = [_msg substringWithRange:NSMakeRange(19, 1)];
    sys.getMaster = @"1";
    
    //[sys saveChacheAccount];
    
    return update;
}


- (void)convertFotTableID:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 4)]intValue];
    LOG(@"count1:%d",count);
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    for (int ct = 0; ct<count; ct++) {
        //2014-03-18 ueda for 漢字
        [self.db executeUpdate:@"insert into Table_MT values (?, ?, ?)",
         //[_msg substringWithRange:NSMakeRange(17+7*ct, 4)],
         //[_msg substringWithRange:NSMakeRange(21+7*ct, 3)],
         [self getShiftJisMid:_msg startPos:17+7*ct length:4],
         [self getShiftJisMid:_msg startPos:21+7*ct length:3],
         @""
         ];
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (NSArray*)convertFotTanto:(NSString*)_msg{
    
    int count = [[_msg substringWithRange:NSMakeRange(13, 2)]intValue];
    DataList *_data = [DataList sharedInstance];
    if (!_data.tantoList)_data.tantoList = [[NSMutableArray alloc]init];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    for (int ct = 0; ct<count; ct++) {

        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        char *s5 = calloc(kCharaSize,sizeof(char));
        char *s6 = calloc(kCharaSize,sizeof(char));
        char *s7 = calloc(kCharaSize,sizeof(char));
        char *s8 = calloc(kCharaSize,sizeof(char));
        char *s9 = calloc(kCharaSize,sizeof(char));
        char *s10 = calloc(kCharaSize,sizeof(char));
        char *s11 = calloc(kCharaSize,sizeof(char));
        char *s12 = calloc(kCharaSize,sizeof(char));

        //2015-06-17 ueda 担当者コードを６桁に
        int span;
        if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
            //担当者コード：６桁
            span = 44;

            strncpy(s1,  s+15+span*ct,6);
            strncpy(s2,  s+21+span*ct,8);
            strncpy(s3,  s+29+span*ct,1);
            strncpy(s4,  s+30+span*ct,1);
            strncpy(s5,  s+31+span*ct,20);
            strncpy(s6,  s+51+span*ct,1);
            strncpy(s7,  s+52+span*ct,1);
            strncpy(s8,  s+53+span*ct,1);
            strncpy(s9,  s+54+span*ct,1);
            strncpy(s10, s+55+span*ct,1);
            strncpy(s11, s+56+span*ct,1);
            strncpy(s12, s+57+span*ct,2);

            s1[7] = '\0';
        } else {
            span = 40;
            
            strncpy(s1,  s+15+span*ct,2);
            strncpy(s2,  s+17+span*ct,8);
            strncpy(s3,  s+25+span*ct,1);
            strncpy(s4,  s+26+span*ct,1);
            strncpy(s5,  s+27+span*ct,20);
            strncpy(s6,  s+47+span*ct,1);
            strncpy(s7,  s+48+span*ct,1);
            strncpy(s8,  s+49+span*ct,1);
            strncpy(s9,  s+50+span*ct,1);
            strncpy(s10, s+51+span*ct,1);
            strncpy(s11, s+52+span*ct,1);
            strncpy(s12, s+53+span*ct,2);
            
            s1[3] = '\0';
        }

        
        s2[9] = '\0';
        s3[2] = '\0';
        s4[2] = '\0';
        s5[21] = '\0';
        s6[2] = '\0';
        s7[2] = '\0';
        s8[2] = '\0';
        s9[2] = '\0';
        s10[2] = '\0';
        s11[2] = '\0';
        s12[3] = '\0';
        
        NSString *_name = [NSString stringWithCString:s2 encoding:kEnc];
        _name = [_name stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self.db executeUpdate:@"insert into Tanto_MT values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         _name,
         [NSString stringWithCString:s3 encoding:kEnc],
         [NSString stringWithCString:s4 encoding:kEnc],
         [NSString stringWithCString:s5 encoding:kEnc],
         [NSString stringWithCString:s6 encoding:kEnc],
         [NSString stringWithCString:s7 encoding:kEnc],
         [NSString stringWithCString:s8 encoding:kEnc],
         [NSString stringWithCString:s9 encoding:kEnc],
         [NSString stringWithCString:s10 encoding:kEnc],
         [NSString stringWithCString:s11 encoding:kEnc],
         [NSString stringWithCString:s12 encoding:kEnc]
         //[NSString stringWithFormat:@"%d",[[NSString stringWithCString:s12 encoding:kEnc]intValue]]
         ];

        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
        free(s6);
        free(s7);
        free(s8);
        free(s9);
        free(s10);
        free(s11);
        free(s12);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
    
    return _data.tantoList;
}


- (void)convertForCategoty:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 3)]intValue];
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    const char *s1 = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        
        char *s2 = calloc(kCharaSize,sizeof(char));
        strncpy(s2, s1+16+7*ct,7);
        s2[18] = '\0';
        NSString* str = [NSString stringWithCString:s2 encoding:kEnc];
        free(s2);
        
        //2015-12-08 ueda ASTERISK_TEST
        //カテゴリーコードを２桁に変換
        if (YES) {
            NSString *cateCd = [str substringWithRange:NSMakeRange(1, 1)];
            NSString *cateDbVal = convertCategoryCodeTwoCharacter(cateCd);
            [self.db executeUpdate:@"insert into Cate_MT values (?, ?, ?)",
             [str substringWithRange:NSMakeRange(0, 1)],//PatternCD
             cateDbVal,//CateCD
             [str substringWithRange:NSMakeRange(2,[str length]-2)]//DispOrder
             ];
        } else {
            [self.db executeUpdate:@"insert into Cate_MT values (?, ?, ?)",
             [str substringWithRange:NSMakeRange(0, 1)],//PatternCD
             [str substringWithRange:NSMakeRange(1, 1)],//CateCD
             [str substringWithRange:NSMakeRange(2,[str length]-2)]//DispOrder
             ];
        }
        //check
        if ([self.db hadError]) {
            NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }
    }
    
    [self.db commit];
}

- (void)convertForMenu:(NSString*)_msg{
    
    LOG(@"%@",[_msg substringWithRange:NSMakeRange(13, 6)]);
    
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    for (int ct = 0; ct<count; ct++) {
        
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(24+19*ct, 13)];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //2015-12-08 ueda ASTERISK_TEST
        //カテゴリーコードを２桁に変換
        if (YES) {
            NSString *cateCd = [_msg substringWithRange:NSMakeRange(20+19*ct, 1)];
            NSString *cateDbVal = convertCategoryCodeTwoCharacter(cateCd);
            [self.db executeUpdate:@"insert into Menu_MT values (?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+19*ct, 1)],//PatternCD
             cateDbVal,//CateCD
             [_msg substringWithRange:NSMakeRange(21+19*ct,3)],//DispOrder
             SyohinCD,//SyohinCD
             [_msg substringWithRange:NSMakeRange(37+19*ct, 1)]//BNGFLG
             ];
        } else {
            [self.db executeUpdate:@"insert into Menu_MT values (?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+19*ct, 1)],//PatternCD
             [_msg substringWithRange:NSMakeRange(20+19*ct, 1)],//CateCD
             [_msg substringWithRange:NSMakeRange(21+19*ct,3)],//DispOrder
             SyohinCD,//SyohinCD
             [_msg substringWithRange:NSMakeRange(37+19*ct, 1)]//BNGFLG
             ];
        }
        
        //check
        if ([self.db hadError]) {
            NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
        }
    }
    
    [self.db commit];
}

- (void)convertForMenu1:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    LOG(@"count1:%d",count);
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    for (int ct = 0; ct<count; ct++) {
        
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(27+22*ct, 13)];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //2015-12-08 ueda ASTERISK_TEST
        //カテゴリーコードを２桁に変換
        if (YES) {
            NSString *cateCd = [_msg substringWithRange:NSMakeRange(20+22*ct, 1)];
            NSString *cateDbVal = convertCategoryCodeTwoCharacter(cateCd);
            [self.db executeUpdate:@"insert into Menu_B1MT values (?, ?, ?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+22*ct, 1)],//PatternCD
             cateDbVal,//CateCD
             [_msg substringWithRange:NSMakeRange(21+22*ct,2)],//PageNo
             [_msg substringWithRange:NSMakeRange(23+22*ct,1)],//B1CateCD
             [_msg substringWithRange:NSMakeRange(24+22*ct,3)],//DispOrder
             SyohinCD,//SyohinCD
             [_msg substringWithRange:NSMakeRange(40+22*ct, 1)]//BNGFLG
             ];
        } else {
            [self.db executeUpdate:@"insert into Menu_B1MT values (?, ?, ?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+22*ct, 1)],//PatternCD
             [_msg substringWithRange:NSMakeRange(20+22*ct, 1)],//CateCD
             [_msg substringWithRange:NSMakeRange(21+22*ct,2)],//PageNo
             [_msg substringWithRange:NSMakeRange(23+22*ct,1)],//B1CateCD
             [_msg substringWithRange:NSMakeRange(24+22*ct,3)],//DispOrder
             SyohinCD,//SyohinCD
             [_msg substringWithRange:NSMakeRange(40+22*ct, 1)]//BNGFLG
             ];
        }
    }
    [self.db commit];
       
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForMenu2:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    LOG(@"count1:%d",count);
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    
    for (int ct = 0; ct<count; ct++) {
        
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(30+24*ct, 13)];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //2015-12-08 ueda ASTERISK_TEST
        //カテゴリーコードを２桁に変換
        if (YES) {
            NSString *cateCd = [_msg substringWithRange:NSMakeRange(20+24*ct, 1)];
            NSString *cateDbVal = convertCategoryCodeTwoCharacter(cateCd);
            [self.db executeUpdate:@"insert into Menu_B2MT values (?, ?, ?, ?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+24*ct, 1)],//PatternCD
             cateDbVal,//CateCD
             [_msg substringWithRange:NSMakeRange(21+24*ct,2)],//PageNo
             [_msg substringWithRange:NSMakeRange(23+24*ct, 1)],//B1CateCD
             [_msg substringWithRange:NSMakeRange(24+24*ct,2)],//B1PageNo
             [_msg substringWithRange:NSMakeRange(26+24*ct,1)],//B2CateCD
             [_msg substringWithRange:NSMakeRange(27+24*ct,3)],//DispOrder
             SyohinCD//SyohinCD
             ];
        } else {
            [self.db executeUpdate:@"insert into Menu_B2MT values (?, ?, ?, ?, ?, ?, ?, ?)",
             [_msg substringWithRange:NSMakeRange(19+24*ct, 1)],//PatternCD
             [_msg substringWithRange:NSMakeRange(20+24*ct, 1)],//CateCD
             [_msg substringWithRange:NSMakeRange(21+24*ct,2)],//PageNo
             [_msg substringWithRange:NSMakeRange(23+24*ct, 1)],//B1CateCD
             [_msg substringWithRange:NSMakeRange(24+24*ct,2)],//B1PageNo
             [_msg substringWithRange:NSMakeRange(26+24*ct,1)],//B2CateCD
             [_msg substringWithRange:NSMakeRange(27+24*ct,3)],//DispOrder
             SyohinCD//SyohinCD
             ];
        }
    }
    [self.db commit];
       
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForMenuInfo:(NSString*)_msg{
    
    //2014-08-05 ueda
    int infoCount = 0;  //処理済み商品情報のカウント
    
    int count = [[_msg substringWithRange:NSMakeRange(13, 4)]intValue];
    BOOL infoFLG = NO;
    
    const char *s = [_msg cStringUsingEncoding:kEnc];
    
    [self openDb];
    [self.db beginTransaction];
    for (int ct = 0; ct<count; ct++) {
        //2014-08-05 ueda
        /*
        int span;
        if (infoFLG) {
            span = 268;
        }
        else{
            span = 68;
        }
         */
        
        char *debug = calloc(kCharaSize,sizeof(char));
        
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        char *s5 = calloc(kCharaSize,sizeof(char));
        char *s6 = calloc(kCharaSize,sizeof(char));
        char *s7 = calloc(kCharaSize,sizeof(char));
        char *s8 = calloc(kCharaSize,sizeof(char));
        char *s9 = calloc(kCharaSize,sizeof(char));
        char *s10 = calloc(kCharaSize,sizeof(char));
        char *s11 = calloc(kCharaSize,sizeof(char));
        char *s12 = calloc(kCharaSize,sizeof(char));
        char *s13 = calloc(kCharaSize,sizeof(char));
        char *s14 = calloc(kCharaSize,sizeof(char));
        char *s15 = calloc(kCharaSize,sizeof(char));
        
        //2014-08-05 ueda
        /*
        strncpy(debug, s+17+span*ct,248);
        
        strncpy(s1, s+17+span*ct,13);
        strncpy(s2, s+30+span*ct,8);
        strncpy(s3, s+38+span*ct,8);
        strncpy(s4, s+46+span*ct,8);
        strncpy(s5, s+54+span*ct,1);
        strncpy(s6, s+55+span*ct,1);
        strncpy(s7, s+56+span*ct,1);
        strncpy(s8, s+57+span*ct,7);
        strncpy(s9, s+64+span*ct,7);
        strncpy(s10, s+71+span*ct,1);
        strncpy(s11, s+72+span*ct,6);
        strncpy(s12, s+78+span*ct,1);
        strncpy(s13, s+79+span*ct,5);
        strncpy(s14, s+84+span*ct,1);
        strncpy(s15, s+85+span*ct,200);
         */
        
        int offsetX = (ct * 68) + (infoCount * 200);
        strncpy(debug, s + 17 + offsetX, 248);
        
        strncpy(s1   , s + 17 + offsetX,  13);
        strncpy(s2   , s + 30 + offsetX,   8);
        strncpy(s3   , s + 38 + offsetX,   8);
        strncpy(s4   , s + 46 + offsetX,   8);
        strncpy(s5   , s + 54 + offsetX,   1);
        strncpy(s6   , s + 55 + offsetX,   1);
        strncpy(s7   , s + 56 + offsetX,   1);
        strncpy(s8   , s + 57 + offsetX,   7);
        strncpy(s9   , s + 64 + offsetX,   7);
        strncpy(s10  , s + 71 + offsetX,   1);
        strncpy(s11  , s + 72 + offsetX,   6);
        strncpy(s12  , s + 78 + offsetX,   1);
        strncpy(s13  , s + 79 + offsetX,   5);
        strncpy(s14  , s + 84 + offsetX,   1);
        strncpy(s15  , s + 85 + offsetX, 200);
        
        debug[249] = '\0';
        
        s1[14] = '\0';
        s2[9] = '\0';
        s3[9] = '\0';
        s4[9] = '\0';
        s5[2] = '\0';
        s6[2] = '\0';
        s7[2] = '\0';
        s8[8] = '\0';
        s9[8] = '\0';
        s10[2] = '\0';
        s11[7] = '\0';
        s12[2] = '\0';
        s13[10] = '\0';
        s14[2] = '\0';
        s15[201] = '\0';
        
        /*
        NSLog(@"s1:%s",s1);
        NSLog(@"s2:%s",s2);
        NSLog(@"s3:%s",s3);
        NSLog(@"s4:%s",s4);
        NSLog(@"s5:%s",s5);
        NSLog(@"s6:%s",s6);
        NSLog(@"s7:%s",s7);
        NSLog(@"s8:%s",s8);
        NSLog(@"s9:%s",s9);
        NSLog(@"s10:%s",s10);
        NSLog(@"s11:%s",s11);
        NSLog(@"s12:%s",s12);
        NSLog(@"s13:%s",s13);
        NSLog(@"s14:%s",s14);
        NSLog(@"s15:%s",s15);
         */
        
        //NSString *debugS = [NSString stringWithCString:debug encoding:kEnc];

        NSString *SyohinCD = [NSString stringWithCString:s1 encoding:kEnc];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];

            NSString *InfoFLG = [NSString stringWithCString:s14 encoding:kEnc];
        LOG(@"SyohinCD:%@",SyohinCD);
            NSMutableString *Info = [[NSMutableString alloc]init];
            [Info appendString:@""];
            if ([InfoFLG isEqualToString:@"1"]) {
                //2014-08-05 ueda
                infoCount++;
                infoFLG = YES;
                //Info = [NSString stringWithCString:s15 encoding:kEnc];

                NSInteger len = strlen(s15);
                //2014-08-05 ueda
                //int ct = 0;
                
                char *result = calloc(kCharaSize,sizeof(char));
                
                //2014-08-05 ueda
                /*
                for(int i = 0; i < len; i++){
                    if (ct==0) {
                        char *section = calloc(kCharaSize,sizeof(char));
                        strncpy(section, s15+i,20);
                        section[21] = '\0';
                        strcat(result, section);
                        int resultLen = strlen(result);
                        result[resultLen] = '\0';
                        
                        strcat(result, "\n");
                        result[resultLen+4] = '\0';
                        
                        free(section);
                    }
                    
                    ct++;
                    
                    if (ct==20) {
                        ct=0;
                    }
                }
                 */
                for(int i = 0; i < len; i += 20){
                    char *section = calloc(kCharaSize,sizeof(char));
                    strncpy(section, s15+i,20);
                    section[21] = '\0';
                    strcat(result, section);
                    NSInteger resultLen = strlen(result);
                    result[resultLen] = '\0';
                    
                    strcat(result, "\n");
                    result[resultLen+4] = '\0';
                    
                    free(section);
                }
                

                NSInteger resultLen = strlen(result);
                result[resultLen] = '\0';
                
                [Info appendString:[NSString stringWithCString:result encoding:kEnc]];
                free(result);
                LOG(@"INFO:%@",Info);
            }
            else{
                infoFLG = NO;
            }
        
            [self.db executeUpdate:@"insert into Syohin_MT values (?, ?, ?, ?, ?,?, ?, ?, ?, ?,?, ?, ?, ?, ?)",
             SyohinCD,
             [NSString stringWithCString:s2 encoding:kEnc],
             [NSString stringWithCString:s3 encoding:kEnc],
             [NSString stringWithCString:s4 encoding:kEnc],
             [NSString stringWithCString:s5 encoding:kEnc],
             [NSString stringWithCString:s6 encoding:kEnc],
             [NSString stringWithCString:s7 encoding:kEnc],
             [NSString stringWithCString:s8 encoding:kEnc],
             [NSString stringWithCString:s9 encoding:kEnc],
             [NSString stringWithCString:s10 encoding:kEnc],
             [NSString stringWithCString:s11 encoding:kEnc],
             [NSString stringWithCString:s12 encoding:kEnc],
             [NSString stringWithCString:s13 encoding:kEnc],
             InfoFLG,
             Info];

        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
        free(s6);
        free(s7);
        free(s8);
        free(s9);
        free(s10);
        free(s11);
        free(s12);
        free(s13);
        free(s14);
        free(s15);
        free(debug);
    }
    [self.db commit];
    [self closeDb];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForMenuInfo1:(NSString*)_msg{
    
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];

    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        char *s5 = calloc(kCharaSize,sizeof(char));
        char *s6 = calloc(kCharaSize,sizeof(char));
        char *s7 = calloc(kCharaSize,sizeof(char));

        strncpy(s1, s+19+29*ct,13);
        strncpy(s2, s+32+29*ct,1);
        strncpy(s3, s+33+29*ct,4);
        strncpy(s4, s+37+29*ct,5);
        strncpy(s5, s+42+29*ct,1);
        strncpy(s6, s+43+29*ct,4);
        strncpy(s7, s+47+29*ct,1);
        
        s1[14] = '\0';
        s2[2] = '\0';
        s3[5] = '\0';
        s4[6] = '\0';
        s5[2] = '\0';
        s6[4] = '\0';
        s7[2] = '\0';
        
        NSString *SyohinCD = [NSString stringWithCString:s1 encoding:kEnc];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //MstSyohinCD text,SG1ID text,HTDispNM text,GroupType text,GroupCD text,LimitCount text,count text
        
        [self.db executeUpdate:@"insert into SG1_MT values (?, ?, ?, ?, ?,?, ?)",
         SyohinCD,
         [NSString stringWithCString:s2 encoding:kEnc],
         [NSString stringWithCString:s3 encoding:kEnc],
         [NSString stringWithCString:s4 encoding:kEnc],
         [NSString stringWithCString:s5 encoding:kEnc],
         [NSString stringWithCString:s6 encoding:kEnc],
         [NSString stringWithCString:s7 encoding:kEnc]
         ];
       
        
        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
        free(s6);
        free(s7);
    }
    [self.db commit];
       
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}


- (void)convertForMenuInfo2:(NSString*)_msg{
    
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        char *s5 = calloc(kCharaSize,sizeof(char));
        char *s6 = calloc(kCharaSize,sizeof(char));
        char *s7 = calloc(kCharaSize,sizeof(char));
        char *s8 = calloc(kCharaSize,sizeof(char));
        char *s9 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+19+37*ct,13);
        strncpy(s2, s+32+37*ct,4);
        strncpy(s3, s+36+37*ct,4);
        strncpy(s4, s+40+37*ct,1);
        strncpy(s5, s+41+37*ct,4);
        strncpy(s6, s+45+37*ct,5);
        strncpy(s7, s+50+37*ct,1);
        strncpy(s8, s+51+37*ct,4);
        strncpy(s9, s+55+37*ct,1);
        
        s1[14] = '\0';
        s2[5] = '\0';
        s3[5] = '\0';
        s4[2] = '\0';
        s5[5] = '\0';
        s6[6] = '\0';
        s7[2] = '\0';
        s8[5] = '\0';
        s9[2] = '\0';
        
        NSString *SyohinCD = [NSString stringWithCString:s1 encoding:kEnc];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        //MstSyohinCD text,CondiGCD text,CondiGDID text,SG2ID text,HTDispNM text,GroupType text,GroupCD text,LimitCount text,count text
        

        [self.db executeUpdate:@"insert into SG2_MT values (?, ?, ?, ?, ?,?, ?, ?, ?)",
         SyohinCD,
         [NSString stringWithCString:s2 encoding:kEnc],
         [NSString stringWithCString:s3 encoding:kEnc],
         [NSString stringWithCString:s4 encoding:kEnc],
         [NSString stringWithCString:s5 encoding:kEnc],
         [NSString stringWithCString:s6 encoding:kEnc],
         [NSString stringWithCString:s7 encoding:kEnc],
         [NSString stringWithCString:s8 encoding:kEnc],
         [NSString stringWithCString:s9 encoding:kEnc]
         ];
        
         LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
         LOG(@"1:%@",[NSString stringWithCString:s2 encoding:kEnc]);
         LOG(@"2:%@",[NSString stringWithCString:s3 encoding:kEnc]);
         LOG(@"3:%@",[NSString stringWithCString:s4 encoding:kEnc]);
         LOG(@"4:%@",[NSString stringWithCString:s5 encoding:kEnc]);
         LOG(@"5:%@",[NSString stringWithCString:s6 encoding:kEnc]);
         LOG(@"6:%@",[NSString stringWithCString:s7 encoding:kEnc]);
        
        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
        free(s6);
        free(s7);
        free(s8);
        free(s9);
    }
    [self.db commit];
       
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForCondiment:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    LOG(@"count1:%d",count);
    
    //DB書き込み開始
    [self openDb];
    [self.db beginTransaction];
    for (int ct = 0; ct<count; ct++) {

        
        NSString *TopSyohinCD = [_msg substringWithRange:NSMakeRange(19+41*ct, 13)];
        //TopSyohinCD = [TopSyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(44+41*ct,13)];
        //SyohinCD = [SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        [self.db executeUpdate:@"insert into CondiGD_MT values (?, ?, ?, ?, ?, ?, ?)",
         TopSyohinCD,//TopSyohinCD
         [_msg substringWithRange:NSMakeRange(32+41*ct, 4)],//CondiGCD
         [_msg substringWithRange:NSMakeRange(36+41*ct,4)],//CondiGDID
         [_msg substringWithRange:NSMakeRange(40+41*ct, 4)],//DispOrder
         SyohinCD,//SyohinCD
         [_msg substringWithRange:NSMakeRange(57+41*ct,2)],//Multiple
         [_msg substringWithRange:NSMakeRange(59+41*ct,1)]//SG2FLG
         ];
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForCommentGD:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    LOG(@"count:%d",count);
    
    //DB書き込み開始
     [self openDb];
    [self.db beginTransaction];
    for (int ct = 0; ct<count; ct++) {        
        [self.db executeUpdate:@"insert into CommentGD_MT values (?, ?, ?, ?)",
         [_msg substringWithRange:NSMakeRange(19+16*ct,4)],
         [_msg substringWithRange:NSMakeRange(23+16*ct,4)],
         [_msg substringWithRange:NSMakeRange(27+16*ct,4)],
         [_msg substringWithRange:NSMakeRange(31+16*ct,4)]
         ];
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}
- (void)convertForComment:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 6)]intValue];
    LOG(@"count:%d",count);
    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+19+28*ct,4);
        strncpy(s2, s+23+28*ct,8);
        strncpy(s3, s+31+28*ct,8);
        strncpy(s4, s+39+28*ct,8);
        
        s1[5] = '\0';
        s2[9] = '\0';
        s3[9] = '\0';
        s4[9] = '\0';
        
        [self.db executeUpdate:@"insert into Comment_MT values (?, ?, ?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         [NSString stringWithCString:s2 encoding:kEnc],
         [NSString stringWithCString:s3 encoding:kEnc],
         [NSString stringWithCString:s4 encoding:kEnc]
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        LOG(@"3:%@",[NSString stringWithCString:s3 encoding:kEnc]);
        LOG(@"4:%@",[NSString stringWithCString:s4 encoding:kEnc]);
        
        
        free(s1);
        free(s2);
        free(s3);
        free(s4);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}
- (void)convertForOfferGD:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 2)]intValue];
    LOG(@"count:%d",count);
    
    //DB書き込み開始
     [self openDb];
    [self.db beginTransaction];
    for (int ct = 0; ct<count; ct++) {
        [self.db executeUpdate:@"insert into OfferGD_MT values (?, ?)",
         [_msg substringWithRange:NSMakeRange(15+3*ct,2)],
         [_msg substringWithRange:NSMakeRange(17+3*ct,1)]
         ];
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}
- (void)convertForOffer:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 2)]intValue];
    LOG(@"count:%d",count);
     [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        char *s3 = calloc(kCharaSize,sizeof(char));
        char *s4 = calloc(kCharaSize,sizeof(char));
        char *s5 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+15+26*ct,1);
        strncpy(s2, s+16+26*ct,1);
        strncpy(s3, s+17+26*ct,8);
        strncpy(s4, s+25+26*ct,8);
        strncpy(s5, s+33+26*ct,8);
        
        s1[2] = '\0';
        s2[2] = '\0';
        s3[9] = '\0';
        s4[9] = '\0';
        s4[9] = '\0';
        
        [self.db executeUpdate:@"insert into Offer_MT values (?, ?, ?, ?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         [NSString stringWithCString:s2 encoding:kEnc],
         [NSString stringWithCString:s3 encoding:kEnc],
         [NSString stringWithCString:s4 encoding:kEnc],
         [NSString stringWithCString:s5 encoding:kEnc]
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        LOG(@"3:%@",[NSString stringWithCString:s3 encoding:kEnc]);
        LOG(@"4:%@",[NSString stringWithCString:s4 encoding:kEnc]);
        LOG(@"5:%@",[NSString stringWithCString:s5 encoding:kEnc]);
        
        
        free(s1);
        free(s2);
        free(s3);
        free(s4);
        free(s5);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForNote:(NSString*)_msg{

    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<4; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+13+18*ct,2);
        strncpy(s2, s+15+18*ct,16);
        
        s1[3] = '\0';
        s2[17] = '\0';
        
        //2014-09-18 ueda
        //[self.db executeUpdate:@"insert into Note_MT values (?, ?)",
        [self.db executeUpdate:@"insert into Note_MT (NoteID,HTDispNM,ModifyName) values (?, ?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         [NSString stringWithCString:s2 encoding:kEnc],
         @""
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        
        free(s1);
        free(s2);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForKyakuso:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 4)]intValue];
    LOG(@"count:%d",count);
    
    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        //2015-12-10 ueda ASTERISK
        char *s3 = calloc(kCharaSize,sizeof(char));
        
        //2015-12-10 ueda ASTERISK
        strncpy(s1, s+17+34*ct,2);
        strncpy(s2, s+19+34*ct,30);
        strncpy(s3, s+49+34*ct,2);
        
        s1[3] = '\0';
        s2[31] = '\0';
        //2015-12-10 ueda ASTERISK
        s3[3] = '\0';
        
        //2015-12-10 ueda ASTERISK
        [self.db executeUpdate:@"insert into Kyakuso_MT values (?, ?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         [NSString stringWithCString:s2 encoding:kEnc],
         [NSString stringWithCString:s3 encoding:kEnc]
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        
        free(s1);
        free(s2);
        free(s3);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (void)convertForPattern:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 4)]intValue];
    LOG(@"count:%d",count);
    
    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+17+31*ct,1);
        strncpy(s2, s+18+31*ct,30);
        
        s1[1] = '\0';
        s2[30] = '\0';
        
        [self.db executeUpdate:@"insert into Pattern_MT values (?, ?)",
         [NSString stringWithCString:s1 encoding:kEnc],
         [NSString stringWithCString:s2 encoding:kEnc]
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        
        free(s1);
        free(s2);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

//2014-07-16 ueda
- (void)convertForColor:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(13, 2)]intValue];
    LOG(@"count:%d",count);
    
    [self openDb];
    [self.db beginTransaction];
    const char *s = [_msg cStringUsingEncoding:kEnc];
    for (int ct = 0; ct<count; ct++) {
        char *s1 = calloc(kCharaSize,sizeof(char));
        char *s2 = calloc(kCharaSize,sizeof(char));
        
        strncpy(s1, s+15+10*ct,2);
        strncpy(s2, s+17+10*ct,8);
        
        s1[2] = '\0';
        s2[8] = '\0';
        
        if (s1[1] == ' ') {
            //後ろのスペースをカット
            s1[1] = '\0';
        }
        
        NSString *code  = [NSString stringWithCString:s2 encoding:kEnc];
        NSString *code2 = [NSString stringWithFormat:@"%06x",[code intValue]];
        [self.db executeUpdate:@"insert into Color_MT values (?, ?)",
            [NSString stringWithCString:s1 encoding:kEnc],
            code2
         ];
        
        LOG(@"1:%@",[NSString stringWithCString:s1 encoding:kEnc]);
        LOG(@"2:%@",[NSString stringWithCString:s2 encoding:kEnc]);
        
        free(s1);
        free(s2);
    }
    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

//2015-03-24 ueda
- (void)convertForRegiMt:(NSString*)_msg{
    
    [self openDb];
    [self.db beginTransaction];
    
    const char *s = [_msg cStringUsingEncoding:kEnc];
    char *s1 = calloc(kCharaSize,sizeof(char));
    char *s2 = calloc(kCharaSize,sizeof(char));
    char *s3 = calloc(kCharaSize,sizeof(char));
    char *s4 = calloc(kCharaSize,sizeof(char));
    char *s5 = calloc(kCharaSize,sizeof(char));
    char *s6 = calloc(kCharaSize,sizeof(char));
    char *s7 = calloc(kCharaSize,sizeof(char));
    char *s8 = calloc(kCharaSize,sizeof(char));
    char *s9 = calloc(kCharaSize,sizeof(char));
    char *s10 = calloc(kCharaSize,sizeof(char));
    char *s11 = calloc(kCharaSize,sizeof(char));
    char *s12 = calloc(kCharaSize,sizeof(char));
    char *s13 = calloc(kCharaSize,sizeof(char));
    char *s14 = calloc(kCharaSize,sizeof(char));
    char *s15 = calloc(kCharaSize,sizeof(char));
    
    strncpy(s1   , s +  13 ,   1);
    strncpy(s2   , s +  14 ,   1);
    strncpy(s3   , s +  15 ,   1);
    strncpy(s4   , s +  16 ,  10);
    strncpy(s5   , s +  26 ,  10);
    strncpy(s6   , s +  36 ,   1);
    strncpy(s7   , s +  37 ,  10);
    strncpy(s8   , s +  47 ,   1);
    strncpy(s9   , s +  48 ,  13);
    strncpy(s10  , s +  61 ,  13);
    strncpy(s11  , s +  74 ,  13);
    strncpy(s12  , s +  87 ,  13);
    strncpy(s13  , s + 100 ,   1);
    strncpy(s14  , s + 101 ,  20);
    strncpy(s15  , s + 121 ,   2);

    s1[1] = '\0';
    s2[1] = '\0';
    s3[1] = '\0';
    s4[10] = '\0';
    s5[10] = '\0';
    s6[1] = '\0';
    s7[10] = '\0';
    s8[1] = '\0';
    s9[13] = '\0';
    s10[13] = '\0';
    s11[13] = '\0';
    s12[13] = '\0';
    s13[1] = '\0';
    s14[20] = '\0';
    s15[2] = '\0';
    
    [self.db executeUpdate:@"insert into Regi_MT values (?,?,?,?,?,?,?,?,?,?,?,?,?,?,?)",
     [NSString stringWithCString:s1 encoding:kEnc],
     [NSString stringWithCString:s2 encoding:kEnc],
     [NSString stringWithCString:s3 encoding:kEnc],
     [NSString stringWithCString:s4 encoding:kEnc],
     [NSString stringWithCString:s5 encoding:kEnc],
     [NSString stringWithCString:s6 encoding:kEnc],
     [NSString stringWithCString:s7 encoding:kEnc],
     [NSString stringWithCString:s8 encoding:kEnc],
     [NSString stringWithCString:s9 encoding:kEnc],
     [NSString stringWithCString:s10 encoding:kEnc],
     [NSString stringWithCString:s11 encoding:kEnc],
     [NSString stringWithCString:s12 encoding:kEnc],
     [NSString stringWithCString:s13 encoding:kEnc],
     [NSString stringWithCString:s14 encoding:kEnc],
     [NSString stringWithCString:s15 encoding:kEnc]];
    
    free(s1);
    free(s2);
    free(s3);
    free(s4);
    free(s5);
    free(s6);
    free(s7);
    free(s8);
    free(s9);
    free(s10);
    free(s11);
    free(s12);
    free(s13);
    free(s14);
    free(s15);

    [self.db commit];
    
    //check
    if ([self.db hadError]) {
        NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
    }
}

- (NSMutableDictionary*)convertForKokyakuInfo:(NSString*)_msg{
    
    //2014-04-18 ueda
    /*
    const char *s = [_msg cStringUsingEncoding:kEnc];
     
    char *s1 = calloc(kCharaSize,sizeof(char));
    char *s2 = calloc(kCharaSize,sizeof(char));
    
    strncpy(s1, s+4,30);
    strncpy(s2, s+120,10);
    
    s1[31] = '\0';
    s2[11] = '\0';
    
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithCString:s1 encoding:kEnc] forKey:@"KokyakuName"];
    [dic setObject:[NSString stringWithCString:s2 encoding:kEnc] forKey:@"KokyakuCD"];
    
    free(s1);
    free(s2);
     */
    const char *s = [_msg cStringUsingEncoding:kEnc];
    char *s1 = calloc(kCharaSize,sizeof(char));
    strncpy(s1, s+4,30);
    s1[31] = '\0';
    NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
    [dic setObject:[NSString stringWithCString:s1 encoding:kEnc] forKey:@"KokyakuName"];
    free(s1);

    return dic;
}

- (NSString*)convertForOrderRequest:(NSMutableArray*)_array
                               type:(NSString*)type{ //1=新規 2=追加　3=取消
    
    LOG(@"_array:%@",_array);
    
    NSMutableString *_msg = [[NSMutableString alloc]init];
    DataList *dat = [DataList sharedInstance];

    NSString *typeStr = type;
    NSString *countKey = nil;
    if ([type isEqualToString:@"1"]) {
        if ([dat.currentTable[@"status"]intValue]>3) {
            typeStr = @"9";
        }
        //2014-12-25 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.OrderRequestN31forceFlag) {
            typeStr = @"9";
        }
        countKey = @"count";
    }
    else if ([type isEqualToString:@"2"]) {
        countKey = @"count";
    }
    else if ([type isEqualToString:@"3"]) {
        countKey = @"countDivide";
    }
    
    //顧客入力の判定
    if ([type isEqualToString:@"1"]) {
        if ([[System sharedInstance].kakucho2Type isEqualToString:@"2"]&&dat.currentKokyakuCD) {
            [_msg appendString:@"K31"];
        }
        else{
            [_msg appendString:@"N31"];
        }
    }
    else{
        [_msg appendString:@"N31"];
    }
    
    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
    
    [_msg appendString:[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [_msg appendString:[System sharedInstance].training];
    [_msg appendString:typeStr];
    if ([type isEqualToString:@"1"]) {
        if ([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) {
            [_msg appendString:[self appendSpace:[NSString stringWithFormat:@"%d",[dat.currentKyakusoID intValue]] totalLength:4]];
        }
        else{
            [_msg appendString:@"    "];
        }
    }
    else {
        [_msg appendString:dat.currentVoucher[@"EdaNo"]];
    }

    [_msg appendString:[NSString stringWithFormat:@"%04zd",[dat.currentTable[@"TableID"] intValue]]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.manCount]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.womanCount]];
    //2015-06-17 ueda
    if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
        //担当者コード：６桁
        [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.childCount]];
    } else {
        //2014-12-12 ueda
        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //入力タイプＣ or 小人入力する
            //2014-11-17 ueda
            [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.childCount]];
        } else {
            //小人入力しない
        }
    }
    
    //顧客入力の判定
    if ([type isEqualToString:@"1"]) {
        if ([[System sharedInstance].kakucho2Type isEqualToString:@"2"]&&dat.currentKokyakuCD) {
            LOG(@"dat.currentKokyakuCD:%@",dat.currentKokyakuCD);
            NSString *kokyakuCD = [NSString stringWithFormat:@"%d",[dat.currentKokyakuCD intValue]];
            [_msg appendString:[NSString stringWithFormat:@"KOKYAKU%@",[self appendSpace:kokyakuCD totalLength:10]]];
        }
    }
    
    LOG(@"[DataList sharedInstance].currentNoteID:%@",[DataList sharedInstance].currentNoteID);
    
    //オーダータイプを追加する
    if ([[System sharedInstance].orderType isEqualToString:@"0"]||[type isEqualToString:@"3"]) {
        [_msg appendString:@"00"];
    }
    else{
        [_msg appendString:[DataList sharedInstance].currentNoteID];
    }
    
    
    
    //親商品情報
    NSArray *_menuTop = _array[0];
    
    
    //重複要素を削除する
    NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < _menuTop.count; ct++) {
        NSDictionary *menu = _menuTop[ct];
        
        if ([menu[@"JikaFLG"]intValue]==1&&[menu[@"SG1FLG"]intValue]==0) {
            [fixedArray addObject:menu];
        }
        else{
            if ([type isEqualToString:@"3"]) {
                //2015-10-28 ueda 取消の場合
                BOOL _sameFg = NO;
                for (int ct2 = 0; ct2 < fixedArray.count; ct2++) {
                    NSDictionary *checkDic = fixedArray[ct2];
                    if (([[checkDic objectForKey:@"EdaNo"] isEqualToString:[menu objectForKey:@"EdaNo"]]) &&
                        ([[checkDic objectForKey:@"SyohinCD"] isEqualToString:[menu objectForKey:@"SyohinCD"]])) {
                        _sameFg = YES;
                    }
                }
                if (_sameFg == NO) {
                    [fixedArray addObject:menu];
                }
            } else {
                NSArray *array = [fixedArray valueForKeyPath:@"SyohinCD"];
                if (![array containsObject:menu[@"SyohinCD"]]) {
                    [fixedArray addObject:menu];
                }
            }
        }
    }
    LOG(@"fixedArray:%@",fixedArray);
    
    //NSArray *fixedArray = [[[NSSet alloc] initWithArray:[_menuTop valueForKeyPath:@"SyohinCD"]] allObjects];
    
    //NSArray *array = [self isKindOfClass:[NSArray class]] ? fixedArray : [NSMutableArray arrayWithArray:fixedArray];
    //LOG(@"重複チェック:%@:%@",fixedArray,array);
    
    
    /*
    //親商品の個数を取得する、シングルトレイ対応として「02」以降は含まない
    int topCount = 0;
    for (int ct = 0; ct < [_menuTop count]; ct++) {
        NSDictionary *_dic = [_menuTop objectAtIndex:ct];
        if ([_dic[@"trayNo"]intValue]>0) {
            if ([_dic[@"trayNo"]intValue]==1) {
                topCount++;
            }
        }
        else{
            topCount++;
        }
    }
    */
    [_msg appendString:[NSString stringWithFormat:@"%03zd",fixedArray.count]];
    
    
    LOG(@"3:%zd",fixedArray.count);
    
    for (int ct = 0; ct<fixedArray.count; ct++) {
        LOG(@"msg1-1:%@",_msg);
        
        /*
        NSString *SyohinCD = fixedArray[ct];
        NSDictionary *_dic = [_menuTop objectAtIndex:[[_menuTop valueForKeyPath:@"SyohinCD"] indexOfObject:SyohinCD]];
         */
        NSDictionary *_dic = fixedArray[ct];
        
        NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"SyohinCD"]];
        
        
        
        //時価商品のtrayNoはseq番号
        if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
            if ([type isEqualToString:@"3"]) {
                //2015-10-28 ueda
                //[_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotalForCancel:_dic[@"SyohinCD"]]]];
                [_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotalForCancel:_dic[@"SyohinCD"] EdaNo:_dic[@"EdaNo"]]]];
            }
            else{
                [_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotal:_dic[@"SyohinCD"]]]];
            }
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        }
        
        
        [_msg appendString:_jika];//時価
        LOG(@"msg1-2:%@",_msg);
        
    }
    
    
    //第1階層情報
    NSArray *_menu1 = _array[1];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menu1 count]]];
    for (int ct = 0; ct<[_menu1 count]; ct++) {
        LOG(@"msg2-1:%@",_msg);
        NSDictionary *_dic = [_menu1 objectAtIndex:ct];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        [_msg appendString:_dic[@"trayNo"]];
        [_msg appendString:_dic[@"SG1ID"]];
        [_msg appendString:_dic[@"GroupType"]];
        [_msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%06d",[_dic[@"DispOrder"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%02d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue]]];
        
        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        [_msg appendString:_jika];//時価
        LOG(@"msg2-2:%@",_msg);
    }
    
    
    //[_msg appendString:@"000"];//第2階層情報
    
    //第2階層情報
    NSArray *_menu2 = _array[2];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menu2 count]]];
    for (int ct = 0; ct<[_menu2 count]; ct++) {
        LOG(@"msg3-1:%@",_msg);
        NSDictionary *_dic = [_menu2 objectAtIndex:ct];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        [_msg appendString:_dic[@"trayNo"]];
        [_msg appendString:_dic[@"CondiGCD"]];
        [_msg appendString:_dic[@"CondiGDID"]];
        [_msg appendString:_dic[@"SG2ID"]];
        [_msg appendString:_dic[@"GroupType"]];
        [_msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%010d",[_dic[@"DispOrder"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%02d%d%03d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue],[_dic[@"SG2ID"]intValue],[_dic[@"CondiGDID"]intValue]]];

        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        [_msg appendString:_jika];//時価
        LOG(@"msg2-2:%@",_msg);
    }
    
    
    //テーブル
    if ([type isEqualToString:@"1"]) {
        [_msg appendString:[NSString stringWithFormat:@"%04zd",dat.selectTable.count]];
        for (int ct = 0; ct < dat.selectTable.count; ct++) {
                    [_msg appendString:[NSString stringWithFormat:@"%04d",[dat.selectTable[ct][@"TableID"] intValue]]];
        }
    }
    else {
        [_msg appendString:@"0000"];//新規以外固定
    }
    
    
    //アレンジ1
    NSArray *_menuArrange = _array[3];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menuArrange count]]];
    for (int ct = 0; ct<[_menuArrange count]; ct++) {
        NSDictionary *_dic = [_menuArrange objectAtIndex:ct];
        //2014-12-12 ueda
        //NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        int no = [_dic[@"trayNo"]intValue];
        if (no>0) {
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"trayNo"]intValue]]];
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
        }
        [_msg appendString:_dic[@"SyohinCD"]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%010d",ct]];
        [_msg appendString:[NSString stringWithFormat:@"%04d000000",[_dic[@"PageNo"]intValue]]];
        [_msg appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 7)]];
        [_msg appendString:_jika];//時価
    }
    
    //アレンジ2
    NSArray *_menuArrange2 = _array[4];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menuArrange2 count]]];
    for (int ct = 0; ct<[_menuArrange2 count]; ct++) {
        
        NSDictionary *_dic = [_menuArrange2 objectAtIndex:ct];
        LOG(@"_dic:%@",_dic);
        
        //第１階層サブグループを取得
        //int sub1Disp = 0;
        NSDictionary *_menuSub1 = nil;
        for (int count = 0; count < [_menu1 count]; count++) {
            _menuSub1 = _menu1[count];
            if ([_menuSub1[@"SyohinCD"]isEqualToString:_dic[@"Sub1SyohinCD"]]) {
                LOG(@"arrange_menuSub1:%@",_menuSub1);
                //sub1Disp = count;
                break;
            }
        }
        
        
        NSString *_jika = [NSString stringWithFormat:@"%06d",[_menuSub1[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        //[_msg appendString:_dic[@"trayNo"]];
        int no = [_dic[@"trayNo"]intValue];
        if (no>0) {
            [_msg appendString:[NSString stringWithFormat:@"%02d",[_dic[@"trayNo"]intValue]]];
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%02d",[_dic[@"PageNo"]intValue]]];
        }
        [_msg appendString:_menuSub1[@"SG1ID"]];
        [_msg appendString:_menuSub1[@"GroupType"]];
        [_msg appendString:[self appendSpace:_menuSub1[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_menuSub1[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
        [_msg appendString:_dic[@"SyohinCD"]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%016d",ct]];
        [_msg appendString:[NSString stringWithFormat:@"1%02d1%03d%03d00000",[_menuSub1[@"trayNo"]intValue],[_menuSub1[@"CD"]intValue],ct+1]];
        [_msg appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 8)]];
        [_msg appendString:_jika];//時価
    }
    
    
    //親商品のトレイ数を取得する
    int trayCount = 0;
    for (int ct = 0; ct < [_menuTop count]; ct++) {
        NSDictionary *_dic = [_menuTop objectAtIndex:ct];
        if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
            trayCount++;
        }
    }
    
    if (trayCount>0) {
        [_msg appendString:[NSString stringWithFormat:@"%03d",trayCount]];
        LOG(@"3:%zd",[_menuTop count]);
        
        for (int ct = 0; ct<[_menuTop count]; ct++) {
            NSDictionary *_dic = [_menuTop objectAtIndex:ct];
            
            if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
                
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
                
                //2014-08-19 ueda
                //[_msg appendString:[NSString stringWithFormat:@"00"]];
                [_msg appendString:_dic[@"EdaNo"]];
                [_msg appendString:_dic[@"SyohinCD"]];
                [_msg appendString:_jika];//時価
                [_msg appendString:_dic[@"trayNo"]];
            }
        }
    }
    else{
        [_msg appendString:@"000"];
    }
    
    //任意のメッセージ入力
    if ([dat.currentNoteID isEqualToString:@"99"]&&dat.orderMessage.length>0) {
        
    
        NSString *str2 = [dat.orderMessage stringByAddingPercentEscapesUsingEncoding:NSShiftJISStringEncoding];
        str2= [str2 stringByReplacingOccurrencesOfString:@"%" withString:@""];
        //[_msg appendString:str2];
        
        
        
        /*
        int ascii = [dat.orderMessage characterAtIndex:0];
        NSString *strAscii = [NSString stringWithFormat:@"%c",ascii];
        [_msg appendString:strAscii];
        */
        

        //NSData *data1 = [dat.orderMessage dataUsingEncoding:NSASCIIStringEncoding];
        //NSString *str = [[NSString alloc] initWithData:data1 encoding:NSShiftJISStringEncoding];
        
        
        //const char *ptr = [dat.orderMessage cStringUsingEncoding:NSASCIIStringEncoding];
        //NSString *str3 = [NSString stringWithFormat:@"%c",ptr];
        
        NSString *str3 = [self encodeString:dat.orderMessage];
        [_msg appendString:str3];
        LOG(@"dat.orderMessage:%@",dat.orderMessage);
        LOG(@"strAscii:%@",str2);
        //LOG(@"strAscii:%@",str);
        LOG(@"strAscii:%@",str3);
    }

    return _msg;
}


//2014-09-11 ueda
- (NSString*)convertForOrderRequestTypeC_Header:(NSString*)type{ //1=新規 2=追加　3=取消
    NSMutableString *_msg = [[NSMutableString alloc]init];
    DataList *dat = [DataList sharedInstance];
    
    NSString *typeStr = type;
    if ([type isEqualToString:@"1"]) {
        if ([dat.currentTable[@"status"]intValue]>3) {
            typeStr = @"9";
        }
        //2014-12-25 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.OrderRequestN31forceFlag) {
            typeStr = @"9";
        }
    }
    [_msg appendString:@"X31"];
    [_msg appendString:[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [_msg appendString:[System sharedInstance].training];
    [_msg appendString:typeStr];
    if ([type isEqualToString:@"1"]) {
        if ([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) {
            [_msg appendString:[self appendSpace:[NSString stringWithFormat:@"%d",[dat.currentKyakusoID intValue]] totalLength:4]];
        }
        else{
            [_msg appendString:@"    "];
        }
    }
    else {
        [_msg appendString:dat.currentVoucher[@"EdaNo"]];
    }
    
    [_msg appendString:[NSString stringWithFormat:@"%04zd",[dat.currentTable[@"TableID"] intValue]]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.manCount]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.womanCount]];
    //2014-10-23 ueda
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.childCount]];

    //テーブル
    if ([type isEqualToString:@"1"]) {
        [_msg appendString:[NSString stringWithFormat:@"%04zd",dat.selectTable.count]];
        for (int ct = 0; ct < dat.selectTable.count; ct++) {
            [_msg appendString:[NSString stringWithFormat:@"%04d",[dat.selectTable[ct][@"TableID"] intValue]]];
        }
    }
    else {
        [_msg appendString:@"0000"];//新規以外固定
    }

    return _msg;
}

//2014-09-11 ueda
- (NSString*)convertForOrderRequestTypeC_Detail:(NSMutableArray*)_array
                                           type:(NSString*)type{ //1=新規 2=追加　3=取消
    NSMutableString *_msg = [[NSMutableString alloc]init];
    //DataList *dat = [DataList sharedInstance];
    
    NSString *countKey = nil;
    if ([type isEqualToString:@"1"]) {
        countKey = @"count";
    }
    else if ([type isEqualToString:@"2"]) {
        countKey = @"count";
    }
    else if ([type isEqualToString:@"3"]) {
        countKey = @"countDivide";
    }

    //親商品情報
    NSArray *_menuTop = _array[0];
    
    //重複要素を削除する
    NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < _menuTop.count; ct++) {
        NSDictionary *menu = _menuTop[ct];
        
        if ([menu[@"JikaFLG"]intValue]==1&&[menu[@"SG1FLG"]intValue]==0) {
            [fixedArray addObject:menu];
        }
        else{
            NSArray *array = [fixedArray valueForKeyPath:@"SyohinCD"];
            if (![array containsObject:menu[@"SyohinCD"]]) {
                [fixedArray addObject:menu];
            }
        }
    }
    LOG(@"fixedArray:%@",fixedArray);
    
    //席番・オーダー種類
    [_msg appendString:fixedArray[0][@"SeatNumber"]];
    [_msg appendString:fixedArray[0][@"OrderType"]];
    //2014-09-18 ueda
    NSMutableString *tmpText;
    tmpText = [[NSMutableString alloc]init];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *rsNote = [_net.db executeQuery:@"SELECT * FROM Note_MT WHERE NoteID = ?",fixedArray[0][@"OrderType"]];
    if ([rsNote next]) {
        if ([[rsNote stringForColumn:@"ModifyName"] isEqualToString:@""]) {
        } else {
            [tmpText appendString:[rsNote stringForColumn:@"ModifyName"]];
        }
    }
    [rsNote close];
    [_net closeDb];
    [_msg appendString:[System getByteText:(NSString*)tmpText length:60]];

    [_msg appendString:[NSString stringWithFormat:@"%03zd",fixedArray.count]];
    
    LOG(@"3:%zd",fixedArray.count);
    
    for (int ct = 0; ct<fixedArray.count; ct++) {
        LOG(@"msg1-1:%@",_msg);
        
        /*
         NSString *SyohinCD = fixedArray[ct];
         NSDictionary *_dic = [_menuTop objectAtIndex:[[_menuTop valueForKeyPath:@"SyohinCD"] indexOfObject:SyohinCD]];
         */
        NSDictionary *_dic = fixedArray[ct];
        
        NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"SyohinCD"]];
        
        
        
        //時価商品のtrayNoはseq番号
        if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
            if ([type isEqualToString:@"3"]) {
                //2015-10-28 ueda
                //[_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotalForCancel:_dic[@"SyohinCD"]]]];
                [_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotalForCancel:_dic[@"SyohinCD"] EdaNo:_dic[@"EdaNo"]]]];
            }
            else{
                //2016-02-02 ueda
                //[_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotal:_dic[@"SyohinCD"]]]];
                [_msg appendString:[NSString stringWithFormat:@"%03zd",[[OrderManager sharedInstance] getTrayTotalTypeC:_dic[@"SyohinCD"] SeatNumber:_dic[@"SeatNumber"] OrderType:_dic[@"OrderType"]]]];
            }
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        }
        
        
        [_msg appendString:_jika];//時価
        LOG(@"msg1-2:%@",_msg);
        
    }
    
    
    //第1階層情報
    NSArray *_menu1 = _array[1];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menu1 count]]];
    for (int ct = 0; ct<[_menu1 count]; ct++) {
        LOG(@"msg2-1:%@",_msg);
        NSDictionary *_dic = [_menu1 objectAtIndex:ct];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        [_msg appendString:_dic[@"trayNo"]];
        [_msg appendString:_dic[@"SG1ID"]];
        [_msg appendString:_dic[@"GroupType"]];
        [_msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%06d",[_dic[@"DispOrder"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%02d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue]]];
        
        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        [_msg appendString:_jika];//時価
        LOG(@"msg2-2:%@",_msg);
    }
    
    
    //[_msg appendString:@"000"];//第2階層情報
    
    //第2階層情報
    NSArray *_menu2 = _array[2];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menu2 count]]];
    for (int ct = 0; ct<[_menu2 count]; ct++) {
        LOG(@"msg3-1:%@",_msg);
        NSDictionary *_dic = [_menu2 objectAtIndex:ct];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        [_msg appendString:_dic[@"trayNo"]];
        [_msg appendString:_dic[@"CondiGCD"]];
        [_msg appendString:_dic[@"CondiGDID"]];
        [_msg appendString:_dic[@"SG2ID"]];
        [_msg appendString:_dic[@"GroupType"]];
        [_msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[countKey]intValue]]];
        //[_msg appendString:[NSString stringWithFormat:@"%010d",[_dic[@"DispOrder"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%02d%d%03d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue],[_dic[@"SG2ID"]intValue],[_dic[@"CondiGDID"]intValue]]];
        
        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        [_msg appendString:_jika];//時価
        LOG(@"msg2-2:%@",_msg);
    }
    
    //アレンジ1
    NSArray *_menuArrange = _array[3];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menuArrange count]]];
    for (int ct = 0; ct<[_menuArrange count]; ct++) {
        NSDictionary *_dic = [_menuArrange objectAtIndex:ct];
        //2014-12-12 ueda
        //NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
        NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
        NSString *_jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        int no = [_dic[@"trayNo"]intValue];
        if (no>0) {
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"trayNo"]intValue]]];
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
        }
        if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
            [_msg appendString:@"9999999999999"];
            [_msg appendString:_dic[@"HTDispNMU"]];
            [_msg appendString:_dic[@"HTDispNMM"]];
            [_msg appendString:_dic[@"HTDispNML"]];
            [_msg appendString:@"      "];
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
            [_msg appendString:[NSString stringWithFormat:@"%04d000000",[_dic[@"PageNo"]intValue]]];
            [_msg appendString:@"9999999"];
            [_msg appendString:_jika];//時価
        } else {
            [_msg appendString:_dic[@"SyohinCD"]];
            [_msg appendString:@"                              "];
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
            [_msg appendString:[NSString stringWithFormat:@"%04d000000",[_dic[@"PageNo"]intValue]]];
            [_msg appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 7)]];
            [_msg appendString:_jika];//時価
        }
    }
    
    //アレンジ2
    NSArray *_menuArrange2 = _array[4];
    [_msg appendString:[NSString stringWithFormat:@"%03zd",[_menuArrange2 count]]];
    for (int ct = 0; ct<[_menuArrange2 count]; ct++) {
        
        NSDictionary *_dic = [_menuArrange2 objectAtIndex:ct];
        LOG(@"_dic:%@",_dic);
        
        //第１階層サブグループを取得
        //int sub1Disp = 0;
        NSDictionary *_menuSub1 = nil;
        for (int count = 0; count < [_menu1 count]; count++) {
            _menuSub1 = _menu1[count];
            if ([_menuSub1[@"SyohinCD"]isEqualToString:_dic[@"Sub1SyohinCD"]]) {
                LOG(@"arrange_menuSub1:%@",_menuSub1);
                //sub1Disp = count;
                break;
            }
        }
        
        
        NSString *_jika = [NSString stringWithFormat:@"%06d",[_menuSub1[@"Jika"]intValue]];
        //2014-08-19 ueda
        //[_msg appendString:[NSString stringWithFormat:@"00"]];
        [_msg appendString:_dic[@"EdaNo"]];
        [_msg appendString:_dic[@"TopSyohinCD"]];
        //[_msg appendString:_dic[@"trayNo"]];
        int no = [_dic[@"trayNo"]intValue];
        if (no>0) {
            [_msg appendString:[NSString stringWithFormat:@"%02d",[_dic[@"trayNo"]intValue]]];
        }
        else{
            [_msg appendString:[NSString stringWithFormat:@"%02d",[_dic[@"PageNo"]intValue]]];
        }
        [_msg appendString:_menuSub1[@"SG1ID"]];
        [_msg appendString:_menuSub1[@"GroupType"]];
        [_msg appendString:[self appendSpace:_menuSub1[@"GCD"] totalLength:4]];
        [_msg appendString:[NSString stringWithFormat:@"%04d",[_menuSub1[@"CD"]intValue]]];
        [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
        if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
            [_msg appendString:@"9999999999999"];
            [_msg appendString:_dic[@"HTDispNMU"]];
            [_msg appendString:_dic[@"HTDispNMM"]];
            [_msg appendString:_dic[@"HTDispNML"]];
            [_msg appendString:@"      "];
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
            [_msg appendString:[NSString stringWithFormat:@"1%02d1%03d%03d00000",[_menuSub1[@"trayNo"]intValue],[_menuSub1[@"CD"]intValue],ct+1]];
            [_msg appendString:@"99999999"];
            [_msg appendString:_jika];//時価
        } else {
            [_msg appendString:_dic[@"SyohinCD"]];
            [_msg appendString:@"                              "];
            [_msg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"count"]intValue]]];
            [_msg appendString:[NSString stringWithFormat:@"1%02d1%03d%03d00000",[_menuSub1[@"trayNo"]intValue],[_menuSub1[@"CD"]intValue],ct+1]];
            [_msg appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 8)]];
            [_msg appendString:_jika];//時価
        }
    }
    
    
    //親商品のトレイ数を取得する
    int trayCount = 0;
    for (int ct = 0; ct < [_menuTop count]; ct++) {
        NSDictionary *_dic = [_menuTop objectAtIndex:ct];
        if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
            trayCount++;
        }
    }
    
    if (trayCount>0) {
        [_msg appendString:[NSString stringWithFormat:@"%03d",trayCount]];
        LOG(@"3:%zd",[_menuTop count]);
        
        for (int ct = 0; ct<[_menuTop count]; ct++) {
            NSDictionary *_dic = [_menuTop objectAtIndex:ct];
            
            if ([_dic[@"SG1FLG"]intValue]==1&&[_dic[@"trayNo"]intValue]>0) {
                
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
                
                //2014-08-19 ueda
                //[_msg appendString:[NSString stringWithFormat:@"00"]];
                [_msg appendString:_dic[@"EdaNo"]];
                [_msg appendString:_dic[@"SyohinCD"]];
                [_msg appendString:_jika];//時価
                [_msg appendString:_dic[@"trayNo"]];
            }
        }
    }
    else{
        [_msg appendString:@"000"];
    }
    
    return _msg;
}

- (NSMutableString*)encodeString:(NSString*)field {
    NSMutableString *digitString = [[NSMutableString alloc]init];
    for (int i = 0; i < [field length]; i++) {
        
        NSString *text = [field substringWithRange:NSMakeRange(i, 1)];
        if ([text canBeConvertedToEncoding:NSASCIIStringEncoding]) {
            
            int c = [text characterAtIndex:0];
            NSLog(@"char %d = %X", i, c);
            [digitString appendFormat:@"%X  ",c];
        }
        else{
            NSString *str2 = [text stringByAddingPercentEscapesUsingEncoding:NSShiftJISStringEncoding];
            str2= [str2 stringByReplacingOccurrencesOfString:@"%" withString:@""];
            [digitString appendFormat:@"%@", str2];
        }
    }

    return digitString;
}

- (int)stringToHex:(NSString *)x{
    unsigned int intHex;
    
    NSScanner *scanner = [NSScanner scannerWithString:x];
    [scanner scanHexInt:&intHex];
    
    return intHex;
}

- (NSString*)convertForOrderDirection:(NSArray*)_array{
    LOG(@"_array:%@",_array);
    
    NSMutableString *_msg = [[NSMutableString alloc]init];
    DataList *dat = [DataList sharedInstance];
    
    
    //RCV 00,30,0056=00301306130507459101A0101C312 00007000100002300030
    //RCV 00,30,0052=00301306130511049101A0101C312 0001900002300030
    
    [_msg appendString:@"C31"];
    
    [_msg appendString:[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [_msg appendString:[System sharedInstance].training];
    [_msg appendString:dat.currentVoucher[@"EdaNo"]];
    [_msg appendString:[NSString stringWithFormat:@"%04zd",[_array count]]];

    
    for (int ct = 0; ct<[_array count]; ct++) {
        NSDictionary *_dic = [_array objectAtIndex:ct];
        [_msg appendString:_dic[@"edaNo"]];
        [_msg appendString:_dic[@"trayNo"]];
        //[_msg appendString:_dic[@"trayNo"]];
        [_msg appendString:[self appendSpace:_dic[@"SyohinCD"] totalLength:13]];
    }
        return _msg;
}

- (NSString*)convertDataKeppin:(NSString*)_msg{
    OrderManager *orderManager = [OrderManager sharedInstance];
    LOG(@"MSG:%@",_msg);
    //Menu
    int menuCount = [[_msg substringWithRange:NSMakeRange(4, 1)]intValue];
    LOG(@"count1:%d",menuCount);
    
    [DataList sharedInstance].keppinList = [[NSMutableArray alloc]init];
    
    NSMutableString *str = [[NSMutableString alloc]init];
    for (int ct = 0; ct<menuCount; ct++) {
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(5+16*ct, 13)];
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
        
        NSString *HTDispNMU = [_menu[@"HTDispNMU"] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *HTDispNMM = [_menu[@"HTDispNMM"] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *HTDispNML = [_menu[@"HTDispNML"] stringByTrimmingCharactersInSet:
                               [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        [str appendString:[NSString stringWithFormat:@"%@%@%@\n",HTDispNMU,HTDispNMM,HTDispNML]];
        
        NSString *count = [NSString stringWithFormat:@"                   [ %@   %d ]\n",[String Stock],[[_msg substringWithRange:NSMakeRange(18+16*ct, 3)]intValue]];
        [str appendString:count];
        
        LOG(@"keppin:%@:%@",SyohinCD,count);
        
        [[DataList sharedInstance].keppinList addObject:SyohinCD];
    }
    
    [str appendString:[String Out_of_stock_change]];
    
    return str;
}

- (NSArray*)convertDataForTable:(NSString*)_msg{
    
    int shohinStart = 8;
    
    //テーブル状況
    DataList *_data = [DataList sharedInstance];
    [self openDb];
    
    //デモモード判定
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        if ([_msg length]>13) {
            
            //DB書き込み開始
            int statusCount = [[_msg substringWithRange:NSMakeRange(4, 4)]intValue];
            for (int ct = 0; ct < statusCount; ct++) {
                
                NSString *_str =  @"update Table_MT set status = ? where TableID = ?";
                [self.db executeUpdate:_str,
                 [_msg substringWithRange:NSMakeRange(12+6*ct, 2)],
                 [_msg substringWithRange:NSMakeRange(8+6*ct, 4)]
                 ];
                
                
                shohinStart = 12+6*ct + 2;
            }
            
            //check
            if ([self.db hadError]) {
                NSLog(@"Err %d: %@", [_db lastErrorCode], [_db lastErrorMessage]);
            }
            

            //注文パターンAのときには欠品(品切れ)情報を取得する
            //if ([sys.entryType isEqualToString:@"0"]){
                
                if ([_msg length]>shohinStart+3) {
                    [_data.syohinStatusList removeAllObjects];
                    int shohinCount = [[_msg substringWithRange:NSMakeRange(shohinStart, 3)]intValue];
                    for (int ct = 0; ct < shohinCount; ct++) {
                        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
                        NSString *_shohinCD = [_msg substringWithRange:NSMakeRange(shohinStart+3+16*ct, 13)];
                        NSString *_shohinCount = [_msg substringWithRange:NSMakeRange(shohinStart+3+13+16*ct, 3)];
                        [_dic setValue:_shohinCD forKey:@"SyohinCD"];
                        [_dic setValue:_shohinCount  forKey:@"count"];
                        [_data.syohinStatusList addObject:_dic];
                    }
                }
            //}
        }
    }
    
    LOG(@"%@",_data.syohinStatusList);

    
    //ﾃｰﾌﾞﾙ情報の書き出し
    FMResultSet *results = [self.db executeQuery:@"SELECT * FROM Table_MT"];
    NSMutableArray *_tableArray = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [_tableArray addObject:_dic];
    }
    [results close];
    [self closeDb];

    NSArray *_dataArray = [[NSArray alloc]initWithObjects:_tableArray,_data.syohinStatusList, nil];
    return _dataArray;
}

- (NSMutableArray*)convertTableMenu:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(4, 3)]intValue];
    LOG(@"count:%d",count);
    
    NSMutableArray *_resultArray = [[NSMutableArray alloc]init];
    
    OrderManager *orderManager = [OrderManager sharedInstance];
    for (int ct = 0; ct<count; ct++) {
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(7+16*ct,13)];
        NSString *count = [_msg substringWithRange:NSMakeRange(20+16*ct,3)];
        NSMutableDictionary *_menu = [orderManager getMenu:SyohinCD];
        NSString *title = [NSString stringWithFormat:@"%@%@%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
        [_resultArray addObject:@{@"HTDispNM": title,@"count": count}];
    }
    
    LOG(@"%@",_resultArray);
    return _resultArray;
}

- (NSDictionary*)convertForTableReserve:(NSString*)_msg{
    
    char *s1 = calloc(kCharaSize,sizeof(char));
    char *s2 = calloc(kCharaSize,sizeof(char));
    char *s3 = calloc(kCharaSize,sizeof(char));
    char *s4 = calloc(kCharaSize,sizeof(char));
    
    const char *s = [_msg cStringUsingEncoding:kEnc];
    strncpy(s1, s+4,2);
    strncpy(s2, s+6,2);
    strncpy(s3, s+8,20);
    strncpy(s4, s+28,2);
    
    s1[3] = '\0';
    s2[3] = '\0';
    s3[21] = '\0';
    s4[3] = '\0';
    
    NSDictionary *dic = @{@"time1":[NSString stringWithCString:s1 encoding:kEnc],
                          @"time2":[NSString stringWithCString:s2 encoding:kEnc],
                          @"name":[NSString stringWithCString:s3 encoding:kEnc],
                          @"count":[NSString stringWithCString:s4 encoding:kEnc]};
    
    free(s1);
    free(s2);
    free(s3);
    free(s4);
    
    return dic;
}

- (NSArray*)convertVoucherList:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(5, 2)]intValue];
    LOG(@"count1:%d",count);
    
    //配列作成
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    NSInteger packetOffset;
    //2015-06-17 ueda
    if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
        //担当者コード：６桁
        packetOffset = 0;
    } else {
        //2014-12-12 ueda
        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //入力タイプＣ or 小人入力する
            packetOffset = 0;
        } else {
            //小人入力しない
            packetOffset = (-2);
        }
    }
    
    for (int ct = 0; ct<count; ct++) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        _dic[@"EdaNo"] =      [_msg substringWithRange:NSMakeRange( 7 + ((10 + packetOffset) * ct), 4)];
        _dic[@"manCount"] =   [_msg substringWithRange:NSMakeRange(11 + ((10 + packetOffset) * ct), 2)];
        _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(13 + ((10 + packetOffset) * ct), 2)];
        //2015-06-17 ueda
        if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
            //担当者コード：６桁
            _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(15 + ((10 + packetOffset) * ct), 2)];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                //2014-11-17 ueda
                _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(15 + ((10 + packetOffset) * ct), 2)];
            } else {
                //小人入力しない
                _dic[@"childCount"] = @"00";
            }
        }
        
        _dic[@"disp"] = [NSNumber numberWithInt:[_dic[@"EdaNo"]intValue]];
        [_array addObject:_dic];
    }
    
    /*
    NSSortDescriptor *sortDisp = [[NSSortDescriptor alloc] initWithKey:@"disp" ascending:NO] ;
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortDisp, nil];
    NSArray *_listResult = [[NSArray alloc]initWithArray:[_array sortedArrayUsingDescriptors:sortDescArray]];
    */
    return _array;
}

//2014-10-23 ueda
- (NSArray*)convertVoucherListTypeC:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(5, 2)]intValue];
    //配列作成
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    for (int ct = 0; ct<count; ct++) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        _dic[@"EdaNo"]      = [_msg substringWithRange:NSMakeRange( 7 + 10 * ct, 4)];
        _dic[@"manCount"]   = [_msg substringWithRange:NSMakeRange(11 + 10 * ct, 2)];
        _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(13 + 10 * ct, 2)];
        _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(15 + 10 * ct, 2)];
        _dic[@"disp"] = [NSNumber numberWithInt:[_dic[@"EdaNo"]intValue]];
        [_array addObject:_dic];
    }
    return _array;
}

//2014-12-12 ueda
//未使用のためコメントアウト
/*
- (NSArray*)convertVoucherNo1:(NSString*)_msg{

    //配列作成
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5, 4)];
    _dic[@"manCount"] = [_msg substringWithRange:NSMakeRange(13, 2)];
    _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(15, 2)];
    //2014-11-17 ueda
    _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(17, 2)];
    [_array addObject:_dic];
    
    
    DataList *dat = [DataList sharedInstance];
    dat.currentVoucher = _dic;
    dat.manCount = [_dic[@"manCount"]intValue];
    dat.womanCount = [_dic[@"womanCount"]intValue];
    //2014-11-17 ueda
    dat.childCount = [_dic[@"childCount"]intValue];
    
    LOG(@"%@",_dic);
    
    return _array;
}

- (NSArray*)convertVoucherNo2:(NSString*)_msg{
    
    //配列作成
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(5, 4)];
    _dic[@"manCount"] = [_msg substringWithRange:NSMakeRange(12, 2)];
    _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(14, 2)];
    //2014-11-17 ueda
    _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(16, 2)];
    [_array addObject:_dic];
    
    
    DataList *dat = [DataList sharedInstance];
    dat.currentVoucher = _dic;
    dat.manCount = [_dic[@"manCount"]intValue];
    dat.womanCount = [_dic[@"womanCount"]intValue];
    //2014-11-17 ueda
    dat.childCount = [_dic[@"childCount"]intValue];
    
    LOG(@"%@",_dic);
    
    return _array;
}
 */

- (NSArray*)convertVoucherListDirection:(NSString*)_msg{
    int count = [[_msg substringWithRange:NSMakeRange(4, 4)]intValue];
    LOG(@"count1:%d",count);
    
    //DB書き込み開始
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    for (int ct = 0; ct<count; ct++) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(8+4*ct, 4)];
        [_array addObject:_dic];
    }
    
    return [NSArray arrayWithArray:_array];
}

- (NSArray*)convertVoucherDirection:(NSString*)_msg{
    
    OrderManager *orderManager = [OrderManager sharedInstance];

    //Menu
    int menuCount = [[_msg substringWithRange:NSMakeRange(4, 4)]intValue];
    LOG(@"count1:%d",menuCount);
    
    NSMutableArray *array = [[NSMutableArray alloc]init];
    
    int DirectionNo = 0;
    for (int ct = 0; ct<menuCount; ct++) {
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(15+22*ct, 13)];
        NSString *type = [_msg substringWithRange:NSMakeRange(12+22*ct, 1)];
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
        
        if ([type intValue]==1) {
            DirectionNo = 0;
        }
        else{
            //DirectionNo ++;
            NSString *_no = [_msg substringWithRange:NSMakeRange(13+22*ct, 2)];
            _menu[@"DirectionNo"] = [NSString stringWithFormat:@"%d",[_no intValue]];
        }
        _menu[@"edaNo"] = [_msg substringWithRange:NSMakeRange(8+22*ct, 2)];
        _menu[@"trayNo"] = [_msg substringWithRange:NSMakeRange(10+22*ct, 2)];
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[[_msg substringWithRange:NSMakeRange(28+22*ct, 2)]intValue]];
        [array addObject:_menu];
    }
    return [NSArray arrayWithArray:array];
}

- (void)convertVoucherDetail:(NSString*)_msg{

    OrderManager *orderManager = [OrderManager sharedInstance];
    DataList *dat = [DataList sharedInstance];
    dat.manCount = [[_msg substringWithRange:NSMakeRange(8, 2)]intValue];
    dat.womanCount = [[_msg substringWithRange:NSMakeRange(10, 2)]intValue];
    //2015-06-17 ueda
    NSInteger packetOffset;
    if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
        //担当者コード：６桁
        dat.childCount = [[_msg substringWithRange:NSMakeRange(12, 2)]intValue];
        packetOffset = 0;
    } else {
        //2014-12-12 ueda
        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //入力タイプＣ or 小人入力する
            //2014-11-17 ueda
            dat.childCount = [[_msg substringWithRange:NSMakeRange(12, 2)]intValue];
            packetOffset = 0;
        } else {
            //小人入力しない
            dat.childCount = 0;
            packetOffset = (-2);
        }
    }
    
    if (![[_msg substringWithRange:NSMakeRange(0, 3)]isEqualToString:@"N32"]) {
        //配列作成
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        _dic[@"EdaNo"] = [_msg substringWithRange:NSMakeRange(0, 4)];
        _dic[@"manCount"] = [_msg substringWithRange:NSMakeRange(8, 2)];
        _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(10, 2)];
        //2015-06-17 ueda
        if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
            //担当者コード：６桁
            _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(12, 2)];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                //2014-11-17 ueda
                _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(12, 2)];
            } else {
                //小人入力しない
                _dic[@"childCount"] = @"00";
            }
        }

        dat.currentVoucher = _dic;
        
        LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
    }

    
    //Menu
    int menuCount = [[_msg substringWithRange:NSMakeRange(14 + packetOffset, 3)]intValue];
    LOG(@"count1:%d",menuCount);
    for (int ct = 0; ct<menuCount; ct++) {
        //2014-08-19 ueda
        NSString *EdaNo =    [_msg substringWithRange:NSMakeRange(17 + packetOffset + (30 * ct), 2)];
        NSString *SyohinCD = [_msg substringWithRange:NSMakeRange(19 + packetOffset + (30 * ct), 13)];
        //GetMenu
        LOG(@"SyohinCD:%@",SyohinCD);
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
        //2016-03-29 ueda
/*
        _menu[@"count"] =    [_msg substringWithRange:NSMakeRange(33 + packetOffset + (30 * ct), 2)];
 */
        //2016-03-29 ueda
        _menu[@"count"] =    [_msg substringWithRange:NSMakeRange(32 + packetOffset + (30 * ct), 3)];
        _menu[@"Jika"] =     [_msg substringWithRange:NSMakeRange(35 + packetOffset + (30 * ct), 6)];
        NSString *seq =      [_msg substringWithRange:NSMakeRange(41 + packetOffset + (30 * ct), 3)];
        _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
        //2014-08-19 ueda
        _menu[@"EdaNo"] = EdaNo;
        //AddMenuTop
        if ([_menu[@"TrayStyle"]isEqualToString:@"0"]) {//トレイ商品の場合は個数ごとに登録
            if ([[_menu allKeys]containsObject:@"PatternCD"]) {
                //時価商品別の場合
                //2015-10-26 ueda
/*
                if ([_menu[@"JikaFLG"]isEqualToString:@"1"]&&[seq intValue]>0) {
                    _menu[@"trayNo"] = seq;
                }
 */
                //2015-10-26 ueda
                if ([_menu[@"TrayStyle"]isEqualToString:@"1"]&&[seq intValue]>0) {
                    _menu[@"trayNo"] = seq;
                }
                [orderManager addTopMenu:_menu];
            }
        }
    }

    
    //sub1Count
    NSInteger init1 = 17 + packetOffset + (30 * menuCount);
    int sub1Count = [[_msg substringWithRange:NSMakeRange(init1, 3)]intValue];
    LOG(@"sub1Count:%d",sub1Count);
    for (int ct = 0; ct<sub1Count; ct++) {
        //2014-08-18 ueda
        NSString *EdaNo =       [_msg substringWithRange:NSMakeRange(3+init1+60*ct, 2)];
        NSString *TopSyohinCD = [_msg substringWithRange:NSMakeRange(5+init1+60*ct, 13)];
        NSString *trayNo =      [_msg substringWithRange:NSMakeRange(18+init1+60*ct, 2)];
        NSString *GroupType =   [_msg substringWithRange:NSMakeRange(21+init1+60*ct, 1)];
        NSString *GroupCD =     [_msg substringWithRange:NSMakeRange(22+init1+60*ct, 4)];
        NSString *CondiGDID =   [_msg substringWithRange:NSMakeRange(26+init1+60*ct, 4)];
        
        LOG(@"取得情報sub1:%@:%@:%@:%@",TopSyohinCD,GroupCD,CondiGDID,trayNo);
        //GetSub1
        NSMutableDictionary *_sub1 = [orderManager getSubMenu:TopSyohinCD
                                                    GroupType:GroupType
                                                      GroupCD:GroupCD
                                                    CondiGDID:CondiGDID
                                                           SG:1];
        
        //[DataList sharedInstance].TrayNo = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        _sub1[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        //2014-08-18 ueda
        _sub1[@"EdaNo"] = EdaNo;
        
        if ([[_sub1 allKeys]containsObject:@"SyohinCD"]) {
            _sub1[@"Sub1SyohinCD"] = _sub1[@"SyohinCD"];
        }
        else{
            _sub1[@"Sub1SyohinCD"] = @"";
        }
        
        LOG(@"取得情報sub:%@",_sub1);
        _sub1[@"count"] = [_msg substringWithRange:NSMakeRange(30+init1+60*ct, 3)];
        _sub1[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
        [orderManager addSubMenu:_sub1
                              SG:1];
    }
    
    
    //sub2Count
    NSInteger init2 = 3 + init1 + 60*sub1Count;
    int sub2Count = [[_msg substringWithRange:NSMakeRange(init2, 3)]intValue];
    LOG(@"sub2Count:%d",sub2Count);
    for (int ct = 0; ct<sub2Count; ct++) {
        //2014-08-19 ueda
        NSString *EdaNo =       [_msg substringWithRange:NSMakeRange(3+init2+70*ct, 2)];
        NSString *TopSyohinCD = [_msg substringWithRange:NSMakeRange(5+init2+70*ct, 13)];
        NSString *trayNo =      [_msg substringWithRange:NSMakeRange(18+init2+70*ct, 2)];
        NSString *GroupCD1 =    [_msg substringWithRange:NSMakeRange(20+init2+70*ct, 4)];
        NSString *CondiGDID1 =  [_msg substringWithRange:NSMakeRange(24+init2+70*ct, 4)];

        NSString *GroupType =   [_msg substringWithRange:NSMakeRange(29+init2+70*ct, 1)];
        NSString *GroupCD2 =    [_msg substringWithRange:NSMakeRange(30+init2+70*ct, 4)];
        NSString *CondiGDID2 =  [_msg substringWithRange:NSMakeRange(34+init2+70*ct, 4)];
        
        LOG(@"取得情報sub2:%@:%@:%@:%@",TopSyohinCD,GroupCD2,CondiGDID2,trayNo);
        //GetSub2
        NSMutableDictionary *_sub2 = [orderManager getSubMenu:TopSyohinCD
                                                    GroupType:GroupType
                                                      GroupCD:GroupCD2
                                                    CondiGDID:CondiGDID2
                                                           SG:2];
        
        //[DataList sharedInstance].TrayNo = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        _sub2[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        //2014-08-19 ueda
        _sub2[@"EdaNo"] = EdaNo;
        
        _sub2[@"count"] = [_msg substringWithRange:NSMakeRange(38+init2+70*ct, 3)];
        _sub2[@"CondiGCD"] = GroupCD1;
        _sub2[@"CondiGDID"] = CondiGDID1;
        
        _sub2[@"Sub1SyohinCD"] = [self sub1SyohinCD:TopSyohinCD
                                           GroupCD1:GroupCD1
                                         CondiGDID1:CondiGDID1];
        [orderManager addSubMenu:_sub2
                              SG:2];
    }
    
    //arrange1Count
    NSInteger init3 = 3 + init2 + 70*sub2Count;
    int arrange1Count = [[_msg substringWithRange:NSMakeRange(init3, 3)]intValue];
    LOG(@"arrange1Count:%@",[_msg substringWithRange:NSMakeRange(init3, 3)]);
    //2015-01-08 ueda
    NSMutableString *preTopSyohinCD = [[NSMutableString alloc]initWithString:@"ZZ"];
    NSMutableString *preJikaSeq     = [[NSMutableString alloc]initWithString:@"ZZ"];
    NSMutableString *preEdaNo       = [[NSMutableString alloc]initWithString:@"ZZ"];
    NSMutableString *preArNo        = [[NSMutableString alloc]initWithString:@"ZZ"];
    int workPageNo =0;
    for (int ct = 0; ct<arrange1Count; ct++) {
        NSString *EdaNo =       [_msg substringWithRange:NSMakeRange(3+init3+60*ct, 2)];
        NSString *TopSyohinCD = [_msg substringWithRange:NSMakeRange(5+init3+60*ct, 13)];
        NSString *ArNo =        [_msg substringWithRange:NSMakeRange(18+init3+60*ct, 3)];
        NSString *SyohinCD =    [_msg substringWithRange:NSMakeRange(21+init3+60*ct, 13)];
        NSString *count =       [_msg substringWithRange:NSMakeRange(34+init3+60*ct, 3)];
        //NSString *DispOrder = [_msg substringWithRange:NSMakeRange(37+init3+60*ct, 8)];
        NSString *Jika =        [_msg substringWithRange:NSMakeRange(54+init3+60*ct, 6)];
        NSString *JikaSeq =     [_msg substringWithRange:NSMakeRange(60+init3+60*ct, 3)];
        if (([TopSyohinCD isEqualToString:preTopSyohinCD]) &&
            ([JikaSeq     isEqualToString:preJikaSeq])) {
            if (([JikaSeq isEqualToString:preJikaSeq]) &&
                ([EdaNo   isEqualToString:preEdaNo]) &&
                ([ArNo    isEqualToString:preArNo])) {
            } else {
                preJikaSeq     = [[NSMutableString alloc]initWithString:JikaSeq];
                preEdaNo       = [[NSMutableString alloc]initWithString:EdaNo];
                preArNo        = [[NSMutableString alloc]initWithString:ArNo];
                workPageNo++;
            }
        } else {
            workPageNo = 1;
            preTopSyohinCD = [[NSMutableString alloc]initWithString:TopSyohinCD];
            preJikaSeq     = [[NSMutableString alloc]initWithString:JikaSeq];
            preEdaNo       = [[NSMutableString alloc]initWithString:EdaNo];
            preArNo        = [[NSMutableString alloc]initWithString:ArNo];
        }
        NSString *PageNo = [NSString stringWithFormat:@"%03d",workPageNo];
        
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
        //2014-09-17 ueda
        _menu[@"EdaNo"] = EdaNo;
        _menu[@"TopSyohinCD"] = TopSyohinCD;
        _menu[@"Sub1SyohinCD"] = @"";
        
        //2014-10-02 ueda
        if ([SyohinCD isEqualToString:@"9999999999999"]) {
            NSString *ArngComment = [String Arrange_Comment];
            [orderManager addMenuExtMt:ArngComment];
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            SyohinCD = [NSString stringWithFormat:@"A%03zd", appDelegate.typeCarrangeCount];
            _menu[@"SyohinCD"] = SyohinCD;
        } else {
            _menu[@"SyohinCD"] = _menu[@"MstSyohinCD"];
        }
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[count intValue]];
        _menu[@"Jika"] = [NSString stringWithFormat:@"%d",[Jika intValue]];
        _menu[@"PageNo"] = [NSString stringWithFormat:@"%d",[PageNo intValue]];
        _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
        //[DataList sharedInstance].TrayNo = [NSString stringWithFormat:@"%02d",[PageNo intValue]];
        
        [orderManager addArrangeMenu:_menu
                                update:NO];
        
        LOG(@"%d",ct);
    }
    
    //arrange2Count
    NSInteger init4 = 3 + init3 + 60*arrange1Count;
    int arrange2Count = [[_msg substringWithRange:NSMakeRange(init4, 3)]intValue];
    LOG(@"arrange2Count:%@",[_msg substringWithRange:NSMakeRange(init4, 3)]);
    for (int ct = 0; ct<arrange2Count; ct++) {
        //2014-09-17 ueda
        NSString *EdaNo =        [_msg substringWithRange:NSMakeRange(3+init4+91*ct, 2)];
        NSString *TopSyohinCD =  [_msg substringWithRange:NSMakeRange(5+init4+91*ct, 13)];
        NSString *trayNo =       [_msg substringWithRange:NSMakeRange(18+init4+91*ct, 2)];
        NSString *PageNo =       [_msg substringWithRange:NSMakeRange(30+init4+91*ct, 3)];
        NSString *SyohinCD =     [_msg substringWithRange:NSMakeRange(33+init4+91*ct, 13)];
        NSString *count =        [_msg substringWithRange:NSMakeRange(46+init4+91*ct, 3)];
        NSString *Jika =         [_msg substringWithRange:NSMakeRange(70+init4+91*ct, 6)];
        NSString *Sub1SyohinCD = [_msg substringWithRange:NSMakeRange(81+init4+91*ct, 13)];
        
        LOG(@"arrange:%d:%@",ct,SyohinCD);
        
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
        //2014-09-17 ueda
        _menu[@"EdaNo"] = EdaNo;
        _menu[@"TopSyohinCD"] = TopSyohinCD;
        _menu[@"Sub1SyohinCD"] = Sub1SyohinCD;
        _menu[@"SyohinCD"] = _menu[@"MstSyohinCD"];
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[count intValue]];
        _menu[@"Jika"] = [NSString stringWithFormat:@"%d",[Jika intValue]];
        _menu[@"PageNo"] = [NSString stringWithFormat:@"%d",[PageNo intValue]];
        _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
        _menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        
        //[DataList sharedInstance].TrayNo = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        _menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
        [orderManager addArrangeMenu:_menu
                              update:NO];
    }
    
    
    //trayCount
    NSInteger init5 = 3 + init4 + 91*arrange2Count;
    int trayCount = [[_msg substringWithRange:NSMakeRange(init5, 3)]intValue];
    LOG(@"trayCount:%@",[_msg substringWithRange:NSMakeRange(init5, 3)]);
    for (int ct = 0; ct<trayCount; ct++) {
        
        //2014-08-19 ueda
        NSString *EdaNo =       [_msg substringWithRange:NSMakeRange(3+init5+26*ct, 2)];
        NSString *TopSyohinCD = [_msg substringWithRange:NSMakeRange(5+init5+26*ct, 13)];
        NSString *Jika = [_msg substringWithRange:NSMakeRange(18+init5+26*ct, 6)];
        NSString *trayNo = [_msg substringWithRange:NSMakeRange(27+init5+26*ct, 2)];

        //GetMenu
        LOG(@"SyohinCD:%@",TopSyohinCD);
        NSMutableDictionary *_menu = [orderManager getMenuForCancel:TopSyohinCD];

        //2014-08-19 ueda
        _menu[@"EdaNo"] = EdaNo;
        
        _menu[@"Jika"] = Jika;
        _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
        _menu[@"trayNo"] = trayNo;
        _menu[@"count"] = @"1";
        
        //AddMenuTop
        [orderManager addTopMenu:_menu];
    }
}

//2014-09-12 ueda
- (void)convertVoucherDetailTypeC:(NSString*)_msg{
    
    OrderManager *orderManager = [OrderManager sharedInstance];
    [orderManager typeCclearDB];
    DataList *dat = [DataList sharedInstance];
    dat.manCount =   [[_msg substringWithRange:NSMakeRange( 8, 2)]intValue];
    dat.womanCount = [[_msg substringWithRange:NSMakeRange(10, 2)]intValue];
    //2014-10-23 ueda
    dat.childCount = [[_msg substringWithRange:NSMakeRange(12, 2)]intValue];
    
    if (![[_msg substringWithRange:NSMakeRange(0, 3)]isEqualToString:@"X32"]) {
        //配列作成
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        _dic[@"EdaNo"] =      [_msg substringWithRange:NSMakeRange( 0, 4)];
        _dic[@"manCount"] =   [_msg substringWithRange:NSMakeRange( 8, 2)];
        _dic[@"womanCount"] = [_msg substringWithRange:NSMakeRange(10, 2)];
        //2014-10-23 ueda
        _dic[@"childCount"] = [_msg substringWithRange:NSMakeRange(12, 2)];
        dat.currentVoucher = _dic;
    }
    
    //2014-10-23 ueda
    int wMaxLp = [[_msg substringWithRange:NSMakeRange(14, 3)]intValue];
    int wPtr = 17;
    for (int ctX = 0; ctX < wMaxLp; ctX++) {
        NSString *wSeatNumber = [self getShiftJisMid:_msg startPos:wPtr     length:2];
        NSString *wOrderType  = [self getShiftJisMid:_msg startPos:wPtr + 2 length:2];
        NSString *wOTcomment  = [self getShiftJisMid:_msg startPos:wPtr + 4 length:60];
        wPtr += 64;
        
        NSString *saveText = [wOTcomment stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if (!([saveText isEqualToString:@""])) {
            [orderManager updateNoteMt:wOrderType modifyName:saveText];
        }
        
        //Menu
        int menuCount = [[self getShiftJisMid:_msg startPos:wPtr length:3] intValue];
        wPtr += 3;
        for (int ct = 0; ct<menuCount; ct++) {
            NSString *EdaNo =    [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *SyohinCD = [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            
            NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
            _menu[@"count"] =    [self getShiftJisMid:_msg startPos:wPtr + 15 length:3];
            _menu[@"Jika"] =     [self getShiftJisMid:_msg startPos:wPtr + 18 length:6];
            NSString *seq =      [self getShiftJisMid:_msg startPos:wPtr + 24 length:3];
            _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
            _menu[@"EdaNo"] = EdaNo;
            //AddMenuTop
            if ([_menu[@"TrayStyle"]isEqualToString:@"0"]) {//トレイ商品の場合は個数ごとに登録
                if ([[_menu allKeys]containsObject:@"PatternCD"]) {
                    //時価商品別の場合
                    if ([_menu[@"JikaFLG"]isEqualToString:@"1"]&&[seq intValue]>0) {
                        _menu[@"trayNo"] = seq;
                    }
                    [orderManager addTopMenu:_menu];
                }
            }
            wPtr += 30;
        }
        
        //sub1
        int sub1Count = [[self getShiftJisMid:_msg startPos:wPtr length:3]intValue];
        wPtr += 3;
        for (int ct = 0; ct<sub1Count; ct++) {
            NSString *EdaNo =       [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *TopSyohinCD = [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            NSString *trayNo =      [self getShiftJisMid:_msg startPos:wPtr + 15 length:2];
            
            NSString *GroupType =   [self getShiftJisMid:_msg startPos:wPtr + 18 length:1];
            NSString *GroupCD =     [self getShiftJisMid:_msg startPos:wPtr + 19 length:4];
            NSString *CondiGDID =   [self getShiftJisMid:_msg startPos:wPtr + 23 length:4];
            //GetSub1
            NSMutableDictionary *_sub1 = [orderManager getSubMenu:TopSyohinCD
                                                        GroupType:GroupType
                                                          GroupCD:GroupCD
                                                        CondiGDID:CondiGDID
                                                               SG:1];
            _sub1[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
            _sub1[@"EdaNo"] = EdaNo;
            if ([[_sub1 allKeys]containsObject:@"SyohinCD"]) {
                _sub1[@"Sub1SyohinCD"] = _sub1[@"SyohinCD"];
            }
            else{
                _sub1[@"Sub1SyohinCD"] = @"";
            }
            _sub1[@"count"] =       [self getShiftJisMid:_msg startPos:wPtr + 27 length:3];
            _sub1[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
            [orderManager addSubMenu:_sub1
                                  SG:1];
            wPtr += 60;
        }
        
        //sub2
        int sub2Count = [[self getShiftJisMid:_msg startPos:wPtr length:3] intValue];
        wPtr += 3;
        for (int ct = 0; ct<sub2Count; ct++) {
            NSString *EdaNo =       [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *TopSyohinCD = [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            NSString *trayNo =      [self getShiftJisMid:_msg startPos:wPtr + 15 length:2];
            NSString *GroupCD1 =    [self getShiftJisMid:_msg startPos:wPtr + 17 length:4];
            NSString *CondiGDID1 =  [self getShiftJisMid:_msg startPos:wPtr + 21 length:4];
            
            NSString *GroupType =   [self getShiftJisMid:_msg startPos:wPtr + 26 length:1];
            NSString *GroupCD2 =    [self getShiftJisMid:_msg startPos:wPtr + 27 length:4];
            NSString *CondiGDID2 =  [self getShiftJisMid:_msg startPos:wPtr + 31 length:4];
            //GetSub2
            NSMutableDictionary *_sub2 = [orderManager getSubMenu:TopSyohinCD
                                                        GroupType:GroupType
                                                          GroupCD:GroupCD2
                                                        CondiGDID:CondiGDID2
                                                               SG:2];
            _sub2[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
            _sub2[@"EdaNo"] = EdaNo;
            _sub2[@"count"] = [self getShiftJisMid:_msg startPos:wPtr + 35 length:3];
            _sub2[@"CondiGCD"] = GroupCD1;
            _sub2[@"CondiGDID"] = CondiGDID1;
            _sub2[@"Sub1SyohinCD"] = [self sub1SyohinCD:TopSyohinCD
                                               GroupCD1:GroupCD1
                                             CondiGDID1:CondiGDID1];
            
            [orderManager addSubMenu:_sub2
                                  SG:2];
            wPtr += 70;
        }
        
        //arrange1
        int arrange1Count = [[self getShiftJisMid:_msg startPos:wPtr length:3] intValue];
        wPtr += 3;
        //2014-10-02 ueda
        NSMutableString *preTopSyohinCD = [[NSMutableString alloc]initWithString:@"ZZ"];
        NSMutableString *preJika        = [[NSMutableString alloc]initWithString:@"ZZ"];
        int workPageNo =0;
        for (int ct = 0; ct<arrange1Count; ct++) {
            NSString *EdaNo =       [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *TopSyohinCD = [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            //2014-10-02 ueda
            //NSString *PageNo =      [self getShiftJisMid:_msg startPos:wPtr + 15 length:3];
            NSString *SyohinCD =    [self getShiftJisMid:_msg startPos:wPtr + 18 length:13];
            NSString *ArngComment = [self getShiftJisMid:_msg startPos:wPtr + 31 length:30];
            NSString *count =       [self getShiftJisMid:_msg startPos:wPtr + 61 length:3];
            //NSString *DispOrder =   [self getShiftJisMid:_msg startPos:wPtr + 64 length:17];
            NSString *Jika =        [self getShiftJisMid:_msg startPos:wPtr + 81 length:6];
            //2014-10-02 ueda
            if (([TopSyohinCD isEqualToString:preTopSyohinCD]) && ([Jika isEqualToString:preJika])) {
                workPageNo++;
            } else {
                workPageNo = 1;
                preTopSyohinCD = [[NSMutableString alloc]initWithString:TopSyohinCD];
                preJika        = [[NSMutableString alloc]initWithString:Jika];
            }
            NSString *PageNo = [NSString stringWithFormat:@"%03d",workPageNo];
            
            if ([SyohinCD isEqualToString:@"9999999999999"]) {
                [orderManager addMenuExtMt:ArngComment];
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                SyohinCD = [NSString stringWithFormat:@"A%03zd", appDelegate.typeCarrangeCount];
            }
            
            NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
            _menu[@"EdaNo"] = EdaNo;
            _menu[@"TopSyohinCD"] = TopSyohinCD;
            _menu[@"Sub1SyohinCD"] = @"";
            _menu[@"SyohinCD"] = SyohinCD;
            _menu[@"count"] = [NSString stringWithFormat:@"%d",[count intValue]];
            _menu[@"Jika"] = [NSString stringWithFormat:@"%d",[Jika intValue]];
            _menu[@"PageNo"] = [NSString stringWithFormat:@"%d",[PageNo intValue]];
            _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
            
            [orderManager addArrangeMenu:_menu
                                  update:NO];
            wPtr += 90;
        }
        
        //arrange2
        int arrange2Count = [[self getShiftJisMid:_msg startPos:wPtr length:3] intValue];
        wPtr += 3;
        for (int ct = 0; ct<arrange2Count; ct++) {
            NSString *EdaNo =        [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *TopSyohinCD =  [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            NSString *trayNo =       [self getShiftJisMid:_msg startPos:wPtr + 15 length:2];
            
            NSString *PageNo =       [self getShiftJisMid:_msg startPos:wPtr + 27 length:3];
            NSString *SyohinCD =     [self getShiftJisMid:_msg startPos:wPtr + 30 length:13];
            NSString *ArngComment =  [self getShiftJisMid:_msg startPos:wPtr + 43 length:30];
            NSString *count =        [self getShiftJisMid:_msg startPos:wPtr + 73 length:3];
            NSString *Jika =         [self getShiftJisMid:_msg startPos:wPtr + 97 length:6];
            NSString *Sub1SyohinCD = [self getShiftJisMid:_msg startPos:wPtr + 108 length:13];
            
            if ([SyohinCD isEqualToString:@"9999999999999"]) {
                [orderManager addMenuExtMt:ArngComment];
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                SyohinCD = [NSString stringWithFormat:@"A%03zd", appDelegate.typeCarrangeCount];
            }
            
            NSMutableDictionary *_menu = [orderManager getMenuForCancel:SyohinCD];
            _menu[@"EdaNo"] = EdaNo;
            _menu[@"TopSyohinCD"] = TopSyohinCD;
            _menu[@"Sub1SyohinCD"] = Sub1SyohinCD;
            _menu[@"SyohinCD"] = SyohinCD;
            _menu[@"count"] = [NSString stringWithFormat:@"%d",[count intValue]];
            _menu[@"Jika"] = [NSString stringWithFormat:@"%d",[Jika intValue]];
            _menu[@"PageNo"] = [NSString stringWithFormat:@"%d",[PageNo intValue]];
            _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
            _menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
            
            //[DataList sharedInstance].TrayNo = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
            _menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",[trayNo intValue]];
            [orderManager addArrangeMenu:_menu
                                  update:NO];
            wPtr += 121;
        }
        
        
        //tray
        int trayCount = [[self getShiftJisMid:_msg startPos:wPtr length:3] intValue];
        wPtr += 3;
        for (int ct = 0; ct<trayCount; ct++) {
            NSString *EdaNo =       [self getShiftJisMid:_msg startPos:wPtr      length:2];
            NSString *TopSyohinCD = [self getShiftJisMid:_msg startPos:wPtr +  2 length:13];
            NSString *Jika =        [self getShiftJisMid:_msg startPos:wPtr + 15 length:6];
            
            NSString *trayNo =      [self getShiftJisMid:_msg startPos:wPtr + 24 length:2];
            //GetMenu
            NSMutableDictionary *_menu = [orderManager getMenuForCancel:TopSyohinCD];
            _menu[@"EdaNo"] = EdaNo;
            _menu[@"Jika"] = Jika;
            _menu[@"countDivide"] = [@[@"0"] componentsJoinedByString:@","];
            _menu[@"trayNo"] = trayNo;
            _menu[@"count"] = @"1";
            
            //AddMenuTop
            [orderManager addTopMenu:_menu];
            
            wPtr += 26;
        }
        
        //TypeC DB
        [DataList sharedInstance].typeCseatSelect = [[NSMutableArray alloc]init];
        if ([wSeatNumber isEqualToString:@"00"]) {
        } else {
            NSMutableArray *wSeatNumberData = orderManager.getSeatNumberData;
            NSMutableDictionary *search = [wSeatNumberData objectAtIndex:[[wSeatNumberData valueForKeyPath:@"keyText"] indexOfObject:wSeatNumber]];
            [[DataList sharedInstance].typeCseatSelect addObject:search];
        }
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.typeCorderIndex = ctX + 1;
        dat.currentNoteID = wOrderType;
        [orderManager typeCcopyDB];
        [orderManager zeroReset2];
    }
}

- (NSString*)sub1SyohinCD:(NSString*)TopSyohinCD
                 GroupCD1:(NSString*)GroupCD1
               CondiGDID1:(NSString*)CondiGDID1{
    
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];

    NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher1 WHERE TopSyohinCD = ? and GCD = ? and CD = ?"];
    FMResultSet *results1 = [_net.db executeQuery:str1,TopSyohinCD,GroupCD1,CondiGDID1];
    [results1 next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results1 columnCount]; ct++) {
        NSString *column = [results1 columnNameForIndex:ct];
        [_dic setValue:[results1 stringForColumn:column] forKey:column];
    }
    [results1 close];
    [_net closeDb];
    
    LOG(@"%@",_dic);
    
    return _dic[@"Sub1SyohinCD"];
}

//0:なし　1:発行　2:表示
- (NSString*)convertForVoucherDivide:(NSMutableArray*)_array
                                type:(NSString*)type{
    
    NSMutableString *_msg = [[NSMutableString alloc]init];
    DataList *dat = [DataList sharedInstance];
    
    //LOG(@"%d:%@:%@",dat.divideCount,dat.currentVoucher,_array);

    NSMutableString *renban = [[NSMutableString alloc]init];
    for (int ct = 0; ct < dat.divideCount; ct++) {
        [renban appendString:[NSString stringWithFormat:@"%02d",ct+1]];
    }
    
    
    [_msg appendString:@"N22"];
    [_msg appendString:[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [_msg appendString:[System sharedInstance].training];
    [_msg appendString:dat.currentVoucher[@"EdaNo"]];
    [_msg appendString:type];
    //[_msg appendString:@"02"];//分割件数
    //[_msg appendString:@"0102"];//分割番号
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.divideCount]];//分割件数
    [_msg appendString:renban];//分割番号
    
    

    
    //TOP階層
    NSArray *_menuTop1 = _array[0];
    
    //重複要素を削除する
    NSMutableArray *fixedArray = [self returnDivideArray:_menuTop1];

    NSMutableString *_top1Msg = [[NSMutableString alloc]init];
    int _topCount = 0;
    
    LOG(@"dat.divideCount:%zd",dat.divideCount);
    
    for (int mstCt = 0; mstCt < dat.divideCount; mstCt++) {
        for (int ct = 0; ct<fixedArray.count; ct++) {
            
            NSDictionary *_dic = [fixedArray objectAtIndex:ct];
            //NSString *SyohinCD = fixedArray[ct];
            //NSDictionary *_dic = [_menuTop1 objectAtIndex:[[_menuTop1 valueForKeyPath:@"SyohinCD"] indexOfObject:SyohinCD]];
            //NSDictionary *_dic = [_menuTop1 objectAtIndex:ct];
            
            //カウント番号を取得
            /*
            NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            int divideCount = [array[mstCt]intValue];
            */
            int divideCt = [self countContainsObject:_dic
                                               array:_menuTop1
                                              divide:mstCt];
            if (divideCt>0) {
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
                [_top1Msg appendString:[NSString stringWithFormat:@"00"]];
                [_top1Msg appendString:_dic[@"SyohinCD"]];
                //[_top1Msg appendString:[NSString stringWithFormat:@"%03d",divideCount]];
                [_top1Msg appendString:[NSString stringWithFormat:@"%03d",divideCt]];
                [_top1Msg appendString:[NSString stringWithFormat:@"%02d",mstCt+1]];//分割番号
                [_top1Msg appendString:_jika];//時価
                
                _topCount++;
            }
        }
    }
    //[_msg appendString:[NSString stringWithFormat:@"%03d",fixedArray.count]];
    [_msg appendString:[NSString stringWithFormat:@"%03d",_topCount]];
    [_msg appendString:_top1Msg];

    
    
    
    //第1階層情報
    NSArray *_menuSub1_1 = _array[1];
    //重複要素を削除する
    //NSMutableArray *fixedSub1Array = [self returnDivideSubArray:_menuSub1_1];
    NSMutableString *_sub1Msg = [[NSMutableString alloc]init];
    //LOG(@"fixedSub1Array:%@",fixedSub1Array);
    int _sub1Count = 0;
    if ([_menuSub1_1 count]>0) {
        for (int mstCt = 0; mstCt < dat.divideCount; mstCt++) {
            for (int ct = 0; ct<[_menuSub1_1 count]; ct++) {

                NSDictionary *_dic = [_menuSub1_1 objectAtIndex:ct];
                
                //カウント番号を取得
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                int divideCount = [array[mstCt]intValue];

                LOG(@"3");
                if (divideCount>0) {
                    [_sub1Msg appendString:[NSString stringWithFormat:@"00"]];
                    [_sub1Msg appendString:_dic[@"TopSyohinCD"]];
                    [_sub1Msg appendString:_dic[@"trayNo"]];
                    [_sub1Msg appendString:_dic[@"SG1ID"]];
                    [_sub1Msg appendString:_dic[@"GroupType"]];
                    [_sub1Msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
                    [_sub1Msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
                    [_sub1Msg appendString:[NSString stringWithFormat:@"%03d",divideCount]];
                    //[_sub1Msg appendString:[NSString stringWithFormat:@"%03d",divideCt]];
                    //[_sub1Msg appendString:[NSString stringWithFormat:@"%06d",[_dic[@"DispOrder"]intValue]]];
                    [_sub1Msg appendString:[NSString stringWithFormat:@"%02d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue]]];
                    [_sub1Msg appendString:[NSString stringWithFormat:@"%02d",mstCt+1]];//分割番号
                    //[_sub1Msg appendString:@"000000"];//時価
                    NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
                    NSString *jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
                    [_sub1Msg appendString:jika];
                    
                    _sub1Count ++;
                } 
            }
        }
    }
    LOG(@"msg3-2:%@",_sub1Msg);
    [_msg appendString:[NSString stringWithFormat:@"%03d",_sub1Count]];
    [_msg appendString:_sub1Msg];

    
    //第2階層情報
    NSArray *_menuSub2_1 = _array[2];
    LOG(@"countSub2_1:%@",_menuSub2_1);
    NSMutableString *_sub2Msg = [[NSMutableString alloc]init];
    int _sub2Count = 0;
    if ([_menuSub2_1 count]>0) {
        for (int mstCt = 0; mstCt < dat.divideCount; mstCt++) {
            
            for (int ct = 0; ct<[_menuSub2_1 count]; ct++) {
                NSDictionary *_dic = [_menuSub2_1 objectAtIndex:ct];
                
                //カウント番号を取得
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                int divideCount = [array[mstCt]intValue];
                if (divideCount>0) {
                    [_sub2Msg appendString:[NSString stringWithFormat:@"00"]];
                    [_sub2Msg appendString:_dic[@"TopSyohinCD"]];
                    [_sub2Msg appendString:_dic[@"trayNo"]];
                    [_sub2Msg appendString:_dic[@"CondiGCD"]];
                    [_sub2Msg appendString:_dic[@"CondiGDID"]];
                    [_sub2Msg appendString:_dic[@"SG2ID"]];
                    [_sub2Msg appendString:_dic[@"GroupType"]];
                    [_sub2Msg appendString:[self appendSpace:_dic[@"GCD"] totalLength:4]];
                    [_sub2Msg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"CD"]intValue]]];
                    [_sub2Msg appendString:[NSString stringWithFormat:@"%03d",divideCount]];
                    //[_sub2Msg appendString:[NSString stringWithFormat:@"%010d",[_dic[@"DispOrder"]intValue]]];
                    [_sub2Msg appendString:[NSString stringWithFormat:@"%02d%d%03d%d%03d",[_dic[@"trayNo"]intValue],[_dic[@"SG1ID"]intValue],[_dic[@"CD"]intValue],[_dic[@"SG2ID"]intValue],[_dic[@"CondiGDID"]intValue]]];
                    [_sub2Msg appendString:[NSString stringWithFormat:@"%02d",mstCt+1]];//分割番号
                    //[_sub2Msg appendString:@"000000"];//時価
                    NSMutableDictionary *top = [fixedArray objectAtIndex:[[fixedArray valueForKeyPath:@"SyohinCD"] indexOfObject:_dic[@"TopSyohinCD"]]];
                    NSString *jika = [NSString stringWithFormat:@"%06d",[top[@"Jika"]intValue]];
                    [_sub2Msg appendString:jika];
                    
                     _sub2Count ++;
                }
            }
        }
    }

    LOG(@"msg2-2:%@",_sub2Msg);
    [_msg appendString:[NSString stringWithFormat:@"%03d",_sub2Count]];
    [_msg appendString:_sub2Msg];
    
    
    
    //アレンジ
    NSArray *_menuArrange = _array[3];
    NSMutableString *_arrangeMsg = [[NSMutableString alloc]init];
    int _arrangeCount = 0;
    for (int mstCt = 0; mstCt < dat.divideCount; mstCt++) {
        for (int ct = 0; ct<[_menuArrange count]; ct++) {
            NSDictionary *_dic = [_menuArrange objectAtIndex:ct];
            LOG(@"%@",_dic);
            //カウント番号を取得
            NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            int divideCount = [array[mstCt]intValue];
            if (divideCount>0) {
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
                //[_arrangeMsg appendString:[NSString stringWithFormat:@"00"]];
                [_arrangeMsg appendString:_dic[@"trayNo"]];
                [_arrangeMsg appendString:_dic[@"TopSyohinCD"]];
                [_arrangeMsg appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
                //2014-10-01 ueda
                if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
                    [_arrangeMsg appendString:@"9999999999999"];
                } else {
                    [_arrangeMsg appendString:_dic[@"SyohinCD"]];
                }
                [_arrangeMsg appendString:[NSString stringWithFormat:@"%03d",divideCount]];
                //[_arrangeMsg appendString:[NSString stringWithFormat:@"%08d",[_dic[@"DispOrder"]intValue]]];
                
                [_arrangeMsg appendString:[NSString stringWithFormat:@"%04d",[_dic[@"PageNo"]intValue]]];
                [_arrangeMsg appendString:@"00000"];//時価
                //2014-10-01 ueda
                if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
                    [_arrangeMsg appendString:@"99999999"];
                } else {
                    [_arrangeMsg appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 8)]];
                }
                [_arrangeMsg appendString:[NSString stringWithFormat:@"%02d",mstCt+1]];//分割番号
                //[_arrangeMsg appendString:[NSString stringWithFormat:@"%02d",_arrangeCount+1]];//分割番号
                [_arrangeMsg appendString:_jika];//時価
                _arrangeCount++;
            }
        }
    }
    [_msg appendString:[NSString stringWithFormat:@"%03d",_arrangeCount]];
    [_msg appendString:_arrangeMsg];
    
    
    
    //アレンジ2
    NSArray *_menuArrange2 = _array[4];
    //[_msg appendString:[NSString stringWithFormat:@"%03d",[_menuArrange2 count]]];
    
    NSMutableString *_arrangeMsg2 = [[NSMutableString alloc]init];
    int _arrange2Count = 0;
    for (int mstCt = 0; mstCt < dat.divideCount; mstCt++) {
        for (int ct = 0; ct<[_menuArrange2 count]; ct++) {
            NSDictionary *_dic = [_menuArrange2 objectAtIndex:ct];
            LOG(@"%@",_dic);
            //カウント番号を取得
            NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            int divideCount = [array[mstCt]intValue];
            if (divideCount>0) {
                
                
                //第１階層サブグループを取得
                //int sub1Disp = 0;
                NSDictionary *_menuSub1 = nil;
                for (int count = 0; count < [_menuSub1_1 count]; count++) {
                    _menuSub1 = _menuSub1_1[count];
                    if ([_menuSub1[@"SyohinCD"]isEqualToString:_dic[@"Sub1SyohinCD"]]) {
                        LOG(@"arrange_menuSub1:%@",_menuSub1);
                        //sub1Disp = count;
                        break;
                    }
                }
                
                
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_menuSub1[@"Jika"]intValue]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"00"]];
                [_arrangeMsg2 appendString:_dic[@"TopSyohinCD"]];
                //[_msg appendString:_dic[@"trayNo"]];
                int no = [_dic[@"trayNo"]intValue];
                if (no>0) {
                    [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%02d",[_dic[@"trayNo"]intValue]]];
                }
                else{
                    [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%02d",[_dic[@"PageNo"]intValue]]];
                }
                [_arrangeMsg2 appendString:_menuSub1[@"SG1ID"]];
                [_arrangeMsg2 appendString:_menuSub1[@"GroupType"]];
                [_arrangeMsg2 appendString:[self appendSpace:_menuSub1[@"GCD"] totalLength:4]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%04d",[_menuSub1[@"CD"]intValue]]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%03d",[_dic[@"PageNo"]intValue]]];
                [_arrangeMsg2 appendString:_dic[@"SyohinCD"]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%03d",divideCount]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"1%02d%@%03d%03d00000",[_dic[@"trayNo"]intValue],_menuSub1[@"DispOrder"],[_menuSub1[@"CD"]intValue],[_dic[@"trayNo"]intValue]]];
                [_arrangeMsg2 appendString:[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 8)]];
                [_arrangeMsg2 appendString:[NSString stringWithFormat:@"%02d",mstCt+1]];
                [_arrangeMsg2 appendString:_jika];//時価
                _arrange2Count++;
            }
        }
        
    }
    [_msg appendString:[NSString stringWithFormat:@"%03d",_arrange2Count]];
    [_msg appendString:_arrangeMsg2];
    
    

    //親商品のトレイ数を取得する
    int trayCount = 0;
    for (int ct = 0; ct < [_menuTop1 count]; ct++) {
        NSDictionary *_dic = [_menuTop1 objectAtIndex:ct];
        if ([_dic[@"trayNo"]intValue]>0) {
            trayCount++;
        }
    }
    
    if (trayCount>0) {
        [_msg appendString:[NSString stringWithFormat:@"%03d",trayCount]];
        LOG(@"3:%zd",[_menuTop1 count]);
        
        for (int ct = 0; ct<[_menuTop1 count]; ct++) {
            NSDictionary *_dic = [_menuTop1 objectAtIndex:ct];
            
            if ([_dic[@"trayNo"]intValue]>0) {
                
                NSString *_jika = [NSString stringWithFormat:@"%06d",[_dic[@"Jika"]intValue]];
                [_msg appendString:@"00"];
                [_msg appendString:_dic[@"SyohinCD"]];
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                for (int count = 0; count < array.count; count++) {
                    if ([array[count]intValue]>0) {
                        [_msg appendString:[NSString stringWithFormat:@"%02d",count+1]];
                        break;
                    }
                }
                [_msg appendString:_jika];//時価
                [_msg appendString:_dic[@"trayNo"]];
            }
        }
    }
    else{
        [_msg appendString:@"000"];
    }
    
    return _msg;
}


- (NSMutableArray*)returnDivideArray:(NSArray*)array{
    NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < array.count; ct++) {
        NSMutableDictionary *tempDic = array[ct];
        if ([[fixedArray valueForKeyPath:@"SyohinCD"]containsObject:tempDic[@"SyohinCD"]]) {
            /*
            if (![[fixedArray valueForKeyPath:@"countDivide"]containsObject:tempDic[@"countDivide"]]) {
                [fixedArray addObject:tempDic];
            }
            */
        }
        else{
            [fixedArray addObject:tempDic];
        }
    }
    
    LOG(@"%@",fixedArray);
    
    return fixedArray;
}

- (NSMutableArray*)returnDivideSubArray:(NSArray*)array{
    NSMutableArray *fixedArray = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < array.count; ct++) {
        NSMutableDictionary *tempDic = array[ct];
        if ([[fixedArray valueForKeyPath:@"CD"]containsObject:tempDic[@"CD"]]) {
            if ([[fixedArray valueForKeyPath:@"GCD"]containsObject:tempDic[@"GCD"]]) {
                if (![[fixedArray valueForKeyPath:@"countDivide"]containsObject:tempDic[@"countDivide"]]) {
                    [fixedArray addObject:tempDic];
                }
            }
            else{
                [fixedArray addObject:tempDic];
            }
        }
        else{
            [fixedArray addObject:tempDic];
        }
    }
    return fixedArray;
}

- (int)countContainsObject:(NSDictionary*)object
                     array:(NSArray*)array
                    divide:(int)divideCt{

    int count = 0;
    for (int ct = 0; ct < array.count; ct++) {
        NSMutableDictionary *_dic = array[ct];
        if ([_dic[@"SyohinCD"]isEqualToString:object[@"SyohinCD"]]) {
            /*
            if ([_dic[@"countDivide"]isEqualToString:object[@"countDivide"]]) {
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                count = count + [divide[divideCt]intValue];
            }
             */
            NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
            count = count + [divide[divideCt]intValue];
            
        }
    }
    
    LOG(@"count:%d番目:%d",divideCt,count);
    
    return count;
}

- (int)countContainsSubObject:(NSDictionary*)object
                        array:(NSArray*)array
                       divide:(int)divideCt{
    int count = 0;
    for (int ct = 0; ct < array.count; ct++) {
        NSMutableDictionary *_dic = array[ct];
        if ([_dic[@"CD"]isEqualToString:object[@"CD"]]) {
            if ([_dic[@"GCD"]isEqualToString:object[@"GCD"]]) {
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                count = count + [divide[divideCt]intValue];
            }
        }
    }
    
    LOG(@"count:%d",count);
    
    return count;
}

- (NSArray*)convertForVoucherDivideResult:(NSString*)_msg{
    int menuCount = [[_msg substringWithRange:NSMakeRange(4, 2)]intValue];
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    
    for (int ct = 0; ct<menuCount; ct++) {
        NSString *cd = [_msg substringWithRange:NSMakeRange(6+4*ct,4)];
        //2014-11-17 ueda
        [_array addObject:@{@"EdaNo": cd,@"manCount": @"",@"womanCount": @"",@"childCount": @""}];
    }
    return [[NSArray alloc]initWithArray:_array];
}

- (NSMutableDictionary*)convertVoucherCheck:(NSString*)_msg{
    OrderManager *orderManager = [OrderManager sharedInstance];
    
    NSMutableDictionary *_array = [[NSMutableDictionary alloc]init];
    
    int init = 0;
    //2014-12-12 ueda
    int edaCount = 0;
    //2015-06-17 ueda
    if ([[System sharedInstance].staffCodeKetaKbn isEqualToString:@"1"]) {
        //担当者コード：６桁
        _array[@"header"] = [NSString stringWithFormat:@"%d",[[self getShiftJisMid:_msg startPos:13 length:7] intValue]];
        init = 2;
        edaCount = [[self getShiftJisMid:_msg startPos:20 length:2]intValue];
    } else {
        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //入力タイプＣ or 小人入力する
            //2014-03-18 ueda
            //_array[@"header"] = [NSString stringWithFormat:@"%d",[[_msg substringWithRange:NSMakeRange(11, 7)] intValue]];
            //2014-11-17 ueda
            //_array[@"header"] = [NSString stringWithFormat:@"%d",[[self getShiftJisMid:_msg startPos:11 length:7] intValue]];
            _array[@"header"] = [NSString stringWithFormat:@"%d",[[self getShiftJisMid:_msg startPos:13 length:7] intValue]];
            //2014-11-17 ueda
            init = 2;
            //2014-03-18 ueda
            //int edaCount = [[_msg substringWithRange:NSMakeRange(18, 2)]intValue];
            //2014-11-17 ueda
            //int edaCount = [[self getShiftJisMid:_msg startPos:18 length:2]intValue];
            //2014-12-12 ueda
            //int edaCount = [[self getShiftJisMid:_msg startPos:20 length:2]intValue];
            edaCount = [[self getShiftJisMid:_msg startPos:20 length:2]intValue];
        } else {
            //小人入力しない
            _array[@"header"] = [NSString stringWithFormat:@"%d",[[self getShiftJisMid:_msg startPos:11 length:7] intValue]];
            edaCount = [[self getShiftJisMid:_msg startPos:18 length:2]intValue];
        }
    }
    
    LOG(@"edaCount:%d",edaCount);
    int span = 21;
    int end = 0;
    
    [self openDb];
    for (int num = 0; num < edaCount; num++) {
        //2014-03-18 ueda
        //int edaNo = [[_msg substringWithRange:NSMakeRange(init+20+span*num, 2)]intValue];
        //int count = [[_msg substringWithRange:NSMakeRange(init+22+span*num, 3)]intValue];
        int edaNo = [[self getShiftJisMid:_msg startPos:init+20+span*num length:2]intValue];
        int count = [[self getShiftJisMid:_msg startPos:init+22+span*num length:3]intValue];
        LOG(@"count:%d",count);
        
        
        NSMutableArray *_subArray = [[NSMutableArray alloc]init];
        for (int ct = 0; ct<count; ct++) {
            //2014-03-18 ueda
            //int layer = [[_msg substringWithRange:NSMakeRange(init+25+span*num, 1)]intValue];
            //int type = [[_msg substringWithRange:NSMakeRange(init+26+span*num, 1)]intValue];
            //NSString *cd = [_msg substringWithRange:NSMakeRange(init+27+span*num, 13)];
            int layer    = [[self getShiftJisMid:_msg startPos:init+25+span*num length:1]intValue];
            int type     = [[self getShiftJisMid:_msg startPos:init+26+span*num length:1]intValue];
            NSString *cd =  [self getShiftJisMid:_msg startPos:init+27+span*num length:13];

            NSMutableDictionary *_menu = [[NSMutableDictionary alloc]init];
            if (layer==0) {
                _menu = [orderManager getMenuForCancel:cd];
                //2014-10-01 ueda
                if ([cd isEqualToString:@"9999999999999"]) {
                    _menu[@"HTDispNMU"] = [String Arrange_Comment];
                    _menu[@"HTDispNMM"] = @"";
                    _menu[@"HTDispNML"] = @"";
                    _menu[@"PatternCD"] = @"9";
                }
            }
            else if(layer==1||layer==2){
                if (type==1) {
                    _menu = [orderManager getMenuForCancel:cd];
                }
                else if (type==2) {
                    cd = [cd stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    _menu = [orderManager getComment:cd];
                }
                else if (type==3) {
                    cd = [cd stringByTrimmingCharactersInSet:
                          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
                    _menu = [orderManager getOffer:cd];
                }
                else if (type==4||type==5){
                    _menu = [orderManager getMenuForCancel:cd];
                }
            }
            //2014-03-18 ueda
            //_menu[@"count"] = [_msg substringWithRange:NSMakeRange(init+40+span*num, 3)];
            _menu[@"count"] = [self getShiftJisMid:_msg startPos:init+40+span*num length:3];
            _menu[@"layer"] = [NSString stringWithFormat:@"%d",layer];
            //2016-02-23 ueda ASTERISK
            _menu[@"type"] = [NSString stringWithFormat:@"%d",type];
            LOG(@"_menu:%@",_menu);
            [_subArray addObject:_menu];
            
            init = init + 18;
        }
        end = init - 18 +40+span*num;
        
        init = init - 18 + 2;
        //NSString *edaKey = [NSString stringWithFormat:@"%d",edaNo];
        NSNumber *numKey = [NSNumber numberWithInt:edaNo];
        _array[numKey] = _subArray;
    }
    
    DataList *dat = [DataList sharedInstance];
    //2014-03-18 ueda
    //dat.printMax = [_msg substringWithRange:NSMakeRange(end+3, 1)];
    //dat.printDefault = [_msg substringWithRange:NSMakeRange(end+4, 1)];
    dat.printMax     = [self getShiftJisMid:_msg startPos:end+3 length:1];
    dat.printDefault = [self getShiftJisMid:_msg startPos:end+4 length:1];
    
    [self closeDb];
    
    return _array;
}



#pragma mark Ftp Request client
- (NSURL *)smartURLForString:(NSString *)str
{
    NSURL *     result;
    NSString *  trimmedStr;
    NSRange     schemeMarkerRange;
    NSString *  scheme;
    
    assert(str != nil);
    
    result = nil;
    
    trimmedStr = [str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
    if ( (trimmedStr != nil) && ([trimmedStr length] != 0) ) {
        schemeMarkerRange = [trimmedStr rangeOfString:@"://"];
        
        if (schemeMarkerRange.location == NSNotFound) {
            result = [NSURL URLWithString:[NSString stringWithFormat:@"ftp://%@", trimmedStr]];
        } else {
            scheme = [trimmedStr substringWithRange:NSMakeRange(0, schemeMarkerRange.location)];
            assert(scheme != nil);
            
            if ( ([scheme compare:@"ftp"  options:NSCaseInsensitiveSearch] == NSOrderedSame) ) {
                result = [NSURL URLWithString:trimmedStr];
            } else {
                // It looks like this is some unsupported URL scheme.
            }
        }
    }
    
    return result;
}

- (BOOL)isImageURL:(NSURL *)url
{
    BOOL        result;
    NSString *  extension;
    
    assert(url != nil);
    
    extension = [url pathExtension];
    result = NO;
    if (extension != nil) {
        result = ([extension caseInsensitiveCompare:@"gif"] == NSOrderedSame)
        || ([extension caseInsensitiveCompare:@"png"] == NSOrderedSame)
        || ([extension caseInsensitiveCompare:@"jpg"] == NSOrderedSame);
    }
    return result;
}

- (NSString *)pathForTestImage:(NSUInteger)imageNumber
// In order to fully test the send and receive code paths, we need some really big
// files.  Rather than carry theshe files around in our binary, we synthesise them.
// Specifically, for each test image, we expand the image by an order of magnitude,
// based on its image number.  That is, image 1 is not expanded, image 2
// gets expanded 10 times, and so on.  We expand the image by simply copying it
// to the temporary directory, writing the same data to the file over and over
// again.
{
    NSUInteger          power;
    NSUInteger          expansionFactor;
    NSString *          originalFilePath;
    NSString *          bigFilePath;
    NSFileManager *     fileManager;
    NSDictionary *      attrs;
    unsigned long long  originalFileSize;
    unsigned long long  bigFileSize;
    
    assert( (imageNumber >= 1) && (imageNumber <= 4) );
    
    // Argh, C has no built-in power operator, so I have to do 10 ** (imageNumber - 1)
    // in floating point and then cast back to integer.  Fortunately the range
    // of values is small enough (1..1000) that floating point isn't going
    // to cause me any problems.
    
    // On the simulator we expand by an extra order of magnitude; Macs are fast!
    
    power = imageNumber - 1;
#if TARGET_IPHONE_SIMULATOR
    power += 1;
#endif
    expansionFactor = (NSUInteger) pow(10, power);
    
    fileManager = [NSFileManager defaultManager];
    assert(fileManager != nil);
    
    // Calculate paths to both the original file and the expanded file.
    
    originalFilePath = [[NSBundle mainBundle] pathForResource:[NSString stringWithFormat:@"TestImage%zu", (size_t) imageNumber] ofType:@"png"];
    assert(originalFilePath != nil);
    
    bigFilePath = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"TestImage%zu.png", (size_t) imageNumber]];
    assert(bigFilePath != nil);
    
    // Get the sizes of each.
    
    attrs = [fileManager attributesOfItemAtPath:originalFilePath error:NULL];
    assert(attrs != nil);
    
    originalFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    
    attrs = [fileManager attributesOfItemAtPath:bigFilePath error:NULL];
    if (attrs == NULL) {
        bigFileSize = 0;
    } else {
        bigFileSize = [[attrs objectForKey:NSFileSize] unsignedLongLongValue];
    }
    
    // If the expanded file is missing, or the wrong size, create it from scratch.
    
    if (bigFileSize != (originalFileSize * expansionFactor)) {
        NSOutputStream *    bigFileStream;
        NSData *            data;
        const uint8_t *     dataBuffer;
        NSUInteger          dataLength;
        NSUInteger          dataOffset;
        NSUInteger          counter;
        
        NSLog(@"%5zu - %@", (size_t) expansionFactor, bigFilePath);
        
        data = [NSData dataWithContentsOfMappedFile:originalFilePath];
        assert(data != nil);
        
        dataBuffer = [data bytes];
        dataLength = [data length];
        
        bigFileStream = [NSOutputStream outputStreamToFileAtPath:bigFilePath append:NO];
        assert(bigFileStream != NULL);
        
        [bigFileStream open];
        
        for (counter = 0; counter < expansionFactor; counter++) {
            dataOffset = 0;
            while (dataOffset != dataLength) {
                NSInteger       bytesWritten;
                
                bytesWritten = [bigFileStream write:&dataBuffer[dataOffset] maxLength:dataLength - dataOffset];
                assert(bytesWritten > 0);
                
                dataOffset += (NSUInteger) bytesWritten;
            }
        }
        
        [bigFileStream close];
    }
    
    return bigFilePath;
}

- (NSString *)pathForTemporaryFileWithPrefix:(NSString *)prefix
{
    NSString *  result;
    CFUUIDRef   uuid;
    CFStringRef uuidStr;
    
    uuid = CFUUIDCreate(NULL);
    assert(uuid != NULL);
    
    uuidStr = CFUUIDCreateString(NULL, uuid);
    assert(uuidStr != NULL);
    
    result = [NSTemporaryDirectory() stringByAppendingPathComponent:[NSString stringWithFormat:@"%@-%@", prefix, uuidStr]];
    assert(result != nil);
    
    CFRelease(uuidStr);
    CFRelease(uuid);
    
    return result;
}

- (void)didStartNetworkOperation
{
    // If you start a network operation off the main thread, you'll have to update this code
    // to ensure that any observers of this property are thread safe.
    self.networkOperationCount += 1;
}

- (void)didStopNetworkOperation
{
    // If you stop a network operation off the main thread, you'll have to update this code
    // to ensure that any observers of this property are thread safe.
    self.networkOperationCount -= 1;
}

//2015-02-04 ueda
- (void)sendTableDeleteCalled:(id)delegate{
    LOG(@"F02");
    DataList *dat = [DataList sharedInstance];
    NSString *_F02 = [NSString stringWithFormat:@"F02%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentTable[@"TableID"]];
    [self writeAndRead:_F02
           requestType:RequestTypeTableEmpty
              delegate:delegate];
}

//2015-03-24 ueda
- (void)pokeRegiStart:(id)delegate
            retryFlag:(BOOL)_retryFlag {
    DataList *dat = [DataList sharedInstance];
    NSString *_N61 = [NSString stringWithFormat:@"N61%@%@%@0",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndReadRetry:_N61
           requestType:RequestTypePokeRegiStart
              delegate:delegate
             retryFlag:_retryFlag];
}
- (void)pokeRegiFinish:(id)delegate
             retryFlag:(BOOL)_retryFlag {
    //宿掛専用 簡易版
    DataList *dat = [DataList sharedInstance];
    NSMutableString *N66 = [[NSMutableString alloc]init];
    [N66 appendString:@"N66"];
    [N66 appendString:[self appendSpaceWithNum:sys.currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [N66 appendString:sys.training];
    [N66 appendString:[NSString stringWithFormat:@"%8zd", dat.Pay_Total]];  //注文合計
    [N66 appendString:[NSString stringWithFormat:@"%8zd", 0]];              //チップ
    [N66 appendString:[NSString stringWithFormat:@"%8zd", 0]];              //現金
    [N66 appendString:[NSString stringWithFormat:@"%8zd", 0]];              //カード
    [N66 appendString:@"0"];                                                //カード種別
    [N66 appendString:[NSString stringWithFormat:@"%8zd", dat.Pay_Total]];  //支払区分１
    for (int ct = 2; ct <= 15; ct++) {
        [N66 appendString:[NSString stringWithFormat:@"%8zd", 0]];          //支払区分２〜１５
    }
    [N66 appendString:[NSString stringWithFormat:@"%8zd", 0]];              //つり銭
    [N66 appendString:[self appendSpace:dat.currentKokyakuCD totalLength:12]];  //顧客コード
    [self writeAndReadRetry:N66
           requestType:RequestTypePokeRegiFinish
              delegate:delegate
             retryFlag:_retryFlag];
}
- (void)pokeRegiCancel:(id)delegate
             retryFlag:(BOOL)_retryFlag {
    DataList *dat = [DataList sharedInstance];
    NSString *_N68 = [NSString stringWithFormat:@"N68%@%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,dat.currentVoucher[@"EdaNo"]];
    [self writeAndReadRetry:_N68
           requestType:RequestTypePokeRegiCancel
              delegate:delegate
                  retryFlag:_retryFlag];
}
- (void)convertPokeRegiStart:(NSString*)_msg{
    DataList *dat = [DataList sharedInstance];
    dat.Pay_DenNo = [DataList sharedInstance].currentVoucher[@"EdaNo"];
    dat.Pay_Total = [[self getShiftJisMid:_msg startPos:4 length:8] intValue];
}

//2015-05-12 ueda
- (void)clearMessage:(id)delegate {
    LOG(@"お知らせメッセージクリア:N72");
    NSString *_N72 = [NSString stringWithFormat:@"N72%@%@",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training];
    [self writeAndRead:_N72
           requestType:RequestTypeClearMessage
              delegate:delegate];
}

//2015-06-05 ueda
- (void)getOrderStat:(id)delegate
               count:(NSInteger)_count{
    NSString *_N45 = [NSString stringWithFormat:@"N45%@%@%06zd",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,_count];
    [self writeAndRead:_N45
           requestType:RequestTypeOrderStat
              delegate:delegate];
}
- (int)convertAndSaveOrderStat:(NSString*)_msg
                         count:(NSInteger)_count{
    if (_count == 1) {
        [self openDb];
        [self.db beginTransaction];
        [self.db executeUpdate:@"DELETE FROM OrderStat_DT"];
        [self.db commit];
        [self closeDb];
    }

    [self openDb];
    [self.db beginTransaction];
    int remain = [[self getShiftJisMid:_msg startPos:4 length:6]intValue];
    int count = [[self getShiftJisMid:_msg startPos:10 length:4]intValue];
    for (int ct = 0; ct < count; ct++) {
        [self.db executeUpdate:@"insert into OrderStat_DT values (?, ?, ?, ?, ?, ?, ?)",
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 +  0 length:7],
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 +  7 length: 3],
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 10 length: 2],
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 12 length: 2],
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 14 length: 2],
         [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 16 length: 9],
         [NSString stringWithFormat:@"%@/%@/%@ %@:%@:%@",
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25      length:4],
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25 + 4  length:2],
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25 + 6  length:2],
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25 + 8  length:2],
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25 + 10 length:2],
          [self getShiftJisMid:_msg startPos:ct * 39 + 14 + 25 + 12 length:2]
          ]
         ];
    }
    [self.db commit];
    [self closeDb];
    return remain;
}
- (void)getReserveList:(id)delegate
                 count:(NSInteger)_count{
    NSString *_N46 = [NSString stringWithFormat:@"N46%@%@%06zd",[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue],[System sharedInstance].training,_count];
    [self writeAndRead:_N46
           requestType:RequestTypeReserveList
              delegate:delegate];

}
- (int)convertAndSaveReserveList:(NSString*)_msg
                            count:(NSInteger)_count{
    if (_count == 1) {
        [self openDb];
        [self.db beginTransaction];
        [self.db executeUpdate:@"DELETE FROM Reserve_DT"];
        [self.db commit];
        [self closeDb];
    }
    
    [self openDb];
    [self.db beginTransaction];
    int remain = [[self getShiftJisMid:_msg startPos:4 length:6]intValue];
    int count = [[self getShiftJisMid:_msg startPos:10 length:4]intValue];
    for (int ct = 0; ct < count; ct++) {
        NSString *s0 = [self getShiftJisMid:_msg startPos:ct * 57 + 14 +  0 length: 6];
        NSString *s1 = [NSString stringWithFormat:@"%@/%@/%@",
                        [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 6     length:4],
                        [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 6 + 4 length:2],
                        [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 6 + 6 length:2]
                        ];
        NSString *s2 = [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 14 length: 5];
        NSString *s3 = [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 19 length:20];
        NSString *s4 = [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 39 length:15];
        NSString *s5 = [self getShiftJisMid:_msg startPos:ct * 57 + 14 + 54 length: 3];
        [self.db executeUpdate:@"insert into Reserve_DT values (?, ?, ?, ?, ?, ?)",s0,s1,s2,s3,s4,s5];
    }
    [self.db commit];
    [self closeDb];
    return remain;
}


//2016-01-05 ueda ASTERISK
- (void)sendOrderNinzu:(id)delegate {
    DataList *dat = [DataList sharedInstance];
    NSMutableString *_msg = [[NSMutableString alloc]init];
    [_msg appendString:@"A27"];
    [_msg appendString:[self appendSpaceWithNum:[System sharedInstance].currentTanto[@"MstTantoCD"] totalLength:[System sharedInstance].staffCodeKetaStr.intValue]];
    [_msg appendString:[System sharedInstance].training];
    [_msg appendString:dat.currentVoucher[@"EdaNo"]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.manCount]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.womanCount]];
    [_msg appendString:[NSString stringWithFormat:@"%02zd",dat.childCount]];
    [self writeAndRead:_msg requestType:RequestTypeOrderNinzu delegate:delegate];
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

//2014-03-18 ueda for 漢字
- (NSString*)getShiftJisMid:(NSString*)orgStr startPos:(NSInteger)sp length:(NSInteger)lg{
    const char *s = [orgStr cStringUsingEncoding:kEnc];
    char *s1 = calloc(lg + 1,sizeof(char));
    strncpy(s1, s + sp, lg);
    //2015-06-02 ueda
    //s1[lg + 1] = '\0';
    NSString *retVal = [NSString stringWithCString:s1 encoding:kEnc];
    free(s1);
    return retVal;
}

@end
