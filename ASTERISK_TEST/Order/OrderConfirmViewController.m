//
//  OrderConfirmViewController.m
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "OrderConfirmViewController.h"
#import "OrderTypeViewController.h"
#import "TableViewController.h"
#define kMenuCount 5
#import "SSGentleAlertView.h"
//2015-04-06 ueda
#import "CustomerViewController.h"
//2015-04-16 ueda
#import "OrderEntryViewController.h"
//2016-04-08 ueda ASTERISK
/*
//2016-02-04 ueda ASTERISK
#import "ErrorSound.h"
 */

@interface OrderConfirmViewController () {
    //2016-02-02 ueda
    NSMutableString *preTopSyohinName;
    //2016-04-08 ueda ASTERISK
/*
    //2016-02-04 ueda ASTERISK
    ErrorSound *errorSound;
 */
}

@end

@implementation OrderConfirmViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    editingDic = nil;
    if (self.type == TypeOrderCancel) {
        if (showCancel||showDivide) {
            [self hideConfirmDisp];
            return;
        }
        else{
            
            if ([self totalDivideAllCount:self.orderList]>0) {
                //2014-01-30 ueda
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_this_slip] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_this_slip]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                //alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 504;
                [alert show];
                return;
            }
            else{
                //キャンセル＆分割時の場合、注文入力画面を飛ばして伝票入力画面に遷移する
                [[OrderManager sharedInstance] zeroReset];
                NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
                UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:index-2];
                [self.navigationController popToViewController:parent animated:YES];
                return;
            }
        }
    }
    
    
    if (self.type == TypeOrderDivide) {
        if ([[System sharedInstance].bunkatsuType isEqualToString:@"1"]||dat.dividePage==0) {
            if ([self totalDivideAllCount:self.orderList]>0) {
                //2014-01-30 ueda
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_this_slip] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_this_slip]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                //alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 504;
                [alert show];
                return;
            }
            else{
                //キャンセル＆分割時の場合、注文入力画面を飛ばして伝票入力画面に遷移する
                [[OrderManager sharedInstance] zeroReset];
                NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
                UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:index-2];
                [self.navigationController popToViewController:parent animated:YES];
                return;
            }
        }
        else{
            //現在が最後のページで入力されている分割商品数が0なら、分割数を１減らす
            LOG(@"%zd:%zd",dat.dividePage,dat.divideCount);
            if (dat.dividePage+1==dat.divideCount) {
                
                LOG(@"orderList:%@",self.orderList);
                
                int totalCount = 0;
                for (int ct = 0;ct<[self.orderList count]; ct++) {
                    NSMutableDictionary *menu = self.orderList[ct];
                    NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
                    LOG(@"divide:%@",divide);
                    totalCount = totalCount + [divide[dat.dividePage]intValue];
                }
                
                LOG(@"totalCount:%d",totalCount);
                if (totalCount==0) {
                    [self removeLastDivideCount];
                }
            }
            
            dat.dividePage --;
            menuPage = 0;//分割時は数量０が表示されなくなるのでページ頭に戻す
            [self.table reloadData];
            [self reloadDispData];
        }
    }
    else{
        self.table.delegate = nil;
        self.table.dataSource = nil;
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)iba_showNext:(id)sender{
    
    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
    
    //2014-12-16 ueda
    //BOOL isLoading = NO;
    switch (self.type) {
        case TypeOrderOriginal:
            
            //注文が0の場合はアラート表示
            if ([self.orderList count]==0) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String No_order2]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_order2]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return;
            }
            //2014-07-07 ueda
            //入力タイプＣ
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                [self performSegueWithIdentifier:@"ToSeatNumberView" sender:nil];
                return;
            }
            
            //要オーダー種類入力の場合は遷移
            if ([[System sharedInstance].orderType isEqualToString:@"1"]) {
                [self performSegueWithIdentifier:@"ToOrderTypeView" sender:nil];
                return;
            }
            
            //入力タイプAorBの判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                [self showIndicator];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                //2014-10-29 ueda
                [_net sendOrderRequest:self retryFlag:NO];
            }
            else{
                [self goToBType];
            }
            
            break;
            
        case TypeOrderAdd:{
            
            //注文が0の場合はアラート表示
            if ([self.orderList count]==0) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String No_order2]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_order2]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return;
            }

            //2014-09-11 ueda
            //入力タイプＣ
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                [self performSegueWithIdentifier:@"ToSeatNumberView" sender:nil];
                return;
            }

            //要オーダー種類入力の場合は遷移
            if ([[System sharedInstance].orderType isEqualToString:@"1"]) {
                [self performSegueWithIdentifier:@"ToOrderTypeView" sender:nil];
                return;
            }
            
            //入力タイプAorBの判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                [self showIndicator];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                //2014-10-29 ueda
                [_net sendOrderAdd:self retryFlag:NO];
            }
            else{
                [self goToBType];
            }
            
            break;
        }
        case TypeOrderCancel:{
            int count = 0;
            for (int ct = 0; ct < [self.orderList count]; ct++) {
                NSMutableDictionary *_dic = [self.orderList objectAtIndex:ct];
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                count = count + [divide[dat.dividePage] intValue];
                
                [DataList sharedInstance].divideCount = MAX([DataList sharedInstance].divideCount,[divide count]);
                
                if(![[_dic allKeys] containsObject:@"SG1ID"]&&![[_dic allKeys] containsObject:@"SG2ID"]&&
                   [_dic[@"trayNo"]intValue]==0){
                    if (![self checkArrangeCount:_dic[@"SyohinCD"]
                                     divideCount:divide
                                      totalCount:[_dic[@"count"]intValue]]) {
                        //2014-01-31 ueda
                        //Alert([String Order_Station],[String No_canceled_date]);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_canceled_date]];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        return;
                    }
                }
            }
            
            
            if (count>0) {
                if (showCancel) {
                    //2014-12-16 ueda
                    //isLoading = YES;
                    [self showIndicator];
                    
                    NetWorkManager *_net = [NetWorkManager sharedInstance];
                    //2014-09-12 ueda
                    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                        [orderManager typeCcopyDB];
                        //2016-02-02 ueda
                        //[orderManager zeroReset];
                        [_net sendOrderCancelTypeC:self retryFlag:NO];
                    } else {
                        //2014-10-29 ueda
                        [_net sendOrderCancel:self retryFlag:NO];
                    }
                }
                else{
                    showCancel = YES;
                    [self showConfirmDisp];
                }
            }
            else{
                //2014-01-31 ueda
                //Alert([String Order_Station], [String No_canceled]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_canceled]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
            break;
        }
        case TypeOrderCheck:
            
            break;
            
        case TypeOrderDivide:{

            isFinish = YES;
            int countDividePageTotal = 0;
            int countDivideTotal = 0;
            int count = 0;
            
            //各種カウント取得とアレンジデータとの整合をﾁｪｯｸする
            for (int ct = 0; ct < [self.orderList count]; ct++) {
                NSMutableDictionary *_dic = [self.orderList objectAtIndex:ct];
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                countDividePageTotal = countDividePageTotal + [divide[dat.dividePage]intValue];
                countDivideTotal = countDivideTotal + [self totalDivideCount:divide];
                count = count + [_dic[@"count"] intValue];
                
                [DataList sharedInstance].divideCount = MAX([DataList sharedInstance].divideCount,[divide count]);
                
                if(![[_dic allKeys] containsObject:@"SG1ID"]&&![[_dic allKeys] containsObject:@"SG2ID"]&&
                   [_dic[@"trayNo"]intValue]==0){
                    if (![self checkArrangeCount:_dic[@"SyohinCD"]
                                     divideCount:divide
                                      totalCount:[_dic[@"count"]intValue]]) {
                        
                        //2014-01-31 ueda
                        //Alert([String Order_Station],[String No_canceled_date]);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_canceled_date]];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        return;
                    }
                }
            }
            
            
            //商品数が登録させれているか確認
            //2015-01-08 ueda
            //if (count<=1&&dat.dividePage==0) {
            if ((count < 1) && (dat.dividePage == 0)) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Cannot_be_divide1]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cannot_be_divide1]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return;
            }
            
            //分割個数が登録されているか判定
            if (countDividePageTotal==0) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String Choose]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Choose]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                return;
            }


            if ([[System sharedInstance].bunkatsuType isEqualToString:@"1"]) {// 0=10分割　1=2分割
                if (count<=countDividePageTotal) {
                    //2014-01-31 ueda
                    //Alert([String Order_Station], [String Cannot_be_divide2]);
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cannot_be_divide2]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=nil;
                    [alert addButtonWithTitle:@"OK"];
                    alert.cancelButtonIndex=0;
                    [alert show];
                    return;
                }
                //2014-01-30 ueda
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Divide_Execute] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Divide_Execute]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 602;
                [alert show];
                
                if (dat.divideCount<2) {
                    [self appendRetainArray];
                }
                dat.divideCount = 2;
            }
            else{
                //残カウントが0なら送信
                LOG(@"%d:%d",countDivideTotal,count);
                if (countDivideTotal==count&&dat.dividePage==[DataList sharedInstance].divideCount-1) {
                    
                    
                    if (dat.dividePage==0) {
                        //2014-01-31 ueda
                        //Alert([String Order_Station], [String Choose]);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Choose]];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        return;
                    }
                    
                    NSString *str = [NSString stringWithFormat:[String Divide_Execute_some],[DataList sharedInstance].divideCount];
                    //2014-01-30 ueda
                    /*
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:str delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                    */
                    //2014-01-30 ueda
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",str];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 602;
                    [alert show];
                }
                else{
                    
                    if (dat.dividePage==9) {
                        //2014-01-31 ueda
                        //Alert([String Order_Station], [String Can_be_divided]);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Can_be_divided]];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        return;
                    }
                    
                    [self appendZeroArray];
                    dat.dividePage ++;
                    menuPage = 0;//分割時は数量０が表示されなくなるのでページ頭に戻す
                    [self reloadDispData];
                }
            }
            
            break;
        }
        case TypeOrderDirection:
            if ([directionList count]>0) {
                //2014-12-16 ueda
                //isLoading = YES;
                [self showIndicator];
                
                [[NetWorkManager sharedInstance] sendOrderDirection:self
                                                               list:directionList];
            }
            break;
            
            
        default:
            break;
    }
    
    //2014-12-16 ueda
/*
    if(isLoading){
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
        [mbProcess show:YES];
    }
 */
}

- (int)totalDivideAllCount:(NSArray*)array {
    int count = 0;
    for (int ct = 0; ct<[array count]; ct++) {
        NSDictionary *_dic = array[ct];
        NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
        int countDivideTotal = [self totalDivideCount:divide];
        count = count + countDivideTotal;
    }
    return count;
}

- (void)goToBType{
    self.type = TypeOrderOriginal;
    //2015-04-07 ueda
/*
    if ([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) {
        [self performSegueWithIdentifier:@"ToCustomerView" sender:nil];
    }
    else if([[System sharedInstance].kakucho2Type isEqualToString:@"1"]){
        if ([[System sharedInstance].tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:nil];
        }
        else{
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
 */
    //2015-04-07 ueda
    if (([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) || ([[System sharedInstance].kakucho2Type isEqualToString:@"1"])) {
        if ([[System sharedInstance].tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:nil];
        }
        else{
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
    else{
        [self performSegueWithIdentifier:@"SearchView" sender:@"typeKokyaku"];
    }
    
    /*
    else if(alertView.tag==604){
        self.type = TypeOrderAdd;
        
        if ([[System sharedInstance].tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:nil];
        }
        else{
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
    */
}



//アレンジ商品の選択が整合しているかの判定
- (BOOL)checkArrangeCount:(NSString*)SyohinCD
                    divideCount:(NSArray*)divide
                    totalCount:(int)totalCount{
    
    //対応するアレンジ商品の配列を取得する
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results2 = [_net.db executeQuery:@"SELECT * FROM Arrange where TopSyohinCD = ?",
                             SyohinCD];
    NSMutableArray *_menuArrange = [[NSMutableArray alloc]init];
    while([results2 next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results2 columnCount]; ct++) {
            NSString *column = [results2 columnNameForIndex:ct];
            [_dic setValue:[results2 stringForColumn:column] forKey:column];
        }
        [_menuArrange addObject:_dic];
    }
    [results2 close];
    [_net closeDb];
    
    LOG(@"_menuArrange:%@",_menuArrange);
    
    //PageNoでカウントを集計する
    if ([_menuArrange count]>0) {

        
        //現在のページNo別にカウントを集計
        NSMutableDictionary *countTemp = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [_menuArrange count]; ct++) {
            NSMutableDictionary *_dic = [_menuArrange objectAtIndex:ct];
            NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
            [countTemp setValue:divide forKey:_dic[@"PageNo"]];
        }
        
        LOG(@"countTemp:%zd:%@",[countTemp count],countTemp);
        
        int arrangeTotalCount = 0;
        for (int ct = 0; ct < [countTemp count]; ct++) {
            NSArray *subDivide = [countTemp allValues][ct];
            BOOL isDivide = NO;
            for (int count = 0; count < [subDivide count]; count++) {
                if ([subDivide[count]intValue]>0) {
                    isDivide = YES;
                }
            }
            
            if (isDivide) {
                arrangeTotalCount ++ ;
            }
        }
        
        /*
        int arrangeTotalCount = [self totalCount:_menuArrange
                                 pageNo:dat.dividePage];
         */
        
        //LOG(@"arrangeTotalCount:%d",arrangeTotalCount);
        
        //count = 親商品の分割数
        //arrangeTotalCount = アレンジ商品の分割orキャンセル数（分子）
        //[countTemp count] = アレンジ商品数（分母）
        //divideCount =　分割商品数の合計を算出する
        int divideCount = 0;
        for (int ct = 0; ct< [divide count]; ct++) {
            divideCount = divideCount + [divide[ct]intValue];
        }
        
        
        //親商品の分割数よりもアレンジ商品の分割数が大きい
        if (divideCount < arrangeTotalCount) {
            return NO;
        }
        
        LOG(@"%zd:%zd:%zd:%zd",totalCount,divideCount,[countTemp count],arrangeTotalCount);
        LOG(@"%zd ? %zd",totalCount-divideCount,[countTemp count]-arrangeTotalCount);
        
        //親商品の分割後残数よりもアレンジ商品の残数が大きい
        if (totalCount-divideCount<[countTemp count]-arrangeTotalCount) {
            return NO;
        }
    }
    return YES;
}


//現在のページNo別にカウントを集計
- (int)totalCount:(NSArray*)array
           pageNo:(int)pageNo{
    
    NSMutableDictionary *countTemp = [[NSMutableDictionary alloc]init];
    
    for (int ct = 0; ct < [array count]; ct++) {
        NSMutableDictionary *_dic = [array objectAtIndex:ct];
        NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
        [countTemp setValue:divide[pageNo] forKey:_dic[@"PageNo"]];
    }
    
    LOG(@"countTemp:%zd:%@",[countTemp count],countTemp);
    
    int totalCount = 0;
    for (int ct = 0; ct < [countTemp count]; ct++) {
        if ([[countTemp allValues][ct] intValue]>0) {
            totalCount ++ ;
        }
    }
    
    return totalCount;
}

//次のページで表示する0配列を追加する
-(void)appendZeroArray{
    //2015-02-16 ueda
    NSMutableArray *list = [orderManager getOrderListForConfirm:NO
                                                     isSubGroup:YES
                                                      isArrange:YES
                                                    typeOrderNo:self.type];
    for (int ct = 0; ct<[list count]; ct++) {
        NSMutableDictionary *menu = list[ct];
        NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
        
        if (divide.count > dat.dividePage+1) {
            break;
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
        array[divide.count] = @"0";
        menu[@"countDivide"] = [array componentsJoinedByString:@","];
        
        
        if([[menu allKeys] containsObject:@"SG1ID"]){
            LOG(@"追加内容の確認　SG1に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:1];
        }
        else if([[menu allKeys] containsObject:@"SG2ID"]){
            LOG(@"追加内容の確認　SG2に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:2];
        }
        else if ([menu[@"ArrangeFLG"] isEqualToString:@"1"]) {
            LOG(@"追加内容の確認　Arrangeに追加:%d:%@",ct,menu);
            
            [orderManager addArrangeMenu:menu
                                    update:NO];
        }
        else{
            LOG(@"追加内容の確認　TOPに追加:%d:%@",ct,menu);
            [orderManager addTopMenu:menu];
        }
        
        [DataList sharedInstance].divideCount = MAX([DataList sharedInstance].divideCount,[array count]);
    }
}

//残りの個数を分割に当てる（2分割時に使用）
-(void)appendRetainArray{
    //次のページで表示する0配列を追加する
    //2015-02-16 ueda
    NSMutableArray *list = [orderManager getOrderListForConfirm:NO
                                                     isSubGroup:YES
                                                      isArrange:YES
                                                    typeOrderNo:self.type];
    for (int ct = 0; ct<[list count]; ct++) {
        NSMutableDictionary *menu = list[ct];
        NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
        
        if (divide.count > dat.dividePage+1) {
            break;
        }
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
        array[divide.count] = [NSString stringWithFormat:@"%d",[menu[@"count"]intValue]-[array[0]intValue]];
        menu[@"countDivide"] = [array componentsJoinedByString:@","];
        
        
        if([[menu allKeys] containsObject:@"SG1ID"]){
            LOG(@"追加内容の確認　SG1に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:1];
        }
        else if([[menu allKeys] containsObject:@"SG2ID"]){
            LOG(@"追加内容の確認　SG2に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:2];
        }
        else if ([menu[@"ArrangeFLG"] isEqualToString:@"1"]) {
            LOG(@"追加内容の確認　Arrangeに追加:%d:%@",ct,menu);
            [orderManager addArrangeMenu:menu
                                    update:NO];
        }
        else{
            LOG(@"追加内容の確認　TOPに追加:%d:%@",ct,menu);
            [orderManager addTopMenu:menu];
        }
        
        [DataList sharedInstance].divideCount = MAX([DataList sharedInstance].divideCount,[array count]);
    }
}

//各分割個数の最後の配列を削除する
-(void)removeLastDivideCount{
    //次のページで表示する0配列を追加する
    //2015-02-16 ueda
    NSMutableArray *list = [orderManager getOrderListForConfirm:NO
                                                     isSubGroup:YES
                                                      isArrange:YES
                                                    typeOrderNo:self.type];
    
    for (int ct = 0; ct<[list count]; ct++) {
        NSMutableDictionary *menu = list[ct];
        NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
        
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];

        LOG(@"array1[%d]:%@",ct,array);
        
        //現在のページの配列を削除
        if ([array count]==dat.dividePage+1) {
            [array removeObjectAtIndex:dat.dividePage];
        }
        
        menu[@"countDivide"] = [array componentsJoinedByString:@","];
        
        
        if([[menu allKeys] containsObject:@"SG1ID"]){
            LOG(@"追加内容の確認　SG1に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:1];
        }
        else if([[menu allKeys] containsObject:@"SG2ID"]){
            LOG(@"追加内容の確認　SG2に追加:%d:%@",ct,menu);
            [orderManager addSubMenu:menu SG:2];
        }
        else if ([menu[@"ArrangeFLG"] isEqualToString:@"1"]) {
            LOG(@"追加内容の確認　Arrangeに追加:%d:%@",ct,menu);
            [orderManager addArrangeMenu:menu
                                    update:NO];
        }
        else{
            LOG(@"追加内容の確認　TOPに追加:%d:%@",ct,menu);
            [orderManager addTopMenu:menu];
        }
        
        [DataList sharedInstance].divideCount = [array count];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //2016-04-08 ueda ASTERISK
/*
    //2016-02-04 ueda ASTERISK
    [errorSound soundOff];
 */
    switch (buttonIndex) {
        case 0:
            if(alertView.tag==602){
                
                showDivide = YES;
                [self showDivideConfirm];
            }
            else if(alertView.tag==603){
                //2014-12-16 ueda
/*
                mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
                //2014-10-30 ueda
                //mbProcess.labelText = @"Loading Data";
                [self.view addSubview:mbProcess];
                [mbProcess setDelegate:self];
                [mbProcess show:YES];
 */
                [self showIndicator];
                
                //2014-10-30 ueda
                orderDivideType = [[NSMutableString alloc]init];
                [orderDivideType appendString:@"1"];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendVoucherDivide:self
                                   type:@"1"
                              retryFlag:NO];
            }
            else if(alertView.tag==504){

                //キャンセル＆分割時の場合、注文入力画面を飛ばして伝票入力画面に遷移する
                [[OrderManager sharedInstance] zeroReset];
                NSInteger index = [self.navigationController.viewControllers indexOfObject:self];
                UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:index-2];
                [self.navigationController popToViewController:parent animated:YES];
            }
            //2014-10-29 ueda
            else if(alertView.tag==1101){
                [self orderSendRetry];
            }
            //2014-12-25 ueda
            else if (alertView.tag==1102){
                [self orderSendForce];
            }
            //2015-04-16 ueda
            else if (alertView.tag==1301){
                OrderEntryViewController *oevc = nil;
                for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
                    UIViewController *vc = self.navigationController.viewControllers[ct];
                    if ([vc isKindOfClass:[OrderEntryViewController class]]) {
                        oevc = (OrderEntryViewController*)vc;
                    }
                }
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.type = TypeOrderAdd;
                [self.navigationController popToViewController:oevc animated:YES];
            }
            
            break;
            
        case 1:
            if(alertView.tag==603){
                //2014-12-16 ueda
/*
                mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
                //2014-10-30 ueda
                //mbProcess.labelText = @"Loading Data";
                [self.view addSubview:mbProcess];
                [mbProcess setDelegate:self];
                [mbProcess show:YES];
 */
                [self showIndicator];
                
                LOG(@"%@",dat.currentVoucher);
                
                //2014-10-30 ueda
                orderDivideType = [[NSMutableString alloc]init];
                [orderDivideType appendString:@"2"];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendVoucherDivide:self
                                   type:@"2"
                              retryFlag:NO];
            }
            //2014-12-25 ueda
            else if (alertView.tag==1102){
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.OrderRequestN31forceFlag = NO;
            }
            //2015-01-08 ueda
            if(alertView.tag==602){
                [self resetValue];
            }
            //2015-04-16 ueda
            else if (alertView.tag==1301){
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
            break;
            
        case 2:
            //2015-01-08 ueda
            if(alertView.tag==603){
                [self resetValue];
            }
            break;
    }
}

- (int)totalDivideCount:(NSArray*)divide{
    int countDivide = 0;
    for (int ct2 = 0; ct2<divide.count; ct2++) {
        countDivide = countDivide + [divide[ct2] intValue];
    }
    return countDivide;
}

-(void)showDivideConfirm{
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Print_Slip] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String Show_slip],[String Cancel1], nil];
    */
	//2014-01-30 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Print_Slip]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String Show_slip]];
    //2015-01-08 ueda
    //[alert addButtonWithTitle:[String Cancel1]];
    [alert addButtonWithTitle:[String Cancel_slip]];
    alert.cancelButtonIndex=0;
    alert.tag = 603;
    [alert show];
}

- (void)showConfirmDisp{

    editingDic = nil;
    menuPage = 0;
    
    [self.table reloadData];
    [self.table scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
    
    self.bt_down.enabled = NO;
    self.bt_up.enabled = NO;
    
    [self reloadDispData];
}

- (void)hideConfirmDisp{
    //2014-02-26 ueda
    /*
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    [delegate buttonSetColorWithButton:self.bt_push
                                 face1:[UIColor colorWithWhite:0.55f alpha:1.0]
                                 face2:[UIColor colorWithWhite:0.35f alpha:1.0]
                                 side1:[UIColor colorWithWhite:0.35f alpha:1.0]
                                 side2:[UIColor colorWithWhite:0.25f alpha:1.0]];
     */
    showCancel = NO;
    showDivide = NO;
    menuPage = 0;
    [self reloadDispData];
    [self.table reloadData];
    [self.table scrollRectToVisible:CGRectMake(0, 0, 10, 10) animated:NO];
}

- (void)countUp:(id)sender{
    
    if (showCancel) {
        return;
    }
    
    UIButton *_bt = (UIButton*)sender;
    LOG(@"_bt.tag:%zd",_bt.tag);
    editingDic = [self.orderList objectAtIndex:_bt.tag];
    
    //2015-07-21 ueda
    NSString *EdaNo = editingDic[@"EdaNo"];
    NSString *trayNo = editingDic[@"trayNo"];
    if (trayNo&&[trayNo intValue]>0) {
        for (int ct = 0; ct < self.orderList.count; ct++) {
            NSMutableDictionary*menu = self.orderList[ct];
            //2015-07-21 ueda
            if (![[menu allKeys]containsObject:@"TopSyohinCD"]&&
                [menu[@"EdaNo"] intValue]==[EdaNo intValue]&&
                [menu[@"trayNo"] intValue]==[trayNo intValue]&&
                [menu[@"MstSyohinCD"]isEqualToString:editingDic[@"TopSyohinCD"]]) {
                editingDic = menu;
                break;
            }
        }
    }
    
    
    BOOL isArrangeMenu = NO;
    if ([editingDic[@"ArrangeFLG"] isEqualToString:@"1"]) {
        isArrangeMenu = YES;
    }
    
    
    if (self.type==TypeOrderCancel) {
        //2014-08-18 ueda
        [System tapSound];
        NSArray *divide = [editingDic[@"countDivide"] componentsSeparatedByString:@","];
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
        
        int count = 0;
        if (isArrangeMenu) {
            count = [editingDic[@"count"]intValue];
        }
        else{
            count = [divide[dat.dividePage] intValue]+1;
        }
        
        //2016-03-31 ueda
/*
        if (count<=[editingDic[@"count"] intValue]) {
 */
        //2016-03-31 ueda
        if ((count<=[editingDic[@"count"] intValue]) && (count<=99)) {
            NSString *_str = [NSString stringWithFormat:@"%d",count];
            array[dat.dividePage] = _str;
            editingDic[@"countDivide"] = [array componentsJoinedByString:@","];
            
            
            if (isArrangeMenu) {
                [orderManager addArrangeMenu:editingDic
                                        update:YES];
            }
            else{
                [orderManager addTopMenu:editingDic];
            }
        }
    }
    else if (self.type==TypeOrderDivide) {
        //2014-08-18 ueda
        [System tapSound];
        //int count = [editingDic[@"countDivide"][dat.dividePage] intValue]+1;
        NSArray *divide = [editingDic[@"countDivide"] componentsSeparatedByString:@","];
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
        
        if (!array) {
            array = [[NSMutableArray alloc]init];
        }
        
        LOG(@"array:%@",array);
        
        //上限数を取得する
        int bunbo = [editingDic[@"count"] intValue];
        
        //上限数から追加可能の個数を取得する
        for (int ct = 0; ct<[array count]; ct++) {
            bunbo = bunbo - [array[ct]intValue];
        }
        
        //追加する個数を生成する
        int bunshi = 0;
        int sabun = 0;
        if (isArrangeMenu) {
            bunshi = [editingDic[@"count"] intValue];
            sabun = [editingDic[@"count"] intValue];
        }
        else{
            bunshi = [array[dat.dividePage]intValue] + 1;
            sabun = 1;
        }
        
        LOG(@"%d:%d:%d",bunshi,bunbo,sabun);
        //2016-03-31 ueda
/*
        if (sabun<=bunbo) {
 */
        //2016-03-31 ueda
        if ((sabun<=bunbo) && (bunshi<=99)) {
            array[dat.dividePage] = [NSString stringWithFormat:@"%d",bunshi];
            NSString *str = [array componentsJoinedByString:@","];
            editingDic[@"countDivide"] = str;

            if (isArrangeMenu) {
                [orderManager addArrangeMenu:editingDic
                                        update:YES];
            }
            else{
                [orderManager addTopMenu:editingDic];
            }
        }
    }

    /*
    int index = _bt.tag - kMenuCount * menuPage;
    [self.table reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForItem:index inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
     */
    //[self.table reloadData];
    [self reloadDispData];
}

- (void)countDown:(id)sender{
    
    if (showCancel) {
        return;
    }
    
    UIButton *_bt = (UIButton*)sender;
    LOG(@"_bt.tag:%zd",_bt.tag);
    editingDic = [self.orderList objectAtIndex:_bt.tag];
    
    //2015-07-21 ueda
    NSString *EdaNo = editingDic[@"EdaNo"];
    NSString *trayNo = editingDic[@"trayNo"];
    if (trayNo&&[trayNo intValue]>0) {
        for (int ct = 0; ct < self.orderList.count; ct++) {
            NSMutableDictionary*menu = self.orderList[ct];
            //2015-07-21 ueda
            if (![[menu allKeys]containsObject:@"TopSyohinCD"]&&
                [menu[@"EdaNo"] intValue]==[EdaNo intValue]&&
                [menu[@"trayNo"] intValue]==[trayNo intValue]&&
                [menu[@"MstSyohinCD"]isEqualToString:editingDic[@"TopSyohinCD"]]) {
                editingDic = menu;
                break;
            }
        }
    }
    
    BOOL isArrangeMenu = NO;
    if ([editingDic[@"ArrangeFLG"] isEqualToString:@"1"]) {
        isArrangeMenu = YES;
    }
    
    
    int count = 0;
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        NSArray *divide = [editingDic[@"countDivide"] componentsSeparatedByString:@","];
        count = [divide[dat.dividePage] intValue];
    }
    
    else{
        count = [editingDic[@"count"] intValue];
    }

    count = 0;
    NSString *_str = [NSString stringWithFormat:@"%d",count];
    
    
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        //2014-08-18 ueda
        [System tapSound];
        NSArray *divide = [editingDic[@"countDivide"] componentsSeparatedByString:@","];
        NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
        array[dat.dividePage] = _str;
        editingDic[@"countDivide"] = [array componentsJoinedByString:@","];
    }
    else{
        editingDic[@"count"] = _str;
    }
    

    if (isArrangeMenu) {
        [orderManager addArrangeMenu:editingDic
                               update:YES];
    }
    else{
        [orderManager addTopMenu:editingDic];
    }
    
    [self reloadDispData];
}

- (IBAction)iba_nextPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        NSInteger maxHeight  = self.table.contentSize.height;
        NSInteger pageHeight = self.table.frame.size.height;
        CGPoint currentPos = self.table.contentOffset;
        //2016-02-08 ueda ASTERISK
/*
        currentPos.y += self.table.frame.size.height;
 */
        //2016-02-08 ueda ASTERISK
        currentPos.y += self.table.frame.size.height / 5;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.table scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        menuPage++;
        [self.table reloadData];
    }
}

- (IBAction)iba_prevPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        CGPoint currentPos = self.table.contentOffset;
        //2016-02-08 ueda ASTERISK
/*
        currentPos.y -= self.table.frame.size.height;
 */
        //2016-02-08 ueda ASTERISK
        currentPos.y -= self.table.frame.size.height / 5;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.table scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.table.frame.size.height) animated:YES];
    } else {
        menuPage--;
        [self.table reloadData];
    }
}

//エントリー画面に戻って選択したメニューを表示する
- (IBAction)iba_returnAndDispLoadMenu:(id)sender{
    
    //2014-02-18 ueda
    [System tapSound];
    UIButton *_bt = (UIButton*)sender;
    if (self.type == TypeOrderCancel||self.type == TypeOrderDivide){
        [self countUp:sender];
    }
    else{
        editingDic = [self.orderList objectAtIndex:_bt.tag];
    }
    
    
    self.table.delegate = nil;
    self.table.dataSource = nil;
    
    [self.delegate setDispMenu:editingDic];
    [self.navigationController popViewControllerAnimated:YES];
}

//エントリー画面に戻って選択したメニューを表示する(アレンジメニュー)
- (IBAction)iba_returnAndDispLoadArrange:(id)sender{
    
    UIButton *_bt = (UIButton*)sender;
    NSMutableDictionary *arrangeMenu = [self.orderList objectAtIndex:_bt.tag];
    
    LOG(@"%@",arrangeMenu);
    
    for (int ct = 0; ct < [self.orderList count]; ct++) {
        NSMutableDictionary *tempMenu = [self.orderList objectAtIndex:ct];
        
        NSString *SyohinCD = nil;
        if ([[tempMenu allKeys] containsObject:@"SyohinCD"]) {
            SyohinCD = tempMenu[@"SyohinCD"];
        }
        else if ([[tempMenu allKeys] containsObject:@"MstSyohinCD"]) {
            SyohinCD = tempMenu[@"MstSyohinCD"];
        }
        
        //商品コードでの判定
        if ([SyohinCD isEqualToString:arrangeMenu[@"TopSyohinCD"]]) {
            _bt.tag = ct;
            if ([tempMenu[@"B1CateCD"] length]>0) {
                [self iba_returnAndDispLoadSub1Menu:_bt];
            }
            else{
                [self iba_returnAndDispLoadMenu:_bt];
            }
            return;
        }
    }
	//2014-01-31 ueda
    //Alert([String Order_Station], @"");
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",@""];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
	alert.delegate=nil;
    [alert addButtonWithTitle:@"OK"];
    alert.cancelButtonIndex=0;
    [alert show];
}

//エントリー画面に戻って選択したメニューを表示する（必ずSG1を表示する）
- (IBAction)iba_returnAndDispLoadSub1Menu:(id)sender{
    
    //2016-02-17 ueda
    [System tapSound];

    self.table.delegate = nil;
    self.table.dataSource = nil;
    
    
    UIButton *_bt = (UIButton*)sender;
    NSMutableDictionary *_menu = [self.orderList objectAtIndex:_bt.tag];
    NSMutableDictionary *_subMenu = nil;

    if([[_menu allKeys] containsObject:@"TopSyohinCD"]){
        for (int ct = 0; ct < [self.orderList count]; ct++) {
            NSMutableDictionary *_temp = [self.orderList objectAtIndex:ct];
            if ([_temp[@"MstSyohinCD"]isEqualToString:_menu[@"TopSyohinCD"]]) {
                _subMenu = _menu;
                _menu = _temp;
                _bt.tag = ct;
            }
        }
        
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide){
            [self countUp:_bt];
        }

        //2015-02-16 ueda
        if ([_menu.allKeys containsObject:@"trayNo"]) {
            //2015-07-14 ueda
            if ([_menu[@"trayNo"] isEqualToString:@"00"]) {
                //通常のセット（シングルトレイではない）
            } else {
                [_menu removeObjectForKey:@"count"];
                [_menu setValue:@"1" forKey:@"count"];
                [_subMenu removeObjectForKey:@"count"];
                [_subMenu setValue:@"1" forKey:@"count"];
            }
        }

        if([_menu[@"B1CateCD"] length]>0||[_menu[@"B2CateCD"] length]>0){
            [self.delegate setDispGroupMenu:_menu
                                        sub:_subMenu];
        }
        else{
            [self.delegate setDispSub1Menu:_menu
                                       sub:_subMenu];
        }
    }
    else if([_menu[@"B1CateCD"] length]>0||[_menu[@"B2CateCD"] length]>0){
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide){
            [self countUp:_bt];
        }
        //2015-02-16 ueda
        if ([_menu.allKeys containsObject:@"trayNo"]) {
            //2015-07-14 ueda
            if ([_menu[@"trayNo"] isEqualToString:@"00"]) {
                //通常のセット（シングルトレイではない）
            } else {
                [_menu removeObjectForKey:@"count"];
                [_menu setValue:@"1" forKey:@"count"];
                [_subMenu removeObjectForKey:@"count"];
                [_subMenu setValue:@"1" forKey:@"count"];
            }
        }
        [self.delegate setDispGroupMenu:_menu
                                    sub:_menu];
    }
    else if([_menu[@"SG1FLG"] isEqualToString:@"1"]){
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide){
            [self countUp:_bt];
        }
        //2015-02-16 ueda
        if ([_menu.allKeys containsObject:@"trayNo"]) {
            //2015-07-14 ueda
            if ([_menu[@"trayNo"] isEqualToString:@"00"]) {
                //通常のセット（シングルトレイではない）
            } else {
                [_menu removeObjectForKey:@"count"];
                [_menu setValue:@"1" forKey:@"count"];
            }
        }
        [self.delegate setDispSub1Menu:_menu
                                   sub:nil];
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_directionSelect:(id)sender{
    UIButton *_bt = (UIButton*)sender;
    NSMutableDictionary *_menu = [self.orderList objectAtIndex:_bt.tag];
    
    //2015-03-03 ueda
    [System tapSound];

    if (!directionList) {
        directionList = [[NSMutableArray alloc]init];
    }
    
    if ([directionList containsObject:_menu]) {
        [directionList removeObject:_menu];
    }
    else{
        [directionList addObject:_menu];
    }
    [self.table reloadData];
    
    /*
    index = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:_menu[@"SyohinCD"]];
    */
}

//==============================================================================


#pragma mark -
#pragma mark - Lifecycle delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        // Custom initialization
        showCancel = NO;
        menuPage = 0;
    }
    return self;
}

//2014-11-20 ueda
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.table respondsToSelector:@selector(setLayoutMargins:)]) {
        self.table.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([System is568h]) {
        defaultHeight = 440;
    }
    else{
        defaultHeight = 352;
    }
    
    [System adjustStatusBarSpace:self.view];
    
    if ([[System sharedInstance].orderType isEqualToString:@"0"]) {
        [self.bt_push setTitle:[String bt_send] forState:UIControlStateNormal];
    }
    else{
        [self.bt_push setTitle:[String bt_next] forState:UIControlStateNormal];
    }
    //2014-10-17 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
        //入力タイプＣの場合
        [self.bt_push setTitle:[String bt_next] forState:UIControlStateNormal];
    }
    [self.bt_back setTitle:[String bt_return] forState:UIControlStateNormal];
    
    orderManager = [OrderManager sharedInstance];
    dat = [DataList sharedInstance];

    
    isFinish = NO;
    isSetIsSingle = YES;
    isSetMenuFlag = NO;
    showCancel = NO;
    showDivide = NO;
    
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.table.scrollEnabled = YES;
        self.table.showsVerticalScrollIndicator = YES;
        self.table.bounces = YES;
        self.table.alwaysBounceVertical = YES;
        self.table.backgroundColor = [UIColor clearColor];
        //2015-04-30 ueda
        //self.table.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.table.tableFooterView = [[UIView alloc] init];
        
        //2015-04-03 ueda
/*
        self.bt_up.enabled = NO;
        self.bt_down.enabled = NO;
        self.bt_up.hidden = YES;
        self.bt_down.hidden = YES;
 */
    }
    [self reloadDispData];
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2015-12-17 ueda ASTERISK
    if (self.type == TypeOrderCancel) {
        //取消の場合は赤色
        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
    }
    
    //2015-09-17 ueda
    if ((self.type == TypeOrderOriginal) || (self.type == TypeOrderAdd)) {
        //新規、追加、Ｂタイプの注文
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            //2015-09-18
            [self performSegueWithIdentifier:@"ToSeatNumberView" sender:nil];
        } else {
            if (!([[System sharedInstance].useOrderConfirm isEqualToString:@"0"])) {
                //オーダー確認画面を表示する
            } else {
                if ([[System sharedInstance].orderType isEqualToString:@"1"]) {
                    //オーダー種類を入力する
                    [self performSegueWithIdentifier:@"ToOrderTypeView" sender:nil];
                }
            }
        }
    }
    
    //2016-02-08 ueda ASTERISK
/*
    //2016-02-03 ueda ASTERISK
    [self.bt_up setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_up setNumberOfLines:0];
    [self.bt_down setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_down setNumberOfLines:0];
 */
    
    //2016-04-08 ueda ASTERISK
/*
    //2016-02-04 ueda ASTERISK
    errorSound = [[ErrorSound alloc] init];
    [errorSound soundSetup];
 */
    
    //2016-02-08 ueda ASTERISK
    [self.bt_up setTitle:@"↓" forState:UIControlStateNormal];
    [self.bt_down setTitle:@"↑" forState:UIControlStateNormal];
}


- (void)reloadDispData{
    
    //2016-02-02 ueda
    preTopSyohinName = [[NSMutableString alloc]initWithString:@""];

    NSString *_str;
    NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if (self.type == TypeOrderOriginal||self.type == TypeOrderAdd) {
        //2015-02-16 ueda
        self.orderList = [orderManager getOrderListForConfirm:NO
                                                   isSubGroup:YES
                                                    isArrange:YES
                                                  typeOrderNo:self.type];
        //2014-11-17 ueda
/*
        //2014-07-07 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Confirm]];
            } else {
                //2014-09-22 ueda
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    //英語
                    _str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Confirm]];
                } else {
                    //日本語
                    _str = [NSString stringWithFormat:@"　%@%@　M%d F%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Confirm]];
                }
            }
        }
 */
        if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
            //2014-11-18 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                _str = [NSString stringWithFormat:@"　%@%@  %@",[String Str_t],_no,[String Confirm]];
            } else {
                //2014-12-12 ueda
                if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                    //入力タイプＣ or 小人入力する
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Confirm]];
                } else {
                    //小人入力しない
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Confirm]];
                }
            }
        }
        else{
            _str = [NSString stringWithFormat:@"  %@",[String bt_confirm]];
            [self.bt_push setTitle:[String bt_next] forState:UIControlStateNormal];
        }
    }
    else if (self.type == TypeOrderCancel){
        if (showCancel) {
            //2015-02-16 ueda
            self.orderList = [orderManager getOrderListForConfirm:YES
                                                       isSubGroup:YES
                                                        isArrange:YES
                                                      typeOrderNo:self.type];
            //2014-11-17 ueda
/*
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Cancel_confirm]];
            } else {
                //2014-09-22 ueda
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    //英語
                    _str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Cancel_confirm]];
                } else {
                    //日本語
                    _str = [NSString stringWithFormat:@"　%@%@　M%d F%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Cancel_confirm]];
                }
            }
 */
            //2014-11-18 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                _str = [NSString stringWithFormat:@"　%@%@  %@",[String Str_t],_no,[String Cancel_confirm]];
            } else {
                //2014-12-12 ueda
                if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                    //入力タイプＣ or 小人入力する
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Cancel_confirm]];
                } else {
                    //小人入力しない
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Cancel_confirm]];
                }
            }
            
            [self.bt_push setTitle:[String bt_send] forState:UIControlStateNormal];
        }
        else{
            //2015-02-16 ueda
            self.orderList = [orderManager getOrderListForConfirm:NO
                                                       isSubGroup:NO
                                                        isArrange:YES
                                                      typeOrderNo:self.type];
            //2014-11-17 ueda
/*
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String bt_cancel]];
            } else {
                //2014-09-22 ueda
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    //英語
                    _str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_cancel]];
                } else {
                    //日本語
                    _str = [NSString stringWithFormat:@"　%@%@　M%d F%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_cancel]];
                }
            }
 */
            //2014-11-18 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                _str = [NSString stringWithFormat:@"　%@%@  %@",[String Str_t],_no,[String bt_cancel]];
            } else {
                //2014-12-12 ueda
                if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                    //入力タイプＣ or 小人入力する
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String bt_cancel]];
                } else {
                    //小人入力しない
                    _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_cancel]];
                }
            }
            [self.bt_push setTitle:[String bt_confirm] forState:UIControlStateNormal];
        }
    }
    else if (self.type == TypeOrderDivide){
        //2014-10-02 ueda 分割はとりあえず通常の機能で行う → 商品単位でまとまっていないと分割できないため
/*
        //2014-10-01 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            if (!divideFirstFg) {
                //最初の１回だけ
                divideFirstFg = YES;
                [orderManager zeroReset];
                [orderManager typeCrestoreDBall];
            }
        }
 */
        NSArray *array = nil;
        if (showDivide) {
            //2015-02-16 ueda
            self.orderList = [orderManager getOrderListForConfirm:YES
                                                       isSubGroup:YES
                                                        isArrange:YES
                                                      typeOrderNo:self.type];
        }
        else{
            //2015-02-16 ueda
            array = [orderManager getOrderListForConfirm:NO
                                              isSubGroup:YES
                                               isArrange:YES
                                             typeOrderNo:self.type];
            
            self.orderList = [[NSMutableArray alloc]init];
            for (int ct = 0; ct<[array count]; ct++) {
                NSDictionary *_dic = array[ct];
                NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
                int countDivideTotal = [self totalDivideCount:divide];
                if (countDivideTotal<[_dic[@"count"]intValue]) {
                    [self.orderList addObject:_dic];
                }
                else if([divide[dat.dividePage] intValue]>0){
                    [self.orderList addObject:_dic];
                }
            }
        }
        //2014-11-17 ueda
/*
        //2014-10-23 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@%d/%d",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String bt_divide],dat.dividePage+1,dat.divideCount];
        } else {
            //2014-09-22 ueda
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                //英語
                _str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d %@%d/%d",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_divide],dat.dividePage+1,dat.divideCount];
            } else {
                //日本語
                _str = [NSString stringWithFormat:@"　%@%@　M%d F%d %@%d/%d",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_divide],dat.dividePage+1,dat.divideCount];
            }
        }
 */
        //2014-11-18 ueda
        if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
            _str = [NSString stringWithFormat:@"　%@%@  %@%zd/%zd",[String Str_t],_no,[String bt_divide],dat.dividePage+1,dat.divideCount];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@%zd/%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String bt_divide],dat.dividePage+1,dat.divideCount];
            } else {
                //小人入力しない
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd  %@%zd/%zd",[String Str_t],_no,dat.manCount,dat.womanCount,[String bt_divide],dat.dividePage+1,dat.divideCount];
            }
        }
        
        if (dat.dividePage+1 == dat.divideCount) {
            [self.bt_push setTitle:[String bt_divide] forState:UIControlStateNormal];
        }
        else{
            NSString *str = [NSString stringWithFormat:@"[%zd]",dat.dividePage+2];
            [self.bt_push setTitle:str forState:UIControlStateNormal];
        }
        
        if (dat.dividePage==0) {
            [self.bt_back setTitle:[String bt_return] forState:UIControlStateNormal];
        }
        else{
            NSString *str = [NSString stringWithFormat:@"[%zd]",dat.dividePage];
            [self.bt_back setTitle:str forState:UIControlStateNormal];
        }
    }
    else if (self.type == TypeOrderDirection) {
        /*
        self.orderList = [orderManager getOrderListForConfirm:NO
                                              isSubGroup:YES
                                               isArrange:NO];
        */
        _str = [NSString stringWithFormat:@"　%@%@　No.%@",[String Str_t],_no,dat.currentVoucher[@"EdaNo"]];
        [self.bt_push setTitle:[String bt_send] forState:UIControlStateNormal];
    }
    
    //セットメニューの配色フラグ設定
    [self addColorFlag];
    
    //LOG(@"orderList:%@",self.orderList);
    self.lb_title.text = _str;
    [self.table reloadData];
}

- (void)addColorFlag{
    //セットメニューが複数か否か
    isSetMenuFlag = NO;
    isSetIsSingle = YES;
    setMenuCount = 0;
    int setCt = 0;
    for (int ct = 0;ct < self.orderList.count; ct++) {
        
        NSMutableDictionary *menu = self.orderList[ct];


        
        
        
        //アレンジメニューの場合
        if (isSetMenuFlag&&[menu[@"ArrangeFLG"] isEqualToString:@"1"]) {
            isSetMenuFlag = YES;
        }
        //セットメニューの場合
        else if(![[menu allKeys] containsObject:@"SG1ID"]){
            if(![[menu allKeys] containsObject:@"SG2ID"]){
                if ([menu[@"SG1FLG"] isEqualToString:@"1"]) {
                    setCt++;
                    isSetMenuFlag = YES;
                }
                else{
                    isSetMenuFlag = NO;
                }
            }
            else{
                isSetMenuFlag = YES;
            }
        }
        else{
            isSetMenuFlag = YES;
        }
        
        
        
        if (isSetMenuFlag) {
            menu[@"ColorFLG"] = [NSString stringWithFormat:@"%d",setCt];
            LOG(@"after:%d:%@",ct,menu[@"ColorFLG"]);
        }
    }
    
    if (setCt>1) {
        isSetIsSingle = NO;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    editingDic = nil;
    
    //2014-09-12 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
        //入力タイプＣの場合
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.type == TypeOrderCancel) {
            //取消の場合
            if (appDelegate.typeCcancelStartFg) {
                //最初の画面の場合
                appDelegate.typeCcancelStartFg = NO;
                //確認画面へジャンプ
                [self performSegueWithIdentifier:@"ToOrderSummaryView" sender:nil];
            } else {
                [self reloadDispData];
            }
        }
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    //2016-04-08 ueda ASTERISK
/*
    //2016-02-04 ueda ASTERISK
    [errorSound soundTerminate];
 */
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
}

// For ios6
//2015-12-10 ueda ASTERISK
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations {
    //2015-08-27 ueda Upsidownを有効にする
    //return UIInterfaceOrientationMaskPortrait;
    return UIInterfaceOrientationMaskAll;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

// For ios6
- (BOOL)shouldAutorotate {
    NSLog(@"shouldAutorotate");
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    return YES;
}

// For ios5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    NSLog(@"shouldAutorotateToInterfaceOrientation");
    
    if(interfaceOrientation == UIInterfaceOrientationPortrait){
        return YES;
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeLeft){
        return NO;
    }else if(interfaceOrientation == UIInterfaceOrientationLandscapeRight){
        return NO;
    }else if(interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown){
        return NO;
    }
    return NO;
}

- (void)viewDidUnload {
    [self setLb_title:nil];
    [self setTable:nil];
    [self setBt_down:nil];
    [self setBt_up:nil];
    [self setBt_push:nil];
    [self setBt_back:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
     if([[segue identifier]isEqualToString:@"ToTableView"]){
         TableViewController *view_ = (TableViewController *)[segue destinationViewController];
             view_.type = self.type;
     }
     else if([[segue identifier]isEqualToString:@"ToCountView"]){
         CountViewController *view_ = (CountViewController *)[segue destinationViewController];
         view_.type = self.type;
         if (self.type==TypeOrderAdd) {
             view_.entryType = EntryTypeTableOnly;
         }
         else{
             //2014-12-25 ueda
             if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                 view_.entryType = EntryTypeTableOnly;
             } else {
                 view_.entryType = EntryTypeTableAndNinzu;
             }
         }
     }
     else if([[segue identifier]isEqualToString:@"ToTableView"]){
         TableViewController *view_ = (TableViewController *)[segue destinationViewController];
         view_.type = self.type;
     }
     else if([[segue identifier]isEqualToString:@"ToOrderTypeView"]){
         OrderTypeViewController *view_ = (OrderTypeViewController *)[segue destinationViewController];
         view_.type = self.type;
     }
     else if([[segue identifier]isEqualToString:@"SearchView"]){
         EntryViewController *view_ = (EntryViewController *)[segue destinationViewController];
         view_.type = self.type;
         
         if ([(NSString*)sender isEqualToString:@"typeKokyaku"]) {
             view_.entryType = EntryTypeKokyaku;
         }
         else if ([(NSString*)sender isEqualToString:@"typeSearch"]) {//←検索機能はHomeViewControllerでしか呼ばれない
             view_.entryType = EntryTypeSearch;
         }
     }
    //2015-04-06 ueda
    else if([[segue identifier]isEqualToString:@"ToCustomerView"]){
        CustomerViewController *view_ = (CustomerViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}


#pragma mark -
#pragma mark - Data Source Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return defaultHeight/5;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    
    NSInteger count = 0;
    NSInteger maxPage = 0;
    count = MIN(kMenuCount, [self.orderList count]-kMenuCount*menuPage);
    maxPage = ([self.orderList count]-1)/kMenuCount;
    
    LOG(@"%zd",count);

    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        count = [self.orderList count];
    } else {
        int height = defaultHeight/kMenuCount;
        self.table.frame = CGRectMake(self.table.frame.origin.x, self.table.frame.origin.y, self.table.frame.size.width, MIN(height*count, defaultHeight));
        
        self.bt_up.enabled = NO;
        self.bt_down.enabled = NO;
        
        if (menuPage<maxPage)
            self.bt_up.enabled = YES;
        if (0<menuPage)
            self.bt_down.enabled = YES;
    }
    
    //2015-04-03 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.bt_up.enabled   = YES;
        self.bt_down.enabled = YES;
    }
    return count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Confirm";
    ConfirmCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConfirmCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
    NSInteger page = indexPath.row + kMenuCount * menuPage;
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    
    //2014-07-28 ueda
    CGRect rect = cell.contentView.bounds;
    rect.size.height = defaultHeight / 5;
    //2014-07-28 ueda
    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
    
    NSMutableDictionary *_dic = [self.orderList objectAtIndex:page];

    LOG(@"indexPath row:%zd:%@",indexPath.row,_dic);
    
    BOOL isSingleTray = NO;
    BOOL isHaveSubMenu = NO;
    BOOL isSub1Menu = NO;
    BOOL isSub2Menu = NO;
    BOOL isJikaMenu = NO;
    BOOL isGroupMenu = NO;
    BOOL isArrangeMenu = NO;
    BOOL isDirectionSubMenu = NO;
    BOOL countDouble = NO;
    BOOL isKeppin = NO;
    if ([_dic[@"trayNo"]intValue]>0) {
        isSingleTray = YES;
    }
    if ([_dic[@"SG1FLG"] isEqualToString:@"1"]) {
        isHaveSubMenu = YES;
    }
    if([[_dic allKeys] containsObject:@"SG1ID"]){
        isSub1Menu = YES;
    }
    if([[_dic allKeys] containsObject:@"SG2ID"]){
        isSub2Menu = YES;
    }
    if ([_dic[@"B1CateCD"] length]>0) {
        isGroupMenu = YES;
    }
    if ([_dic[@"ArrangeFLG"] isEqualToString:@"1"]) {
        isArrangeMenu = YES;
    }
    if([_dic[@"JikaFLG"] isEqualToString:@"1"]){
        if (!isArrangeMenu) {
            isJikaMenu = YES;
        }
    }
    if([[_dic allKeys] containsObject:@"DirectionNo"]){
        isDirectionSubMenu = YES;
    }
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide){
        countDouble = YES;
    }
    if ([dat.keppinList containsObject:_dic[@"SyohinCD"]]) {
        isKeppin = YES;
    }
    
    
    //編集中の場合はハイライトする
    NSString *_code1 = nil;
    NSString *_code2 = nil;
    NSString *_top1 = editingDic[@"CateCD"];
    NSString *_top2 = _dic[@"CateCD"];
    NSString *_tray1 = editingDic[@"trayNo"];
    NSString *_tray2 = _dic[@"trayNo"];
    
    if (isArrangeMenu) {
        _code1 = editingDic[@"TopSyohinCD"];
        _code2 = _dic[@"TopSyohinCD"];
    }
    else{
        _code1 = editingDic[@"SyohinCD"];
        _code2 = _dic[@"SyohinCD"];
    }

    //2015-03-03 ueda
    if (self.type == TypeOrderDirection) {
        //調理指示
        if ([directionList containsObject:_dic]) {
            [cell.contentView setBackgroundColor:BLUE];
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
        } else {
            if (!(isDirectionSubMenu)) {
                [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:1.0f]];
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.5f green:0.5f blue:1.0f alpha:1.0f] bounds:rect]]];
            } else {
                [cell.contentView setBackgroundColor:[UIColor whiteColor]];
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
            }
        }
    } else {
        
        //欠品メニュー
        if (isKeppin) {
            [cell.contentView setBackgroundColor:[UIColor redColor]];
            //2014-07-28 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:rect]]];
        }
        else if(isHaveSubMenu||isSub1Menu||isSub2Menu){
            
            if (isSetIsSingle) {
                
                [cell.contentView setBackgroundColor:[UIColor yellowColor]];
                //2014-07-28 ueda
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor yellowColor] bounds:rect]]];
                
            }
            else{
                
                //2015-12-28 ueda
/*
                if (isHaveSubMenu) {
                    setMenuCount = [_dic[@"ColorFLG"]intValue];
                }
 */
                //2015-12-28 ueda
                if (YES) {
                    if ([[_dic allKeys]containsObject:@"ColorFLG"]) {
                        setMenuCount = [_dic[@"ColorFLG"]intValue];
                    }
                }
                
                if (setMenuCount % 2) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.196f green:0.804f blue:0.196f alpha:1.0f]];
                    //2014-07-28 ueda
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.196f green:0.804f blue:0.196f alpha:1.0f] bounds:rect]]];
                }
                else {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.498f green:1.0f blue:0.831f alpha:1.0f]];
                    //2014-07-28 ueda
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.498f green:1.0f blue:0.831f alpha:1.0f] bounds:rect]]];
                }
            }
        }
        else if (isArrangeMenu&&[[_dic allKeys]containsObject:@"ColorFLG"]) {
            
            if (isSetIsSingle) {
                [cell.contentView setBackgroundColor:[UIColor yellowColor]];
                //2014-07-28 ueda
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor yellowColor] bounds:rect]]];
            }
            else{
                if (setMenuCount % 2) {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.196f green:0.804f blue:0.196f alpha:1.0f]];
                    //2014-07-28 ueda
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.196f green:0.804f blue:0.196f alpha:1.0f] bounds:rect]]];
                }
                else {
                    [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.498f green:1.0f blue:0.831f alpha:1.0f]];
                    //2014-07-28 ueda
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.498f green:1.0f blue:0.831f alpha:1.0f] bounds:rect]]];
                }
            }
        }
        else if ([_code1 isEqualToString:_code2]&&[_top1 isEqualToString:_top2]&&[_tray1 isEqualToString:_tray2]) {
            
            //アレンジメニュー
            if (isArrangeMenu) {
                NSNumber *_page1 = editingDic[@"PageNo"];
                NSString *_page2 = _dic[@"PageNo"];
                if ([_page1 intValue]==[_page2 intValue]) {
                    [cell.contentView setBackgroundColor:BLUE];
                    //2014-07-28 ueda
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
                }
            }
            else{
                [cell.contentView setBackgroundColor:BLUE];
                //2014-07-28 ueda
                [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
            }
        }
        else if ([directionList containsObject:_dic]) {
            [cell.contentView setBackgroundColor:BLUE];
            //2014-07-28 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
        }
        else{
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            //2014-07-28 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
        }
        
    }
    

    
    NSString *text1 = @"";
    NSString *text2 = @"";
    NSString *text3 = @"";
    if (isSub1Menu) {
        if (indexPath.row==0) {
            text1 = _dic[@"TopDispNM"] ;
        }
        else{
            //2014-01-28 ueda
            text1 = @"　\n　〃\n　";
        }
        text2 = [NSString stringWithFormat:@"%@\n%@\n%@",_dic[@"HTDispNMU"],_dic[@"HTDispNMM"],_dic[@"HTDispNML"]];
    }
    else if (isSub2Menu) {
        if (indexPath.row==0) {
            text1 = _dic[@"TopDispNM"] ;
            text2 = _dic[@"Sub2DispNM"];
        }
        else{
            //2014-01-28 ueda
            text1 = @"　\n　〃\n　";
            text2 = @"　\n　〃\n　";
        }
        text3 = [NSString stringWithFormat:@"%@\n%@\n%@",_dic[@"HTDispNMU"],_dic[@"HTDispNMM"],_dic[@"HTDispNML"]];
        //text3 = _dic[@"HTDispNM"];
    }
    else if (isArrangeMenu) {
        
        NSString *arrange1 = nil;
        NSString *arrange2 = nil;
        //2014-02-07 ueda
        //2016-02-03 ueda ASTERISK
        //arrange1 = [NSString stringWithFormat:@"　[%d]",[_dic[@"PageNo"]intValue]];
        //2016-02-08 ueda ASTERISK
        //arrange1 = @"　[TP]";
        arrange1 = @"　ＴＰ";
        if (indexPath.row>0) {
            NSMutableDictionary *prevMenu = [self.orderList objectAtIndex:page-1];
            if ([prevMenu[@"PageNo"]intValue]== [_dic[@"PageNo"]intValue]) {
                //2014-01-28 ueda
                arrange1 = @"　\n　〃\n　";
            }
        }
        arrange2 = [NSString stringWithFormat:@"%@\n%@\n%@",_dic[@"HTDispNMU"],_dic[@"HTDispNMM"],_dic[@"HTDispNML"]];
        
        if ([_dic[@"Sub1SyohinCD"]length]==0) {
            text1 = arrange1;
            text2 = arrange2;
        }
        else{
            //2016-02-02 ueda
            //text1 = @"";
            //2016-02-02 ueda
            if (YES) {
                if (indexPath.row>0) {
                    text1 = @"　\n　〃\n　";
                } else {
                    text1 = preTopSyohinName;
                }
            }
            text2 = arrange1;
            text3 = arrange2;
        }
    }
    else if (isDirectionSubMenu) {
        text1 = [NSString stringWithFormat:@"%d>>",[_dic[@"DirectionNo"]intValue]];
        text2 = [NSString stringWithFormat:@"%@\n%@\n%@",_dic[@"HTDispNMU"],_dic[@"HTDispNMM"],_dic[@"HTDispNML"]];
    }
    else{
        text1 = [NSString stringWithFormat:@"%@\n%@\n%@",_dic[@"HTDispNMU"],_dic[@"HTDispNMM"],_dic[@"HTDispNML"]];
        //2016-02-02 ueda
        preTopSyohinName = [[NSMutableString alloc]initWithString:text1];
    }
    
    if (isJikaMenu&&self.type != TypeOrderDirection) {
        text2 = [NSString stringWithFormat:@"@ %@",[DataList appendComma:_dic[@"Jika"]]];
    }
    cell.title.text = text1;
    cell.titleSub.text = text2;
    cell.titleSub2.text = text3;
    

    
    if (countDouble) {
        cell.count.frame = CGRectMake(253, 42, 51, 35);
        cell.countSub.frame = CGRectMake(253, 8, 51, 35);
        
        NSArray *divide = [_dic[@"countDivide"] componentsSeparatedByString:@","];
        int count = [_dic[@"count"]intValue];
        int countDivide = [divide[dat.dividePage] intValue];
        //2016-03-31 ueda
/*
        if ([[System sharedInstance].bunkatsuType isEqualToString:@"0"]&&
            self.type==TypeOrderDivide) {
 */
        //2016-03-31 ueda
        if (self.type==TypeOrderDivide) {
            int countDivideTotal = [self totalDivideCount:divide];
            cell.count.text = [NSString stringWithFormat:@"%d",count-countDivideTotal];
        }
        else{
            cell.count.text = [NSString stringWithFormat:@"%d",count];
        }
        
        cell.countSub.text = [NSString stringWithFormat:@"%d",MAX(countDivide,0)];
        
        cell.count.font = [UIFont boldSystemFontOfSize:15];
        cell.countSub.font = [UIFont boldSystemFontOfSize:25];
    }
    else{
        cell.count.frame = CGRectMake(253, 7, 51, 71);
        cell.countSub.frame = CGRectMake(253, 7, 51, 71);
        cell.count.text = [NSString stringWithFormat:@"%@",_dic[@"count"]];
        cell.countSub.text = @"";
        cell.count.font = [UIFont boldSystemFontOfSize:25];
        cell.countSub.font = [UIFont boldSystemFontOfSize:25];
    }
    
    cell.bt_left.tag = page;
    cell.bt_right.tag = page;
    
    [cell.bt_left removeTarget:self action:@selector(iba_returnAndDispLoadMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_right removeTarget:self action:@selector(iba_returnAndDispLoadMenu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_left removeTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_right removeTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_left removeTarget:self action:@selector(iba_directionSelect:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_right removeTarget:self action:@selector(iba_directionSelect:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_left removeTarget:self action:@selector(countUp:) forControlEvents:UIControlEventTouchUpInside];
    [cell.bt_right removeTarget:self action:@selector(countDown:) forControlEvents:UIControlEventTouchUpInside];
    
    if (self.type==TypeOrderCancel||self.type == TypeOrderDivide) {
        if ((isHaveSubMenu||isSub1Menu||isSub2Menu)&&!isSingleTray) {
            [cell.bt_left addTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
            [cell.bt_right addTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [cell.bt_left addTarget:self action:@selector(countUp:) forControlEvents:UIControlEventTouchUpInside];
            [cell.bt_right addTarget:self action:@selector(countDown:) forControlEvents:UIControlEventTouchUpInside];
        }

    }
    else if (self.type == TypeOrderDirection) {
        [cell.bt_left addTarget:self action:@selector(iba_directionSelect:) forControlEvents:UIControlEventTouchUpInside];
        [cell.bt_right addTarget:self action:@selector(iba_directionSelect:) forControlEvents:UIControlEventTouchUpInside];
    }
    else{
        if (isHaveSubMenu||isSub1Menu||isSub2Menu||isGroupMenu) {
            [cell.bt_left addTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
            [cell.bt_right addTarget:self action:@selector(iba_returnAndDispLoadSub1Menu:) forControlEvents:UIControlEventTouchUpInside];
        }
        else if (isArrangeMenu) {
            [cell.bt_left addTarget:self action:@selector(iba_returnAndDispLoadArrange:) forControlEvents:UIControlEventTouchUpInside];
            [cell.bt_right addTarget:self action:@selector(iba_returnAndDispLoadArrange:) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            [cell.bt_left addTarget:self action:@selector(iba_returnAndDispLoadMenu:) forControlEvents:UIControlEventTouchUpInside];
            [cell.bt_right addTarget:self action:@selector(iba_returnAndDispLoadMenu:) forControlEvents:UIControlEventTouchUpInside];
        }
    }
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"didSelectRowAtIndexPath:%@",indexPath);
  
    /*
    if (self.type != TypeOrderDirection) {
        editingDic = orderList[indexPath.row];
        [self.table reloadData];
    }
    else{
        
    }
     */
}

#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (type==RequestTypeOrderRequest) {
            if (_dataList) {
                isFinish = YES;
                [orderManager zeroReset];
                //2015-04-16 ueda
/*
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
 */
                
                //2015-04-27 ueda
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if ((appDelegate.type == TypeOrderCancel) && ([[System sharedInstance].entryType isEqualToString:@"0"])) {
                    //2015-08-07 ueda Ａタイプの場合（Ｂタイプで不具合があるので）
                    //取消の場合
                    //2015-04-16 ueda
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                    //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String AddOrderConfirm]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    //alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 1301;
                    [alert show];
                } else {
                    //2015-04-27 ueda
                    HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                    [self.navigationController popToViewController:parent animated:YES];
                }
                
            }
        }
        if (type==RequestTypeOrderDirection) {
            if (_dataList) {
                [orderManager zeroReset];
                UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
        }
        else if(type==RequestTypeVoucherDividePrint){
            UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
            [self.navigationController popToViewController:parent animated:YES];
        }
        else if(type==RequestTypeVoucherDivideNotPrint){
            if (_dataList) {
                VouchingListViewController *parent = [self.navigationController.viewControllers objectAtIndex:2];
                if (![parent isKindOfClass:[VouchingListViewController class]]) {
                    
                    TableViewController *table = [self.navigationController.viewControllers objectAtIndex:1];
                    LOG(@"table:%@",table);
                    
                    [self.navigationController popToViewController:table animated:NO];
                    
                    parent = [self.storyboard instantiateViewControllerWithIdentifier:@"VouchingListViewController"];
                    parent.voucherList = [[NSMutableArray alloc]initWithArray:(NSArray*)_dataList];
                    parent.type = TypeOrderCheck;
                    //[parent setVoucher:parent.voucherList[0]];
                    [table.navigationController pushViewController:parent animated:YES];
                }
                else{
                    parent.voucherList = [[NSMutableArray alloc]initWithArray:(NSArray*)_dataList];
                    parent.type = TypeOrderCheck;
                    [self.navigationController popToViewController:parent animated:YES];
                }
                LOG(@"%@",parent);
            }
        }
        [mbProcess hide:YES];
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //2014-12-04 ueda
/*
        //2014-10-30 ueda
        if ((type==RequestTypeOrderRequest) ||
            (type==RequestTypeVoucherDividePrint) ||
            (type==RequestTypeVoucherDivideNotPrint)) {
            if([_msg rangeOfString:[String Out_of_stock_change]].location != NSNotFound){
                //欠品(品切れ)情報
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                [self.table reloadData];
            } else {
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                alert.tag=1101;
                [alert show];
            }
        } else {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            //2014-01-30 ueda
            //if ([alert subviews].count>2) {
            //    ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
            //}
            [self.table reloadData];
        }
 */
        //2016-04-08 ueda ASTERISK
/*
        //2016-02-04 ueda ASTERISK
        [errorSound soundOn];
 */
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        //2016-02-04 ueda ASTERISK
        alert.delegate = self;
        if (type==RequestTypeOrderRequest) {
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            //2014-12-25 ueda
            if (appDelegate.communication_Return_Status == communication_Return_8) {
                appDelegate.OrderRequestN31retryFlag = NO;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.delegate=self;
                alert.tag=1102;
            }
            else if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                [alert addButtonWithTitle:@"OK"];
                //2014-12-25 ueda
                if (appDelegate.communication_Step_Status == communication_Step_Recieved) {
                    appDelegate.OrderRequestN31retryFlag = NO;
                    appDelegate.OrderRequestN31forceFlag = NO;
                }
                if (appDelegate.communication_Return_Status == communication_Return_2) {
                    //品切れ
                    alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    [self.table reloadData];
                }
            } else {
                [alert addButtonWithTitle:@"OK"];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1101;
            }
        } else {
            //2015-01-08 ueda
            [alert addButtonWithTitle:@"OK"];
        }
        [alert show];
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

/////////////////////////////////////////////////////////////////
#pragma mark - MBProgressHUD Delegate
/////////////////////////////////////////////////////////////////

- (void)showIndicator{
    if (!mbProcess) {
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
    }
    [mbProcess show:YES];
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [mbProcess removeFromSuperview];
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

//2014-09-17 ueda
- (void)orderSendRetry {
    [self showIndicator];
    //2014-12-25 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31retryFlag = YES;
    //2014-12-16 ueda
    //BOOL isLoading = NO;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    switch (self.type) {
        case TypeOrderOriginal:
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                
                [_net sendOrderRequest:self retryFlag:YES];
            }
            break;
            
        case TypeOrderAdd:
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                
                [_net sendOrderAdd:self retryFlag:YES];
            }
            break;
            
        case TypeOrderCancel:
            //2014-12-16 ueda
            //isLoading = YES;
            
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2016-02-02 ueda
/*
                [orderManager typeCcopyDB];
                [orderManager zeroReset];
 */
                [_net sendOrderCancelTypeC:self retryFlag:YES];
            } else {
                [_net sendOrderCancel:self retryFlag:YES];
            }
            break;
            
        case TypeOrderDivide:
            //2014-12-16 ueda
            //isLoading = YES;
            
            //2014-10-30 ueda
            [_net sendVoucherDivide:self type:orderDivideType retryFlag:YES];

            break;
    }
    //2014-12-16 ueda
/*
    if(isLoading){
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
        [mbProcess show:YES];
    }
 */
}

//2014-12-25 ueda
- (void)orderSendForce {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31forceFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}

//2015-01-08 ueda
//分割の確認画面で「いいえ」を押した時に変数をリセット
-(void)resetValue {
    if ([[System sharedInstance].bunkatsuType isEqualToString:@"1"]) {// 0=10分割　1=2分割
        dat.dividePage  = 1;
        dat.divideCount = 1;
        [self removeLastDivideCount];
        dat.dividePage  = 0;
        dat.divideCount = 1;
        menuPage = 0;
        showDivide = NO;
        [self reloadDispData];
    } else {
        showDivide = NO;
        [self reloadDispData];
    }
}

@end
