//
//  DataList.m
//  Order
//
//  Created by koji kodama on 13/04/09.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "DataList.h"
#import "SSGentleAlertView.h"

@implementation DataList
#define SharedInstanceImplementation

//static DataList* sharedInstance = nil;

+ (DataList *)sharedInstance
{
    static DataList *_sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[DataList alloc] init];
        [_sharedInstance reloadTantoList];
    });
    return _sharedInstance;
}

- (id)init{
    self = [super init];
    if (self != nil){
        self.moveToTable = [[NSMutableArray alloc]init];
        self.selectTable = [[NSMutableArray alloc]init];
        self.syohinStatusList = [[NSMutableArray alloc]init];
        //2014-09-05 ueda
        self.typeCseatSelect = [[NSMutableArray alloc]init];
        //2014-09-10 ueda
        self.typeCeditSyohin = nil;
    }
    
    return self;
}

- (void)reloadTantoList{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    FMResultSet *results = nil;
    
    LOG(@"%@",[System sharedInstance].sectionCD);
    if ([[System sharedInstance].sectionCD length]>0) {
        //NSString *section = [NSString stringWithFormat:@"%d",[[System sharedInstance].sectionCD intValue]];
        results = [_net.db executeQuery:@"SELECT * FROM Tanto_MT where sectionCD = ?",[System sharedInstance].sectionCD];
    }
    else{
        results = [_net.db executeQuery:@"SELECT * FROM Tanto_MT"];
    }
    
    
    _tantoList = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            
            if ([column isEqualToString:@"MstTantoCD"]) {
                int num = [[results stringForColumn:column]intValue];
                [_dic setValue:[NSNumber numberWithInt:num] forKey:column];
            }
            else{
                [_dic setValue:[results stringForColumn:column] forKey:column];
            }
        }
        [_tantoList addObject:_dic];
    }
    [results close];
    
    
    NSSortDescriptor *sortDispNo = [[NSSortDescriptor alloc] initWithKey:@"MstTantoCD" ascending:YES] ;
    NSArray *sortDescArray = [NSArray arrayWithObjects:sortDispNo, nil];
    self.tantoList = [[NSMutableArray alloc]initWithArray:[_tantoList sortedArrayUsingDescriptors:sortDescArray]];
    
    
    //check
    if ([_net.db hadError]) {
        NSLog(@"Err %d: %@", [_net.db lastErrorCode], [_net.db lastErrorMessage]);
    }
    
    [_net closeDb];
    
    LOG(@"self.tantoList:%@",self.tantoList);
}

- (void)clearData{
    //self.currentTanto = nil;
    self.currentTable = nil;
    [self.moveToTable removeAllObjects];
    [self.selectTable removeAllObjects];
    self.currentVoucher = nil;
    
    self.currentKyakusoID = nil;
    self.currentKokyakuCD = nil;
    self.currentNoteID = nil;
    self.printMax = nil;
    self.printDefault = nil;
    //self.keppinList = nil;
    
    self.manCount=0;
    self.womanCount=0;
    //2014-10-23 ueda
    self.childCount=0;
    self.divideCount = 1;
    self.dividePage = 0;
    self.menuPage = 0;
    self.Sub1MenuPage = 0;
    self.Sub2MenuPage = 0;
    self.ArrangeMenuPage = 0;
    self.ArrangeMenuPageNo = 9999;
    self.TrayMenuPageNo = 0;
    self.TrayNo = @"00";
    self.orderMessage = @"";
    self.isMove = NO;
    
    [self.tableIDList removeAllObjects];
    //[self.tantoList removeAllObjects];
    [self.tableStatusList removeAllObjects];
    //[self.syohinStatusList removeAllObjects];
    
    //2015-03-24 ueda
    self.Pay_Total = 0;
    self.Pay_DenNo = nil;
}


//通信を伴う場合はYESを返す
- (BOOL)tableCheck:(id)delegate
              type:(int)type{
    
    //テーブルが選択されているかの判定
    if ([self.selectTable count]==0&&!self.currentTable) {
        //2014-01-31 ueda
        //Alert([String Order_Station], [String Table_did_not_select]);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_did_not_select]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        return NO;
    }
    
    
    //経路による条件分岐
    switch (type) {
        case TypeOrderOriginal:{
            
            System *sys = [System sharedInstance];
            

            //選択テーブルの１つ目を選択
            if (self.selectTable.count>0) {
                self.currentTable = self.selectTable[0];
            }
            
            LOG(@"self.selectTable=%@",self.selectTable);
            
            //相席の判定
            BOOL isAiseki = NO;
            for (int ct = 0; ct < [self.selectTable count]; ct++) {
                //2014-12-18 ueda
                //if ([self.selectTable[ct][@"status"] intValue]>3){
                if (([self.selectTable[ct][@"status"] intValue] >= 5) && ([self.selectTable[ct][@"status"] intValue] != 11)){
                    
                    //注文Bタイプの場合は追加の場合があるので、Aの場合のみフラグを更新する
                    //2014-07-07 ueda
                    if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                        isAiseki = YES;
                    }
                }
            }
            if (isAiseki) {
                //確認
                if ([sys.aiseki isEqualToString:@"0"]) {
                    //2014-01-31 ueda
                    //UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Split_Table_for_New_Customer] delegate:delegate cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Split_Table_for_New_Customer]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=delegate;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 501;
                    [alert show];
                    
                    return NO;
                }
                //不許可
                else if ([sys.aiseki isEqualToString:@"2"]) {
                    //2014-01-31 ueda
                    //Alert([String Order_Station], [String Slip_has_been_printed]);
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Slip_has_been_printed]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=nil;
                    [alert addButtonWithTitle:@"OK"];
                    alert.cancelButtonIndex=0;
                    [alert show];
                    return NO;
                }
            }
            
            
            //エントリータイプAorB
            //2014-07-07 ueda
            if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                //人数入力設定 0:しない　1:する
                System *sys = [System sharedInstance];
                if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                    [delegate performSegueWithIdentifier:@"ToOrderEntryView" sender:delegate];
                }
                else{
                    //2014-10-21 ueda
                    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                        //入力タイプＣの場合
                        [delegate performSegueWithIdentifier:@"ToTypeCCountView" sender:delegate];
                    } else {
                        [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                    }
                }
                return NO;
            }
            else{
                //2015-04-07 ueda
/*
                //人数入力設定 0:しない　1:する
                if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                    //2014-10-29 ueda
                    [[NetWorkManager sharedInstance]sendOrderRequest:delegate retryFlag:NO];
                    return YES;
                }
                else{
                    [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                    return NO;
                }
 */
                //2015-04-07 ueda
                if ([sys.kakucho2Type isEqualToString:@"0"]) {
                    //客層入力
                    [delegate performSegueWithIdentifier:@"ToCustomerView" sender:delegate];
                    return NO;
                } else {
                    if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                        [[NetWorkManager sharedInstance]sendOrderRequest:delegate retryFlag:NO];
                        return YES;
                    }
                    else{
                        [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                        return NO;
                    }
                }
            }
            
            
            /*
            LOG(@"%@",self.currentTable);
            if ([self.currentTable[@"status"] intValue]>3) {
                //相席設定にて判定 0:確認　1:許可　2:禁止
                if ([sys.aiseki isEqualToString:@"0"]) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Split_Table_for_New_Customer] delegate:delegate cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                    alert.tag = 501;
                    [alert show];
                    
                    return NO;
                }
                else if ([sys.aiseki isEqualToString:@"1"]) {
                    
                    //エントリータイプAorB
                    if ([sys.entryType isEqualToString:@"0"]) {
                        //人数入力設定 0:しない　1:する
                        System *sys = [System sharedInstance];
                        if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                            [delegate performSegueWithIdentifier:@"ToOrderEntryView" sender:delegate];
                        }
                        else{
                            [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                        }
                        return NO;
                    }
                    else{
                        if ([sys.tableType isEqualToString:@"0"]) {
                            [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                        }
                        else{
                            [[NetWorkManager sharedInstance]sendOrderRequest:delegate];
                        }
                        return NO;
                    }
                }
                else if ([sys.aiseki isEqualToString:@"2"]) {
                    Alert([String Order_Station], [String Slip_has_been_printed]);
                    return NO;
                }
            }
            else{
                //エントリータイプAorB
                if ([sys.entryType isEqualToString:@"0"]) {
                    //人数入力設定 0:しない　1:する
                    System *sys = [System sharedInstance];
                    if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                        [delegate performSegueWithIdentifier:@"ToOrderEntryView" sender:delegate];
                    }
                    else{
                        [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                    }
                }
                else{
                    //人数入力設定 0:しない　1:する
                    LOG(@"%@:%@",sys.ninzu,sys.tableType);
                    if ([sys.ninzu isEqualToString:@"0"]||[sys.tableType isEqualToString:@"1"]) {
                        [[NetWorkManager sharedInstance]sendOrderRequest:delegate];
                    }
                    else{
                        [delegate performSegueWithIdentifier:@"ToCountView" sender:delegate];
                    }
                }
                return NO;
            }
             */
            break;
        }
        case TypeOrderAdd:
            
            LOG(@"TypeOrderAdd:%@",self.currentTable);
            
            if ([self.currentTable[@"status"] intValue]>0&&[self.currentTable[@"status"] intValue]<4) {
                
                //検索機能が有効で追加の際は、全てのテーブルを選択可能
                if (![[System sharedInstance].searchType isEqualToString:@"0"]) {
                    //2014-01-31 ueda
                    //Alert([String Order_Station], [String Table_is_empty]);
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_is_empty]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=nil;
                    [alert addButtonWithTitle:@"OK"];
                    alert.cancelButtonIndex=0;
                    [alert show];
                    return NO;
                }
            }

            
            //検索機能が有効で追加の際は、全てのテーブルを選択可能にするためテーブル状況を表示しない
            if ([[System sharedInstance].searchType isEqualToString:@"0"]&&type==TypeOrderAdd) {
                
                //選択テーブルの１つ目を選択
                if (self.selectTable.count>0) {
                    self.currentTable = self.selectTable[0];
                }
                
                [delegate performSegueWithIdentifier:@"ToOrderEntryView" sender:delegate];
                return NO;
            }
            else{
                //2014-10-23 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
            }

            break;
            
        case TypeOrderCancel:
            if ([self.currentTable[@"status"] intValue]>0&&[self.currentTable[@"status"] intValue]<4) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Table_is_empty]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_is_empty]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return NO;
            }
            else{
                //2014-09-11 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
            }
            break;
            
        case TypeOrderCheck:
            if ([self.currentTable[@"status"] intValue]>0&&[self.currentTable[@"status"] intValue]<4) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Table_is_empty]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_is_empty]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return NO;
            }
            else{
                //2014-09-11 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
            }
            break;
            
        case TypeOrderDivide:
            if ([self.currentTable[@"status"] intValue]>0&&[self.currentTable[@"status"] intValue]<4) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Table_is_empty]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_is_empty]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return NO;
            }
            else{
                //2014-10-02 ueda 分割はとりあえず通常の機能で行う → 商品単位でまとまっていないと分割できないため
/*
                //2014-10-01 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
 */
                //2014-10-23 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
            }
            break;
            
        case TypeOrderMove:{
            LOG(@"2:%@",self.moveToTable);
            if (!self.isMove) {
                //2014-10-24 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    [[NetWorkManager sharedInstance] getVoucherListTypeC:delegate];
                } else {
                    [[NetWorkManager sharedInstance] getVoucherList:delegate];
                }
            }
            else{
                [[NetWorkManager sharedInstance] sendTableMove:delegate];
            }
            
            break;
        }
        case TypeOrderDirection:
            if ([self.currentTable[@"status"] intValue]>0&&[self.currentTable[@"status"] intValue]<4) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Table_is_empty]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_is_empty]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return NO;
            }
            else{
                [[NetWorkManager sharedInstance] sendTableReadyDirection:delegate];
            }
            break;
            
        default:
            break;
    }
    return YES;
}


+(NSString*)appendComma:(NSString*)price{
    NSNumberFormatter *formatter = nil;
    NSString *_price = nil;
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@",###"];
        _price = [formatter stringForObjectValue:[NSNumber numberWithInt:[self intValue:price]]];
    }
    else{
        formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@",##0.00"];
        
        float price1 = [self intValue:price];
        LOG(@"%f",price1);
        _price = [formatter stringForObjectValue:[NSNumber numberWithFloat:price1/100]];
    }
    
    LOG(@"%@",_price);
    
    return _price;
}

+(int)intValue:(NSString*)price{
    
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    NSNumber * myNumber = [f numberFromString:price];
    
    LOG(@"%@",myNumber);
    
    return [myNumber intValue];
}

@end