//
//  OrderManager.m
//  Order
//
//  Created by koji kodama on 13/03/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "OrderManager.h"

#define   kTanto_MT @"MstTantoCD,TantoNM,CancelFLG,CheckFLG,Password,Special,OriginalFLG,AddFLG,DivideFLG,MoveFLG,VoidFLG,SectionCD"
#define   kTable_MT @"TableID,TableNo,status"
#define   kCate_MT @"PatternCD,MstCateCD,CateNM"
#define   kMenu_MT @"PatternCD,CateCD,DispOrder,SyohinCD,BNGFLG"
#define   kMenu_B1MT @"PatternCD,CateCD,PageNo,B1CateCD,DispOrder,SyohinCD,BNGFLG"
#define   kMenu_B2MT @"PatternCD,CateCD,PageNo,B1CateCD,B1PageNo,B2CateCD,DispOrder,SyohinCD"
#define   kSyohin_MT @"MstSyohinCD,HTDispNMU,HTDispNMM,HTDispNML,JikaFLG,SG1FLG,TrayStyle,Tanka,BNGTanka,KakeFLG,Kakeritsu,BFLG,CateNM,InfoFLG,Info"
#define   kSG1_MT @"SyohinCD,SG1ID,DispOrder,HTDispNM,GroupType,GroupCD,LimitCount"
#define   kSG2_MT @"SyohinCD,CondiGCD,CondiGDID,SG2ID,DispOrder,HTDispNM,GroupType,GroupCD,LimitCount"//Limit>LimitCount 使用不可のため
#define   kCondiGD_MT @"TopSyohinCD,CondiGCD,CondiGDID,DispOrder,SyohinCD,Multiple,SG2FLG"
#define   kCommentGD_MT @"CommentGCD,CommentGDID,DispOrder,CommentCD"
#define   kComment_MT @"MstCommentCD,HTDispNMU,HTDispNMM,HTDispNML"
#define   kOfferGD_MT @"OfferGCD,OfferCD"
#define   kOffer_MT @"MstOfferCD,DispOrder,HTDispNMU,HTDispNMM,HTDispNML"
#define   kNote_MT @"NoteID,HTDispNM"
#define   kKyakuso_MT @"KyakusoID,HTDispNM"
#define   kPattern_MT @"PatternID,HTDispNM"
//2014-07-16 ueda
#define   kColor_MT @"ColorID,ColorCD"
#define   kVoucherTop @"PatternCD,CateCD,EdaNo, SyohinCD,count,countDivide,Jika,trayNo"
#define   kVoucher1 @"TopSyohinCD, Sub1SyohinCD, CondiGCD, CondiGDID,GCD,CD, count ,countDivide,Jika,trayNo"
#define   kVoucher2 @"TopSyohinCD, Sub1SyohinCD, CondiGCD, CondiGDID,GCD,CD, count ,countDivide,Jika,trayNo"
#define   kArrange @"TopSyohinCD,Sub1SyohinCD, SyohinCD, count ,countDivide,Jika,PageNo,Layer,trayNo"

@implementation OrderManager

//#define SharedInstanceImplementation

static OrderManager* sharedInstance = nil;
/*
+ (id)sharedInstance {
    @synchronized(self) {
        [[self alloc] init];
    }
    return sharedInstance;
}
*/
+ (OrderManager *)sharedInstance
{
    //static OrderManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OrderManager alloc] init];
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

- (id)init{
    self = [super init];
    if (self) {
        currentPage = 0;
    }
    return self;
}

- (void)zeroReset {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    [_net.db beginTransaction];
    [_net.db executeUpdate:@"DELETE FROM VoucherTop"];
    [_net.db executeUpdate:@"DELETE FROM Voucher1"];
    [_net.db executeUpdate:@"DELETE FROM Voucher2"];
    [_net.db executeUpdate:@"DELETE FROM Arrange"];
    //2014-07-24 ueda 「autoincrement」の値をリセット
    [_net.db executeUpdate:@"delete from sqlite_sequence where name='VoucherTop'"];
    [_net.db commit];
    [_net closeDb];
}

//2014-10-02 ueda
- (void)zeroReset2 {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    [_net.db beginTransaction];
    [_net.db executeUpdate:@"DELETE FROM VoucherTop"];
    [_net.db executeUpdate:@"DELETE FROM Voucher1"];
    [_net.db executeUpdate:@"DELETE FROM Voucher2"];
    [_net.db executeUpdate:@"DELETE FROM Arrange"];
    [_net.db commit];
    [_net closeDb];
}

- (NSArray*)getCategoryList{

    System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Cate_MT WHERE PatternCD = ?",kCate_MT];
    //2016-03-15 ueda
/*
    FMResultSet *results = [_net.db executeQuery:table01,
                            sys.menuPatternType];
 */
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    FMResultSet *results = [_net.db executeQuery:table01,
                            menuPatternCD];
    int num = 0;
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        [_array addObject:_dic];
        num++;
    }
    [results close];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    return [self categoryListAddBlank:_array idKey:@"MstCateCD"];
}


- (NSArray*)getSubCategoryList:(NSMutableDictionary*)_dic{
    
    LOG(@"%@",_dic);
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = nil;
    BOOL isSub2 = NO;
    BOOL isFolder = NO;
    NSString *_idKey = nil;
    if ([[_dic allKeys] containsObject:@"SG2FLG"]) {
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM SG2_MT WHERE SyohinCD = ? and CondiGCD = ? and CondiGDID = ?",kSG2_MT];
        results = [_net.db executeQuery:table01,
                   _dic[@"TopSyohinCD"],
                   _dic[@"CondiGCD"],
                   _dic[@"CondiGDID"]
                   ];
        _idKey = @"SG2ID";
        isSub2 = YES;
    }
    else if([_dic[@"BFLG"]isEqualToString:@"1"]){
        return [self getFolderCategoryList:1];
    }
    else{
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM SG1_MT WHERE SyohinCD = ?",kSG1_MT];
        results = [_net.db executeQuery:table01,
                   _dic[@"SyohinCD"]];
        _idKey = @"SG1ID";
    }

    
    int num = 0;
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_cate = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_cate setValue:[results stringForColumn:column] forKey:column];
        }
        
        if (isSub2) {
            _cate[@"Sub1SyohinCD"] = _dic[@"SyohinCD"];
        }
        else if (isFolder) {
            _cate[@"Sub1SyohinCD"] = _dic[@"MstSyohinCD"];
        }
        else{
            _cate[@"Sub1SyohinCD"] = _cate[@"SyohinCD"];
        }
        [_array addObject:_cate];
        num++;
    }
    [results close];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    _array = [self categoryListAddBlank:_array idKey:_idKey];

    return _array;
}

- (NSMutableArray*)categoryListAddBlank:(NSArray*)array
                                 idKey:(NSString*)idKey{
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < array.count; ct++) {
        NSDictionary *dic = array[ct];
        LOG(@"%zd:%zd",[dic[idKey]intValue],result.count);
        if ([dic[idKey]intValue]!=result.count) {
            
            NSInteger sabun = [dic[idKey]intValue] - result.count;
            for (int count = 0; count < sabun; count++) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"MstSyohinCD": @"0",@"CateNM": @"",@"MstCateCD": @"0",@"PatternCD": @"9"}];
                [result addObject:dic];
            }
            [result addObject:dic];
        }
        else{
            [result addObject:dic];
        }
    }
    
    return result;
}


- (NSArray*)getFolderCategoryList:(NSInteger)layer{
 
    //メニューパターンのみを抽出する
    System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }

    FMResultSet *results = nil;
    if (layer==1) {
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Menu_MT WHERE PatternCD = ? and BNGFLG = 1",kMenu_MT];
        //2016-03-15 ueda
/*
        results = [_net.db executeQuery:table01,
                                sys.menuPatternType];
 */
        //2016-03-15 ueda
        results = [_net.db executeQuery:table01,
                   menuPatternCD];
    }
    else if(layer==2){
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Menu_B1MT WHERE PatternCD = ? and BNGFLG = 1",kMenu_B1MT];
        //2016-03-15 ueda
/*
        results = [_net.db executeQuery:table01,
                   sys.menuPatternType];
 */
        //2016-03-15 ueda
        results = [_net.db executeQuery:table01,
                   menuPatternCD];
    }

    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        
        //商品情報を追加する
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
        [syohin close];
        
        
        [_array addObject:_dic];
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    if ([_array count]>0) {
        //表示順を並び替える
        NSSortDescriptor *sortDispNo = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES] ;
        NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispNo, nil];
        NSArray *_temp = [[NSArray alloc]initWithArray:[_array sortedArrayUsingDescriptors:sortDescArray]];
        
        LOG(@"_temp:%@",_temp);
        
        return _temp;
    }
    return nil;
}

- (NSArray*)getArrangeCategoryList{

    System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Cate_MT WHERE PatternCD = 9",kCate_MT];
    //2016-03-15 ueda
/*
    FMResultSet *results = [_net.db executeQuery:table01,
                            sys.menuPatternType];
 */
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    FMResultSet *results = [_net.db executeQuery:table01,
                            menuPatternCD];
    int num = 0;
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        [_array addObject:_dic];
        num++;
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    if (_array.count > 0) {
        _array = [self categoryListAddBlank:_array idKey:@"MstCateCD"];
        LOG(@"_array:%@",_array);
        return _array;
    }
    else{
        return nil;
    }
}

- (NSArray*)getMenuList:(NSMutableDictionary*)dic{
    
    LOG(@"%@",dic);
    
    NSString *CateCD = @"";
    if ([[dic allKeys]containsObject:@"CateCD"]) {
        CateCD = dic[@"CateCD"];
    }
    else if ([[dic allKeys]containsObject:@"MstCateCD"]){
        CateCD = dic[@"MstCateCD"];
    }
    else{
        return nil;
    }
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    //[_net.db beginTransaction];
    
   
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Menu_MT WHERE PatternCD = ? and CateCD = ?",kMenu_MT];
    FMResultSet *results = [_net.db executeQuery:table01,
                            dic[@"PatternCD"],
                            CateCD
                            ];
    int num = 0;
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        
        
        //商品情報を追加する
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                                _dic[@"SyohinCD"]];
        
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
        [syohin close];
        
        
        //現在の個数を追加する
        FMResultSet *counts = nil;;
        if ([dic[@"PatternCD"] isEqualToString:@"9"]) {
            
            if (![[dic allKeys]containsObject:@"Sub1SyohinCD"]) {
                dic[@"Sub1SyohinCD"] = @"";
            }
            
            NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?",kArrange];
            counts = [_net.db executeQuery:table01,
                      dic[@"TopSyohinCD"],
                      dic[@"Sub1SyohinCD"],
                      _dic[@"SyohinCD"],
                      [NSString stringWithFormat:@"%zd",[DataList sharedInstance].ArrangeMenuPageNo+1],
                      [DataList sharedInstance].TrayNo
                      ];
            
        }
        else{
            NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM VoucherTop WHERE SyohinCD = ?",kVoucherTop];
            counts = [_net.db executeQuery:table01,
                      _dic[@"SyohinCD"]];
        }
        
        
        [counts next];
        if ([counts columnCount]!=0) {
            //_dic[@"id"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"id"]];
            _dic[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
            _dic[@"countDivide"] = [counts stringForColumn:@"countDivide"];
            _dic[@"Jika"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"Jika"]];
        }
        else{
            _dic[@"count"] = @"0";
            NSMutableArray *array = [NSMutableArray array];
            for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
                array[ct] = @"0";
            }
            _dic[@"countDivide"] = [array componentsJoinedByString:@","];
        }
        [counts close];
        
        [_array addObject:_dic];
        num++;
    }
    [results close];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    //2014-09-16 ueda
    if (([dic[@"PatternCD"] isEqualToString:@"9"]) && ([CateCD isEqualToString:@"9"])) {
        FMResultSet *rsMenuExt = [_net.db executeQuery:@"SELECT * FROM MenuExt_MT ORDER BY DispOrder "];
        while ([rsMenuExt next]) {
            NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [rsMenuExt columnCount]; ct++) {
                NSString *column = [rsMenuExt columnNameForIndex:ct];
                [_dic setValue:[rsMenuExt stringForColumn:column] forKey:column];
            }
            _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
            //商品マスターと同じような内容
            _dic[@"MstSyohinCD"] = _dic[@"SyohinCD"];
            _dic[@"Tanka"]       = @"0";
            _dic[@"KakeFLG"]     = @"0";
            _dic[@"JikaFLG"]     = @"0";
            _dic[@"InfoFLG"]     = @"0";
            _dic[@"SG1FLG"]      = @"0";
            _dic[@"Kakeritsu"]   = @"0";
            _dic[@"BFLG"]        = @"0";
            _dic[@"BNGTanka"]    = @"0";
            _dic[@"TrayStyle"]   = @"0";
            _dic[@"Info"]        = @"";
            
            //2014-09-30 ueda
            if (![[dic allKeys]containsObject:@"Sub1SyohinCD"]) {
                dic[@"Sub1SyohinCD"] = @"";
            }
            //現在の個数を追加する
            FMResultSet *counts = nil;;
            NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?",kArrange];
            counts = [_net.db executeQuery:table01,
                      dic[@"TopSyohinCD"],
                      dic[@"Sub1SyohinCD"],
                      _dic[@"SyohinCD"],
                      [NSString stringWithFormat:@"%zd",[DataList sharedInstance].ArrangeMenuPageNo+1],
                      [DataList sharedInstance].TrayNo
                      ];
            
            [counts next];
            if ([counts columnCount]!=0) {
                //_dic[@"id"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"id"]];
                _dic[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
                _dic[@"countDivide"] = [counts stringForColumn:@"countDivide"];
                _dic[@"Jika"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"Jika"]];
            }
            else{
                _dic[@"count"] = @"0";
                NSMutableArray *array = [NSMutableArray array];
                for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
                    array[ct] = @"0";
                }
                _dic[@"countDivide"] = [array componentsJoinedByString:@","];
            }
            [counts close];
            
            [_array addObject:_dic];
            num++;
        }
        [rsMenuExt close];
    }
    
    [_net closeDb];
    
    if ([_array count]>0) {
        //表示順を並び替える
        NSSortDescriptor *sortDispNo = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES] ;
        NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispNo, nil];
        NSArray *_temp = [[NSArray alloc]initWithArray:[_array sortedArrayUsingDescriptors:sortDescArray]];
        return _temp;
    }
    return nil;
}

- (NSArray*)getFolderMenuList:(NSString*)code
                       index1:(NSString*)index1
                       index2:(NSString*)index2
                        layer:(NSInteger)layer
                        page1:(NSInteger)page1
                        page2:(NSInteger)page2{
    
    LOG(@"%@:%@:%@:%zd:%zd",code,index1,index2,layer,page1);
    //メニューパターンのみを抽出する
    System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }

    FMResultSet *results = nil;
    if (layer==1) {
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Menu_B1MT WHERE PatternCD = ? and CateCD = ? and B1CateCD = ? and PageNo = ?",kMenu_B1MT];
        //2016-03-15 ueda
/*
        results = [_net.db executeQuery:table01,
                                sys.menuPatternType,
                                code,
                   index1,
                   [NSString stringWithFormat:@"%02zd",page1]];
 */
        //2016-03-15 ueda
        results = [_net.db executeQuery:table01,
                   menuPatternCD,
                   code,
                   index1,
                   [NSString stringWithFormat:@"%02zd",page1]];
    }
    else if(layer==2){

        //2016-03-15 ueda
/*
        results = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE PatternCD = ? and CateCD = ? and B1CateCD = ? and B2CateCD = ? and PageNo = ? and B1PageNo = ?",
                   sys.menuPatternType,
                   code,
                   index1,
                   index2,
                   [NSString stringWithFormat:@"%02zd",page1],
                   [NSString stringWithFormat:@"%02zd",page2]];
 */
        //2016-03-15 ueda
        results = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE PatternCD = ? and CateCD = ? and B1CateCD = ? and B2CateCD = ? and PageNo = ? and B1PageNo = ?",
                   menuPatternCD,
                   code,
                   index1,
                   index2,
                   [NSString stringWithFormat:@"%02zd",page1],
                   [NSString stringWithFormat:@"%02zd",page2]];
    }
    
    int num = 0;
    NSMutableArray *_array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        
        //商品情報を追加する
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
        [syohin close];
        
        
        //現在の個数を追加する
        NSString *table02 = [NSString stringWithFormat:@"SELECT %@ FROM VoucherTop WHERE SyohinCD = ?",kVoucherTop];
        FMResultSet *counts = [_net.db executeQuery:table02,
                               _dic[@"SyohinCD"]];
        
        
        [counts next];
        if ([counts columnCount]!=0) {
            _dic[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
            _dic[@"countDivide"] = [counts stringForColumn:@"countDivide"];
            _dic[@"Jika"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"Jika"]];
        }
        else{
            _dic[@"count"] = @"0";
            NSMutableArray *array = [NSMutableArray array];
            for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
                array[ct] = @"0";
            }
            _dic[@"countDivide"] = [array componentsJoinedByString:@","];
        }
        [counts close];
        
        
        [_array addObject:_dic];
        num++;
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    if ([_array count]>0) {
        //表示順を並び替える
        NSSortDescriptor *sortDispNo = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES] ;
        NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispNo, nil];
        NSArray *_temp = [[NSArray alloc]initWithArray:[_array sortedArrayUsingDescriptors:sortDescArray]];
        
        return _temp;
    }
    return nil;
}

- (NSArray*)getSubMenuList:(NSMutableDictionary*)_dic{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSMutableArray *_menuList = [[NSMutableArray alloc]init];
    
    if ([_dic[@"GroupType"] isEqualToString:@"1"]) {
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM CondiGD_MT WHERE TopSyohinCD = ? and CondiGCD = ?",kCondiGD_MT];
        FMResultSet *results = [_net.db executeQuery:table01,
                                _dic[@"SyohinCD"],
                                _dic[@"GroupCD"]];
        while([results next])
        {
            NSMutableDictionary *_menu = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [results columnCount]; ct++) {
                NSString *column = [results columnNameForIndex:ct];
                [_menu setValue:[results stringForColumn:column] forKey:column];
            }
            
            NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
            FMResultSet *syohin = [_net.db executeQuery:table01,
                                   _menu[@"SyohinCD"]];
            [syohin next];
            for (int ct = 0; ct < [syohin columnCount]; ct++) {
                NSString *column = [syohin columnNameForIndex:ct];
                [_menu setValue:[syohin stringForColumn:column] forKey:column];
            }
            _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
            [syohin close];
            
            //データの追加とカラム名を変更する
            _menu[@"TopSyohinCD"] = _dic[@"SyohinCD"];
            
            _menu[@"GCD"] = _menu[@"CondiGCD"];
            _menu[@"CD"] = _menu[@"CondiGDID"];
            if (_dic[@"CondiGCD"]) {
                _menu[@"CondiGCD"] = _dic[@"CondiGCD"];
                _menu[@"CondiGDID"] = _dic[@"CondiGDID"];
            }
            
            [self appendCurrentCount:_dic _menu:_menu];
            
            [_menuList addObject:_menu];
        }
        [results close];
    }
    else if ([_dic[@"GroupType"] isEqualToString:@"2"]){
        
        LOG(@"2");
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM CommentGD_MT WHERE CommentGCD = ?",kCommentGD_MT];
        FMResultSet *results = [_net.db executeQuery:table01,
                                _dic[@"GroupCD"]];
        while([results next])
        {
            NSMutableDictionary *_menu = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [results columnCount]; ct++) {
                NSString *column = [results columnNameForIndex:ct];
                [_menu setValue:[results stringForColumn:column] forKey:column];
            }
            
            NSString *table02 = [NSString stringWithFormat:@"SELECT %@ FROM Comment_MT WHERE MstCommentCD = ?",kComment_MT];
            FMResultSet *syohin = [_net.db executeQuery:table02,
                                   _menu[@"CommentCD"]];
            [syohin next];
            for (int ct = 0; ct < [syohin columnCount]; ct++) {
                NSString *column = [syohin columnNameForIndex:ct];
                [_menu setValue:[syohin stringForColumn:column] forKey:column];
            }
            _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
            [syohin close];
            
            
            //データの追加とカラム名を変更する
            _menu[@"TopSyohinCD"] = _dic[@"SyohinCD"];
            _menu[@"GCD"] = _menu[@"CommentGCD"];
            _menu[@"CD"] = _menu[@"CommentGDID"];
            
            if (_dic[@"CondiGCD"]) {
                _menu[@"CondiGCD"] = _dic[@"CondiGCD"];
                _menu[@"CondiGDID"] = _dic[@"CondiGDID"];
            }
            
            [self appendCurrentCount:_dic _menu:_menu];
            
            [_menuList addObject:_menu];
        }
        [results close];
    }
    else if ([_dic[@"GroupType"] isEqualToString:@"3"]){
        
        LOG(@"3");
        
        NSString *cd = [_dic[@"GroupCD"] stringByTrimmingCharactersInSet:
                                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM OfferGD_MT WHERE OfferGCD = ?",kOfferGD_MT];
        FMResultSet *results = [_net.db executeQuery:table01,
                                cd];
        while([results next])
        {
            NSMutableDictionary *_menu = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [results columnCount]; ct++) {
                NSString *column = [results columnNameForIndex:ct];
                [_menu setValue:[results stringForColumn:column] forKey:column];
            }
            NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Offer_MT WHERE MstOfferCD = ?",kOffer_MT];
            FMResultSet *syohin = [_net.db executeQuery:table01,
                                   _menu[@"OfferCD"]];
            [syohin next];
            for (int ct = 0; ct < [syohin columnCount]; ct++) {
                NSString *column = [syohin columnNameForIndex:ct];
                [_menu setValue:[syohin stringForColumn:column] forKey:column];
            }
            _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
            [syohin close];
            
            
            //データの追加とカラム名を変更する
            _menu[@"TopSyohinCD"] = _dic[@"SyohinCD"];
            _menu[@"GCD"] = _menu[@"OfferGCD"];
            _menu[@"CD"] = _menu[@"OfferCD"];
            
            if (_dic[@"CondiGCD"]) {
                _menu[@"CondiGCD"] = _dic[@"CondiGCD"];
                _menu[@"CondiGDID"] = _dic[@"CondiGDID"];
            }
            
            [self appendCurrentCount:_dic _menu:_menu];
            
            [_menuList addObject:_menu];
        }
        [results close];
    }
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    if ([_menuList count]>0) {
        //表示順を並び替える
        NSSortDescriptor *sortDispNo = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES] ;
        NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispNo, nil];
        NSArray *_temp = [[NSArray alloc]initWithArray:[_menuList sortedArrayUsingDescriptors:sortDescArray]];
        
        //LOG(@"%@",_temp);
        
        if([_dic[@"GroupType"] isEqualToString:@"3"]) {
            _temp = [self subMenuListAddBlank:_temp idKey:@"DispOrder"];
        }

        return _temp;
    }
    return nil;
}

- (NSMutableArray*)subMenuListAddBlank:(NSArray*)array
                                  idKey:(NSString*)idKey{
    
    NSMutableArray *result = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < array.count; ct++) {
        NSDictionary *dic = array[ct];
        LOG(@"%zd:%zd",[dic[idKey]intValue],result.count+1);
        if ([dic[idKey]intValue]!=result.count+1) {
            
            NSInteger sabun = [dic[idKey]intValue] - (result.count+1);
            for (int count = 0; count < sabun; count++) {
                NSMutableDictionary *dic = [[NSMutableDictionary alloc]initWithDictionary:@{@"MstSyohinCD": @"0",@"count": @"0",@"countDivide": @"0"}];
                [result addObject:dic];
            }
            [result addObject:dic];
        }
        else{
            [result addObject:dic];
        }
    }
    
    return result;
}

- (NSMutableDictionary*)appendCurrentCount:(NSMutableDictionary*)_dic
                                     _menu:(NSMutableDictionary*)_menu{
    
    //LOG(@"%@\n%@\n%@",_dic,_menu,[DataList sharedInstance].TrayNo);
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    
    [_net openDb];
    
    FMResultSet *counts = nil;
    if ([[_dic allKeys] containsObject:@"SG1ID"]) {
        //Sub1SyohinCDを追加する
        if ([[_menu allKeys]containsObject:@"SyohinCD"]) {
            _menu[@"Sub1SyohinCD"] = _menu[@"SyohinCD"];
        }
        else{
            _menu[@"Sub1SyohinCD"] = @"";
        }
        //2015-02-10 ueda
/*
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Voucher1 WHERE TopSyohinCD = ? and CD = ? and GCD = ? and trayNo = ?",kVoucher1];
        counts = [_net.db executeQuery:table01 ,
                  _menu[@"TopSyohinCD"],
                  _menu[@"CD"],
                  _menu[@"GCD"],
                  [DataList sharedInstance].TrayNo
                  ];
 */
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Voucher1 WHERE TopSyohinCD = ? and Sub1SyohinCD = ? and CD = ? and GCD = ? and trayNo = ?",kVoucher1];
        counts = [_net.db executeQuery:table01 ,
                  _menu[@"TopSyohinCD"],
                  _menu[@"Sub1SyohinCD"],
                  _menu[@"CD"],
                  _menu[@"GCD"],
                  [DataList sharedInstance].TrayNo
                  ];
    }
    else if ([[_dic allKeys] containsObject:@"SG2ID"]){
        //Sub1SyohinCDを追加する
        _menu[@"Sub1SyohinCD"] = _dic[@"Sub1SyohinCD"];
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Voucher2 WHERE TopSyohinCD = ? and Sub1SyohinCD = ? and CD = ? and GCD = ? and trayNo = ?",kVoucher2];
        counts = [_net.db executeQuery:table01 ,
                  _menu[@"TopSyohinCD"],
                  _menu[@"Sub1SyohinCD"],
                  _menu[@"CD"],
                  _menu[@"GCD"],
                  [DataList sharedInstance].TrayNo
                  ];
    }
    
    
    [counts next];
    if ([counts columnCount]!=0) {
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
        _menu[@"countDivide"] = [counts stringForColumn:@"countDivide"];
        _menu[@"trayNo"] = [counts stringForColumn:@"trayNo"];
    }
    else{
        _menu[@"count"] = @"0";
        //_menu[@"countDivide"] = @"0";
        
        NSMutableArray *array = [NSMutableArray array];
        for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
            array[ct] = @"0";
        }
        _menu[@"countDivide"] = [array componentsJoinedByString:@","];
    }
    [counts close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return _menu;
}

- (NSMutableDictionary*)getCategory:(NSString*)CateCD{
    System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Cate_MT WHERE PatternCD = ? and MstCateCD = ?",kCate_MT];
    //2016-03-15 ueda
/*
    FMResultSet *results = [_net.db executeQuery:table01,
                            sys.menuPatternType,CateCD];
 */
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    FMResultSet *results = [_net.db executeQuery:table01,
                            menuPatternCD,CateCD];

    [results next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_dic setValue:[results stringForColumn:column] forKey:column];
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    return _dic;
}

- (NSMutableDictionary*)getSubCategory:(NSString*)SyohinCD
                              CondiGDID:(NSString*)CondiGDID{

    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = nil;
    //BOOL isSub2 = NO;
    if (CondiGDID) {
        results = [_net.db executeQuery:@"SELECT * FROM SG2_MT WHERE SyohinCD = ? and CondiGDID = ?",
                   SyohinCD,
                   CondiGDID];
        //isSub2 = YES;
    }
    else{
        results = [_net.db executeQuery:@"SELECT * FROM SG1_MT WHERE SyohinCD = ?",
                   SyohinCD];
    }
    
    [results next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_dic setValue:[results stringForColumn:column] forKey:column];
    }
    
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    return _dic;
}

- (NSMutableDictionary*)getSub2Category:(NSString*)SyohinCD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM SG2_MT WHERE SyohinCD = ?",
                            SyohinCD];
    
    [results next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_dic setValue:[results stringForColumn:column] forKey:column];
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    return _dic;
}

- (NSMutableDictionary*)getMenuForCancel:(NSString*)SyohinCD{
    
    //メニューパターンのみを抽出する
    //System *sys = [System sharedInstance];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    BOOL isEnableData = NO;

    //2016-03-15 ueda
/*
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE SyohinCD = ?",
                            SyohinCD];
 */
    //2016-03-15 ueda
    System *sys = [System sharedInstance];
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = ? and SyohinCD = ?",
                            menuPatternCD, SyohinCD];
    [results next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_dic setValue:[results stringForColumn:column] forKey:column];
        isEnableData = YES;
    }
    [results close];
    

    //アレンジ商品
    if (!isEnableData) {
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = 9 and SyohinCD = ?",
                                SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }

    
    //2014-09-17 ueda
    if (!isEnableData) {
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM MenuExt_MT WHERE PatternCD = 9 and SyohinCD = ?",
                                 SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }
    
    
    //フォルダ商品
    if (!isEnableData) {

        //2016-03-15 ueda
/*
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE SyohinCD = ?",
                                 SyohinCD];
 */
        //2016-03-15 ueda
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE PatternCD = ? and SyohinCD = ?",
                                 menuPatternCD, SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }

    
    
    //コンディメント商品
    if (!isEnableData) {
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM CondiGD_MT WHERE SyohinCD = ?",
                                 SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }
    
    
    if (!isEnableData) {
 
        //2016-03-15 ueda
/*
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE SyohinCD = ?",
                                 SyohinCD];
 */
        //2016-03-15 ueda
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE PatternCD = ? and SyohinCD = ?",
                                 menuPatternCD, SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }
    
    
    //サブグループ1商品
    if (!isEnableData) {
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM SG1_MT WHERE SyohinCD = ?",
                                 SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            isEnableData = YES;
        }
        [results2 close];
    }
    
    //サブグループ2商品
    if (!isEnableData) {
        FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM SG2_MT WHERE SyohinCD = ?",
                                 SyohinCD];
        [results2 next];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
            //isEnableData = YES;
        }
        [results2 close];
    }
    

    
    //商品情報を追加する
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
    FMResultSet *syohin = [_net.db executeQuery:table01,
                           SyohinCD];
    [syohin next];
    for (int ct = 0; ct < [syohin columnCount]; ct++) {
        NSString *column = [syohin columnNameForIndex:ct];
        [_dic setValue:[syohin stringForColumn:column] forKey:column];
    }
    _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
    [syohin close];
    
    //2014-09-17 ueda
    if ([[SyohinCD substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
        //商品マスターと同じような内容
        _dic[@"MstSyohinCD"] = SyohinCD;
        _dic[@"Tanka"]       = @"0";
        _dic[@"KakeFLG"]     = @"0";
        _dic[@"JikaFLG"]     = @"0";
        _dic[@"InfoFLG"]     = @"0";
        _dic[@"SG1FLG"]      = @"0";
        _dic[@"Kakeritsu"]   = @"0";
        _dic[@"BFLG"]        = @"0";
        _dic[@"BNGTanka"]    = @"0";
        _dic[@"TrayStyle"]   = @"0";
        _dic[@"Info"]        = @"";
    }
    
    //現在の個数を追加する
    FMResultSet *counts = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE SyohinCD = ?",
                           _dic[@"SyohinCD"]];
    [counts next];
    if ([counts columnCount]!=0) {
        _dic[@"id"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"id"]];
        _dic[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
        _dic[@"countDivide"] = [counts stringForColumn:@"countDivide"];
        _dic[@"Jika"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"Jika"]];
    }
    else{
        _dic[@"count"] = @"0";
        NSMutableArray *array = [NSMutableArray array];
        for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
            array[ct] = @"0";
        }
        _dic[@"countDivide"] = [array componentsJoinedByString:@","];
    }
    [counts close];
    
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    return _dic;
}

- (NSMutableDictionary*)getMenu:(NSString*)SyohinCD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    
    //商品情報を追加する
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
    FMResultSet *syohin = [_net.db executeQuery:table01,
                           SyohinCD];
    [syohin next];
    for (int ct = 0; ct < [syohin columnCount]; ct++) {
        NSString *column = [syohin columnNameForIndex:ct];
        [_dic setValue:[syohin stringForColumn:column] forKey:column];
    }
    _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
    [syohin close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return _dic;
}

- (NSMutableDictionary*)getCondi:(NSString*)CD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CondiGD_MT WHERE CondiGDID = ? ",
                            CD];
    [results next];
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_dic setValue:[results stringForColumn:column] forKey:column];
    }
    [results close];
    
    
    NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
    FMResultSet *syohin = [_net.db executeQuery:table01,
                           _dic[@"SyohinCD"]];
    
    [syohin next];
    for (int ct = 0; ct < [syohin columnCount]; ct++) {
        NSString *column = [syohin columnNameForIndex:ct];
        [_dic setValue:[syohin stringForColumn:column] forKey:column];
    }
    _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
    [syohin close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return _dic;
}

- (NSMutableDictionary*)getComment:(NSString*)CD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    
    FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Comment_MT WHERE MstCommentCD = ?",
                           [self appendSpace:CD totalLength:4]];
    [syohin next];
    for (int ct = 0; ct < [syohin columnCount]; ct++) {
        NSString *column = [syohin columnNameForIndex:ct];
        [_dic setValue:[syohin stringForColumn:column] forKey:column];
    }
    _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
    [syohin close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return _dic;
}

- (NSMutableDictionary*)getOffer:(NSString*)CD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
    FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Offer_MT WHERE MstOfferCD = ?",
                           CD];
    [syohin next];
    for (int ct = 0; ct < [syohin columnCount]; ct++) {
        NSString *column = [syohin columnNameForIndex:ct];
        [_dic setValue:[syohin stringForColumn:column] forKey:column];
    }
    _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
    [syohin close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return _dic;
}

- (NSMutableDictionary*)getSubMenu:(NSString*)TopSyohinCD
                          GroupType:(NSString*)GroupType
                            GroupCD:(NSString*)GroupCD
                          CondiGDID:(NSString*)CondiGDID
                                 SG:(int)SG{
    
    //Note:トレイ番号を追加する
    
    LOG(@"TopSyohinCD:%@",TopSyohinCD);
     LOG(@"GroupType:%@",GroupType);
     LOG(@"GroupCD:%@",GroupCD);
     LOG(@"CondiGDID:%@",CondiGDID);
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSMutableDictionary *_menu = [[NSMutableDictionary alloc]init];
    
    
    if ([GroupType isEqualToString:@"1"]) {
        FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CondiGD_MT WHERE TopSyohinCD = ? and CondiGCD = ? and CondiGDID = ?",
                                TopSyohinCD,
                                GroupCD,
                                CondiGDID];
        
        [results next];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_menu setValue:[results stringForColumn:column] forKey:column];
        }
        [results close];
        
        LOG(@"%@",_menu);
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _menu[@"SyohinCD"]];
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_menu setValue:[syohin stringForColumn:column] forKey:column];
        }
        _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
        [syohin close];
        
        //データの追加とカラム名を変更する
        _menu[@"TopSyohinCD"] = TopSyohinCD;
        _menu[@"GCD"] = _menu[@"CondiGCD"];
        _menu[@"CD"] = _menu[@"CondiGDID"];
    }
    else if ([GroupType isEqualToString:@"2"]) {
        FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CommentGD_MT WHERE CommentGCD = ? and CommentGDID = ?",
                                GroupCD,
                                CondiGDID];
        
        [results next];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_menu setValue:[results stringForColumn:column] forKey:column];
        }
        [results close];
        
        FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Comment_MT WHERE MstCommentCD = ?",
                               _menu[@"CommentCD"]];
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_menu setValue:[syohin stringForColumn:column] forKey:column];
        }
        _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
        [syohin close];
        
        //データの追加とカラム名を変更する
        _menu[@"TopSyohinCD"] = TopSyohinCD;
        _menu[@"GCD"] = _menu[@"CommentGCD"];
        _menu[@"CD"] = _menu[@"CommentGDID"];

    }
    else if ([GroupType isEqualToString:@"3"]) {
        NSString *gcd = [GroupCD stringByTrimmingCharactersInSet:
                        [NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *cd = [CondiGDID substringFromIndex:3];
        FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM OfferGD_MT WHERE OfferGCD = ? and OfferCD = ?",
                                gcd,
                                cd];
        
        [results next];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_menu setValue:[results stringForColumn:column] forKey:column];
        }
        [results close];
        
        LOG(@"_menu1:%@",_menu);
        
        FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Offer_MT WHERE MstOfferCD = ?",
                               _menu[@"OfferCD"]];
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_menu setValue:[syohin stringForColumn:column] forKey:column];
        }
        _menu[@"DispOrder"] = [NSNumber numberWithInt:[_menu[@"DispOrder"] intValue]];
        [syohin close];
        
        LOG(@"_menu1:%@",_menu);
        
        //データの追加とカラム名を変更する
        _menu[@"TopSyohinCD"] = TopSyohinCD;
        _menu[@"GCD"] = _menu[@"OfferGCD"];
        _menu[@"CD"] = _menu[@"OfferCD"];
    }
    
    
    //現在の個数を追加する
    FMResultSet *counts = nil;
    if (SG==1) {
        counts = [_net.db executeQuery:@"SELECT * FROM Voucher1 WHERE TopSyohinCD = ? and Sub1SyohinCD = ? and CondiGDID = ? and CondiGCD = ? and trayNo = ?" ,
                  _menu[@"TopSyohinCD"],
                  _menu[@"SyohinCD"],
                  _menu[@"CondiGDID"],
                  _menu[@"CondiGCD"],
                  _menu[@"trayNo"]
                  ];
    }
    else{
        counts = [_net.db executeQuery:@"SELECT * FROM Voucher2 WHERE TopSyohinCD = ? and Sub1SyohinCD = ? and CondiGDID = ? and CondiGCD = ? and trayNo = ?" ,
                  _menu[@"TopSyohinCD"],
                  _menu[@"SyohinCD"],
                  _menu[@"CondiGDID"],
                  _menu[@"CondiGCD"],
                  _menu[@"trayNo"]
                  ];
    }

    [counts next];
    for (int ct = 0; ct < [counts columnCount]; ct++) {
        NSString *column = [counts columnNameForIndex:ct];
        [_menu setValue:[counts stringForColumn:column] forKey:column];
    }
    
    if ([counts columnCount]!=0) {
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
        _menu[@"countDivide"] = [counts stringForColumn:@"countDivide"];
    }
    else{
        _menu[@"count"] = @"0";
        //_menu[@"countDivide"] = @"0";
        
        NSMutableArray *array = [NSMutableArray array];
        for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
            array[ct] = @"0";
        }
        _menu[@"countDivide"] = [array componentsJoinedByString:@","];
    }
    [counts close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    return _menu;
}

- (NSMutableDictionary*)reloadMenu:(NSMutableDictionary*)_menu{
    LOG(@"%@",_menu);
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];

    FMResultSet *counts = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE SyohinCD = ?",
                           _menu[@"SyohinCD"]];
    [counts next];
    if ([counts columnCount]!=0) {
        _menu[@"count"] = [NSString stringWithFormat:@"%d",[counts intForColumn:@"count"]];
        _menu[@"countDivide"] = [counts stringForColumn:@"countDivide"];
    }
    else{
        _menu[@"count"] = @"0";
        //_menu[@"countDivide"] = @"0";
        
        NSMutableArray *array = [NSMutableArray array];
        for (int ct = 0; ct<[DataList sharedInstance].dividePage+1; ct++) {
            array[ct] = @"0";
        }
        _menu[@"countDivide"] = [array componentsJoinedByString:@","];
    }
    [counts close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    return _menu;
}

- (NSInteger)getTrayTotal:(NSString*)SyohinCD{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSUInteger count = [_net.db intForQuery:@"SELECT count(id) FROM VoucherTop where SyohinCD = ?",SyohinCD];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    return count;
}

//2016-02-02 ueda
- (NSInteger)getTrayTotalTypeC:(NSString*)SyohinCD
                    SeatNumber:(NSString*)SeatNumber
                     OrderType:(NSString*)OrderType {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSUInteger count = [_net.db intForQuery:@"SELECT count(id) FROM VoucherTopTypeC where SyohinCD = ? AND SeatNumber = ? AND OrderType = ?",SyohinCD,SeatNumber,OrderType];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    return count;
}

//2015-10-28 ueda
//- (NSInteger)getTrayTotalForCancel:(NSString*)SyohinCD

- (NSInteger)getTrayTotalForCancel:(NSString*)SyohinCD
                             EdaNo:(NSString*)EdaNo{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    //2015-10-28 ueda
    //NSUInteger count = [_net.db intForQuery:@"SELECT count(id) FROM VoucherTop where SyohinCD = ? and countDivide > 0",SyohinCD];
    NSUInteger count = [_net.db intForQuery:@"SELECT count(id) FROM VoucherTop where SyohinCD = ? and countDivide > 0 and EdaNo = ?",SyohinCD,EdaNo];
    [_net closeDb];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    return count;
}

- (NSArray*)getTrayList:(NSString*)SyohinCD{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE SyohinCD = ?",
                           SyohinCD];
    
    NSMutableArray *_menuTop = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [_menuTop addObject:_dic];
    }
    [results close];
    
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    [_net closeDb];
    
    LOG(@"%@",_menuTop);
    
    return _menuTop;
}

- (void)addTopMenu:(NSMutableDictionary*)_menu{
    
    LOG(@"_menu:%@",_menu);
    
    _menu = [[NSMutableDictionary alloc]initWithDictionary:_menu];
    
    
    if (![[_menu allKeys]containsObject:@"trayNo"]) {
        _menu[@"trayNo"] = @"00";
    }
    //2015-07-23 ueda
    if (![[_menu allKeys]containsObject:@"EdaNo"]) {
        _menu[@"EdaNo"] = @"00";
    }

    NSString *_str = nil;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //2015-07-21 ueda
    NSUInteger count = [_net.db intForQuery:@"SELECT count(id) FROM VoucherTop where PatternCD = ? and SyohinCD = ? and EdaNo = ? and trayNo = ?",
                        _menu[@"PatternCD"],
                        _menu[@"SyohinCD"],
                        _menu[@"EdaNo"],    //2015-07-21 ueda
                        _menu[@"trayNo"]
                        ];
    

    
    //書き込み
    BOOL isDelete = NO;
    BOOL isUpdate = NO;
    if (count>0&&[_menu[@"count"]intValue]!=0) {
        //2015-07-21 ueda
        _str =  @"update VoucherTop set PatternCD = ? ,SyohinCD = ? ,count = ? ,countDivide = ? ,Jika = ? where PatternCD = ? and SyohinCD = ? and EdaNo = ? and trayNo = ?";
        [_net.db executeUpdate:_str,
         _menu[@"PatternCD"],
         _menu[@"SyohinCD"],
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"Jika"],
         _menu[@"PatternCD"],
         _menu[@"SyohinCD"],
         _menu[@"EdaNo"],    //2015-07-21 ueda
         _menu[@"trayNo"]
         ];
        isUpdate = YES;
    }
    else if([_menu[@"count"]intValue]==0){
        //2015-07-21 ueda
        _str =  @"DELETE FROM VoucherTop where PatternCD = ? and SyohinCD = ? and EdaNo = ? and trayNo = ?";
        [_net.db executeUpdate:_str,
         _menu[@"PatternCD"],
         _menu[@"SyohinCD"],
         _menu[@"EdaNo"],    //2015-07-21 ueda
         _menu[@"trayNo"]
         ];
        isDelete = YES;
    }
    else{
        //2014-08-19 ueda
        //_str = @"INSERT INTO VoucherTop (PatternCD,SyohinCD,count,countDivide,Jika,trayNo) VALUES (?,?,?,?,?,?)";
        _str = @"INSERT INTO VoucherTop (PatternCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo) VALUES (?,?,?,?,?,?,?)";
        [_net.db executeUpdate:_str,
         _menu[@"PatternCD"],
         _menu[@"EdaNo"], //2014-08-18 ueda
         _menu[@"SyohinCD"],
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"Jika"],
         _menu[@"trayNo"]
         ];
    }    
    
    LOG(@"%@",_str);
    
    if ([_net.db hadError]) {
        NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    if (isDelete) {
        
        LOG(@"削除");
        
        [_net openDb];
        
        //Note:シングルトレイ
        [_net.db executeUpdate:@"DELETE FROM Voucher1 where TopSyohinCD = ?  and trayNo = ?",_menu[@"SyohinCD"],_menu[@"trayNo"]];
        [_net.db executeUpdate:@"DELETE FROM Voucher2 where TopSyohinCD = ?  and trayNo = ?",_menu[@"SyohinCD"],_menu[@"trayNo"]];
        [_net.db executeUpdate:@"DELETE FROM Arrange where TopSyohinCD = ?  and PageNo = ?",_menu[@"SyohinCD"],
         [NSString stringWithFormat:@"%d",[_menu[@"trayNo"]intValue]]];

        if ([_net.db hadError]) {
            NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
        }
        
        if ([_menu[@"TrayStyle"]isEqualToString:@"1"]) {

            NSArray *trayList = [self getTrayList:_menu[@"SyohinCD"]];
            for (int ct = 0; ct < trayList.count; ct++) {
                
                [_net openDb];
                
                NSString *trayNo = trayList[ct][@"trayNo"];
                
                NSString *v0 =  @"update VoucherTop set trayNo = ? where SyohinCD = ?  and trayNo = ?";
                [_net.db executeUpdate:v0,
                 [NSString stringWithFormat:@"%02d",ct+1],
                 _menu[@"SyohinCD"],
                 trayNo
                 ];
                
                NSString *v1 =  @"update Voucher1 set trayNo = ? where TopSyohinCD = ?  and trayNo = ?";
                [_net.db executeUpdate:v1,
                 [NSString stringWithFormat:@"%02d",ct+1],
                 _menu[@"SyohinCD"],
                 trayNo
                 ];
                
                NSString *v2 =  @"update Voucher2 set trayNo = ? where TopSyohinCD = ?  and trayNo = ?";
                [_net.db executeUpdate:v2,
                 [NSString stringWithFormat:@"%02d",ct+1],
                 _menu[@"SyohinCD"],
                 trayNo
                 ];
                
                NSString *ar =  @"update Arrange set trayNo = ? where TopSyohinCD = ? and trayNo = ?";
                [_net.db executeUpdate:ar,
                 [NSString stringWithFormat:@"%02d",ct+1],
                 _menu[@"SyohinCD"],
                 trayNo
                 ];
                
                
                if ([_net.db hadError]) {
                    NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
                }
            }
        }
        
        
        if ([DataList sharedInstance].ArrangeMenuPageNo!=9999) {
            NSString *no = [NSString stringWithFormat:@"%zd",[DataList sharedInstance].ArrangeMenuPageNo+1];
            [_net.db executeUpdate:@"DELETE FROM Arrange where TopSyohinCD = ? and PageNo = ?",_menu[@"SyohinCD"],no];
        }
        else{
            [_net.db executeUpdate:@"DELETE FROM Arrange where TopSyohinCD = ?",_menu[@"SyohinCD"]];
        }
        
        if ([_net.db hadError]) {
            LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
        }

    }
    else if(isUpdate){
        
        LOG(@"更新");

        //SGメニューの場合
        if ([_menu[@"SG1FLG"] isEqualToString:@"1"]){
            
            //シングルトレイの場合は同じトレイをカウントアップする
            NSString *trayNo = _menu[@"trayNo"];
            if (trayNo&&[trayNo intValue]>0) {
                
                [_net openDb];
                
                //2015-07-21 ueda
                NSString *v1 =  @"update Voucher1 set countDivide = ? where TopSyohinCD = ? and EdaNo = ? and trayNo = ?";
                [_net.db executeUpdate:v1,
                 _menu[@"countDivide"],
                 _menu[@"SyohinCD"],
                 _menu[@"EdaNo"],   //2015-07-21 ueda
                 trayNo
                 ];
                
                //2015-07-21 ueda
                NSString *v2 =  @"update Voucher2 set countDivide = ? where TopSyohinCD = ? and EdaNo = ? and trayNo = ?";
                [_net.db executeUpdate:v2,
                 _menu[@"countDivide"],
                 _menu[@"SyohinCD"],
                 _menu[@"EdaNo"],   //2015-07-21 ueda
                 trayNo
                 ];
                
                
                if ([_menu[@"countDivide"]intValue]==0) {
                    //親商品アレンジ
                    //2016-02-02 ueda
                    NSString *ar =  @"update Arrange set countDivide = 0 where TopSyohinCD = ?  and Sub1SyohinCD = ?  and pageNo = ? AND EdaNo = ?";
                    [_net.db executeUpdate:ar,
                     _menu[@"SyohinCD"],
                     @"",
                     [NSString stringWithFormat:@"%d",[trayNo intValue]],
                     _menu[@"EdaNo"]    //2016-02-01 ueda
                     ];
                    
                    //第一階層アレンジ
                    //2016-02-02 ueda
                    NSString *ar2 =  @"update Arrange set countDivide = 0 where TopSyohinCD = ? and Sub1SyohinCD > 0 and trayNo = ? AND EdaNo = ?";
                    [_net.db executeUpdate:ar2,
                     _menu[@"SyohinCD"],
                     trayNo,
                     _menu[@"EdaNo"]    //2016-02-02 ueda
                     ];
                }
                else{
                    //親商品アレンジ
                    //2016-02-02 ueda
                    NSString *ar =  @"update Arrange set countDivide = count where TopSyohinCD = ?  and Sub1SyohinCD = ?  and PageNo = ? AND EdaNo = ?";
                    [_net.db executeUpdate:ar,
                     _menu[@"SyohinCD"],
                     @"",
                     [NSString stringWithFormat:@"%d",[trayNo intValue]],
                     _menu[@"EdaNo"]    //2016-02-02 ueda
                     ];
                    
                    //第一階層アレンジ
                    //2016-02-02 ueda
                    NSString *ar2 =  @"update Arrange set countDivide = count where TopSyohinCD = ? and Sub1SyohinCD > 0 and trayNo = ? AND EdaNo = ?";
                    [_net.db executeUpdate:ar2,
                     _menu[@"SyohinCD"],
                     trayNo,
                     _menu[@"EdaNo"]    //2016-02-02 ueda
                     ];
                }
            }
        }
        
        if ([_net.db hadError]) {
            LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
        }
        
        
        //SGメニューの場合はノンセレクト商品の判定を行う
        [self addsub1Automatic:_menu];
    }
    else{
        
        if ([_net.db hadError]) {
            LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
        }
        
        //SGメニューの場合はノンセレクト商品の判定を行う
        [self addsub1Automatic:_menu];
    }
}


- (void)addsub1Automatic:(NSMutableDictionary*)_menu{

    NSArray *_sub1CateList = [self getSubCategoryList:_menu];
    for (int ct = 0; ct < [_sub1CateList count]; ct++) {
        NSMutableDictionary *_sub1Cate = [_sub1CateList objectAtIndex:ct];
        
        if ([_sub1Cate[@"LimitCount"] isEqualToString:@"5"]) {//ノンセレクト商品かの判定
            NSArray *_sub1List  = [self getSubMenuList:_sub1Cate];
            for (int ct1 = 0; ct1 < [_sub1List count]; ct1++) {
                NSMutableDictionary *_sub1 = [_sub1List objectAtIndex:ct1];
                
                if (![self keppinCheck:_sub1[@"SyohinCD"]]) {
                    //2015-01-05 ueda
                    if ([_sub1.allKeys containsObject:@"Multiple"]) {
                        int count = [_menu[@"count"]intValue]*[_sub1[@"Multiple"]intValue];
                        _sub1[@"count"] = [NSString stringWithFormat:@"%d",count];
                    } else {
                        _sub1[@"count"] = _menu[@"count"];
                    }
                    
                    NSArray *divide = [_menu[@"countDivide"]  componentsSeparatedByString:@","];
                    NSMutableArray *divideM = [NSMutableArray arrayWithArray:divide];
                    for (int ct2 = 0;ct2 < divideM.count ; ct2++) {
                        //2015-01-05 ueda
                        if ([_sub1.allKeys containsObject:@"Multiple"]) {
                            int divideC = [divideM[ct2] intValue]*[_sub1[@"Multiple"]intValue];
                            divideM[ct2] = [NSString stringWithFormat:@"%d",divideC];
                        }
                    }
                    _sub1[@"countDivide"] = [divideM componentsJoinedByString:@","];;
                    _sub1[@"trayNo"] = _menu[@"trayNo"];
                    //2015-01-05 ueda
                    if ([_menu.allKeys containsObject:@"EdaNo"]) {
                        _sub1[@"EdaNo"] = _menu[@"EdaNo"];
                    }
                    [self addSubMenu:_sub1
                                  SG:1];
                }
            }
        }
    }
}

- (void)addSubMenu:(NSMutableDictionary*)_menu
                SG:(NSInteger)SG{
    
    LOG(@"_menu:%zd:%@",SG,_menu);
    _menu = [[NSMutableDictionary alloc]initWithDictionary:_menu];
    
    
    //2015-08-24 ueda
    NSString *trayNo = nil;
    if ([[_menu allKeys]containsObject:@"trayNo"]) {
        trayNo = _menu[@"trayNo"];
    }
    else{
        trayNo = [DataList sharedInstance].TrayNo;
    }
    //2015-07-23 ueda
    NSString *edaNo = nil;
    if ([[_menu allKeys]containsObject:@"EdaNo"]) {
        edaNo = _menu[@"EdaNo"];
    } else {
        edaNo = @"00";
    }
    
    NSString *_str = nil;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSString *table = @"";
    if (SG==1) {
        table = @"Voucher1";
    }
    else if(SG==2){
        table = @"Voucher2";
    }
    
    
    LOG(@"trayNo:%@",trayNo);

    //2015-07-23 ueda
//    _str = [NSString stringWithFormat:@"SELECT count(TopSyohinCD) FROM %@ where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and trayNo = ?",table];
    _str = [NSString stringWithFormat:@"SELECT count(TopSyohinCD) FROM %@ where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and EdaNo = ? and trayNo = ?",table];
    NSUInteger count = [_net.db intForQuery:_str,
                        _menu[@"TopSyohinCD"],
                        _menu[@"Sub1SyohinCD"],
                        _menu[@"GCD"],
                        _menu[@"CD"],
                        edaNo,
                        trayNo
                        ];
    
    if ([_net.db hadError]) {
        NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    //1070100
    
    LOG(@"%zd",count);
    
    BOOL isDelete = NO;
    
    if (count>0&&[_menu[@"count"]intValue]!=0) {
        LOG(@"UPDATE");
        //2015-07-23 ueda
//        _str = [NSString stringWithFormat:@"update %@ set count = ?, countDivide = ? where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and trayNo = ?",table];
        _str = [NSString stringWithFormat:@"update %@ set count = ?, countDivide = ? where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and EdaNo = ? and trayNo = ?",table];
        [_net.db executeUpdate:_str,
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"GCD"],
         _menu[@"CD"],
         edaNo,     //2015-07-23 ueda
         trayNo
         ];
    }
    else if(([_menu[@"count"]intValue]==0)&&([_menu[@"countDivide"]intValue]==0)){
        LOG(@"DELETE");
        //2015-07-23 ueda
//        _str = [NSString stringWithFormat:@"DELETE FROM %@ where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and trayNo = ?",table];
        _str = [NSString stringWithFormat:@"DELETE FROM %@ where TopSyohinCD = ? and Sub1SyohinCD = ? and GCD = ? and CD = ? and EdaNo = ?and trayNo = ?",table];
        [_net.db executeUpdate:_str,
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"GCD"],
         _menu[@"CD"],
         edaNo,       //2015-07-23 ueda
         trayNo
         ];
        isDelete = YES;
    }
    else{
        LOG(@"INSERT");
        //2014-08-18 ueda
        //_str = [NSString stringWithFormat:@"INSERT INTO %@ (TopSyohinCD ,Sub1SyohinCD , CondiGCD, CondiGDID,GCD,CD ,count, countDivide,trayNo) VALUES (?,?,?,?,?,?,?,?,?)",table];
        _str = [NSString stringWithFormat:@"INSERT INTO %@ (EdaNo,TopSyohinCD ,Sub1SyohinCD , CondiGCD, CondiGDID,GCD,CD ,count, countDivide,trayNo) VALUES (?,?,?,?,?,?,?,?,?,?)",table];
        [_net.db executeUpdate:_str,
         edaNo,     //2015-07-23 ueda
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"CondiGCD"],
         _menu[@"CondiGDID"],
         _menu[@"GCD"],
         _menu[@"CD"],
         _menu[@"count"],
         _menu[@"countDivide"],
         trayNo
         ];
    }
    
    if (isDelete) {
        [_net.db executeUpdate:@"DELETE FROM Voucher2 where TopSyohinCD = ? and Sub1SyohinCD = ? and EdaNo = ? and trayNo = ?",
         _menu[@"TopSyohinCD"],
        _menu[@"Sub1SyohinCD"],
         edaNo,     //2015-07-23 ueda
         trayNo];
        
        
        [_net.db executeUpdate:@"DELETE FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and EdaNo = ? and trayNo = ?",
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         edaNo,     //2015-07-23 ueda
         trayNo];
    }
    
    if ([_net.db hadError]) {
        NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
}

- (void)addArrangeMenu:(NSMutableDictionary*)_menu
                update:(BOOL)enable{
    
    LOG(@"_menu:%@\n%@",_menu,[DataList sharedInstance].TrayNo);
    _menu = [[NSMutableDictionary alloc]initWithDictionary:_menu];
    
    if (![[_menu allKeys]containsObject:@"Sub1SyohinCD"]) {
        _menu[@"Sub1SyohinCD"] = @"";
    }
    
    //2015-08-24 ueda
    NSString *trayNo = nil;
    if ([[_menu allKeys]containsObject:@"trayNo"]) {
        trayNo = _menu[@"trayNo"];
    }
    else{
        trayNo = [DataList sharedInstance].TrayNo;
    }
    //2016-02-02 ueda
    NSString *edaNo = nil;
    if ([[_menu allKeys]containsObject:@"EdaNo"]) {
        edaNo = _menu[@"EdaNo"];
    } else {
        edaNo = @"00";
    }
    
    NSString *_str = nil;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSUInteger count = [_net.db intForQuery:@"SELECT count(TopSyohinCD) FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?",
                        _menu[@"TopSyohinCD"],
                        _menu[@"Sub1SyohinCD"],
                        _menu[@"SyohinCD"],
                        _menu[@"PageNo"],
                        trayNo
                        ];
    
    
    BOOL isCancel = NO;
    
    //書き込み
    //BOOL isDelete = NO;
    if (count>0&&[_menu[@"count"]intValue]!=0) {
        _str =  @"update Arrange set count = ? ,countDivide = ? ,Jika = ? where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?";
        [_net.db executeUpdate:_str,
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"Jika"],         
         _menu[@"TopSyohinCD"],//↓
         _menu[@"Sub1SyohinCD"],
         _menu[@"SyohinCD"],
         _menu[@"PageNo"],
         trayNo
         ];
        
        /*
        if ([_menu[@"countDivide"] intValue]>0||[_menu[@"countDivide"] length]>1) {
            isCancel = YES;
        }
        */
        isCancel = YES;
    }
    else if([_menu[@"count"]intValue]==0){
        
        _str =  @"DELETE FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?";
        [_net.db executeUpdate:_str,
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"SyohinCD"],
         _menu[@"PageNo"],
         trayNo
         ];
        //isDelete = YES;
    }
    else{
        //2014-09-17 ueda
        //_str = @"INSERT INTO Arrange (TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,PageNo,trayNo) VALUES (?,?,?,?,?,?,?)";
        //2016-02-02 ueda
        /*
         _str = @"INSERT INTO Arrange (EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,PageNo,trayNo) VALUES (?,?,?,?,?,?,?,?)";
         [_net.db executeUpdate:_str,
         _menu[@"EdaNo"],
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"SyohinCD"],
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"PageNo"],
         trayNo
         ];
         */
        //2016-02-02 ueda
        _str = @"INSERT INTO Arrange (EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,PageNo,trayNo) VALUES (?,?,?,?,?,?,?,?)";
        [_net.db executeUpdate:_str,
         edaNo,
         _menu[@"TopSyohinCD"],
         _menu[@"Sub1SyohinCD"],
         _menu[@"SyohinCD"],
         _menu[@"count"],
         _menu[@"countDivide"],
         _menu[@"PageNo"],
         trayNo
         ];
    }

    
    LOG(@"%@",_str);
    
    if ([_net.db hadError]) {
        NSLog(@"Err up %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    
    
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Arrange"];
    NSMutableArray *array = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [dic setValue:[results stringForColumn:column] forKey:column];
        }
        [array addObject:dic];
    }
    LOG(@"array:%@",array);
    [results close];
    

    //同じPageNoの商品に代入する
    if (isCancel&&enable) {
        FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Arrange where TopSyohinCD = ? and PageNo = ? and trayNo = ?",
                                _menu[@"TopSyohinCD"],
                                _menu[@"PageNo"],
                                [DataList sharedInstance].TrayNo
                                ];
        
        NSArray *p_divide = [_menu[@"countDivide"] componentsSeparatedByString:@","];
        NSMutableArray *p_array = [NSMutableArray arrayWithArray:p_divide];
        int parentCount = [p_array[[DataList sharedInstance].dividePage]intValue];
        
        while([results next])
        {
            NSArray *c_divide = [[results stringForColumn:@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *c_array = [NSMutableArray arrayWithArray:c_divide];
            if (parentCount==0) {
                c_array[[DataList sharedInstance].dividePage] = @"0";
            }
            else{
                c_array[[DataList sharedInstance].dividePage] = [NSString stringWithFormat:@"%d",[results intForColumn:@"count"]];
            }
            
            NSString *_str =  @"update Arrange set countDivide = ? where TopSyohinCD = ? and Sub1SyohinCD = ? and SyohinCD = ? and PageNo = ? and trayNo = ?";
            [_net.db executeUpdate:_str,
             [c_array componentsJoinedByString:@","],
             [results stringForColumn:@"TopSyohinCD"],//↓
             [results stringForColumn:@"Sub1SyohinCD"],
             [results stringForColumn:@"SyohinCD"],
             [results stringForColumn:@"PageNo"],
             [DataList sharedInstance].TrayNo
             ];
        }
        [results close];
    }
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
}


- (NSMutableArray*)getOrderList:(NSInteger)type{

    //0 = normal 1 = countDivide
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    
    //TopMenuを取得する
    FMResultSet *results = nil;
    if (type==0) {
        results = [_net.db executeQuery:@"SELECT * FROM VoucherTop"];
    }
    else if(type==1){
        //results = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE countDivide > 0"];
        results = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE countDivide <> 0"];
    }
    else if(type==2){
        //results = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE (count - countDivide) > 0"];
        results = [_net.db executeQuery:@"SELECT * FROM VoucherTop WHERE countDivide <> 0"];
    }
    
    
    //結果データの配列を収納する
    NSMutableArray *master = [[NSMutableArray alloc]init];
    //System *sys = [System sharedInstance];
    
    int EdaNo = 0;
    NSMutableArray *_menuTop = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }

        BOOL isData = NO;

        if (!isData) {
            //2015-09-16 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = ? and SyohinCD = ?",
                                 _dic[@"PatternCD"],
                                 _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                isData = YES;
                LOG(@"Menu_MT");
            }
            [menu close];
        }

        if (!isData) {
            //2015-09-16 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE PatternCD = ? and SyohinCD = ?",
                                 _dic[@"PatternCD"],
                                 _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                isData = YES;
                LOG(@"Menu_B1MT");
            }
            [menu close];
        }

        if (!isData) {
            //2015-09-16 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE PatternCD = ? and SyohinCD = ?",
                                 _dic[@"PatternCD"],
                                 _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                //isData = YES;
                LOG(@"Menu_B2MT");
            }
            [menu close];
        }

        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        [syohin close];
        
        //2015-07-21 ueda
/*
        //2014-08-19 ueda
        if (type == 1) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
 */
        //2015-07-21 ueda
        if ([[_dic allKeys]containsObject:@"EdaNo"]) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
        
        [_menuTop addObject:_dic];
        EdaNo++;
    }
    [results close];

    [master addObject:_menuTop];
    
    //SubMenuを取得する
    int num = 0;
    for (int index = 0; index < 2; index++) {
        NSLog(@"start");
        num++;
        EdaNo = 0;
        
        
        FMResultSet *results1 = nil;
        if (type==0) {
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%d",num];
            results1 = [_net.db executeQuery:str1];
        }
        else if(type==1){
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%d WHERE countDivide <> 0",num];
            results1 = [_net.db executeQuery:str1];
        }
        else if(type==2){
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%d WHERE countDivide <> 0",num];
            results1 = [_net.db executeQuery:str1];
        }
        
        NSMutableArray *_array1 = [[NSMutableArray alloc]init];
        
        while([results1 next])
        {
            NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [results1 columnCount]; ct++) {
                NSString *column = [results1 columnNameForIndex:ct];
                [_dic setValue:[results1 stringForColumn:column] forKey:column];
            }
            
            LOG(@"Voucher0:%d:%@",num,_dic);
            
            FMResultSet *menu = nil;
            if (num==1) {
                //2015-02-10 ueda
/*
                NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE SyohinCD = ? and GroupCD = ?",num];
                menu = [_net.db executeQuery:str2,
                        _dic[@"TopSyohinCD"],
                        [self appendSpace:_dic[@"GCD"] totalLength:4]];
 */
                BOOL is_exists = [_dic.allKeys containsObject:@"CondiGCD"];
                if (is_exists) {
                    NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE GroupType = '1' and SyohinCD = ? and GroupCD = ?",num];
                    menu = [_net.db executeQuery:str2,
                            _dic[@"TopSyohinCD"],
                            [self appendSpace:_dic[@"GCD"] totalLength:4]];
                } else {
                    NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE GroupType != '1' and SyohinCD = ? and GroupCD = ?",num];
                    menu = [_net.db executeQuery:str2,
                            _dic[@"TopSyohinCD"],
                            [self appendSpace:_dic[@"GCD"] totalLength:4]];
                }
            }
            else  if (num==2){
                NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE SyohinCD = ? and CondiGCD = ? and CondiGDID = ?",num];
                menu = [_net.db executeQuery:str2,
                        _dic[@"TopSyohinCD"],
                        _dic[@"CondiGCD"],
                        _dic[@"CondiGDID"]];
            }

            
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                //if (![column isEqualToString:@"SyohinCD"]) {
                [_dic setValue:[menu stringForColumn:column] forKey:column];
                //}
            }
            [menu close];
            
            
            LOG(@"Voucher1:%d:%@",num,_dic);
            
            if ([_dic[@"GroupType"] isEqualToString:@"1"]) {
                
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CondiGD_MT WHERE TopSyohinCD = ? and CondiGCD = ? and CondiGDID = ?",
                                        _dic[@"TopSyohinCD"],
                                        _dic[@"CondiGCD"],
                                        _dic[@"CondiGDID"]];
                
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                
                NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
                FMResultSet *syohin = [_net.db executeQuery:table01,
                                       _dic[@"SyohinCD"]];
                
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
                [results close];
            }
            else if ([_dic[@"GroupType"] isEqualToString:@"2"]) {
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CommentGD_MT WHERE CommentGCD = ? and CommentGDID = ?",
                                        _dic[@"GCD"],
                                        _dic[@"CD"]];
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                [results close];
                
                
                FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Comment_MT WHERE MstCommentCD = ?",
                                       _dic[@"CommentCD"]];
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
            }
            else if ([_dic[@"GroupType"] isEqualToString:@"3"]) {
                
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM OfferGD_MT WHERE OfferGCD = ? and OfferCD = ?",
                                        _dic[@"GCD"],
                                        _dic[@"CD"]];
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                [results close];
                

                
                FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Offer_MT WHERE MstOfferCD = ?",
                                       _dic[@"OfferCD"]];
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
            }
            
            //2015-07-21 ueda
/*
            //2014-08-19 ueda
            if (type == 1) {
                //取消の場合
                //DBの値をそのまま使用
            } else {
                _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
            }
 */
            //2015-07-21 ueda
            if ([[_dic allKeys]containsObject:@"EdaNo"]) {
                //取消の場合
                //DBの値をそのまま使用
            } else {
                _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
            }
            
            [_array1 addObject:_dic];
            EdaNo++;
        }
        
        [results1 close];
        
        //表示順を並び替える（ソート順）
        NSSortDescriptor *disp1 = nil;
        if (num==1) {
            disp1 = [[NSSortDescriptor alloc] initWithKey:@"SG1ID" ascending:YES];
        }
        else{
            disp1 = [[NSSortDescriptor alloc] initWithKey:@"SG2ID" ascending:YES];
        }
        NSSortDescriptor *disp2 = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES];
        NSArray *sortDispArray = [NSArray arrayWithObjects:disp1,disp2, nil];
        NSArray *_sub1menuList = [[NSArray alloc]initWithArray:[_array1 sortedArrayUsingDescriptors:sortDispArray]];
        
        [master addObject:_sub1menuList];
    }
    
    
    //アレンジ情報を取得する
    //FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Arrange"];
    FMResultSet *results2 = nil;
    if (type==0) {
        results2 = [_net.db executeQuery:@"SELECT * FROM Arrange"];
    }
    else if(type==1){
        results2 = [_net.db executeQuery:@"SELECT * FROM Arrange WHERE countDivide <> 0"];
    }
    else if(type==2){
        results2 = [_net.db executeQuery:@"SELECT * FROM Arrange WHERE countDivide <> 0"];
    }
    
    EdaNo = 0;
    NSMutableArray *_menuArrange1 = [[NSMutableArray alloc]init];
    NSMutableArray *_menuArrange2 = [[NSMutableArray alloc]init];
    while([results2 next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            if ([column isEqualToString:@"PageNo"]) {
                [_dic setValue:[NSNumber numberWithInt:[[results2 stringForColumn:column]intValue]] forKey:column];
            }
            else{
                [_dic setValue:[results2 stringForColumn:column] forKey:column];
            }
        }
        
        //2016-03-15 ueda
/*
        FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE SyohinCD = ?",
                             _dic[@"SyohinCD"]];
 */
        //2016-03-15 ueda
        System *sys = [System sharedInstance];
        NSString *menuPatternCD;
        if ([sys.menuPatternEnable isEqualToString:@"1"]) {
            menuPatternCD = sys.menuPattern;
        } else {
            menuPatternCD = sys.menuPatternType;
        }
        FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = ? and SyohinCD = ?",
                             menuPatternCD, _dic[@"SyohinCD"]];
        [menu next];
        for (int ct = 0; ct < [menu columnCount]; ct++) {
            NSString *column = [menu columnNameForIndex:ct];
            [_dic setValue:[menu stringForColumn:column] forKey:column];
        }
        [menu close];
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        [syohin close];
        
        
        //2014-09-16 ueda
        if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
            FMResultSet *rsMenuExt = [_net.db executeQuery:@"SELECT * FROM MenuExt_MT WHERE SyohinCD = ?",_dic[@"SyohinCD"]];
            [rsMenuExt next];
            for (int ct = 0; ct < [rsMenuExt columnCount]; ct++) {
                NSString *column = [rsMenuExt columnNameForIndex:ct];
                [_dic setValue:[rsMenuExt stringForColumn:column] forKey:column];
            }
            [rsMenuExt close];
            //商品マスターと同じような内容
            _dic[@"MstSyohinCD"] = _dic[@"SyohinCD"];
            _dic[@"Tanka"]       = @"0";
            _dic[@"KakeFLG"]     = @"0";
            _dic[@"JikaFLG"]     = @"0";
            _dic[@"InfoFLG"]     = @"0";
            _dic[@"SG1FLG"]      = @"0";
            _dic[@"Kakeritsu"]   = @"0";
            _dic[@"BFLG"]        = @"0";
            _dic[@"BNGTanka"]    = @"0";
            _dic[@"TrayStyle"]   = @"0";
            _dic[@"Info"]        = @"";
        }
        
        //2015-07-21 ueda
/*
        //2014-08-19 ueda
        if (type == 1) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
 */
        //2015-07-21 ueda
        if ([[_dic allKeys]containsObject:@"EdaNo"]) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
        _dic[@"ArrangeFLG"] = @"1";
        
        if ([_dic[@"Sub1SyohinCD"]length]==0||[_dic[@"Sub1SyohinCD"] isEqualToString:_dic[@"SyohinCD"]]) {
            [_menuArrange1 addObject:_dic];
        }
        else{
            [_menuArrange2 addObject:_dic];
        }
        EdaNo++;
    }
    [results2 close];
    
    
    //表示順を並び替える(フォルダ商品を頭に)
    NSSortDescriptor *sortPageNo = [[NSSortDescriptor alloc] initWithKey:@"PageNo" ascending:YES] ;
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortPageNo, nil];
    NSArray *_menuArrange1Result = [[NSArray alloc]initWithArray:[_menuArrange1 sortedArrayUsingDescriptors:sortDescArray]];
    NSArray *_menuArrange2Result = [[NSArray alloc]initWithArray:[_menuArrange2 sortedArrayUsingDescriptors:sortDescArray]];
    
    [master addObject:_menuArrange1Result];
    [master addObject:_menuArrange2Result];
    
    [_net closeDb];
    
    LOG(@"%@",master);
    LOG(@"count:%zd",master.count);
    return master;
}

//2015-02-16 ueda
- (NSMutableArray*)getVoucherList:(NSInteger)voucherNo
                         syohinCD:(NSString*)syohinCD
                           trayNo:(NSString*)trayNo {
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];

    NSMutableArray *master = [[NSMutableArray alloc]init];
    
    //2015-02-26 ueda
    NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%zd WHERE TopSyohinCD = ? AND trayNo = ? ORDER BY Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD",voucherNo];
    FMResultSet *results = [_net.db executeQuery:str1,syohinCD,trayNo];

    while([results next]) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [master addObject:_dic];
    }
    [results close];
    
    [_net closeDb];
    
    return master;
}

//2016-02-02 ueda
//シングルトレイのアレンジの情報を返す
//シングルトレイの同一チェックで使用
- (NSMutableArray*)getArrangeList:(NSString*)topSyohinCD
                     sub1SyohinCD:(NSString*)sub1SyohinCD
                           trayNo:(NSString*)trayNo {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    NSMutableArray *master = [[NSMutableArray alloc]init];
    
    FMResultSet *results;
    if ([sub1SyohinCD length] == 0) {
        //親の場合
        NSString *sql = [NSString stringWithFormat:@"SELECT * FROM Arrange WHERE TopSyohinCD = ? AND PageNo = '%zd' AND trayNo = '00' ORDER BY SyohinCD",[trayNo integerValue]];
        results = [_net.db executeQuery:sql,topSyohinCD];
    } else {
        results = [_net.db executeQuery:@"SELECT * FROM Arrange WHERE TopSyohinCD = ? AND Sub1SyohinCD = ? AND trayNo = ?  ORDER BY SyohinCD",topSyohinCD,sub1SyohinCD,trayNo];
    }
    
    while([results next]) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [master addObject:_dic];
    }
    [results close];
    
    [_net closeDb];
    
    return master;
}

//2015-02-16 ueda
- (NSMutableArray*)getOrderListForConfirm:(BOOL)isCancel
                               isSubGroup:(BOOL)isSubGroup
                                isArrange:(BOOL)isArrange
                              typeOrderNo:(int)typeOrderNo{
    
    int type = 0;
    if (isCancel) {
        type = 1;
    }
   
    NSMutableArray *_array = [self getOrderList:type];
    NSMutableArray *_menuList = _array[0];
    NSMutableArray *_sub1List = _array[1];
    NSMutableArray *_sub2List = _array[2];
    NSMutableArray *_arrangeList1 = _array[3];
    NSMutableArray *_arrangeList2 = _array[4];
    
    LOG(@"%zd:%zd:%zd:%zd:%zd",[_menuList count],[_sub1List count],[_sub1List count],[_arrangeList1 count],[_arrangeList2 count]);
    LOG(@"%@:%@:%@:%@:%@",_menuList,_sub1List,_sub2List,_arrangeList1,_arrangeList2);
    
    System *sys = [System sharedInstance];
    
    NSMutableArray *_conList = [[NSMutableArray alloc]init];
    for (int ct = 0; ct < [_menuList count]; ct++) {
        NSMutableDictionary *_menu = _menuList[ct];
        
        //2015-02-16 ueda
        //第２階層まで同じシングルトレイの場合はまとめる
        int _sameTrayNo = 0;
        if ((typeOrderNo == TypeOrderOriginal) || (typeOrderNo == TypeOrderAdd)) {
            if ([_menu[@"trayNo"] intValue] > 1) {
                int maxTray = [_menu[@"trayNo"] intValue];
                for (int ctTray = 1; ctTray < maxTray; ctTray++) {
                    //トレイ＝０１から同じかどうかチェック
                    NSMutableArray *_voucher1tray1 = [self getVoucherList:1 syohinCD:_menu[@"SyohinCD"] trayNo:[NSString stringWithFormat:@"%02d", ctTray]];
                    NSMutableArray *_voucher1trayn = [self getVoucherList:1 syohinCD:_menu[@"SyohinCD"] trayNo:_menu[@"trayNo"]];
                    NSMutableArray *_voucher2tray1 = [self getVoucherList:2 syohinCD:_menu[@"SyohinCD"] trayNo:[NSString stringWithFormat:@"%02d", ctTray]];
                    NSMutableArray *_voucher2trayn = [self getVoucherList:2 syohinCD:_menu[@"SyohinCD"] trayNo:_menu[@"trayNo"]];
                    //2016-01-29 ueda
                    NSMutableArray *_arrangeToptray1 = [self getArrangeList:_menu[@"SyohinCD"] sub1SyohinCD:@"" trayNo:[NSString stringWithFormat:@"%02d", ctTray]];
                    NSMutableArray *_arrangeToptrayn = [self getArrangeList:_menu[@"SyohinCD"] sub1SyohinCD:@"" trayNo:_menu[@"trayNo"]];
                    
                    //2016-01-29 ueda
                    //if (([_voucher1tray1 count] == [_voucher1trayn count]) && ([_voucher2tray1 count] == [_voucher2trayn count])) {
                    if (([_voucher1tray1 count] == [_voucher1trayn count]) && ([_voucher2tray1 count] == [_voucher2trayn count]) && ([_arrangeToptray1 count] == [_arrangeToptrayn count])) {
                        //第１階層、第２階層の商品数が同じ
                        _sameTrayNo = ctTray;
                        //2016-02-02 ueda
                        for (int ctAr = 0; ctAr < [_arrangeToptray1 count]; ctAr++) {
                            //トップのアレンジ
                            NSMutableDictionary *_ar1 = _arrangeToptray1[ctAr];
                            NSMutableDictionary *_arn = _arrangeToptrayn[ctAr];
                            if (([_ar1[@"SyohinCD"]isEqualToString:_arn[@"SyohinCD"]]) &&
                                ([_ar1[@"count"]isEqualToString:_arn[@"count"]])) {
                                //同一商品
                            } else {
                                _sameTrayNo = 0;
                                break;
                            }
                        }
                        if (_sameTrayNo != 0) {
                            for (int ct1 = 0; ct1<[_voucher1tray1 count]; ct1++) {
                                NSMutableDictionary *_sub1 = _voucher1tray1[ct1];
                                NSMutableDictionary *_subn = _voucher1trayn[ct1];
                                if (([_sub1[@"Sub1SyohinCD"]isEqualToString:_subn[@"Sub1SyohinCD"]]) &&
                                    ([_sub1[@"CondiGCD"]isEqualToString:_subn[@"CondiGCD"]]) &&
                                    ([_sub1[@"CondiGDID"]isEqualToString:_subn[@"CondiGDID"]]) &&
                                    ([_sub1[@"GCD"]isEqualToString:_subn[@"GCD"]]) &&
                                    ([_sub1[@"CD"]isEqualToString:_subn[@"CD"]]) &&
                                    ([_sub1[@"count"]isEqualToString:_subn[@"count"]])) {
                                    //同一商品
                                    //2016-02-02 ueda
                                    if (YES) {
                                        NSMutableArray *_arrange1tray1 = [self getArrangeList:_menu[@"SyohinCD"] sub1SyohinCD:_sub1[@"Sub1SyohinCD"] trayNo:_sub1[@"trayNo"]];
                                        NSMutableArray *_arrange1trayn = [self getArrangeList:_menu[@"SyohinCD"] sub1SyohinCD:_subn[@"Sub1SyohinCD"] trayNo:_subn[@"trayNo"]];
                                        if ([_arrange1tray1 count] == [_arrange1trayn count]) {
                                            for (int ctAr = 0; ctAr < [_arrange1tray1 count]; ctAr++) {
                                                //第１階層のアレンジ
                                                NSMutableDictionary *_ar1 = _arrange1tray1[ctAr];
                                                NSMutableDictionary *_arn = _arrange1trayn[ctAr];
                                                if (([_ar1[@"SyohinCD"]isEqualToString:_arn[@"SyohinCD"]]) &&
                                                    ([_ar1[@"count"]isEqualToString:_arn[@"count"]])) {
                                                    //同一商品
                                                } else {
                                                    _sameTrayNo = 0;
                                                    break;
                                                }
                                            }
                                        } else {
                                            _sameTrayNo = 0;
                                        }
                                    }
                                } else {
                                    _sameTrayNo = 0;
                                    break;
                                }
                                if (_sameTrayNo == 0) {
                                    break;
                                }
                            }
                        }
                        if (_sameTrayNo != 0) {
                            for (int ct2 = 0; ct2<[_voucher2tray1 count]; ct2++) {
                                NSMutableDictionary *_sub2 = _voucher2tray1[ct2];
                                NSMutableDictionary *_subn = _voucher2trayn[ct2];
                                if (([_sub2[@"Sub1SyohinCD"]isEqualToString:_subn[@"Sub1SyohinCD"]]) &&
                                    ([_sub2[@"CondiGCD"]isEqualToString:_subn[@"CondiGCD"]]) &&
                                    ([_sub2[@"CondiGDID"]isEqualToString:_subn[@"CondiGDID"]]) &&
                                    ([_sub2[@"GCD"]isEqualToString:_subn[@"GCD"]]) &&
                                    ([_sub2[@"CD"]isEqualToString:_subn[@"CD"]]) &&
                                    ([_sub2[@"count"]isEqualToString:_subn[@"count"]])) {
                                    //同一商品
                                } else {
                                    _sameTrayNo = 0;
                                    break;
                                }
                            }
                        }
                    }
                    
                    if (_sameTrayNo != 0) {
                        break;
                    }
                }
            }
        }
        
        if (_sameTrayNo != 0) {
            //第２階層まで同じシングルトレイ
            for (int ct = 0; ct < [_conList count]; ct++) {
                NSMutableDictionary *_con = _conList[ct];
                if ([_con.allKeys containsObject:@"TopSyohinCD"]) {
                    if (([_con[@"TopSyohinCD"]isEqualToString:_menu[@"SyohinCD"]]) &&
                        ([_con[@"trayNo"]isEqualToString:[NSString stringWithFormat:@"%02d", _sameTrayNo]])) {
                        int count = [_con[@"count"] intValue];
                        count++;
                        [_con removeObjectForKey:@"count"];
                        [_con setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
                    }
                } else {
                    if (([_con[@"SyohinCD"]isEqualToString:_menu[@"SyohinCD"]]) &&
                        ([_con[@"trayNo"]isEqualToString:[NSString stringWithFormat:@"%02d", _sameTrayNo]])) {
                        int count = [_con[@"count"] intValue];
                        count++;
                        [_con removeObjectForKey:@"count"];
                        [_con setValue:[NSString stringWithFormat:@"%d", count] forKey:@"count"];
                    }
                }
            }
        } else {
            
            [_conList addObject:_menu];
            
            //親商品の後方にアレンジ情報を挿入する
            if (isArrange){
                for (int ct1 = 0; ct1<[_arrangeList1 count]; ct1++) {
                    NSMutableDictionary *_arrange = _arrangeList1[ct1];
                    if ([_menu[@"SyohinCD"]isEqualToString:_arrange[@"TopSyohinCD"]]&&
                        ([_arrange[@"Sub1SyohinCD"]isEqualToString:_arrange[@"SyohinCD"]]||
                         [_arrange[@"Sub1SyohinCD"]length] == 0)) {
                            
                            if ([_menu[@"TrayStyle"]isEqualToString:@"1"]) {
                                if ([_menu[@"trayNo"]intValue] == [_arrange[@"PageNo"]intValue]) {
                                    //2016-02-02 ueda
                                    if (_menu[@"EdaNo"] == _arrange[@"EdaNo"]) {
                                        _arrange[@"trayNo"] = _menu[@"trayNo"];
                                        [_conList addObject:_arrange];
                                    }
                                }
                            }
                            else{
                                [_conList addObject:_arrange];
                            }
                            
                        }
                }
            }
            
            //親商品の後方に第１階層を挿入する
            if ((isSubGroup||[_menu[@"TrayStyle"]isEqualToString:@"1"])&&
                [_menu[@"SG1FLG"]isEqualToString:@"1"]) {
                
                for (int ct1 = 0; ct1<[_sub1List count]; ct1++) {
                    
                    NSMutableDictionary *_sub1 = _sub1List[ct1];
                    
                    //2015-07-21 ueda
                    BOOL isSub1Fg = NO;
                    if ((typeOrderNo == TypeOrderCancel) || (typeOrderNo == TypeOrderDivide)) {
                        if ([_menu[@"SyohinCD"]isEqualToString:_sub1[@"TopSyohinCD"]]&&
                            [_menu[@"EdaNo"]isEqualToString:_sub1[@"EdaNo"]]&&
                            [_menu[@"trayNo"]isEqualToString:_sub1[@"trayNo"]]) {
                            isSub1Fg = YES;
                        }
                    } else {
                        if ([_menu[@"SyohinCD"]isEqualToString:_sub1[@"TopSyohinCD"]]&&
                            [_menu[@"trayNo"]isEqualToString:_sub1[@"trayNo"]]) {
                            isSub1Fg = YES;
                        }
                    }
                    //2015-07-21 ueda
                    if (isSub1Fg) {
                        
                        if (![_sub1[@"LimitCount"]isEqualToString:@"5"]||
                            [sys.nonselect isEqualToString:@"0"]) {
                            
                            NSString *dispName = [NSString stringWithFormat:@"%@\n%@\n%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
                            _sub1[@"TopDispNM"] = dispName;
                            [_conList addObject:_sub1];
                            
                            //第１階層の後方にアレンジ情報を挿入する
                            if (isArrange){
                                for (int ct1 = 0; ct1<[_arrangeList2 count]; ct1++) {
                                    NSMutableDictionary *_arrange = _arrangeList2[ct1];
                                    //2015-08-24 ueda
                                    if ((typeOrderNo == TypeOrderCancel) || (typeOrderNo == TypeOrderDivide)) {
                                        if ([_menu[@"SyohinCD"]isEqualToString:_arrange[@"TopSyohinCD"]]&&
                                            [_arrange[@"Sub1SyohinCD"]isEqualToString:_sub1[@"SyohinCD"]]&&
                                            [_menu[@"EdaNo"]isEqualToString:_arrange[@"EdaNo"]]&&
                                            [_menu[@"trayNo"]isEqualToString:_arrange[@"trayNo"]]) {
                                            
                                            [_conList addObject:_arrange];
                                        }
                                    } else {
                                        if ([_menu[@"SyohinCD"]isEqualToString:_arrange[@"TopSyohinCD"]]&&
                                            [_arrange[@"Sub1SyohinCD"]isEqualToString:_sub1[@"SyohinCD"]]&&
                                            [_menu[@"trayNo"]isEqualToString:_arrange[@"trayNo"]]) {
                                            
                                            [_conList addObject:_arrange];
                                        }
                                    }
                                }
                            }
                            
                            //親商品の後方に第2階層を挿入する
                            if ([_sub1[@"SG2FLG"]isEqualToString:@"1"]) {
                                
                                for (int ct2 = 0; ct2<[_sub2List count]; ct2++) {
                                    
                                    NSMutableDictionary *_sub2 = _sub2List[ct2];
                                    
                                    //2015-07-21 ueda
                                    BOOL isSub2Fg = NO;
                                    if ((typeOrderNo == TypeOrderCancel) || (typeOrderNo == TypeOrderDivide)) {
                                        if ([_menu[@"SyohinCD"]isEqualToString:_sub2[@"TopSyohinCD"]]&&
                                            [_sub1[@"SyohinCD"]isEqualToString:_sub2[@"Sub1SyohinCD"]]&&
                                            [_menu[@"EdaNo"]isEqualToString:_sub2[@"EdaNo"]]&&
                                            [_menu[@"trayNo"]isEqualToString:_sub2[@"trayNo"]]) {
                                            isSub2Fg = YES;
                                        }
                                    } else {
                                        if ([_menu[@"SyohinCD"]isEqualToString:_sub2[@"TopSyohinCD"]]&&
                                            [_sub1[@"SyohinCD"]isEqualToString:_sub2[@"Sub1SyohinCD"]]&&
                                            [_menu[@"trayNo"]isEqualToString:_sub2[@"trayNo"]]) {
                                            isSub2Fg = YES;
                                        }
                                    }
                                    //2015-07-21 ueda
                                    if (isSub2Fg) {
                                        if (![_sub2[@"LimitCount"]isEqualToString:@"5"]||
                                            [sys.nonselect isEqualToString:@"0"]) {
                                            NSString *subDispName = [NSString stringWithFormat:@"%@\n%@\n%@",_sub1[@"HTDispNMU"],_sub1[@"HTDispNMM"],_sub1[@"HTDispNML"]];
                                            _sub2[@"TopDispNM"] = dispName;
                                            _sub2[@"Sub2DispNM"] = subDispName;
                                            [_conList addObject:_sub2];
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
            
        }
    }
    
    if ([_conList count]==[_menuList count]+[_sub1List count]) {
        LOG(@"succes");
    }
    return _conList;
}

- (NSMutableArray*)getOrderListForDivide{
    
    NSMutableArray *_array2 = [self getOrderList:1];
    
    NSMutableArray *_menuList2 = _array2[0];
    
    NSMutableArray *_sub1List2 = _array2[1];
    
    NSMutableArray *_sub2List2 = _array2[2];

    NSMutableArray *_arrangeList1 = _array2[3];
    NSMutableArray *_arrangeList2 = _array2[4];
    
    return [[NSMutableArray alloc]initWithArray:@[_menuList2,_sub1List2,_sub2List2,_arrangeList1,_arrangeList2]];
}

//2014-09-11 ueda
- (NSMutableArray*)getOrderListTypeC_Header:(int)type {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];

    //席番・オーダー種類
    NSMutableArray *topGroupArray = [[NSMutableArray alloc]init];
    FMResultSet *rsTopGroup = nil;
    if (type==0) {
        //新規 or 追加
        rsTopGroup = [_net.db executeQuery:@"SELECT SeatNumber,OrderType FROM VoucherTopTypeC GROUP BY SeatNumber,OrderType ORDER BY SeatNumber,OrderType "];
    }
    else if(type==1){
        //取消
        rsTopGroup = [_net.db executeQuery:@"SELECT SeatNumber,OrderType FROM VoucherTopTypeC WHERE countDivide <> 0 GROUP BY SeatNumber,OrderType ORDER BY SeatNumber,OrderType "];
    }
    while ([rsTopGroup next]) {
        NSMutableDictionary *wDic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [rsTopGroup columnCount]; ct++) {
            NSString *wColumnName = [rsTopGroup columnNameForIndex:ct];
            [wDic setValue:[rsTopGroup stringForColumn:wColumnName] forKey:wColumnName];
        }
        [topGroupArray addObject:wDic];
    }
    [rsTopGroup close];

    [_net closeDb];
    
    return topGroupArray;
}


//2014-09-11 ueda
- (NSMutableArray*)getOrderListTypeC_Detail:(int)type
                                 seatNumber:(NSString*)seatNumber
                                  orderType:(NSString*)orderType {

    //0 = normal 1 = countDivide
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //TopMenuを取得する
    FMResultSet *results = nil;
    if (type==0) {
        //新規 or 追加
        results = [_net.db executeQuery:@"SELECT * FROM VoucherTopTypeC WHERE SeatNumber = ? AND OrderType = ? ",seatNumber,orderType];
    }
    else if(type==1){
        //取消
        results = [_net.db executeQuery:@"SELECT * FROM VoucherTopTypeC WHERE countDivide <> 0 "];
    }
    
    //結果データの配列を収納する
    NSMutableArray *master = [[NSMutableArray alloc]init];
    //System *sys = [System sharedInstance];
    
    int EdaNo = 0;
    NSMutableArray *_menuTop = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        
        BOOL isData = NO;
    
        //2016-03-15 ueda
        System *sys = [System sharedInstance];
        NSString *menuPatternCD;
        if ([sys.menuPatternEnable isEqualToString:@"1"]) {
            menuPatternCD = sys.menuPattern;
        } else {
            menuPatternCD = sys.menuPatternType;
        }

        if (!isData) {
            //2016-03-15 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            //2016-03-15 ueda
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = ? and SyohinCD = ?",
                                 menuPatternCD, _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                isData = YES;
                LOG(@"Menu_MT");
            }
            [menu close];
        }
        
        if (!isData) {
            //2016-03-15 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            //2016-03-15 ueda
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B1MT WHERE PatternCD = ? and SyohinCD = ?",
                                 menuPatternCD, _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                isData = YES;
                LOG(@"Menu_B1MT");
            }
            [menu close];
        }
        
        if (!isData) {
            //2016-03-15 ueda
/*
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
 */
            //2016-03-15 ueda
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_B2MT WHERE PatternCD = ? and SyohinCD = ?",
                                 menuPatternCD, _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                if (![column isEqualToString:@"PatternCD"]) {
                    [_dic setValue:[menu stringForColumn:column] forKey:column];
                }
                //isData = YES;
                LOG(@"Menu_B2MT");
            }
            [menu close];
        }
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        [syohin close];
        
        //2014-08-19 ueda
        if (type == 1) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
        
        [_menuTop addObject:_dic];
        EdaNo++;
    }
    [results close];
    
    [master addObject:_menuTop];
    
    //SubMenuを取得する
    int num = 0;
    for (int index = 0; index < 2; index++) {
        NSLog(@"start");
        num++;
        EdaNo = 0;
        
        
        FMResultSet *results1 = nil;
        if (type==0) {
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%dTypeC WHERE SeatNumber = ? AND OrderType = ? ",num];
            results1 = [_net.db executeQuery:str1,seatNumber,orderType];
        }
        else if(type==1){
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%dTypeC WHERE SeatNumber = ? AND OrderType = ? AND countDivide <> 0",num];
            results1 = [_net.db executeQuery:str1,seatNumber,orderType];
        }
        else if(type==2){
            NSString *str1 = [NSString stringWithFormat:@"SELECT * FROM Voucher%dTypeC WHERE SeatNumber = ? AND OrderType = ? AND countDivide <> 0",num];
            results1 = [_net.db executeQuery:str1,seatNumber,orderType];
        }
        
        NSMutableArray *_array1 = [[NSMutableArray alloc]init];
        
        while([results1 next])
        {
            NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
            for (int ct = 0; ct < [results1 columnCount]; ct++) {
                NSString *column = [results1 columnNameForIndex:ct];
                [_dic setValue:[results1 stringForColumn:column] forKey:column];
            }
            
            LOG(@"Voucher0:%d:%@",num,_dic);
            
            FMResultSet *menu = nil;
            if (num==1) {
                NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE SyohinCD = ? and GroupCD = ?",num];
                menu = [_net.db executeQuery:str2,
                        _dic[@"TopSyohinCD"],
                        [self appendSpace:_dic[@"GCD"] totalLength:4]];
            }
            else  if (num==2){
                NSString *str2 = [NSString stringWithFormat:@"SELECT * FROM SG%d_MT WHERE SyohinCD = ? and CondiGCD = ? and CondiGDID = ?",num];
                menu = [_net.db executeQuery:str2,
                        _dic[@"TopSyohinCD"],
                        _dic[@"CondiGCD"],
                        _dic[@"CondiGDID"]];
            }
            
            
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                //if (![column isEqualToString:@"SyohinCD"]) {
                [_dic setValue:[menu stringForColumn:column] forKey:column];
                //}
            }
            [menu close];
            
            
            LOG(@"Voucher1:%d:%@",num,_dic);
            
            if ([_dic[@"GroupType"] isEqualToString:@"1"]) {
                
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CondiGD_MT WHERE TopSyohinCD = ? and CondiGCD = ? and CondiGDID = ?",
                                        _dic[@"TopSyohinCD"],
                                        _dic[@"CondiGCD"],
                                        _dic[@"CondiGDID"]];
                
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                
                NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
                FMResultSet *syohin = [_net.db executeQuery:table01,
                                       _dic[@"SyohinCD"]];
                
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
                [results close];
            }
            else if ([_dic[@"GroupType"] isEqualToString:@"2"]) {
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM CommentGD_MT WHERE CommentGCD = ? and CommentGDID = ?",
                                        _dic[@"GCD"],
                                        _dic[@"CD"]];
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                [results close];
                
                
                FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Comment_MT WHERE MstCommentCD = ?",
                                       _dic[@"CommentCD"]];
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
            }
            else if ([_dic[@"GroupType"] isEqualToString:@"3"]) {
                
                FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM OfferGD_MT WHERE OfferGCD = ? and OfferCD = ?",
                                        _dic[@"GCD"],
                                        _dic[@"CD"]];
                [results next];
                for (int ct = 0; ct < [results columnCount]; ct++) {
                    NSString *column = [results columnNameForIndex:ct];
                    [_dic setValue:[results stringForColumn:column] forKey:column];
                }
                [results close];
                
                
                
                FMResultSet *syohin = [_net.db executeQuery:@"SELECT * FROM Offer_MT WHERE MstOfferCD = ?",
                                       _dic[@"OfferCD"]];
                [syohin next];
                for (int ct = 0; ct < [syohin columnCount]; ct++) {
                    NSString *column = [syohin columnNameForIndex:ct];
                    [_dic setValue:[syohin stringForColumn:column] forKey:column];
                }
                _dic[@"DispOrder"] = [NSNumber numberWithInt:[_dic[@"DispOrder"] intValue]];
                [syohin close];
            }
            
            //2014-08-19 ueda
            if (type == 1) {
                //取消の場合
                //DBの値をそのまま使用
            } else {
                _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
            }
            
            [_array1 addObject:_dic];
            EdaNo++;
        }
        
        [results1 close];
        
        //表示順を並び替える（ソート順）
        NSSortDescriptor *disp1 = nil;
        if (num==1) {
            disp1 = [[NSSortDescriptor alloc] initWithKey:@"SG1ID" ascending:YES];
        }
        else{
            disp1 = [[NSSortDescriptor alloc] initWithKey:@"SG2ID" ascending:YES];
        }
        NSSortDescriptor *disp2 = [[NSSortDescriptor alloc] initWithKey:@"DispOrder" ascending:YES];
        NSArray *sortDispArray = [NSArray arrayWithObjects:disp1,disp2, nil];
        NSArray *_sub1menuList = [[NSArray alloc]initWithArray:[_array1 sortedArrayUsingDescriptors:sortDispArray]];
        
        [master addObject:_sub1menuList];
    }
    
    
    //アレンジ情報を取得する
    //FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Arrange"];
    FMResultSet *results2 = nil;
    if (type==0) {
        results2 = [_net.db executeQuery:@"SELECT * FROM ArrangeTypeC WHERE SeatNumber = ? AND OrderType = ? ",seatNumber,orderType];
    }
    else if(type==1){
        results2 = [_net.db executeQuery:@"SELECT * FROM ArrangeTypeC WHERE SeatNumber = ? AND OrderType = ? AND countDivide <> 0",seatNumber,orderType];
    }
    else if(type==2){
        results2 = [_net.db executeQuery:@"SELECT * FROM ArrangeTypeC WHERE SeatNumber = ? AND OrderType = ? AND countDivide <> 0",seatNumber,orderType];
    }
    
    EdaNo = 0;
    NSMutableArray *_menuArrange1 = [[NSMutableArray alloc]init];
    NSMutableArray *_menuArrange2 = [[NSMutableArray alloc]init];
    while([results2 next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            if ([column isEqualToString:@"PageNo"]) {
                [_dic setValue:[NSNumber numberWithInt:[[results2 stringForColumn:column]intValue]] forKey:column];
            }
            else{
                [_dic setValue:[results2 stringForColumn:column] forKey:column];
            }
        }
        
        //2016-03-15 ueda
/*
        FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE SyohinCD = ?",
                             _dic[@"SyohinCD"]];
 */
        //2016-03-15 ueda
        System *sys = [System sharedInstance];
        NSString *menuPatternCD;
        if ([sys.menuPatternEnable isEqualToString:@"1"]) {
            menuPatternCD = sys.menuPattern;
        } else {
            menuPatternCD = sys.menuPatternType;
        }
        FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM Menu_MT WHERE PatternCD = ? and SyohinCD = ?",
                             menuPatternCD, _dic[@"SyohinCD"]];
        [menu next];
        for (int ct = 0; ct < [menu columnCount]; ct++) {
            NSString *column = [menu columnNameForIndex:ct];
            [_dic setValue:[menu stringForColumn:column] forKey:column];
        }
        [menu close];
        
        
        NSString *table01 = [NSString stringWithFormat:@"SELECT %@ FROM Syohin_MT WHERE MstSyohinCD = ?",kSyohin_MT];
        FMResultSet *syohin = [_net.db executeQuery:table01,
                               _dic[@"SyohinCD"]];
        
        [syohin next];
        for (int ct = 0; ct < [syohin columnCount]; ct++) {
            NSString *column = [syohin columnNameForIndex:ct];
            [_dic setValue:[syohin stringForColumn:column] forKey:column];
        }
        [syohin close];
        
        //2014-09-16 ueda
        if ([[_dic[@"SyohinCD"] substringWithRange:NSMakeRange(0, 1)] isEqualToString:@"A"]) {
            FMResultSet *menu = [_net.db executeQuery:@"SELECT * FROM MenuExt_MT WHERE SyohinCD = ?",
                                 _dic[@"SyohinCD"]];
            [menu next];
            for (int ct = 0; ct < [menu columnCount]; ct++) {
                NSString *column = [menu columnNameForIndex:ct];
                [_dic setValue:[menu stringForColumn:column] forKey:column];
            }
            [menu close];
            //商品マスターと同じような内容
            _dic[@"MstSyohinCD"] = _dic[@"SyohinCD"];
            _dic[@"Tanka"]       = @"0";
            _dic[@"KakeFLG"]     = @"0";
            _dic[@"JikaFLG"]     = @"0";
            _dic[@"InfoFLG"]     = @"0";
            _dic[@"SG1FLG"]      = @"0";
            _dic[@"Kakeritsu"]   = @"0";
            _dic[@"BFLG"]        = @"0";
            _dic[@"BNGTanka"]    = @"0";
            _dic[@"TrayStyle"]   = @"0";
            _dic[@"Info"]        = @"";
        }
        
        //2014-08-19 ueda
        if (type == 1) {
            //取消の場合
            //DBの値をそのまま使用
        } else {
            _dic[@"EdaNo"] = [NSString stringWithFormat:@"%02d",EdaNo];
        }
        _dic[@"ArrangeFLG"] = @"1";
        
        if ([_dic[@"Sub1SyohinCD"]length]==0||[_dic[@"Sub1SyohinCD"] isEqualToString:_dic[@"SyohinCD"]]) {
            [_menuArrange1 addObject:_dic];
        }
        else{
            [_menuArrange2 addObject:_dic];
        }
        EdaNo++;
    }
    [results2 close];
    
    
    //表示順を並び替える(フォルダ商品を頭に)
    NSSortDescriptor *sortPageNo = [[NSSortDescriptor alloc] initWithKey:@"PageNo" ascending:YES] ;
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortPageNo, nil];
    NSArray *_menuArrange1Result = [[NSArray alloc]initWithArray:[_menuArrange1 sortedArrayUsingDescriptors:sortDescArray]];
    NSArray *_menuArrange2Result = [[NSArray alloc]initWithArray:[_menuArrange2 sortedArrayUsingDescriptors:sortDescArray]];
    
    [master addObject:_menuArrange1Result];
    [master addObject:_menuArrange2Result];
    
    [_net closeDb];
    
    LOG(@"%@",master);
    LOG(@"count:%zd",master.count);
    return master;
}


//2014-09-09 ueda
- (NSMutableArray*)getOrderListTypeCForSummary:(int)type{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //TopMenuを取得する
    FMResultSet *rsTop = nil;
    if (type==0) {
        rsTop = [_net.db executeQuery:@"SELECT * FROM VoucherTopTypeC"];
    }
    else if(type==1){
        rsTop = [_net.db executeQuery:@"SELECT * FROM VoucherTopTypeC WHERE countDivide <> 0"];
    }
    else if(type==2){
        rsTop = [_net.db executeQuery:@"SELECT * FROM VoucherTopTypeC WHERE countDivide <> 0"];
    }

    NSMutableArray *menuTop = [[NSMutableArray alloc]init];
    while([rsTop next])
    {
        NSMutableDictionary *dic = [[NSMutableDictionary alloc]init];
        //テーブル「VoucherTopTypeC」の内容
        for (int ct = 0; ct < [rsTop columnCount]; ct++) {
            NSString *column = [rsTop columnNameForIndex:ct];
            [dic setValue:[rsTop stringForColumn:column] forKey:column];
        }
        //商品名
        FMResultSet *rsSyohin = [_net.db executeQuery:@"SELECT HTDispNMU,HTDispNMM,HTDispNML FROM Syohin_MT WHERE MstSyohinCD = ?",dic[@"SyohinCD"]];
        [rsSyohin next];
        NSMutableString* mutStr = [NSMutableString string];
        [mutStr setString:   [[rsSyohin stringForColumn:@"HTDispNMU"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [mutStr appendString:[[rsSyohin stringForColumn:@"HTDispNMM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [mutStr appendString:[[rsSyohin stringForColumn:@"HTDispNML"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
        [rsSyohin close];
        [dic setValue:mutStr forKey:@"SyohinName"];
        //該当する「オーダー種類マスタ」の内容
        if ([dic[@"OrderType"] isEqualToString:@"00"]) {
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                [dic setValue:@"Normal" forKey:@"OrderTypeName"];
            } else {
                [dic setValue:@"指定なし" forKey:@"OrderTypeName"];
            }
        } else {
            FMResultSet *rsNote = [_net.db executeQuery:@"SELECT HTDispNM,ModifyName FROM Note_MT WHERE NoteId = ?",dic[@"OrderType"]];
            [rsNote next];
            if ([[rsNote stringForColumn:@"ModifyName"] isEqualToString:@""]) {
                [dic setValue:[rsNote stringForColumn:@"HTDispNM"] forKey:@"OrderTypeName"];
            } else {
                [dic setValue:[rsNote stringForColumn:@"ModifyName"] forKey:@"OrderTypeName"];
            }
            [rsNote close];
        }
        [dic setValue:@"0" forKey:@"OrderTypeKubun"];
        [menuTop addObject:dic];
    }
    [rsTop close];
    return menuTop;
}


//複数入力の物かの判定
- (NSInteger)entryIsEnabled:(NSMutableDictionary*)_menu
                  key:(NSString*)key{
    //LOG(@"%d:%d",[_menu[@"LimitCount"]intValue],[_menu[key]intValue]);
    
    int maxCount = [_menu[key]intValue];
    int num = 9999;
    
    
    NSArray *_sub1CateList = [self getSubCategoryList:_menu];
    for (int ct = 0; ct < [_sub1CateList count]; ct++) {
        NSMutableDictionary *_sub1Cate = [_sub1CateList objectAtIndex:ct];
        
        NSArray *_sub1List  = [self getSubMenuList:_sub1Cate];
        //LOG(@"%@",_sub1List);
        int currentCount = [self countFromArray:[_sub1List valueForKey:key]];
        //LOG(@"%d:%d",maxCount,currentCount);
        
        //1=同数のみ　2=多可 3=少可 4=制限無し 5=ノンセレクト
        int Limit = [_sub1Cate[@"LimitCount"]intValue];
        switch (Limit) {
            case 1:
                if (currentCount != maxCount) {
                    return ct;
                }
                break;
                
            case 2:
                if (currentCount < maxCount) {
                    return ct;
                }
                break;
                
            case 3:
                if (currentCount > maxCount) {
                    return ct;
                }
                break;
                
            case 4:
                
                break;
                
            case 5:
                
                break;
                
            default:
                break;
        }
    }
    
    LOG(@"%d",num);
    
    return num;
}

//2015-12-24 ueda ASTERISK
- (NSInteger)entryIsEnabled:(NSMutableDictionary*)_menu
                        key:(NSString*)key
                 checkCount:(NSInteger)_checkCount {
    int maxCount = [_menu[key]intValue];
    int num = 9999;
    
    
    NSArray *_sub1CateList = [self getSubCategoryList:_menu];
    //for (int ct = 0; ct < [_sub1CateList count]; ct++) {
    NSInteger ctMax = [_sub1CateList count];
    if (_checkCount != 9999) {
        ctMax = _checkCount;
    }
    for (int ct = 0; ct < ctMax; ct++) {
        NSMutableDictionary *_sub1Cate = [_sub1CateList objectAtIndex:ct];
        
        NSArray *_sub1List  = [self getSubMenuList:_sub1Cate];
        //LOG(@"%@",_sub1List);
        int currentCount = [self countFromArray:[_sub1List valueForKey:key]];
        //LOG(@"%d:%d",maxCount,currentCount);
        
        //1=同数のみ　2=多可 3=少可 4=制限無し 5=ノンセレクト
        int Limit = [_sub1Cate[@"LimitCount"]intValue];
        switch (Limit) {
            case 1:
                if (currentCount != maxCount) {
                    return ct;
                }
                break;
                
            case 2:
                if (currentCount < maxCount) {
                    return ct;
                }
                break;
                
            case 3:
                if (currentCount > maxCount) {
                    return ct;
                }
                break;
                
            case 4:
                
                break;
                
            case 5:
                
                break;
                
            default:
                break;
        }
    }
    
    LOG(@"%d",num);
    
    return num;

}


- (int)countFromArray:(NSArray*)_array{
    int index = 0;
    for (int ct = 0; ct < [_array count]; ct++) {
        index = index + [[_array objectAtIndex:ct]intValue];
    }
    return index;
}

- (BOOL)checkArangeIsEnable:(NSString*)TopSyohinCD{

    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSUInteger count = [_net.db intForQuery:@"SELECT count(TopSyohinCD) FROM Arrange where TopSyohinCD = ? and trayNo = ?",
                        TopSyohinCD,
                        [DataList sharedInstance].TrayNo
                        ];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    if (count>0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)checkArangeIsEnableForSub1:(NSString*)TopSyohinCD
                      Sub1SyohinCD:(NSString*)Sub1SyohinCD{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    NSUInteger count = [_net.db intForQuery:@"SELECT count(TopSyohinCD) FROM Arrange where TopSyohinCD = ? and Sub1SyohinCD = ? and trayNo = ?",
                        TopSyohinCD,
                        Sub1SyohinCD,
                        [DataList sharedInstance].TrayNo
                        ];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    if (count>0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)checkArangeMenuIsExit{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];

    System *sys = [System sharedInstance];
    //2016-03-15 ueda
/*
    NSUInteger count = [_net.db intForQuery:@"SELECT count(PatternCD) FROM Cate_MT WHERE PatternCD = 9",
                        sys.menuPatternType];
 */
    //2016-03-15 ueda
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    NSUInteger count = [_net.db intForQuery:@"SELECT count(PatternCD) FROM Cate_MT WHERE PatternCD = 9",
                        menuPatternCD];
    
    if ([_net.db hadError]) {
        LOG(@"Err read %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    if (count>0) {
        return YES;
    }
    
    return NO;
}

- (BOOL)keppinCheck:(NSString*)SyohinCD{
    DataList *_data = [DataList sharedInstance];
    NSArray *_array = [_data.syohinStatusList valueForKeyPath:@"SyohinCD"];
    
    if ([_array containsObject:SyohinCD]) {
        NSInteger _index = [_array indexOfObject:SyohinCD];
        NSMutableDictionary *_sStatus = [_data.syohinStatusList objectAtIndex:_index];
        if ( [_sStatus[@"count"]intValue]==0) {
            return YES;
        }
    }
    return NO;
}


-(NSString*)appendSpace:(NSString*)str
            totalLength:(int)length{
    NSMutableString *mutable = [[NSMutableString alloc]init];
    [mutable appendString:str];
    if ([mutable length]<length) {
        for (int ct1 = 0; ct1<length-[str length]; ct1++) {
            [mutable appendString:@" "];
        }
    }
    return [NSString stringWithFormat:@"%@",mutable];
}

//2014-09-13 ueda
#pragma mark Ueda Added

//エントリーしたオーダーをタイプＣのテーブルにコピーする
-(void)typeCcopyDB {
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];

    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    DataList *dat = [DataList sharedInstance];
    NSString * sql1 = nil;
    NSString * sql2 = nil;
    NSString * sql3 = nil;
    NSString * sql4 = nil;
    
    if (dat.typeCseatSelect.count == 0) {
        //席番が選択されていない場合
        sql1 = @"INSERT INTO VoucherTopTypeC (id,OrderIndex,SeatNumber,OrderType,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,'00' AS SeatNumber,? AS OrderType,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo FROM VoucherTop ";
        [net.db executeUpdate:sql1,
         [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
         dat.currentNoteID
         ];
        sql2 = @"INSERT INTO Voucher1TypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,'00' AS SeatNumber,? AS OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher1 ";
        [net.db executeUpdate:sql2,
         [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
         dat.currentNoteID
         ];
        
        sql3 = @"INSERT INTO Voucher2TypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,'00' AS SeatNumber,? AS OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher2 ";
        [net.db executeUpdate:sql3,
         [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
         dat.currentNoteID
         ];
        
        sql4 = @"INSERT INTO ArrangeTypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo) SELECT id,? AS OrderIndex,'00' AS SeatNumber,? OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo FROM Arrange ";
        [net.db executeUpdate:sql4,
         [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
         dat.currentNoteID
         ];

    } else {
        sql1 = @"INSERT INTO VoucherTopTypeC (id,OrderIndex,SeatNumber,OrderType,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,? AS SeatNumber,? AS OrderType,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo FROM VoucherTop ";
        sql2 = @"INSERT INTO Voucher1TypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,? AS SeatNumber,? AS OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher1 ";
        sql3 = @"INSERT INTO Voucher2TypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,? AS OrderIndex,? AS SeatNumber,? AS OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher2 ";
        sql4 = @"INSERT INTO ArrangeTypeC (id,OrderIndex,SeatNumber,OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo) SELECT id,? AS OrderIndex,? AS SeatNumber,? OrderType,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo FROM Arrange ";

        for (int i = 0; i < dat.typeCseatSelect.count; i++) {
            //席番の数分
            NSMutableDictionary *selectSeat = [dat.typeCseatSelect objectAtIndex:i];
            [net.db executeUpdate:sql1,
             [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
             selectSeat[@"keyText"],
             dat.currentNoteID
             ];
            
            [net.db executeUpdate:sql2,
             [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
             selectSeat[@"keyText"],
             dat.currentNoteID
             ];
            
            [net.db executeUpdate:sql3,
             [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
             selectSeat[@"keyText"],
             dat.currentNoteID
             ];

            [net.db executeUpdate:sql4,
             [NSString stringWithFormat:@"%zd",appDelegate.typeCorderIndex],
             selectSeat[@"keyText"],
             dat.currentNoteID
             ];

        }
    }

    [net.db commit];
    [net closeDb];
}

//タイプＣのテーブルのレコード削除
-(void)typeCclearDB {
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];
    [net.db executeUpdate:@"DELETE FROM VoucherTopTypeC"];
    [net.db executeUpdate:@"DELETE FROM Voucher1TypeC"];
    [net.db executeUpdate:@"DELETE FROM Voucher2TypeC"];
    [net.db executeUpdate:@"DELETE FROM ArrangeTypeC"];
    [net.db executeUpdate:@"DELETE FROM MenuExt_MT"];
    //2014-09-18 ueda
    [net.db executeUpdate:@"UPDATE Note_MT SET ModifyName = '' "];
    [net.db commit];
    [net closeDb];
}

//2014-09-09 ueda
//タイプＣの席番情報
-(NSMutableArray*)getSeatNumberData {
    NSArray *abcText = @[@"A",@"B",@"C",@"D",@"E",@"F",@"G",@"H",@"I",@"J",@"K",@"L"];
    NSMutableArray *seatNumberData = [[NSMutableArray alloc] init];
    for (int i = 1; i <= 6; i ++)
    {
        seatNumberData[i - 1] = @{@"keyText"   : [NSString stringWithFormat:@"%02d", i],
                                  @"titleText" : [NSString stringWithFormat:@"%d", i],
                                  @"abcText"   : abcText[i - 1],
                                  @"dummy"     : @0,
                                  };
    }
    int p = 6;
    for (int i = 12; i >= 7; i --)
    {
        seatNumberData[p    ] = @{@"keyText"   : [NSString stringWithFormat:@"%02d", i],
                                  @"titleText" : [NSString stringWithFormat:@"%d", i],
                                  @"abcText"   : abcText[i - 1],
                                  @"dummy"     : @0,
                                  };
        p++;
    }
    return seatNumberData;
}

//通常のオーダーテーブルに戻す
-(void)typeCrestoreDB:(NSInteger)orderIndex {
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];

    //席番
    [DataList sharedInstance].typeCseatSelect = [[NSMutableArray alloc]init];
    NSMutableArray *_seatNumberData = self.getSeatNumberData;
    NSString *sql00 = @"SELECT SeatNumber FROM VoucherTopTypeC WHERE OrderIndex = ? GROUP BY SeatNumber ";
    FMResultSet *rsSeatNumber = [net.db executeQuery:sql00,[NSString stringWithFormat:@"%zd",orderIndex]];
    while ([rsSeatNumber next]) {
        if ([[rsSeatNumber stringForColumn:@"SeatNumber"] isEqualToString:@"00"]) {
            //未選択
        } else {
            NSMutableDictionary *search = [_seatNumberData objectAtIndex:[[_seatNumberData valueForKeyPath:@"keyText"] indexOfObject:[rsSeatNumber stringForColumn:@"SeatNumber"]]];
            [[DataList sharedInstance].typeCseatSelect addObject:search];
        }
    }
    [rsSeatNumber close];
    
    //オーダー種類
    NSString *sql01 = @"SELECT OrderType FROM VoucherTopTypeC WHERE OrderIndex = ? ";
    FMResultSet *rsOrderType = [net.db executeQuery:sql01,[NSString stringWithFormat:@"%zd",orderIndex]];
    if ([rsOrderType next]) {
        [DataList sharedInstance].currentNoteID = [rsOrderType stringForColumn:@"OrderType"];
    }
    [rsOrderType close];
    
    //注文データ
    NSString *sql11 = @"INSERT INTO VoucherTop (id,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo) SELECT id,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo FROM VoucherTopTypeC WHERE OrderIndex = ? GROUP BY id,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo ";
    [net.db executeUpdate:sql11,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql12 = @"INSERT INTO Voucher1 (id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher1TypeC WHERE OrderIndex = ? GROUP BY id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo ";
    [net.db executeUpdate:sql12,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql13 = @"INSERT INTO Voucher2 (id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher2TypeC WHERE OrderIndex = ? GROUP BY id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo ";
    [net.db executeUpdate:sql13,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql14 = @"INSERT INTO Arrange (id,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo FROM ArrangeTypeC WHERE OrderIndex = ? GROUP BY id,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo ";
    [net.db executeUpdate:sql14,[NSString stringWithFormat:@"%zd",orderIndex]];

    NSString *sql21 = @"DELETE FROM VoucherTopTypeC WHERE OrderIndex = ? ";
    [net.db executeUpdate:sql21,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql22 = @"DELETE FROM Voucher1TypeC   WHERE OrderIndex = ? ";
    [net.db executeUpdate:sql22,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql23 = @"DELETE FROM Voucher2TypeC   WHERE OrderIndex = ? ";
    [net.db executeUpdate:sql23,[NSString stringWithFormat:@"%zd",orderIndex]];
    NSString *sql24 = @"DELETE FROM ArrangeTypeC    WHERE OrderIndex = ? ";
    [net.db executeUpdate:sql24,[NSString stringWithFormat:@"%zd",orderIndex]];

    [net.db commit];
    [net closeDb];
}

//2014-10-01 ueda
-(void)typeCrestoreDBall {
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];
    
    //注文データ
    NSString *sql11 = @"INSERT INTO VoucherTop (id,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo) SELECT id,PatternCD,CateCD,EdaNo,SyohinCD,count,countDivide,Jika,trayNo FROM VoucherTopTypeC ";
    [net.db executeUpdate:sql11];
    NSString *sql12 = @"INSERT INTO Voucher1 (id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher1TypeC ";
    [net.db executeUpdate:sql12];
    NSString *sql13 = @"INSERT INTO Voucher2 (id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,CondiGCD,CondiGDID,GCD,CD,count,countDivide,Jika,trayNo FROM Voucher2TypeC ";
    [net.db executeUpdate:sql13];
    NSString *sql14 = @"INSERT INTO Arrange (id,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo) SELECT id,EdaNo,TopSyohinCD,Sub1SyohinCD,SyohinCD,count,countDivide,Jika,PageNo,Layer,trayNo FROM ArrangeTypeC ";
    [net.db executeUpdate:sql14];
    
    NSString *sql21 = @"DELETE FROM VoucherTopTypeC ";
    [net.db executeUpdate:sql21];
    NSString *sql22 = @"DELETE FROM Voucher1TypeC ";
    [net.db executeUpdate:sql22];
    NSString *sql23 = @"DELETE FROM Voucher2TypeC ";
    [net.db executeUpdate:sql23];
    NSString *sql24 = @"DELETE FROM ArrangeTypeC ";
    [net.db executeUpdate:sql24];
    
    [net.db commit];
    [net closeDb];
}

//2014-09-10 ueda
-(NSString*)getCategoryCode:(NSString*)syohinCode {
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];

    NSString *retVal;
    NSString *sql00 = @"SELECT CateCD FROM Menu_MT WHERE PatternCd = ? AND SyohinCD = ? ";
    //2016-03-15 ueda
/*
    FMResultSet *rsMenu = [net.db executeQuery:sql00,[System sharedInstance].menuPatternType,syohinCode];
 */
    //2016-03-15 ueda
    System *sys = [System sharedInstance];
    NSString *menuPatternCD;
    if ([sys.menuPatternEnable isEqualToString:@"1"]) {
        menuPatternCD = sys.menuPattern;
    } else {
        menuPatternCD = sys.menuPatternType;
    }
    FMResultSet *rsMenu = [net.db executeQuery:sql00,menuPatternCD,syohinCode];
    if ([rsMenu next]) {
        retVal = [rsMenu stringForColumn:@"CateCD"];
    } else {
        retVal = @"0";
    }
    [rsMenu close];

    [net closeDb];
    
    return retVal;
}

//2014-09-17 ueda
-(void)addMenuExtMt:(NSString*)inputText {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.typeCarrangeCount ++;

    NSString *addOdr  = [NSString stringWithFormat:@"9%03zd", appDelegate.typeCarrangeCount];
    NSString *addCode = [NSString stringWithFormat:@"A%03zd", appDelegate.typeCarrangeCount];

    NSMutableString *tmpText;
    tmpText = [[NSMutableString alloc]init];
    [tmpText appendString:inputText];
    [tmpText appendString:@"　　　　　　　　　　　　"]; //全角スペース１２個
    NSString *arrangeText = tmpText;
    NSInteger nextStart = 0;
    NSString *nm1;
    NSString *nm2;
    NSString *nm3;
    for (int ct = 0; ct < 3; ct ++) {
        tmpText = [[NSMutableString alloc]init];
        BOOL canLoop = YES;
        for (NSInteger ptr = nextStart; canLoop && ptr < [arrangeText length]; ptr++) {
            NSString *subText = [arrangeText substringWithRange:NSMakeRange(nextStart,ptr - nextStart + 1)];
            NSInteger lenByte = [subText lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
            if (lenByte <= 8) {
                tmpText = [[NSMutableString alloc]init];
                [tmpText appendString:subText];
            } else {
                nextStart = ptr;
                canLoop   = NO;
            }
        }
        if (canLoop) {
            nextStart = [arrangeText length];
        }
        if ([tmpText lengthOfBytesUsingEncoding:NSShiftJISStringEncoding] == 7) {
            [tmpText appendString:@" "];
        }
        switch (ct) {
            case 0:
                if ([tmpText isEqualToString:@""]) {
                    nm1 = @"";
                } else {
                    nm1 = tmpText;
                }
                break;
            case 1:
                if ([tmpText isEqualToString:@""]) {
                    nm2 = @"";
                } else {
                    nm2 = tmpText;
                }
                break;
            case 2:
                if ([tmpText isEqualToString:@""]) {
                    nm3 = @"";
                } else {
                    nm3 = tmpText;
                }
                break;
            default:
                break;
        }
    }
    
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];

    BOOL wDoFlag = YES;
    FMResultSet *rsCate = [net.db executeQuery:@"SELECT * FROM Cate_MT WHERE PatternCD='9' AND MstCateCD='9'"];
    if ([rsCate next]) {
        wDoFlag = NO;
    }
    [rsCate close];
    if (wDoFlag) {
        NSString *cateNm;
        if ([[System sharedInstance].lang isEqualToString:@"1"]) {
            cateNm = @"INPUT";
        } else {
            cateNm = @"入力";
        }
        [net.db executeUpdate:@"insert into Cate_MT (PatternCD,MstCateCD,CateNM) values (?, ?, ?)",
         @"9",
         @"9",
         cateNm
         ];
    }
    
    [net.db executeUpdate:@"insert into MenuExt_MT (PatternCD,CateCD,DispOrder,SyohinCD,BNGFLG,HTDispNMU,HTDispNMM,HTDispNML) values (?, ?, ?, ?, ?, ?, ?, ?)",
     @"9",
     @"9",
     addOdr,
     addCode,
     @"0",
     nm1,
     nm2,
     nm3
     ];
    
    [net.db commit];
    [net closeDb];
}

//2014-09-17 ueda
-(void)updateNoteMt:(NSString*)code
    modifyName:(NSString*)modifyName {
    
    NetWorkManager *net = [NetWorkManager sharedInstance];
    [net openDb];
    [net.db beginTransaction];

    NSString *byteText = [System getByteText:(NSString*)modifyName length:60];
    NSString *saveText = [byteText stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];

    [net.db executeUpdate:@"UPDATE Note_MT SET ModifyName = ? WHERE NoteID = ?",
     saveText,
     code
     ];
    
    [net.db commit];
    [net closeDb];
}

//2015-06-01 ueda
- (NSMutableArray*)loadOrderStatus:(NSInteger)type {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = nil;
    if (type==0) {
        results = [_net.db executeQuery:@"SELECT * FROM OrderStat_DT ORDER BY LastDate DESC"];
    } else {
        results = [_net.db executeQuery:@"SELECT * FROM OrderStat_DT ORDER BY LastDate "];
    }
    
    NSMutableArray *master = [[NSMutableArray alloc]init];
    
    while([results next]) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [master addObject:_dic];
    }
    
    [_net closeDb];
    
    return master;
}
- (NSMutableArray*)loadReserveList:(NSInteger)type {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = nil;
    if (type==0) {
        results = [_net.db executeQuery:@"SELECT * FROM Reserve_DT ORDER BY ReserveTime "];
    } else {
        results = [_net.db executeQuery:@"SELECT * FROM Reserve_DT ORDER BY ReserveTime DESC"];
    }

    NSMutableArray *master = [[NSMutableArray alloc]init];
    
    while([results next]) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [master addObject:_dic];
    }
    
    [_net closeDb];
    
    return master;
}

@end
