//
//  OrderEntryViewController.m
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "OrderEntryViewController.h"
#import "ImageViewController.h"
#import "SSGentleAlertView.h"
#import "CustomFunction.h"

#define kMenuCount 10
#define kSubMenuCount 8

@interface OrderEntryViewController ()
{
    //2014-06-23 ueda
    UIImage *menuImage;
    //2014-09-19 ueda
    //BOOL isDispTray; //2014-10-01 ueda 以前の方式に戻すため不要
    //2014-10-31 ueda
    NSInteger mainIndex;
    //2015-11-18 ueda ASTERISK_TEST
    NSInteger categoryCount;
    //2015-12-04 ueda
    NSInteger saveMenuPage;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_tpTitle;

@end

@implementation OrderEntryViewController

#pragma mark -
#pragma mark - Control object action

- (IBAction)iba_back:(id)sender{

    if (isShowSub1||isShowSub2||isShowArrange) {
        //2015-12-15 ueda ASTERISK
        bool wAlertFlag = YES;
        NSInteger workPtr = 99;
        if (isShowSub1) {
            workPtr = [[editSub1Category objectForKey:@"DispOrder"] integerValue];
            if (workPtr != 1) {
                wAlertFlag = NO;
                workPtr -=2 ;
                NSMutableDictionary *_cate = categoryList[workPtr];
                [self setCategory:_cate];
            }
        } else if (isShowSub2) {
            workPtr = [[editSub2Category objectForKey:@"DispOrder"] integerValue];
            if (workPtr != 1) {
                wAlertFlag = NO;
                workPtr -=2 ;
                NSMutableDictionary *_cate = categoryList[workPtr];
                [self setCategory:_cate];
            }
        }
        if (wAlertFlag) {
            //2014-01-30 ueda
            /*
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
             message:[String Cancel1]
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:[String Yes],[String No], nil];
             */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
            //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cancel1]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 2;
            [alert show];
        }
    }
    else if(isShowGroup1){
        [self hideGroup1Table];
    }
    else if(isShowGroup2){
        [self hideGroup2Table];
    }
    else{
        //コード注文の場合は、エントリー画面を表示する
        if([[System sharedInstance].codeType isEqualToString:@"1"]&&
           (self.type==TypeOrderOriginal||self.type==TypeOrderAdd)){
            [self performSegueWithIdentifier:@"ToEntryView" sender:nil];
            return;
        }
        
        NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
        if ([[System sharedInstance].entryType isEqualToString:@"1"]&&[orderList count]>0) {            
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_this_slip] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
            */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_this_slip]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 3;
            [alert show];
        }
        else{
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

//サブメニューの戻る時のオーダーキャンセル
- (void)orderCancel1{

    if (isShowArrange){
        NSMutableDictionary *tempMenu = nil;
        if (isShowGroup1) {
            tempMenu = [[NSMutableDictionary alloc]initWithDictionary:editFolder1Menu];
        }
        else if (isShowGroup2) {
            tempMenu = [[NSMutableDictionary alloc]initWithDictionary:editFolder2Menu];
        }
        else{
            tempMenu = [[NSMutableDictionary alloc]initWithDictionary:editMenu];
        }
        [self clearTopCount];
        [orderManager addTopMenu:tempMenu];
        
        
        if (isShowGroup1) {
            editFolder1Menu = tempMenu;
        }
        else if (isShowGroup2) {
            editFolder2Menu = tempMenu;
        }
        else{
            editMenu = tempMenu;
        }
    }
    else{
        if (isShowSub1) {
            NSMutableDictionary *pare = [self currentParentEditMenu];
            if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {//トレイ商品の場合は全てのトレイを削除
                pare[@"count"] = @"0";
                NSArray *array = [orderManager getTrayList:pare[@"SyohinCD"]];
                for (int ct = 0; ct < array.count; ct++) {
                    pare[@"trayNo"] = @"01";//削除のたびに更新されるので常に01を消していく
                    [orderManager addTopMenu:pare];
                }
            }
            else{
                [self clearTopCount];
            }
        }
        else{
            [self clearTopCount];
        }
    }
    
    
    if (isShowArrange) {
        [self hideArrangeTable];
        
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
        }
    }
    else if (isShowSub1) {

        [self hideSubTable];

        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
        }
        else if (!isShowConfirm) {

            //新規、追加でコード注文の場合は入力画面に戻る
            if([[System sharedInstance].codeType isEqualToString:@"1"]){
                [self performSegueWithIdentifier:@"ToEntryView" sender:nil];
                return;
            }
        }
    }
    else if(isShowSub2){
        [self showSub1Table];
    }
}

- (IBAction)iba_showNext:(id)sender{
   
    if (isShowSub1||isShowSub2||isShowArrange) {
        //2015-12-15 ueda ASTERISK
        UIButton *button = (UIButton*)sender;
        if ((isShowSub1||isShowSub2) && ([button.currentTitle isEqualToString:[String bt_next]])) {
            //2015-12-24 ueda ASTERISK
            if ([self checkSubMenuOrder:sender]) {
                NSInteger nextPtr;
                if (isShowSub1){
                    nextPtr = [[editSub1Category objectForKey:@"DispOrder"] integerValue];
                } else if (isShowSub2) {
                    nextPtr = [[editSub2Category objectForKey:@"DispOrder"] integerValue];
                } else {
                    nextPtr = 99;
                }
                if (nextPtr !=99) {
                    NSMutableDictionary *_cate = categoryList[nextPtr];
                    [self setCategory:_cate];
                }
            }
        } else {
            if ([self checkSubMenuOrder:sender]) {
                //サブグループ設定を保存する
                if (isShowSub1||isShowArrange) {
                    [self hideSubTable];
                    //2015-11-13 ueda ASTERISK_TEST
                    if (YES) {
                        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
                        //2015-12-17 ueda ASTERISK
                        if (self.type == TypeOrderCancel) {
                            //取消の場合は赤色
                            self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
                        }
                    }
                    if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
                        UIButton *button = (UIButton*)sender;
                        [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:button];
                    }
                    else if(self.type == TypeOrderOriginal || self.type == TypeOrderAdd){
                        if (!isShowConfirm) {
                            if([[System sharedInstance].codeType isEqualToString:@"1"]){
                                [self performSegueWithIdentifier:@"ToEntryView" sender:nil];
                            }
                        }
                    }
                }
                else if(isShowSub2){
                    [self showSub1Table];
                }
            }
        }
    }
    else if(isShowGroup1||isShowGroup2){
        [self hideGroup1Table];
    }
    else{
        NSMutableArray *orderList = [orderManager getOrderList:0][0];
        LOG(@"orderList:%@",orderList);
        //2014-09-10 ueda
        int chkKbn = 0;
        if ([orderList count] == 0) {
            chkKbn = 1;
        }
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.typeCorderCount = [orderList count];
            if (appDelegate.typeCorderIndex > 1) {
                //２回目以降のオーダー
                NSMutableArray *list = [orderManager getOrderListTypeCForSummary:0];
                if (appDelegate.typeCorderCount == 0) {
                    //オーダー内容なし
                    if ([list count] == 0) {
                        chkKbn = 1;
                    } else {
                        chkKbn = 2;
                    }
                }
            }
        }
        if (chkKbn == 0) {
            //2015-09-17 ueda
/*
            [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
 */
            if (!([[System sharedInstance].useOrderConfirm isEqualToString:@"0"])) {
                //オーダー確認画面を表示する
                [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
            } else {
                if ([[System sharedInstance].orderType isEqualToString:@"1"]) {
                    //オーダー種類を入力する
                    [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
                } else {
                    //オーダー送信
                    [self showIndicator];
                    NetWorkManager *_net = [NetWorkManager sharedInstance];
                    //2015-09-18 ueda
                    switch (self.type) {
                        case TypeOrderOriginal:
                            
                            [_net sendOrderRequest:self retryFlag:NO];
                            break;
                            
                        case TypeOrderAdd:
                            
                            [_net sendOrderAdd:self retryFlag:NO];
                            break;
                    }
                }
            }
        }
        if (chkKbn == 1) {
            //2014-01-31 ueda
            //Alert([String Order_Station], [String No_order1]);
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_order1]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
        }
        if (chkKbn == 2) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_order1]];
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                alert.message=@"No order.\nShow check page ?";
            } else {
                alert.message=@"注文がありません。\n確認画面を表示しますか？";
            }
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag=102;
            [alert show];
        }
    }
}

- (BOOL)checkSubMenuOrder:(id)sender{
    
    NSInteger index = 0;//数量確認
    NSMutableDictionary *_cate = nil;
    
    if (isShowArrange) {
        NSMutableDictionary *_pare = [self currentParentEditMenu];
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            index = [orderManager entryIsEnabled:_pare
                                             key:@"countDivide"];
        }
        else{
            index = [orderManager entryIsEnabled:_pare
                                             key:@"count"];
        }
        _cate = editArrangeCategory;
    }
    else if (isShowSub1) {
        //2015-12-24 ueda ASTERISK
/*
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            index = [orderManager entryIsEnabled:[self currentParentEditMenu]
                                             key:@"countDivide"];
        }
        else{
            index = [orderManager entryIsEnabled:[self currentParentEditMenu]
                                             key:@"count"];
        }
 */
        //2015-12-24 ueda ASTERISK
        NSString *_keyStr;
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            _keyStr = @"countDivide";
        }
        else{
            _keyStr = @"count";
        }
        NSInteger _checkCount = [[editSub1Category objectForKey:@"DispOrder"] integerValue];
        index = [orderManager entryIsEnabled:[self currentParentEditMenu] key:_keyStr checkCount:_checkCount];
        _cate = editSub1Category;
    }
    else if (isShowSub2) {
        //2015-12-24 ueda ASTERISK
/*
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            index = [orderManager entryIsEnabled:editSub1Menu
                                             key:@"countDivide"];
        }
        else{
            index = [orderManager entryIsEnabled:editSub1Menu
                                             key:@"count"];
        }
 */
        //2015-12-24 ueda ASTERISK
        NSString *_keyStr;
        if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
            _keyStr = @"countDivide";
        }
        else{
            _keyStr = @"count";
        }
        NSInteger _checkCount = [[editSub2Category objectForKey:@"DispOrder"] integerValue];
        index = [orderManager entryIsEnabled:editSub1Menu key:_keyStr checkCount:_checkCount];
        _cate = editSub2Category;
    }
    
    
    LOG(@"index:%zd",index);
    
    
    if (index==9999) {
        return YES;
    }
    else{
        //入力の必要なカテゴリに遷移
        NSMutableDictionary *_category = [categoryList objectAtIndex:index];
        if (![_category[@"MstCateCD"] isEqualToString:_cate[@"MstCateCD"]]) {
            [self setCategory:_category];
        }
        
        //メッセージ内容を判定する
        //1=同数のみ　2=多可 3=少可 4=制限無し 5=ノンセレクト
        int Limit = [_category[@"LimitCount"]intValue];
        NSString *str = nil;
        switch (Limit) {
            case 1:
                str = @"同数";
                break;
                
            case 2:
                str = @"多数";
                break;
                
            case 3:
                str = @"少数";
                break;
                
            case 4:
                
                break;
                
            case 5:
                
                break;
                
            default:
                break;
        }
        NSString *_str1 = [NSString stringWithFormat:[String Input_num],_category[@"HTDispNM"],str];
        //2014-01-31 ueda
        //Alert([String Order_Station], _str1);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_str1];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        
        return NO;
    }
    return NO;
}

// 0 = メニュー　1 = 第1階層 2 = 第2階層 3 = フォルダ商品1 4 = フォルダ商品2 5 = アレンジ商品
- (BOOL)count:(NSInteger)plus
         type:(NSInteger)type{
    
    NSMutableDictionary *_pare = nil;
    NSMutableDictionary *_edit = nil;
    NSMutableDictionary *_cate = nil;
    NSInteger maxCountParent = 0; //親商品の上限
    NSInteger currentCount = 0; //現在の商品数
    
    //int count = 0;
    if (type==0){
        if (isShowGroup1) {
            _edit = editFolder1Menu;
        }
        else if (isShowGroup2) {
            _edit = editFolder2Menu;
        }
        else{
            _edit = editMenu;
        }
    }
    else if (type==1) {
        if (isShowGroup1) {
            _pare = editFolder1Menu;
        }
        else if (isShowGroup2) {
            _pare = editFolder2Menu;
        }
        else{
            _pare = editMenu;
        }
        _edit = editSub1Menu;
        _cate = editSub1Category;
    }
    else if (type==2) {
        _pare = editSub1Menu;
        _edit = editSub2Menu;
        _cate = editSub2Category;
    }
    else if (type==3){
        _edit = editFolder1Menu;
    }
    else if (type==4){
        _edit = editFolder2Menu;
    }
    else if (type==5){
        _pare = [self currentParentEditMenu];
        _edit = editArrangeMenu;
    }
    
    LOG(@"%@\n%@",_pare,_edit);
    
    //入力許可.不許可の判定
    NSString *key = @"";
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        key = @"countDivide";
        if (type==0) {
            NSArray *divide = [_edit[@"countDivide"] componentsSeparatedByString:@","];
            NSInteger maxCount = [_edit[@"count"]intValue] - [self countFromArray:divide];
            currentCount = [divide[dat.dividePage]intValue] + plus;
            if (maxCount<=0) {
                return NO;
            }
        }
        else if (type==1||type==2) {
            NSArray *divideParent = [_pare[@"countDivide"] componentsSeparatedByString:@","];
            NSArray *divide = [_edit[@"countDivide"] componentsSeparatedByString:@","];
            int maxCount = [_edit[@"count"]intValue] - [self countFromArray:divide];
            maxCountParent = [divideParent[dat.dividePage]intValue];
            currentCount = [divide[dat.dividePage]intValue] + plus;
            if (maxCount<=0) {
                return NO;
            }
        }
    }
    else{
        maxCountParent = [_pare[@"count"]intValue];
        currentCount = [_edit[@"count"]intValue] + plus;
        key = @"count";
        
        if (currentCount<0) {
            return NO;
        }
    }


    //ノンセレクト商品の判定
    if ([_cate[@"LimitCount"]isEqualToString:@"5"]) {
        return NO;
    }
    

    //多可、制限無し商品の判定
    int currentTotalCount = 0; //現在のカテゴリ内商品数
    BOOL isCountLimit = NO;
    
    if (![_cate[@"LimitCount"]isEqualToString:@"2"]&&![_cate[@"LimitCount"]isEqualToString:@"4"]) {
        NSArray *_list = [orderManager getSubMenuList:_cate];
        if ([key isEqualToString:@"count"]) {
            currentTotalCount = [self countFromArray:[_list valueForKey:key]];
        }
        else{
            currentTotalCount = [self countFromArrayDivide:[_list valueForKey:key]];
        }
        
        isCountLimit = YES;
    }
    
    if (_edit) {
        if (currentCount<100) {
            
            //LOG(@"_edit1:%d",currentCount);
            
            NSString *_str = nil;
            if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
                NSMutableArray *array = [NSMutableArray arrayWithArray:[_edit[@"countDivide"] componentsSeparatedByString:@","]];
                array[dat.dividePage] = [NSString stringWithFormat:@"%zd",currentCount];
                _str = [array componentsJoinedByString:@","];
            }
            else{
                _str = [NSString stringWithFormat:@"%zd",currentCount];
            }
            
            
            if (type==1||type==2) {
                
                //多不可を判定する
                if (isCountLimit) {
                    if (maxCountParent<currentTotalCount+1) {
                        NSString *_str = [NSString stringWithFormat:[String The_number_of_the_composition],maxCountParent];
                        //2014-01-31 ueda
                        //Alert([String Order_Station], _str);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_str];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        
                        if (isShowSub1) {
                            [self performSelector:@selector(showSub1Table) withObject:nil afterDelay:0.1f];
                        }
                        
                        return NO;
                    }
                }
                
                _edit[key] = _str;
                
                
                //Note:シングルトレイ
                //トレイ番号を追加する
                NSMutableDictionary *pare = [self currentParentEditMenu];
                if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
                    _edit[@"trayNo"] = dat.TrayNo;
                }
                
                [orderManager addSubMenu:_edit
                                      SG:type];
                [self.subGridView reloadObjectAtIndex:currentPositon animated:NO];
            }
            else if(type==5){
                LOG(@"_edit:%@",_edit);
                _edit[key] = _str;
                _edit[@"PageNo"] = [NSString stringWithFormat:@"%zd",dat.ArrangeMenuPageNo+1];
                
                if (isShowSub1) {
                    _edit[@"TopSyohinCD"] = editSub1Menu[@"TopSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = editSub1Menu[@"MstSyohinCD"];
                }
                else if (isShowGroup1) {
                    _edit[@"TopSyohinCD"] = editFolder1Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else if (isShowGroup2) {
                    _edit[@"TopSyohinCD"] = editFolder2Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else{
                    _edit[@"TopSyohinCD"] = editMenu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                [orderManager addArrangeMenu:_edit update:YES];
                [self.subGridView reloadObjectAtIndex:currentPositon animated:NO];
            }
            else{
                _edit[key] = _str;
                
                
                //トップ商品をプラス1する
                if ([_edit[@"TrayStyle"]isEqualToString:@"1"]) {
                    _edit[@"trayNo"] = @"01";
                }
                
                [orderManager addTopMenu:_edit];

                [self.subGridView reloadObjectAtIndex:currentPositon animated:NO];
                [self.gmGridView reloadObjectAtIndex:currentPositon animated:NO];
            }
        }
    }
    [self performSelector:@selector(reloadDispCount)];
    
    return YES;
}

- (void)showSub1Table{
    
    

    isShowSub1 = YES;
    isShowSub2 = NO;
    
    editSub2Category = nil;
    editSub2Menu = nil;
    editSub1Menu = nil;
    dat.Sub2MenuPage = 0;


    if (!self.gmGridView.hidden) {
        self.gmGridView.hidden = YES;
        self.subView.hidden = NO;
        self.gmGridView.actionDelegate = nil;
        self.gmGridView.dataSource = nil;
        self.subGridView.actionDelegate = self;
        self.subGridView.dataSource = self;
    }

    
    //カテゴリー表示を更新する
    [self reloadCategoryList];//categorySub1List配列更新のため
    [self reloadBottomControl];
    [self reloadMenuList];

    if (editSub1Category) {
        [self setCategory:editSub1Category];
    }
    else{
        [self setCategory:[categoryList objectAtIndex:0]];
    }

    //[self reloadBottomControl];
}

- (void)showSub2Table{
    
    
    
    isShowSub1 = NO;
    isShowSub2 = YES;
    

    if (!self.gmGridView.hidden) {
        self.gmGridView.hidden = YES;
        self.subView.hidden = NO;
        self.gmGridView.actionDelegate = nil;
        self.gmGridView.dataSource = nil;
        self.subGridView.actionDelegate = self;
        self.subGridView.dataSource = self;
    }
    
    
    //カテゴリー表示を更新する
    [self reloadCategoryList];//categorySub1List配列更新のため
    
    [self setCategory:[categoryList objectAtIndex:0]];
    
    [self reloadBottomControl];
}

- (void)hideSubTable{

    isShowSub1 = NO;
    isShowSub2 = NO;
    isShowArrange = NO;
    //2016-02-03 ueda ASTERISK
    self.lb_tpTitle.hidden = YES;

    
    editSub1Category = nil;
    editSub1Menu = nil;
    editMenu = nil;
    dat.Sub1MenuPage = 0;
    dat.TrayMenuPageNo = 0;
    dat.TrayNo = @"00";
    
    
    self.gmGridView.hidden = NO;
    self.subView.hidden = YES;
    self.gmGridView.actionDelegate = self;
    self.gmGridView.dataSource = self;
    self.subGridView.actionDelegate = nil;
    self.subGridView.dataSource = nil;
    
    //カテゴリー表示を更新する
    [self reloadCategoryList];//categorySub1List配列更新のため
    [self setCategory:[self currentEditCategory]];
    
    [self reloadBottomControl];
}

//2014-06-23 ueda
//商品画像表示
- (void)showMenuImage{
    if (menuImage) {
        [self performSegueWithIdentifier:@"ToImageView" sender:menuImage];
    }
    
}

- (void)showArrangeTable{
    
    //isShowSub1 = NO;
    //isShowSub2 = NO;
    isShowArrange = YES;
    //2016-02-03 ueda ASTERISK
    self.lb_tpTitle.hidden = NO;

    dat.ArrangeMenuPage = 0;
    dat.ArrangeMenuPageNo = 0;
    [self reloadBottomControl];

    
    if (!self.gmGridView.hidden) {
        self.gmGridView.hidden = YES;
        self.subView.hidden = NO;
        self.gmGridView.actionDelegate = nil;
        self.gmGridView.dataSource = nil;
        self.subGridView.actionDelegate = self;
        self.subGridView.dataSource = self;
    }
    
    //カテゴリー表示を更新する
    [self reloadCategoryList];//categorySub1List配列更新のため

    for (int ct = 0; ct < categoryList.count; ct++) {
        if (![categoryList[ct][@"MstSyohinCD"] isEqualToString:@"0"]) {
            [self setCategory:categoryList[ct]];
            break;
        }
    }
    
    self.topView.backgroundColor = ARRANGERED;
    //2014-07-11 ueda
    [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:ARRANGERED bounds:self.topView.bounds]]];
}

- (void)hideArrangeTable{
    
    //isShowSub1 = NO;
    //isShowSub2 = NO;
    isShowArrange = NO;
    //2016-02-03 ueda ASTERISK
    self.lb_tpTitle.hidden = YES;
    [self reloadBottomControl];

    
    LOG(@"editSub1Category:%@",editSub1Category);
    
    //[self reloadMenuList];

    //カテゴリー表示を更新する
    [self reloadCategoryList];//categorySub1List配列更新のため
    
    if (!isShowSub1&&!isShowSub2) {
        self.gmGridView.hidden = NO;
        self.subView.hidden = YES;
        self.gmGridView.actionDelegate = self;
        self.gmGridView.dataSource = self;
        self.subGridView.actionDelegate = nil;
        self.subGridView.dataSource = nil;
    }
    
    [self setCategory:[self currentEditCategory]];
    
    dat.ArrangeMenuPageNo = 9999;
}

- (void)hideGroup1Table{
    
    
    dat.Folder1MenuPage = 0;
    editFolder1Category = nil;
    editFolder1Menu = nil;
    editMenu = nil;
    isShowGroup1 = NO;
    isShowGroup2 = NO;
    [self reloadCategoryList];
    [self setCategory:editCategory];
    [self reloadBottomControl];
}

- (void)hideGroup2Table{
    
    dat.Folder2MenuPage = 0;
    editFolder2Category = nil;
    editFolder2Menu = nil;
    editFolder1Menu = nil;
    isShowGroup1 = NO;
    isShowGroup2 = NO;
    
    [self reloadMenuList];
    
    isShowGroup1 = YES;
    
    [self reloadCategoryList];
    [self setCategory:editFolder1Category];
}

- (void)reloadDispCount{
    
    NSMutableDictionary *_pare = [self currentParentEditMenu];
    NSMutableDictionary *_cate = [self currentEditCategory];
    
    NSInteger currentCountTotal = 0;
    NSInteger parentCount = 0;
    NSString *retainCount = 0;
    
    
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        NSArray *divide = [_pare[@"countDivide"] componentsSeparatedByString:@","];
        currentCountTotal = [self countFromArrayDivide:[menuList valueForKey:@"countDivide"]];
        parentCount = [divide[dat.dividePage]intValue];
        //2016-03-17 ueda
/*
         retainCount = [NSString stringWithFormat:@"%d",[_pare[@"count"]intValue]-[self countFromArray:divide]];
 */
        //2016-03-17 ueda
        if (self.type==TypeOrderCancel) {
            //取消
            retainCount = [NSString stringWithFormat:@"%d",[_pare[@"count"]intValue]];
        } else {
            //分割
            retainCount = [NSString stringWithFormat:@"%d",[_pare[@"count"]intValue]-[self countFromArray:divide]];
        }
    }
    else{
        currentCountTotal = [self countFromArray:[menuList valueForKey:@"count"]];
        parentCount = [_pare[@"count"] intValue];
    }
    


    if (isShowArrange) {
        if ([_pare[@"TrayStyle"]isEqualToString:@"1"]) {
            parentCount = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
        }
        LOG(@"isShowArrange:%zd:%@",dat.ArrangeMenuPageNo,_pare);
        self.lb_dispCount.text = [NSString stringWithFormat:@"%zd    /    %zd",dat.ArrangeMenuPageNo+1,parentCount];
    }
    else{
        //ノンセレクト商品の判定
        LOG(@"%@",menuList);
        if ([_cate[@"LimitCount"]isEqualToString:@"5"]) {
            self.lb_dispCount.text = [NSString stringWithFormat:@"           %zd",parentCount];
        }
        else{
            self.lb_dispCount.text = [NSString stringWithFormat:@"%zd    /    %zd",currentCountTotal,parentCount];
        }
    }
    
    if ([_pare[@"JikaFLG"] isEqualToString:@"1"]) {
        self.lb_dispJika.text = [NSString stringWithFormat:@"@%@",[DataList appendComma:_pare[@"Jika"]]];
    }
    else{
        self.lb_dispJika.text = @"";
    }
    
    self.lb_dispCountSub.text = retainCount;
    self.lb_dispName.text = [NSString stringWithFormat:@"%@\n%@\n%@",_pare[@"HTDispNMU"],_pare[@"HTDispNMM"],_pare[@"HTDispNML"]];
    
    LOG(@"3:%@",self.lb_dispCount.text);
    
    //2015-12-15 ueda ASTERISK
    if (isShowSub1&&[_pare[@"TrayStyle"]isEqualToString:@"1"]) {
        NSInteger count = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
        self.lb_dispSingleTrayCountAll.text = [NSString stringWithFormat:@"(%zd)",count];
    } else {
        self.lb_dispSingleTrayCountAll.text = nil;
    }
}

- (void)reloadCategoryList{
    
    if (isShowArrange){
        categoryList = [orderManager getArrangeCategoryList];
    }
    else if (isShowSub1) {
        categoryList = [orderManager getSubCategoryList:[self currentParentEditMenu]];
    }
    else if (isShowSub2) {
        categoryList = [orderManager getSubCategoryList:[self currentParentEditMenu]];
    }
    else if (isShowGroup1){
        NSInteger count = kMenuCount * dat.menuPage;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSInteger ct = count; ct<MIN([menuList count], kMenuCount*(dat.menuPage+1)); ct++) {
            if ([menuList[ct][@"BFLG"]isEqualToString:@"1"]) {
                [array addObject:menuList[ct]];
            }
            else{
                [array addObject:@{@"MstSyohinCD": @"0"}];
            }
        }
        categoryList = [[NSArray alloc]initWithArray:array];
    }
    else if (isShowGroup2){
        LOG(@"1");
        NSInteger count = kMenuCount * dat.Folder1MenuPage;
        NSMutableArray *array = [[NSMutableArray alloc]init];
        for (NSInteger ct = count; ct<MIN([menuList count], kMenuCount*(dat.Folder1MenuPage+1)); ct++) {
            if ([menuList[ct][@"BNGFLG"]isEqualToString:@"1"]) {
                [array addObject:menuList[ct]];
            }
            else{
                [array addObject:@{@"MstSyohinCD": @"0"}];
            }
        }
        categoryList = [[NSArray alloc]initWithArray:array];
        LOG(@"2");
    }
    else{
        categoryList = [orderManager getCategoryList];
    }
}

- (int)countFromArray:(NSArray*)_array{
    
    LOG(@"%@",_array);
    
    if (!_array) {
        return 0;
    }
    
    int index = 0;
    for (int ct = 0; ct < [_array count]; ct++) {
        NSString *_str = [_array objectAtIndex:ct];
        if (_str!=nil&&(id)_str!=[NSNull null]) {
            index = index + [_str intValue];
        }
    }
    return index;
}

- (int)countFromArrayDivide:(NSArray*)_array{
    
    LOG(@"_array:%@",_array);
    
    if (!_array) {
        return 0;
    }
    
    int index = 0;
    for (int ct = 0; ct < [_array count]; ct++) {
        NSString *_str = [_array objectAtIndex:ct];
        NSArray *_divide = [_str componentsSeparatedByString:@","];
        index = index + [_divide[dat.dividePage] intValue];
    }
    
    LOG(@"result:%d",index);
    
    return index;
}

- (int)countFromArrayDivideAll:(NSArray*)_array{
    
    LOG(@"_array:%@",_array);
    
    if (!_array) {
        return 0;
    }
    
    int index = 0;
    for (int ct = 0; ct < [_array count]; ct++) {
        NSString *_str = [_array objectAtIndex:ct];
        NSArray *_divide = [_str componentsSeparatedByString:@","];
        
        for (int ct1 = 0; ct1<[_divide count]; ct1++) {
            index = index + [_divide[dat.dividePage] intValue];
        }
    }
    
    LOG(@"result:%d",index);
    
    return index;
}


- (void)countDown:(NSInteger)type{

    NSMutableDictionary *_edit = nil;
    NSMutableDictionary *_cate = nil;
    int SG = 0;
    if (type==0){
        if (isShowGroup1) {
            _edit = editFolder1Menu;
        }
        else if (isShowGroup1) {
            _edit = editFolder2Menu;
        }
        else{
            _edit = editMenu;
        }
    }
    else if (type==1) {
        _edit = editSub1Menu;
        _cate = editSub1Category;
        SG = 1;
    }
    else if (type==2) {
        _edit = editSub2Menu;
        _cate = editSub2Category;
        SG = 2;
    }
    else if (type==3) {
        _edit = editFolder1Menu;
    }
    else if (type==4) {
        _edit = editFolder2Menu;
    }
    else if (type==5) {
        _edit = editArrangeMenu;
    }
    
    //ノンセレクト商品の判定
    if ([_cate[@"LimitCount"]isEqualToString:@"5"]) {
        return;
    }
    
    if (_edit) {
        if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
            NSArray *divide = [_edit[@"countDivide"]  componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            array[dat.dividePage] = @"0";
            _edit[@"countDivide"] = [array componentsJoinedByString:@","];
            
            if (type==1||type==2) {
                [orderManager addSubMenu:_edit
                                      SG:SG];
                [self.subGridView reloadData];
            }
            else if(type==5){
                NSArray *divide = [_edit[@"countDivide"]  componentsSeparatedByString:@","];
                NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                array[dat.dividePage] = @"0";
                _edit[@"PageNo"] = [NSString stringWithFormat:@"%zd",dat.ArrangeMenuPageNo+1];
                if (isShowSub1) {
                    _edit[@"TopSyohinCD"] = editMenu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = editSub1Menu[@"MstSyohinCD"];
                }
                else if (isShowGroup1) {
                    _edit[@"TopSyohinCD"] = editFolder1Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else if (isShowGroup2) {
                    _edit[@"TopSyohinCD"] = editFolder2Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else{
                    _edit[@"TopSyohinCD"] = editMenu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                [orderManager addArrangeMenu:_edit update:YES];
                [self.subGridView reloadData];
            }
            else{
                [orderManager addTopMenu:_edit];
                [self.gmGridView reloadData];
            }
        }
        else{
            _edit[@"count"] = @"0";
            
            //時価価格をリセットする
            if ([[_edit allKeys]containsObject:@"Jika"]) {
                [_edit removeObjectForKey:@"Jika"];
            }
            
            if (type==1||type==2) {
                [orderManager addSubMenu:_edit
                                      SG:SG];
                [self.subGridView reloadData];
            }
            else if(type==5){
                _edit[@"PageNo"] = [NSString stringWithFormat:@"%zd",dat.ArrangeMenuPageNo+1];
                if (isShowSub1) {
                    _edit[@"TopSyohinCD"] = editMenu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = editSub1Menu[@"MstSyohinCD"];
                }
                else if (isShowGroup1) {
                    _edit[@"TopSyohinCD"] = editFolder1Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else if (isShowGroup2) {
                    _edit[@"TopSyohinCD"] = editFolder2Menu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                else{
                    _edit[@"TopSyohinCD"] = editMenu[@"MstSyohinCD"];
                    _edit[@"Sub1SyohinCD"] = @"";
                }
                [orderManager addArrangeMenu:_edit update:NO];
                [self.subGridView reloadData];
            }
            else{
                
                if ([_edit[@"TrayStyle"]isEqualToString:@"1"]) {//トレイ商品の場合は全てのトレイを削除
                    NSArray *array = [orderManager getTrayList:_edit[@"SyohinCD"]];
                    for (int ct = 0; ct < array.count; ct++) {
                        _edit[@"trayNo"] = @"01";//削除のたびに更新されるので常に01を消していく
                        [orderManager addTopMenu:_edit];
                    }
                }
                else{
                    [orderManager addTopMenu:_edit];
                }
                [self.gmGridView reloadData];
            }
        }
    }
    [self reloadDispCount];
}

- (void)returnEntryCount:(NSString*)jika
               menuCount:(NSString*)count{
    
    NSString *key = @"";
    //int currentCount = 0;
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        key = @"countDivide";
        //currentCount = [self countFromArrayDivide:[menuList valueForKey:key]];
    }
    else{
        key = @"count";
        //currentCount = [self countFromArray:[menuList valueForKey:key]];
    }
    
    //NSMutableDictionary *_pare = nil;
    NSMutableDictionary *_edit = nil;
    //NSMutableDictionary *_cate = nil;
    int SG = 0;
    if (isShowArrange) {
        if (isShowGroup1) {
            //_pare = editFolder1Menu;
        }
        else if (isShowGroup2) {
            //_pare = editFolder2Menu;
        }
        else{
            //_pare = editMenu;
        }
        _edit = editArrangeMenu;
        //_cate = editArrangeCategory;
        SG = 1;
    }
    else if (isShowSub1) {
        //_pare = editMenu;
        _edit = editSub1Menu;
        //_cate = editSub1Category;
        SG = 1;
    }
    else if (isShowSub2) {
        //_pare = editSub1Menu;
        _edit = editSub2Menu;
        //_cate = editSub2Category;
        SG = 2;
    }
    else if (isShowGroup1) {
        //_pare = editMenu;
        _edit = editFolder1Menu;
        //_cate = editFolder1Category;
    }
    else if (isShowGroup2) {
        //_pare = editFolder1Menu;
        _edit = editFolder2Menu;
        //_cate = editFolder2Category;
    }
    else{
        _edit = editMenu;
    }
    
    
    
    if (_edit) {
        _edit[@"count"] = count;
        if ([count intValue]==0) {
            _edit[@"Jika"] = _edit[@"Tanka"];
        }
        else{
            _edit[@"Jika"] = [NSString stringWithFormat:@"%@",jika];
        }
        
        if (isShowSub1||isShowSub2) {
            [orderManager addSubMenu:_edit
                                  SG:SG];
            if (isShowSub1) {
                editSub1Menu = nil;
            }
            else if(isShowSub2){
                editSub2Menu = nil;
            }
            [self.subGridView reloadData];
        }
        else{
            [orderManager addTopMenu:_edit];
            //2016-02-17 ueda
            //editMenu = nil;
            //2016-02-17 ueda
            [self reloadMenuList];
            [self.gmGridView reloadData];
        }
    }
}

- (IBAction)iba_countUpTop:(id)sender{

    if (isShowArrange) {
        //2014-10-01 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            if (isTap) {
                UIAlertView *message = [[UIAlertView alloc] initWithTitle:[String Enter_a_Arrange]
                                                                  message:nil
                                                                 delegate:self
                                                        cancelButtonTitle:nil
                                                        otherButtonTitles:[String bt_ok],[String bt_cancel], nil];
                [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
                message.tag = 103;
                [message show];
            } else {
                isTap = YES;
                [self performSelector:@selector(tapIsDisabaled) withObject:nil afterDelay:0.3f];
            }
        }
        return;
    }
    
    //2015-07-09 ueda
    [System tapSound];

    self.topView.backgroundColor = BLUE;
    //2014-07-11 ueda
    [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
    
    int type = 0;
    if (isShowSub1) {
        type = 0;
        editSub1Menu = nil;
        //parentMenu = editMenu;
    }
    else if (isShowSub2) {
        type = 1;
        editSub2Menu = nil;
        //parentMenu = editSub1Menu;
    }

    //Note:シングルトレイ
    //[self countUp:type];
    
     NSMutableDictionary *parentMenu = [self currentParentEditMenu];
    if ([parentMenu[@"TrayStyle"]isEqualToString:@"0"]) {
        if ([self count:1 type:type]) {
            [self reloadMenuList];
        }
    }
    //2014-09-19 ueda
    //2014-10-01 ueda 再度使用
    else{
        LOG(@"%@",parentMenu);
     
        //2015-11-13 ueda ASTERISK_TEST
/*
        if (isTap) {
            //Alert(@"tray", @"");
            popView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PopViewController"];
            [self.view addSubview:popView.view];
            
            NSInteger trayTotal = [orderManager getTrayTotal:parentMenu[@"SyohinCD"]];
            popView.lb_label.text = [NSString stringWithFormat:@"  %@ [%zd->?]",[String Tray],trayTotal];
            //2014-01-28 ueda
            //popView.lb_title.text = [NSString stringWithFormat:@"%@\n%@\n%@",parentMenu[@"HTDispNMU"],parentMenu[@"HTDispNMM"],parentMenu[@"HTDispNML"]];
            popView.lb_title.text = [NSString stringWithFormat:@"%@%@%@",parentMenu[@"HTDispNMU"],parentMenu[@"HTDispNMM"],parentMenu[@"HTDispNML"]];
            popView.lb_count.text = [NSString stringWithFormat:@"%zd",trayTotal];
            [popView.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
            [popView.bt_done setTitle:[String bt_done] forState:UIControlStateNormal];
            
            [popView.bt_return addTarget:self action:@selector(hidePopView) forControlEvents:UIControlEventTouchUpInside];
            [popView.bt_done addTarget:self action:@selector(donePopView) forControlEvents:UIControlEventTouchUpInside];
            [popView.bt_countUp addTarget:self action:@selector(countUpTray) forControlEvents:UIControlEventTouchUpInside];
            [popView.bt_countDown addTarget:self action:@selector(countDownTray) forControlEvents:UIControlEventTouchUpInside];
        }
        else{
            isTap = YES;
            [self performSelector:@selector(tapIsDisabaled) withObject:nil afterDelay:0.3f];
        }
 */
        //2015-11-13 ueda ASTERISK_TEST
        if (YES) {
            NSMutableDictionary *menu = nil;
            if (isShowGroup1) {
                menu = editFolder1Menu;
            }
            else if (isShowGroup2) {
                menu = editFolder2Menu;
            }
            else{
                menu = editMenu;
            }
            
            //配列を取得
            NSArray *array = [orderManager getTrayList:menu[@"SyohinCD"]];
            
            //2015-12-15 ueda ASTERISK
            if ([array count] < 99) {
                //トレイ番号の最大値を取得
                NSArray *countList = [array valueForKeyPath:@"trayNo"];
                //int count = 0;
                int intTrayNo = 0;
                for (int ct=0; ct<[countList count]; ct++) {
                    if (intTrayNo<[countList[ct]intValue]) {
                        intTrayNo = [countList[ct]intValue];
                    }
                }
                
                //足りない商品を追加
                //int resultCount = [popView.lb_count.text intValue];
                //for (int ct = 0; ct<resultCount-[countList count]; ct++) {
                for (int ct = 0; ct<1; ct++) {
                    menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",intTrayNo+ct+1];
                    [orderManager addTopMenu:menu];
                }
                [self reloadDispCount];
                [self reloadBottomControl];
            }
            
        }
    }
    
    [self.subGridView reloadData];
}

//2014-09-19 ueda
//2014-10-01 ueda 再度使用
- (void)tapIsDisabaled{
    isTap = NO;
}

- (IBAction)iba_countDownTop:(id)sender{

    //2015-07-09 ueda
    [System tapSound];
    
    //2014-01-30 ueda
    //UIAlertView *alert = nil;
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;

    NSMutableDictionary *edit = [self currentParentEditMenu];
    if (isShowSub1&&[edit[@"TrayStyle"]isEqualToString:@"1"]) {//シングルトレイの場合
        NSInteger trayTotal = [orderManager getTrayTotal:edit[@"SyohinCD"]];
        LOG(@"%zd",trayTotal);
        if (trayTotal>1) {
            NSString *mess1 = [NSString stringWithFormat:[String Erase_Tray],dat.TrayMenuPageNo+1];
            //2014-01-30 ueda
            /*
            alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                              message:mess1
                                             delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:[String Yes],[String No], nil];
            */
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",mess1];
       }
        else{
            //2014-01-30 ueda
            /*
            alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                              message:[String Clear_This_Item]
                                             delegate:self
                                    cancelButtonTitle:nil
                                    otherButtonTitles:[String Yes],[String No], nil];
             */
            //2014-01-30 ueda
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_This_Item]];
        }

    }
    else{
        //2014-01-30 ueda
        /*
        alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                          message:[String Cancel_syohin]
                                         delegate:self
                                cancelButtonTitle:nil
                                otherButtonTitles:[String Yes],[String No], nil];
         */
        //2014-01-30 ueda
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cancel_syohin]];
    }
    

    if (isShowSub1&&[edit[@"TrayStyle"]isEqualToString:@"1"]) {//シングルトレイの場合
        NSInteger trayTotal = [orderManager getTrayTotal:edit[@"SyohinCD"]];
        LOG(@"%zd",trayTotal);
        if (trayTotal==1) {
            alert.tag = 6;
        }
        else{
            alert.tag = 1;
        }
    }
    else if (!isShowArrange) {
        self.topView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
        alert.tag = 1;
    }
    else{
        alert.tag = 6;
    }
    
    ///2015-07-09 ueda
    alert.messageLabel.font=[UIFont systemFontOfSize:18];

    [alert show];
}

- (IBAction)iba_countDownTopSub:(id)sender{
    
    if (!isShowArrange) {
        self.topView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
    }
    
    
    NSMutableDictionary *_cate = [self currentEditCategory];
    if ([_cate[@"LimitCount"]isEqualToString:@"5"]) {
        int type = 0;
        if (isShowSub1) {
            type = 0;
            editSub1Menu = nil;
        }
        else if (isShowSub2) {
            type = 1;
            editSub2Menu = nil;
        }
        //NSMutableDictionary *menu = [self currentEditCategory];
        if ([self count:-1 type:type]) {
            [self reloadMenuList];
            [self.subGridView reloadData];
        }
    }
    else{
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                       message:[String Cancel_syohin]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[String Yes],[String No], nil];
        */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cancel_syohin]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 6;
        [alert show];
    }
}

- (void)clearTopCount{
    LOG(@"clearTopCount");
    
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        if (isShowSub1) {
            NSMutableDictionary *_pare = [self currentParentEditMenu];
            NSArray *divide = [_pare[@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            array[dat.dividePage] = @"0";
            _pare[@"countDivide"] = [array componentsJoinedByString:@","];
            [orderManager addTopMenu:_pare];
            
            //サブメニューの0配列を追加する
            //2015-02-16 ueda
            NSMutableArray *list = [orderManager getOrderListForConfirm:NO
                                                             isSubGroup:YES
                                                              isArrange:NO
                                                            typeOrderNo:self.type];
            for (int ct = 0; ct<[list count]; ct++) {
                NSMutableDictionary *menu = list[ct];
                
                if ([menu[@"TopSyohinCD"]isEqualToString:_pare[@"MstSyohinCD"]]&&
                     [menu[@"trayNo"]isEqualToString:_pare[@"trayNo"]]) {
                    NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
                    
                    if (divide.count > dat.dividePage+1) {
                        break;
                    }
                    
                    NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                    array[dat.dividePage] = @"0";
                    menu[@"countDivide"] = [array componentsJoinedByString:@","];
                    
                    
                    if([[menu allKeys] containsObject:@"SG1ID"]){
                        LOG(@"追加内容の確認　SG1に追加:%d:%@",ct,menu);
                        [orderManager addSubMenu:menu SG:1];
                    }
                    else if([[menu allKeys] containsObject:@"SG2ID"]){
                        LOG(@"追加内容の確認　SG2に追加:%d:%@",ct,menu);
                        [orderManager addSubMenu:menu SG:2];
                    }
                    else{
                        LOG(@"追加内容の確認　TOPに追加:%d:%@",ct,menu);
                        [orderManager addTopMenu:menu];
                    }
                }
            }
            
            editSub1Menu = nil;
            
            [self setCategory:[self currentEditCategory]];
        }
        else if (isShowSub2) {
        
            NSArray *divide = [editSub1Menu[@"countDivide"] componentsSeparatedByString:@","];
            NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
            array[dat.dividePage] = @"0";
            editSub1Menu[@"countDivide"] = [array componentsJoinedByString:@","];
            [orderManager addSubMenu:editSub1Menu
                                  SG:1];
            
            //サブメニューの0配列を追加する
            //2015-02-16 ueda
            NSMutableArray *list = [orderManager getOrderListForConfirm:NO
                                                             isSubGroup:YES
                                                              isArrange:NO
                                                            typeOrderNo:self.type];
            for (int ct = 0; ct<[list count]; ct++) {
                NSMutableDictionary *menu = list[ct];
                NSArray *divide = [menu[@"countDivide"] componentsSeparatedByString:@","];
                
                if (divide.count > dat.dividePage+1) {
                    break;
                }
                
                NSMutableArray *array = [NSMutableArray arrayWithArray:divide];
                array[dat.dividePage] = @"0";
                menu[@"countDivide"] = [array componentsJoinedByString:@","];
                
                
                if([[menu allKeys] containsObject:@"SG1ID"]){
                    LOG(@"追加内容の確認　SG1に追加:%d:%@",ct,menu);
                    [orderManager addSubMenu:menu SG:1];
                }
                else if([[menu allKeys] containsObject:@"SG2ID"]){
                    LOG(@"追加内容の確認　SG2に追加:%d:%@",ct,menu);
                    [orderManager addSubMenu:menu SG:2];
                }
                else{
                    LOG(@"追加内容の確認　TOPに追加:%d:%@",ct,menu);
                    [orderManager addTopMenu:menu];
                }
            }
            
            editSub2Menu = nil;
            
            [self setCategory:editSub2Category];
        }
    }
    else{
        
        NSMutableDictionary *pare = [self currentParentEditMenu];
        NSMutableDictionary *menu = [self currentEditMenu];
        pare[@"count"] = @"0";
        
        if (isShowArrange) {
            
            editArrangeMenu = nil;
            
            
            if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
                [self countDown:0];
            }
            else{
                if (isShowGroup1) {
                    //2015-09-17 ueda
/*
                    [orderManager addTopMenu:menu];
 */
                    [orderManager addTopMenu:editFolder1Menu];
                }
                else if (isShowGroup2) {
                    [orderManager addTopMenu:editFolder2Menu];
                }
                else{
                    [orderManager addTopMenu:editMenu];
                }
            }
        }
        else if (isShowSub1) {
            editSub1Menu = nil;
            [orderManager addTopMenu:pare];
            
            if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
                pare[@"count"] = @"1";
                [self reloadBottomControl];//シングルトレイのNo更新対策
            }
        }
        else if (isShowSub2) {
            editSub2Menu = nil;
            [orderManager addSubMenu:editSub1Menu
                                  SG:1];
        }
        
        [self setCategory:[self currentEditCategory]];
    }
}

- (void)countUpTray{
    int count = [popView.lb_count.text intValue];
    count++;
    if (count<100) {
        popView.lb_count.text = [NSString stringWithFormat:@"%d",count];
    }
}

- (void)countDownTray{
    int count = [popView.lb_count.text intValue];
    count--;
    NSMutableDictionary *_pare = [self currentParentEditMenu];
    NSInteger trayTotal = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
    if (count>=trayTotal) {
        popView.lb_count.text = [NSString stringWithFormat:@"%d",count];
    }
}

- (void)hidePopView{
    [popView.view removeFromSuperview];
    //2014-10-01 ueda
    //isDispTray = NO;
}

- (void)donePopView{
    NSMutableDictionary *_pare = [self currentParentEditMenu];
    NSInteger trayTotal = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
    NSInteger count = [popView.lb_count.text intValue];

    if (trayTotal!=count) {
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                       message:[NSString stringWithFormat:[String Add_to_trays],count-trayTotal]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[String Yes],[String No], nil];
        */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        NSString *mess1 = [NSString stringWithFormat:[String Add_to_trays],count-trayTotal];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",mess1];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 5;
        [alert show];
    }
    else{
        [self hidePopView];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==1) {
        switch (buttonIndex) {
            case 0:
                [self clearTopCount];
                
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==2) {
        switch (buttonIndex) {
            case 0:
                //2015-11-13 ueda ASTERISK_TEST
                if (YES) {
                    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
                    //2015-12-17 ueda ASTERISK
                    if (self.type == TypeOrderCancel) {
                        //取消の場合は赤色
                        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
                    }
                }
                [self orderCancel1];
                
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==3) {
        switch (buttonIndex) {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==4) {
        switch (buttonIndex) {
            case 0:
                [self showArrangeTable];
                break;

            case 1:
                break;
                
            case 2:
                [self showMenuImage];
                break;
        }
    }
    else if (alertView.tag==45) {
        switch (buttonIndex) {
            case 0:
                break;
                
            case 1:
                [self showMenuImage];
                break;
        }
    }
    else if (alertView.tag==5) {
        switch (buttonIndex) {
            case 0:{
                
                NSMutableDictionary *menu = nil;
                if (isShowGroup1) {
                    menu = editFolder1Menu;
                }
                else if (isShowGroup2) {
                    menu = editFolder2Menu;
                }
                else{
                    menu = editMenu;
                }
                
                //配列を取得
                NSArray *array = [orderManager getTrayList:menu[@"SyohinCD"]];
                
                //トレイ番号の最大値を取得
                NSArray *countList = [array valueForKeyPath:@"trayNo"];
                //int count = 0;
                int intTrayNo = 0;
                for (int ct=0; ct<[countList count]; ct++) {
                    if (intTrayNo<[countList[ct]intValue]) {
                        intTrayNo = [countList[ct]intValue];
                    }
                }
                
                //足りない商品を追加
                int resultCount = [popView.lb_count.text intValue];
                for (int ct = 0; ct<resultCount-[countList count]; ct++) {
                    menu[@"trayNo"] = [NSString stringWithFormat:@"%02d",intTrayNo+ct+1];
                    [orderManager addTopMenu:menu];
                }
                [self hidePopView];
                [self reloadDispCount];
                [self reloadBottomControl];
                break;
            }
            case 1:
                
                break;
        }
    }
    else if (alertView.tag==6) {//サブメニュークリア
        switch (buttonIndex) {
            case 0:{
                
                //シングルトレイ対応
                NSMutableDictionary *pare = [self currentParentEditMenu];
                if ((self.type!=TypeOrderCancel&&self.type!=TypeOrderDivide)
                    &&isShowSub1&&[pare[@"TrayStyle"]isEqualToString:@"1"]) {
                    editSub1Menu = nil;
                    for (int ct = 0; ct < menuList.count; ct++) {
                        NSMutableDictionary *sub1Menu = menuList[ct];
                        if ([sub1Menu[@"count"]intValue]>0) {
                            sub1Menu[@"count"] = @"0";
                            [orderManager addSubMenu:sub1Menu SG:1];
                        }
                    }
                    [self.subGridView reloadData];
                }
                else{
                
                NSMutableDictionary *tempMenu = nil;
                if (isShowSub2) {
                    tempMenu = [editSub1Menu copy];
                }
                else if (isShowGroup1) {
                    tempMenu = [editFolder1Menu copy];
                }
                else if (isShowGroup2) {
                    tempMenu = [editFolder2Menu copy];
                }
                else{
                    tempMenu = [editMenu copy];
                }
                
                [self clearTopCount];
                
                
                if (isShowSub2) {
                    editSub1Menu = [[NSMutableDictionary alloc]initWithDictionary:tempMenu];
                    [orderManager addSubMenu:editSub1Menu
                                          SG:1];
                }
                else if (isShowGroup1) {
                    editFolder1Menu = [[NSMutableDictionary alloc]initWithDictionary:tempMenu];
                    [orderManager addTopMenu:editFolder1Menu];
                }
                else if (isShowGroup2) {
                    editFolder2Menu = [[NSMutableDictionary alloc]initWithDictionary:tempMenu];
                    [orderManager addTopMenu:editFolder2Menu];
                }
                else{
                    editMenu = [[NSMutableDictionary alloc]initWithDictionary:tempMenu];
                    [orderManager addTopMenu:editMenu];
                }
                }
                
                [self reloadDispCount];
                
                break;
            }
            case 1:
                break;
        }
    }
    //2014-09-10 ueda
    if (alertView.tag==102) {
        switch (buttonIndex) {
            case 0:
                [self performSegueWithIdentifier:@"ToOrderSummaryView" sender:nil];
                break;
                
            case 1:
                break;
        }
    }
    //2014-09-19 ueda
    if (alertView.tag == 103) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        switch (buttonIndex) {
            case 0:
                if([inputText length] > 0) {
                    NSString *convText = [System convertOnlyShiftjisText:inputText];
                    if([convText length] > 0) {
                        [self addArrangeData:convText];
                    }
                    if ([inputText length] != [convText length]) {
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[String Cut_Character];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                    }
                }
                break;
                
            case 1:
                break;
        }
    }
    //2015-09-17 ueda
    else if(alertView.tag==1101){
        [self orderSendRetry];
    }
    //2015-09-17 ueda
    else if (alertView.tag==1102){
        switch (buttonIndex) {
            case 0:
                [self orderSendForce];
                break;
                
            case 1:
                if (YES) {
                    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.OrderRequestN31forceFlag = NO;
                }
                break;
                
        }
    }
}

- (IBAction)iba_nextPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        if ((isShowArrange) || (isShowSub1) || (isShowSub2)) {
            NSInteger maxHeight  = self.subGridView.contentSize.height;
            NSInteger pageHeight = self.subGridView.frame.size.height;
            CGPoint currentPos = self.subGridView.contentOffset;
            currentPos.y += self.subGridView.frame.size.height;
            if (currentPos.y >= (maxHeight - 10)) {
                currentPos.y = maxHeight - pageHeight;
            }
            [self.subGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
        } else {
            NSInteger maxHeight  = self.gmGridView.contentSize.height;
            NSInteger pageHeight = self.gmGridView.frame.size.height;
            CGPoint currentPos = self.gmGridView.contentOffset;
            currentPos.y += self.gmGridView.frame.size.height;
            if (currentPos.y >= (maxHeight - 10)) {
                currentPos.y = maxHeight - pageHeight;
            }
            [self.gmGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
        }
    } else {
        if (isShowArrange) {
            editArrangeMenu = nil;
            dat.ArrangeMenuPage++;
            [self.subGridView reloadData];
        }
        else if (isShowSub1) {
            editSub1Menu = nil;
            dat.Sub1MenuPage++;
            [self.subGridView reloadData];
        }
        else if (isShowSub2) {
            editSub2Menu = nil;
            dat.Sub2MenuPage++;
            [self.subGridView reloadData];
        }
        else if (isShowGroup1) {
            editFolder1Menu = nil;
            dat.Folder1MenuPage++;
            [self.gmGridView reloadData];
        }
        else if (isShowGroup2) {
            editFolder2Menu = nil;
            dat.Folder2MenuPage++;
            [self.gmGridView reloadData];
        }
        else{
            editMenu = nil;
            dat.menuPage++;
            [self.gmGridView reloadData];
        }
    }
}

- (IBAction)iba_prevPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        if ((isShowArrange) || (isShowSub1) || (isShowSub2)) {
            CGPoint currentPos = self.subGridView.contentOffset;
            currentPos.y -= self.subGridView.frame.size.height;
            if (currentPos.y < 0) {
                currentPos.y = 0;
            }
            [self.subGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.gmGridView.frame.size.height) animated:YES];
        } else {
            CGPoint currentPos = self.gmGridView.contentOffset;
            currentPos.y -= self.gmGridView.frame.size.height;
            if (currentPos.y < 0) {
                currentPos.y = 0;
            }
            [self.gmGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.gmGridView.frame.size.height) animated:YES];
        }
    } else {
        if (isShowArrange) {
            editArrangeMenu = nil;
            dat.ArrangeMenuPage = MAX(0, dat.ArrangeMenuPage-1);
            [self.subGridView reloadData];
        }
        else if (isShowSub1) {
            editSub1Menu = nil;
            dat.Sub1MenuPage = MAX(0, dat.Sub1MenuPage-1);
            [self.subGridView reloadData];
        }
        else if (isShowSub2) {
            editSub2Menu = nil;
            dat.Sub2MenuPage = MAX(0, dat.Sub2MenuPage-1);
            [self.subGridView reloadData];
        }
        else if (isShowGroup1) {
            editFolder1Menu = nil;
            dat.Folder1MenuPage = MAX(0, dat.Folder1MenuPage-1);
            [self.gmGridView reloadData];
        }
        else if (isShowGroup2) {
            editFolder2Menu = nil;
            dat.Folder2MenuPage = MAX(0, dat.Folder2MenuPage-1);
            [self.gmGridView reloadData];
        }
        else{
            editMenu = nil;
            dat.menuPage = MAX(0, dat.menuPage-1);
            [self.gmGridView reloadData];
        }
    }
}

- (IBAction)iba_nextPageNo:(id)sender{
    
    NSMutableDictionary *_pare = [self currentParentEditMenu];
    
    if (isShowArrange) {
        NSInteger arrangeCount = [DataList sharedInstance].ArrangeMenuPageNo;
        NSInteger maxCount = 0;
        if ([_pare[@"TrayStyle"]isEqualToString:@"1"]) {
            maxCount = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
        }
        else{
            maxCount = [_pare[@"count"]intValue];
        }
        if (maxCount>arrangeCount+1) {
            arrangeCount++;
            [DataList sharedInstance].ArrangeMenuPageNo = arrangeCount;
            [self reloadMenuList];
            editArrangeMenu = nil;
            [self.subGridView reloadData];
            
            [self reloadBottomControl];
            [self reloadDispCount];
        }
        else{
            [self hideArrangeTable];
        }
    }
    else{
        //シングルトレイ
        NSInteger trayCount = [DataList sharedInstance].TrayMenuPageNo;
        NSInteger trayTotal = [orderManager getTrayTotal:_pare[@"SyohinCD"]];
        LOG(@"%zd:%zd",trayCount,trayTotal);
        //2015-12-16 ueda ASTERISK
        //if (trayTotal>trayCount+1) {
        UIButton *button = (UIButton*)sender;
        if ((trayTotal>trayCount+1) && ([button.currentTitle isEqualToString:[String bt_ok]])) {
            if ([self checkSubMenuOrder:sender]) {
                trayCount++;
                [DataList sharedInstance].TrayMenuPageNo = trayCount;

                //2015-12-24 ueda ASTERISK
                if (YES) {
                    NSMutableDictionary *_cate = categoryList[0];
                    [self setCategory:_cate];
                }
                
                [self reloadBottomControl];
                
                [self currentEditMenuClear];
                
                [self reloadMenuList];
                [self.subGridView reloadData];
                [self reloadDispCount];
            }
        }
        else{
            [self iba_showNext:sender];
        }
    }
}

- (IBAction)iba_prevPageNo:(id)sender{
    if (isShowArrange) {
        NSInteger arrangeCount = [DataList sharedInstance].ArrangeMenuPageNo;
        if (arrangeCount>0) {
            arrangeCount--;
            [DataList sharedInstance].ArrangeMenuPageNo = arrangeCount;
            [self reloadMenuList];
            editArrangeMenu = nil;
            [self.subGridView reloadData];
            
            [self reloadBottomControl];
            [self reloadDispCount];
        }
        else{
            //2014-01-30 ueda
            /*
             UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
             message:[String Cancel1]
             delegate:self
             cancelButtonTitle:nil
             otherButtonTitles:[String Yes],[String No], nil];
             */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
            //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cancel1]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 2;
            [alert show];
        }
    }
    else{
        //シングルトレイ
        NSInteger trayCount = [DataList sharedInstance].TrayMenuPageNo;
        //2015-12-28 ueda ASTERISK
        //if (trayCount>0) {
        NSInteger workPtr = 99;
        if (isShowSub1) {
            workPtr = [[editSub1Category objectForKey:@"DispOrder"] integerValue];
        } else if (isShowSub2) {
            workPtr = [[editSub2Category objectForKey:@"DispOrder"] integerValue];
        }
        if ((trayCount>0) && (workPtr == 1)) {
            trayCount--;
            
            [DataList sharedInstance].TrayMenuPageNo = trayCount;
            
            //2015-12-28 ueda ASTERISK
            if (YES) {
                NSMutableDictionary *_cate = categoryList[0];
                [self setCategory:_cate];
            }
            
            [self reloadBottomControl];
            
            [self currentEditMenuClear];
            
            [self reloadMenuList];
            [self.subGridView reloadData];
            [self reloadDispCount];
        }
        else{
            [self iba_back:sender];
        }
    }
}

- (void)reloadBottomControl{
    
    NSInteger count = 0;
    NSInteger menuPage = 0;
    QBFlatButton *bt_next = nil;
    QBFlatButton *bt_prev = nil;
    
    BOOL isNoButton = NO;
    BOOL isNormal = NO;
    
    NSMutableDictionary *pare = [self currentParentEditMenu];
    
    if (isShowArrange) {
        
        [self.bt_nextArrange setTitle:[String bt_next] forState:UIControlStateNormal];
        [self.bt_prevArrange setTitle:[String bt_return] forState:UIControlStateNormal];
        [self.bt_done2 setTitle:[String bt_done] forState:UIControlStateNormal];
        
        
        menuPage = dat.ArrangeMenuPageNo;
        bt_next = self.bt_nextArrange;
        bt_prev = self.bt_prevArrange;
        isNoButton = YES;
        
        if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
            count = [orderManager getTrayTotal:pare[@"SyohinCD"]];
        }
        else{
            count = [pare[@"count"]intValue];
        }
    }
    else if(isShowSub1){
        //トレイ番号を設定する
        if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
            NSArray *array = [orderManager getTrayList:pare[@"SyohinCD"]];
            
            dat.TrayMenuPageNo = MIN(dat.TrayMenuPageNo,array.count-1);
            
            if (array.count>0) {
                dat.TrayNo = array[dat.TrayMenuPageNo][@"trayNo"];
            }
            else{
                dat.TrayNo = @"01";
            }
            
            isNoButton = YES;
            menuPage = dat.TrayMenuPageNo;
            if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
                bt_next = self.bt_nextSingle2;
                bt_prev = self.bt_prevSingle2;
                
                [self.bt_done3 setTitle:[String Modify2] forState:UIControlStateNormal];
            }
            else{
                bt_next = self.bt_nextSingle1;
                bt_prev = self.bt_prevSingle1;
            }
            
            [self.bt_nextSingle1 setTitle:[String bt_ok] forState:UIControlStateNormal];
            [self.bt_nextSingle2 setTitle:[String bt_ok] forState:UIControlStateNormal];
            //2014-09-19 ueda
            UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
            [self.bt_nextSingle1 setBackgroundImage:img forState:UIControlStateNormal];
            [self.bt_nextSingle2 setBackgroundImage:img forState:UIControlStateNormal];
            //2016-02-03 ueda ASTERISK
            [self.bt_nextSingle1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bt_nextSingle2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            [self.bt_prevSingle1 setTitle:[String bt_return] forState:UIControlStateNormal];
            [self.bt_prevSingle2 setTitle:[String bt_return] forState:UIControlStateNormal];
        }
        else{
            [self.bt_done1_1 setTitle:[String bt_ok] forState:UIControlStateNormal];
            [self.bt_done1_2 setTitle:[String bt_ok] forState:UIControlStateNormal];
            //2015-12-17 ueda
            if (YES) {
                //取消時に通常のセット商品の場合にボタンの画像が表示されないのでセットする
                UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
                [self.bt_done1_1 setBackgroundImage:img forState:UIControlStateNormal];
                //2016-02-03 ueda ASTERISK
                [self.bt_done1_1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.bt_done1_2 setBackgroundImage:img forState:UIControlStateNormal];
                //2016-02-03 ueda ASTERISK
                [self.bt_done1_2 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                img = [UIImage imageNamed:@"ButtonReturn.png"];
                [self.bt_return1_1 setBackgroundImage:img forState:UIControlStateNormal];
                [self.bt_return1_2 setBackgroundImage:img forState:UIControlStateNormal];
            }
            
            dat.TrayNo = @"00";
        }
        pare[@"trayNo"] = dat.TrayNo;
        count = [orderManager getTrayTotal:pare[@"SyohinCD"]];
        //2015-12-15 ueda ASTERISK
        if (YES) {
            //最後のカテゴリーは「決定」ボタン、それ以外は「次へ」ボタンにする
            NSMutableDictionary *_cate = categoryList[[categoryList count]-1];
            NSString * _chk1 = [_cate objectForKey:@"DispOrder"];
            NSString * _chk2 = [editSub1Category objectForKey:@"DispOrder"];
            //2015-12-24 ueda ASTERISK
            if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
                if ([_chk1 isEqualToString:_chk2]) {
                    [self.bt_nextSingle1 setTitle:[String bt_ok] forState:UIControlStateNormal];
                    [self.bt_nextSingle2 setTitle:[String bt_ok] forState:UIControlStateNormal];
                } else {
                    [self.bt_nextSingle1 setTitle:[String bt_next] forState:UIControlStateNormal];
                    [self.bt_nextSingle2 setTitle:[String bt_next] forState:UIControlStateNormal];
                }
            } else {
                if ([_chk1 isEqualToString:_chk2]) {
                    [self.bt_done1_1 setTitle:[String bt_ok] forState:UIControlStateNormal];
                    [self.bt_done1_2 setTitle:[String bt_ok] forState:UIControlStateNormal];
                } else {
                    [self.bt_done1_1 setTitle:[String bt_next] forState:UIControlStateNormal];
                    [self.bt_done1_2 setTitle:[String bt_next] forState:UIControlStateNormal];
                }
            }
            isNoButton = NO;
        }
    }
    else if(isShowSub2){
        [self.bt_done1_1 setTitle:[String bt_ok] forState:UIControlStateNormal];
        [self.bt_done1_2 setTitle:[String bt_ok] forState:UIControlStateNormal];
        //2015-12-15 ueda ASTERISK
        if (YES) {
            //最後のカテゴリーは「決定」ボタン、それ以外は「次へ」ボタンにする
            NSMutableDictionary *_cate = categoryList[[categoryList count]-1];
            NSString * _chk1 = [_cate objectForKey:@"DispOrder"];
            NSString * _chk2 = [editSub2Category objectForKey:@"DispOrder"];
            
            if ([_chk1 isEqualToString:_chk2]) {
                [self.bt_done1_1 setTitle:[String bt_ok] forState:UIControlStateNormal];
                [self.bt_done1_2 setTitle:[String bt_ok] forState:UIControlStateNormal];
            } else {
                [self.bt_done1_1 setTitle:[String bt_next] forState:UIControlStateNormal];
                [self.bt_done1_2 setTitle:[String bt_next] forState:UIControlStateNormal];
            }
            isNoButton = NO;
        }
    }
    else if (isShowGroup1) {
        [self.bt_done1_1 setTitle:[String bt_top] forState:UIControlStateNormal];
        [self.bt_done1_2 setTitle:[String bt_top] forState:UIControlStateNormal];
        
        isNormal = YES;
    }
    else if (isShowGroup2) {
        [self.bt_done1_1 setTitle:[String bt_top] forState:UIControlStateNormal];
        [self.bt_done1_2 setTitle:[String bt_top] forState:UIControlStateNormal];
        
        isNormal = YES;
    }
    else{
        //2015-09-17 ueda
/*
        [self.bt_done1_1 setTitle:[String bt_confirm] forState:UIControlStateNormal];
        [self.bt_done1_2 setTitle:[String bt_confirm] forState:UIControlStateNormal];
 */
        //2015-09-17 ueda
        if (!([[System sharedInstance].useOrderConfirm isEqualToString:@"0"])) {
            //オーダー確認画面を表示する
            [self.bt_done1_1 setTitle:[String bt_confirm] forState:UIControlStateNormal];
            [self.bt_done1_2 setTitle:[String bt_confirm] forState:UIControlStateNormal];
        } else {
            if ([[System sharedInstance].orderType isEqualToString:@"1"]) {
                //オーダー種類を入力する
                [self.bt_done1_1 setTitle:[String bt_next] forState:UIControlStateNormal];
                [self.bt_done1_2 setTitle:[String bt_next] forState:UIControlStateNormal];
            } else {
                //オーダー送信
                [self.bt_done1_1 setTitle:[String bt_send] forState:UIControlStateNormal];
                [self.bt_done1_2 setTitle:[String bt_send] forState:UIControlStateNormal];
                UIImage *img = [UIImage imageNamed:@"ButtonSend.png"];
                [self.bt_done1_1 setBackgroundImage:img forState:UIControlStateNormal];
                //2016-02-03 ueda ASTERISK
                [self.bt_done1_1 setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                [self.bt_done1_2 setBackgroundImage:img forState:UIControlStateNormal];
            }
        }

        isNormal = YES;
    }

    
    //下部ボタンの表示/非表示を行う
    self.arrangeBottom.hidden = YES;
    self.normal1Bottom.hidden = YES;
    self.normal2Bottom.hidden = YES;
    self.single1Bottom.hidden = YES;
    self.single2Bottom.hidden = YES;
    
    if(isShowArrange){
        self.arrangeBottom.hidden = NO;
    }
    else if (isShowSub1) {
        NSMutableDictionary *pare = [self currentParentEditMenu];
        if ([pare[@"TrayStyle"]isEqualToString:@"1"]) {
            
            //表示／非表示設定
            if (self.type==TypeOrderAdd||self.type==TypeOrderOriginal) {
                
                if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
                    self.single2Bottom.hidden = NO;
                }
                else{
                    self.single1Bottom.hidden = NO;
                }
            }
            else{
                self.normal1Bottom.hidden = NO;
            }
        }
        else{
            self.normal1Bottom.hidden = NO;
        }
    }
    else if (isShowSub2) {
        self.normal1Bottom.hidden = NO;
    }
    else if (isShowGroup1) {

    }
    else if(isShowGroup2){

    }
    else{

    }
    
    
    //通常ページ、グループページの共通
    if (isNormal) {
        
        //ボタン設定
        [self.bt_return1_1 setTitle:[String bt_return] forState:UIControlStateNormal];
        [self.bt_return1_2 setTitle:[String bt_return] forState:UIControlStateNormal];
        
        
        if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
            [self.bt_arrange setTitle:[String Modify2] forState:UIControlStateNormal];
        }
        else if ([[System sharedInstance].kakucho1Type isEqualToString:@"2"]) {
            [self.bt_arrange setTitle:[String QTY] forState:UIControlStateNormal];
        }
        
        //表示／非表示設定
        if (self.type==TypeOrderAdd||self.type==TypeOrderOriginal) {
            if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
                self.normal2Bottom.hidden = NO;
            }
            else if ([[System sharedInstance].kakucho1Type isEqualToString:@"1"]) {
                self.normal1Bottom.hidden = NO;
            }
            else if ([[System sharedInstance].kakucho1Type isEqualToString:@"2"]) {
                self.normal2Bottom.hidden = NO;
            }
        }
        else{
            self.normal1Bottom.hidden = NO;
        }
    }
    
    
    //ページ番号入りのボタン表示の設定（シングルトレイ、アレンジ）
    if (isNoButton) {
        if (menuPage+1 == count) {
            [bt_next setTitle:[String bt_ok] forState:UIControlStateNormal];
        }
        else{
            NSString *str = [NSString stringWithFormat:@"[%zd]",menuPage+2];
            [bt_next setTitle:str forState:UIControlStateNormal];
        }
        
        if (menuPage==0) {
            [bt_prev setTitle:[String bt_return] forState:UIControlStateNormal];
        }
        else{
            NSString *str = [NSString stringWithFormat:@"[%zd]",menuPage];
            [bt_prev setTitle:str forState:UIControlStateNormal];
        }
    }
    
    
    //タイトルを更新する
    //2014-07-07 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
        NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        if (isShowSub1&&[pare[@"TrayStyle"]isEqualToString:@"1"]) {
             //2015-11-13 ueda ASTERISK_TEST
            self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
            //2014-11-17 ueda
/*
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  [%d]/%d",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,dat.TrayMenuPageNo+1,count];
            } else {
                //2014-09-22 ueda
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    //英語
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d [%d]/%d",[String Str_t],_no,dat.manCount,dat.womanCount,dat.TrayMenuPageNo+1,count];
                } else {
                    //日本語
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%d F%d [%d]/%d",[String Str_t],_no,dat.manCount,dat.womanCount,dat.TrayMenuPageNo+1,count];
                }
            }
 */
            //2014-11-18 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　[%zd]/%zd",[String Str_t],_no,dat.TrayMenuPageNo+1,count];
            } else {
                //2014-12-12 ueda
                if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                    //入力タイプＣ or 小人入力する
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  [%zd]/%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,dat.TrayMenuPageNo+1,count];
                } else {
                    //小人入力しない
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd  [%zd]/%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.TrayMenuPageNo+1,count];
                }
            }
        }
        else{
            //2014-11-17 ueda
/*
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount];
            } else {
                //2014-09-22 ueda
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    //英語
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d",[String Str_t],_no,dat.manCount,dat.womanCount];
                } else {
                    //日本語
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%d F%d",[String Str_t],_no,dat.manCount,dat.womanCount];
                }
            }
 */
            //2014-11-18 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                self.lb_title.text =  [NSString stringWithFormat:@"　%@%@",[String Str_t],_no];
            } else {
                //2014-12-12 ueda
                if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                    //入力タイプＣ or 小人入力する
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount];
                } else {
                    //小人入力しない
                    self.lb_title.text =  [NSString stringWithFormat:@"　%@%@　M%zd F%zd",[String Str_t],_no,dat.manCount,dat.womanCount];
                }
            }
        }
    }
    else{
        if (isShowSub1&&[pare[@"TrayStyle"]isEqualToString:@"1"]) {
            self.lb_title.text = [NSString stringWithFormat:[String Order_],dat.TrayMenuPageNo+1,count];
        }
        else{
            self.lb_title.text = [NSString stringWithFormat:@" %@",[String bt_order]];
        }
    }
}

- (IBAction)iba_hideArrangetable:(id)sender{
    [self hideArrangeTable];
}

- (IBAction)iba_showArrange:(id)sender{
    
    NSMutableDictionary *_menu = [self currentEditMenu];
    NSMutableDictionary *_pare = [self currentParentEditMenu];
    if (_menu) {
        
        LOG(@"%@",_menu);
        
        BOOL isKeppin = [orderManager keppinCheck:_menu[@"SyohinCD"]];
        if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
            if ((((!isShowSub1&&!isShowSub2&&!isShowArrange)&&
                  ![_menu[@"SG1FLG"] isEqualToString:@"1"]&&
                  ![_menu[@"BNGFLG"] isEqualToString:@"1"])||
                 [_menu[@"TrayStyle"]isEqualToString:@"1"]||
                 [_pare[@"TrayStyle"]isEqualToString:@"1"])&&
                [_menu[@"count"]intValue]>0){
                
                if (!isKeppin) {
                    if (isArrangeMenuEnable) {
                        [self showArrangeTable];
                    }
                }
            }
        }
        else if([[System sharedInstance].kakucho1Type isEqualToString:@"2"]){
            if ([_menu[@"JikaFLG"] isEqualToString:@"1"]) {
                [self performSegueWithIdentifier:@"ToJikaView" sender:@"0"];
            }
            else{
                [self performSegueWithIdentifier:@"ToJikaView" sender:@"1"];
            }
        }
    }
}

- (void)setConfirm{
    
    
    isShowConfirm = YES;
    [self reloadMenuList];
    [self.gmGridView reloadData];
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
    }
    return self;
}

//2014-11-20 ueda
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.categoryTable respondsToSelector:@selector(setLayoutMargins:)]) {
        self.categoryTable.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    LOG(@"Speed test 03");
    
    isShowSub1 = NO;
    isShowSub2 = NO;
    isShowGroup1 = NO;
    isShowGroup2 = NO;
    isShowArrange = NO;
    //2016-02-03 ueda ASTERISK
    self.lb_tpTitle.hidden = YES;
    isShowConfirm = NO;
    
    self.subView.hidden = YES;
    
    orderManager = [OrderManager sharedInstance];
    dat = [DataList sharedInstance];

    dat.menuPage = 0;
    dat.Sub1MenuPage = 0;
    dat.Sub2MenuPage = 0;
    dat.Folder1MenuPage = 0;
    dat.Folder2MenuPage = 0;
    dat.TrayMenuPageNo = 0;
    //dat.ArrangeMenuPageNoは数値判定のためClear時に9999を代入している
    currentPositon = 0;
    
    isArrangeMenuEnable = [orderManager checkArangeMenuIsExit];
    
    //2014-01-27 ueda
    //[self.categoryTable setBackgroundColor:[UIColor colorWithWhite:0.55f alpha:1.0]];
    [self.categoryTable setBackgroundColor:[UIColor colorWithWhite:0.75f alpha:1.0]];
    
    //Set GridView
    self.gmGridView.backgroundColor = [UIColor clearColor];
    self.gmGridView.actionDelegate = self;
    self.gmGridView.dataSource = self;
    self.gmGridView.style = GMGridViewStyleSwap;
    int spacing = 2;
    self.gmGridView.itemSpacing = spacing;
    self.gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.gmGridView.centerGrid = NO;
    self.gmGridView.pagingEnabled = YES;
    self.gmGridView.showsVerticalScrollIndicator = NO;
    self.gmGridView.showsHorizontalScrollIndicator = NO;
    self.gmGridView.clipsToBounds = YES;
    self.gmGridView.minimumPressDuration = 1.0f;
    //2014-10-29 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.gmGridView.showsVerticalScrollIndicator = YES;
        self.gmGridView.scrollEnabled = YES;
        self.gmGridView.pagingEnabled = NO;
        self.gmGridView.bounces = YES;
        self.gmGridView.alwaysBounceVertical = YES;
        
        //2015-04-03 ueda
/*
        self.bt_up1_1.enabled = NO;
        self.bt_down1_1.enabled = NO;
        self.bt_up1_1.hidden = YES;
        self.bt_down1_1.hidden = YES;

        self.bt_up1_2.enabled = NO;
        self.bt_down1_2.enabled = NO;
        self.bt_up1_2.hidden = YES;
        self.bt_down1_2.hidden = YES;
 */
    }
    
    self.subGridView.backgroundColor = [UIColor clearColor];
    self.subGridView.style = GMGridViewStyleSwap;
    self.subGridView.itemSpacing = spacing;
    self.subGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.subGridView.centerGrid = NO;
    self.subGridView.pagingEnabled = YES;
    self.subGridView.showsVerticalScrollIndicator = NO;
    self.subGridView.showsHorizontalScrollIndicator = NO;
    self.subGridView.clipsToBounds = YES;
    self.subGridView.minimumPressDuration = 1.0f;
    //2014-10-29 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.subGridView.showsVerticalScrollIndicator = YES;
        self.subGridView.scrollEnabled = YES;
        self.subGridView.pagingEnabled = NO;
        self.subGridView.bounces = YES;
        self.subGridView.alwaysBounceVertical = YES;
        
        //2015-04-03 ueda
/*
        self.bt_up1_3.enabled = NO;
        self.bt_down1_3.enabled = NO;
        self.bt_up1_3.hidden = YES;
        self.bt_down1_3.hidden = YES;
        
        self.bt_up1_4.enabled = NO;
        self.bt_down1_4.enabled = NO;
        self.bt_up1_4.hidden = YES;
        self.bt_down1_4.hidden = YES;
        
        self.bt_upArrange.enabled = NO;
        self.bt_downArrange.enabled = NO;
        self.bt_upArrange.hidden = YES;
        self.bt_downArrange.hidden = YES;
 */
    }
    
    [System adjustStatusBarSpace:self.view];
    
    //2014-08-07 ueda ここへ移動
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2015-12-17 ueda ASTERISK
    if (self.type == TypeOrderCancel) {
        //取消の場合は赤色
        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
    }
    
    //2014-08-07 ueda ここへ移動
    //2014-06-26 ueda
    if (![System is568h]) {
        self.topView.frame         = CGRectMake(2,    2,      236,  83 - 15);
        self.lb_dispName.frame     = CGRectMake(5,    7 - 8,  126,  70 );
        self.lb_dispCount.frame    = CGRectMake(100,  7 - 7,  126,  44 - 10);
        self.lb_dispJika.frame     = CGRectMake(106, 48 - 9,   83,  28);
        self.lb_dispCountSub.frame = CGRectMake(166, 48 - 9,   60,  28);
        self.subGridView.frame     = CGRectMake(0,   85 - 15, 240, 376 - 92);
    }
    
    if (self.type == TypeOrderCancel||self.type == TypeOrderDivide) {
        if (SYSTEM_VERSION_LESS_THAN(@"7")) {//iOS7以前
            [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
        }
        else{
            OrderConfirmViewController *controller2 = [[self storyboard] instantiateViewControllerWithIdentifier:@"OrderConfirmViewController"];
            controller2.delegate = self;
            controller2.type = self.type;
            [self.navigationController pushViewController:controller2 animated:YES];
        }
    }
    //コード注文の場合は、エントリー画面を表示する
    else if([[System sharedInstance].codeType isEqualToString:@"1"]&&
            (self.type==TypeOrderOriginal||self.type==TypeOrderAdd)){
        //2014-08-07 ueda
        [self reloadBottomControl];
        [self performSegueWithIdentifier:@"ToEntryView" sender:nil];
        return;
    }
    
    //2014-10-01 ueda ボタン動作がワンテンポ遅いので以前の方式に戻す（0.3秒後にシングルタップが確定するから！？）
/*
    //2014-09-19 ueda
    isDispTray = NO;
    //2014-09-16 ueda
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
 */
    //2015-11-13 ueda ASTERISK_TEST
    if (YES) {
        self.categoryTable.showsVerticalScrollIndicator = YES;
        self.categoryTable.scrollEnabled = YES;
        self.categoryTable.pagingEnabled = NO;
        self.categoryTable.bounces = YES;
        self.categoryTable.alwaysBounceVertical = YES;
    }
    //2015-11-18 ueda ASTERISK_TEST
    categoryCount = [[System sharedInstance].categoryCount integerValue];
    if (categoryCount >= 7 && categoryCount <= 10) {
    } else {
        categoryCount = 10;
    }
    //2015-12-08 ueda ASTERISK
    //ステータスバータッチで先頭にスクロールするのはオーダー商品
    //http://blog.kishikawakatsumi.com/entry/20100812/1281625745
    self.categoryTable.scrollsToTop = NO;
    
    //2016-02-02 ueda ASTERISK
    if (YES) {
        self.bt_down1_1.hidden = YES;   //＜
        self.bt_down1_2.hidden = YES;
        self.bt_down1_3.hidden = YES;
        self.bt_down1_4.hidden = YES;
        self.bt_downArrange.hidden = YES;
        
        self.bt_up1_1.hidden = YES;     //＞
        self.bt_up1_2.hidden = YES;
        self.bt_up1_3.hidden = YES;
        self.bt_up1_4.hidden = YES;
        self.bt_upArrange.hidden = YES;
        
        self.bt_up1_2.frame = self.bt_down1_1.frame;
        self.bt_arrange.frame = self.bt_up1_1.frame;
        self.bt_return1_2.frame = self.bt_return1_1.frame;
        self.bt_done1_2.frame = self.bt_done1_1.frame;
        [self.bt_up1_2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_arrange.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_return1_2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_done1_2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        
        self.bt_upArrange.frame = self.bt_down1_1.frame;
        self.bt_done2.frame = self.bt_up1_1.frame;
        self.bt_prevArrange.frame = self.bt_return1_1.frame;
        self.bt_nextArrange.frame = self.bt_done1_1.frame;
        [self.bt_upArrange.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_done2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_prevArrange.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_nextArrange.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        
        self.bt_up1_4.frame = self.bt_down1_1.frame;
        self.bt_done3.frame = self.bt_up1_1.frame;
        self.bt_prevSingle2.frame = self.bt_return1_1.frame;
        self.bt_nextSingle2.frame = self.bt_done1_1.frame;
        [self.bt_up1_4.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_done3.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_prevSingle2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
        [self.bt_nextSingle2.titleLabel setFont:self.bt_done1_1.titleLabel.font];
    }
    
    //2016-02-03 ueda ASTERISK
    self.lb_tpTitle.hidden = YES;
}

//2014-10-01 ueda ボタン動作がワンテンポ遅いので以前の方式に戻す
/*
//2014-09-17 ueda
- (void)handleDoubleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        if (isShowArrange) {
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                CGPoint tapPoint = [sender locationInView:sender.view];
                BOOL wDoFlag = NO;
                //一番上の商品欄の場合 YES
                if ([System is568h]) {
                    if (CGRectContainsPoint(CGRectMake(80,50,120,80),tapPoint)) {
                        wDoFlag = YES;
                    }
                } else {
                    if (CGRectContainsPoint(CGRectMake(80,50,120,60),tapPoint)) {
                        wDoFlag = YES;
                    }
                }
                if (wDoFlag) {
                    UIAlertView *message = [[UIAlertView alloc] initWithTitle:[String Enter_a_Arrange]
                                                                      message:nil
                                                                     delegate:self
                                                            cancelButtonTitle:nil
                                                            otherButtonTitles:[String bt_ok],[String bt_cancel], nil];
                    [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
                    message.tag = 103;
                    [message show];
                }
            }
        }
        //2014-09-19 ueda
        if(isShowSub1){
            NSMutableDictionary *parentMenu = [self currentParentEditMenu];
            if ([parentMenu[@"TrayStyle"]isEqualToString:@"1"]) {
                CGPoint tapPoint = [sender locationInView:sender.view];
                BOOL wDoFlag = NO;
                //一番上の商品欄の場合 YES
                if ([System is568h]) {
                    if (CGRectContainsPoint(CGRectMake(80,50,120,80),tapPoint)) {
                        wDoFlag = YES;
                    }
                } else {
                    if (CGRectContainsPoint(CGRectMake(80,50,120,60),tapPoint)) {
                        wDoFlag = YES;
                    }
                }

                if ((wDoFlag) && (!(isDispTray))) {
                    isDispTray = YES;
                    //Alert(@"tray", @"");
                    popView = [[self storyboard] instantiateViewControllerWithIdentifier:@"PopViewController"];
                    [self.view addSubview:popView.view];
                    
                    int trayTotal = [orderManager getTrayTotal:parentMenu[@"SyohinCD"]];
                    popView.lb_label.text = [NSString stringWithFormat:@"  %@ [%d->?]",[String Tray],trayTotal];
                    popView.lb_title.text = [NSString stringWithFormat:@"%@%@%@",parentMenu[@"HTDispNMU"],parentMenu[@"HTDispNMM"],parentMenu[@"HTDispNML"]];
                    popView.lb_count.text = [NSString stringWithFormat:@"%d",trayTotal];
                    [popView.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
                    [popView.bt_done setTitle:[String bt_done] forState:UIControlStateNormal];
                    
                    [popView.bt_return addTarget:self action:@selector(hidePopView) forControlEvents:UIControlEventTouchUpInside];
                    [popView.bt_done addTarget:self action:@selector(donePopView) forControlEvents:UIControlEventTouchUpInside];
                    [popView.bt_countUp addTarget:self action:@selector(countUpTray) forControlEvents:UIControlEventTouchUpInside];
                    [popView.bt_countDown addTarget:self action:@selector(countDownTray) forControlEvents:UIControlEventTouchUpInside];
                }
            }
        }
    }
}
*/

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

//2015-04-08 ueda
/*
    LOG(@"Speed test 04");
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 */
    
    //2015-04-16 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.type != appDelegate.type) {
        //取消後に追加の入力を行う場合
        //2015-12-17 ueda ASTERISK
        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
        //2015-06-30
        if ((self.type == TypeOrderCancel) && (appDelegate.type == TypeOrderAdd)) {
            self.type = appDelegate.type;
            //2015-04-27 ueda
            menuList = [[NSArray alloc] init];
            //2015-08-24 ueda
            isShowSub1 = NO;
            isShowSub2 = NO;
            isShowGroup1 = NO;
            isShowGroup2 = NO;
            isShowArrange = NO;
            //2016-02-03 ueda ASTERISK
            self.lb_tpTitle.hidden = YES;
            isShowConfirm = NO;
        }
    }
    
    LOG(@"Speed test 05");

    if (!menuList||menuList.count==0) {
        //データセット
        [self reloadCategoryList];
        [self setCategory:nil];
        [self reloadBottomControl];
    }
    //2014-09-05 ueda
    //AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.typeCorderResetFg) {
        //入力タイプＣのオーダー追加の場合
        appDelegate.typeCorderResetFg = NO;
        if (appDelegate.type == TypeOrderCancel) {
            //取消の場合
        } else {
            [self reloadCategoryList];
            [self setCategory:nil];
            [self reloadBottomControl];
            //2014-11-06 ueda
            NSMutableDictionary *_cate;
            int index = [[System sharedInstance].currentCategory intValue];
            //2015-12-14 ueda ASTERISK
            if (index > 0 && index < 20) {
                _cate = categoryList[index];
            } else {
                _cate = categoryList[0];
            }
            [self setCategory:_cate];
        }
    }
    //2014-09-10 ueda
    //2014-09-25 ueda
    if (appDelegate.typeCeditModeFirstFg) {
        //修正時の最初の表示の時（確認画面から戻るのではない）
        appDelegate.typeCeditModeFirstFg = NO;
        NSMutableDictionary *editSyohin = [DataList sharedInstance].typeCeditSyohin;
        NSString *SyohinCd = editSyohin[@"SyohinCD"];
        //2014-09-25 ueda
/*
        NSString *cateCd = [orderManager getCategoryCode:SyohinCd];
        NSMutableDictionary *_cate = [orderManager getCategory:cateCd];
        [self setCategory:_cate];
        if ([[menuList valueForKeyPath:@"SyohinCD"] containsObject:SyohinCd]) {
            int index = 0;
            index = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:SyohinCd];
            dat.menuPage = index/kMenuCount;
            [self.gmGridView reloadData];
        }
 */
        NSMutableArray *orderList =[[NSMutableArray alloc]init];
        //2015-02-16 ueda
        orderList = [orderManager getOrderListForConfirm:NO
                                              isSubGroup:YES
                                               isArrange:YES
                                             typeOrderNo:self.type];
        NSMutableDictionary *_dic;
        for (int ct = 0; ct < [orderList count]; ct++) {
            NSMutableDictionary *tmpMenu = orderList[ct];
            if ([tmpMenu[@"SyohinCD"] isEqualToString:SyohinCd]) {
                _dic = tmpMenu;
                break;
            }
        }
        BOOL isSingleTray = NO;
        BOOL isHaveSubMenu = NO;
        BOOL isSub1Menu = NO;
        BOOL isSub2Menu = NO;
        BOOL isJikaMenu = NO;
        BOOL isGroupMenu = NO;
        BOOL isArrangeMenu = NO;
        BOOL isDirectionSubMenu = NO;
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
        if (isHaveSubMenu||isSub1Menu||isSub2Menu||isGroupMenu) {
            //iba_returnAndDispLoadSub1Menu:
            NSMutableDictionary *_menu = _dic;
            NSMutableDictionary *_subMenu = nil;
            if([[_menu allKeys] containsObject:@"TopSyohinCD"]){
                for (int ct = 0; ct < [orderList count]; ct++) {
                    NSMutableDictionary *_temp = [orderList objectAtIndex:ct];
                    if ([_temp[@"MstSyohinCD"]isEqualToString:_menu[@"TopSyohinCD"]]) {
                        _subMenu = _menu;
                        _menu = _temp;
                    }
                }
                
                if([_menu[@"B1CateCD"] length]>0||[_menu[@"B2CateCD"] length]>0){
                    [self setDispGroupMenu:_menu
                                       sub:_subMenu];
                }
                else{
                    [self setDispSub1Menu:_menu
                                      sub:_subMenu];
                }
            }
            else if([_menu[@"B1CateCD"] length]>0||[_menu[@"B2CateCD"] length]>0){
                [self setDispGroupMenu:_menu
                                   sub:_menu];
            }
            else if([_menu[@"SG1FLG"] isEqualToString:@"1"]){
                [self setDispSub1Menu:_menu
                                  sub:nil];
            }
        }
        else{
            //iba_returnAndDispLoadMenu:
            [self setDispMenu:_dic];
        }
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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
    [self setCategoryTable:nil];;
    [self setBt_down1_1:nil];
    [self setBt_down1_2:nil];
    [self setBt_up1_1:nil];
    [self setBt_up1_2:nil];
    [self setBt_done1_1:nil];
    [self setBt_done1_2:nil];
    [self setGmGridView:nil];
    [self setSubView:nil];
    [self setSubGridView:nil];
    [self setLb_dispName:nil];
    [self setLb_dispCount:nil];
    [self setTopView:nil];
    [self setLb_dispCountSub:nil];
    [self setBt_prevArrange:nil];
    [self setBt_nextArrange:nil];
    [self setArrangeBottom:nil];
    [self setBt_downArrange:nil];
    [self setBt_upArrange:nil];
    [self setBt_done2:nil];
    [self setBt_return1_1:nil];
    [self setBt_return1_2:nil];
    [self setNormal1Bottom:nil];
    [self setNormal2Bottom:nil];
    [self setBt_arrange:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    LOG(@"%@",[segue identifier]);
    
    if([[segue identifier]isEqualToString:@"ToOrderConfirmView"]){
        OrderConfirmViewController *view_ = (OrderConfirmViewController *)[segue destinationViewController];
        view_.delegate = self;
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToJikaView"]){
        CountJikaViewController *view_ = (CountJikaViewController *)[segue destinationViewController];
        view_.delegate = self;
        view_.editMenu = [self currentEditMenu];
        
        if (![[view_.editMenu allKeys]containsObject:@"Jika"]) {
            view_.editMenu[@"Jika"] = view_.editMenu[@"Tanka"];
        }
        
        view_.typeCount = [(NSString*)sender intValue];
    }
    else if([[segue identifier]isEqualToString:@"ToEntryView"]){
        EntryViewController *view_ = (EntryViewController *)[segue destinationViewController];
        view_.delegate = self;
        view_.entryType = EntryTypeOrder;
        isShowConfirm = NO;
    }
    else if([[segue identifier]isEqualToString:@"ToCountView"]){
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        
        //人数入力可否の判定
        if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
            view_.entryType = EntryTypeTableOnly;
        }
        else{
            view_.entryType = EntryTypeTableAndNinzu;
        }
    }
    else if([[segue identifier]isEqualToString:@"ToImageView"]){
        ImageViewController *view_ = (ImageViewController *)[segue destinationViewController];
        view_.image = (UIImage*)sender;
    }
}


- (NSMutableDictionary*)currentEditMenu{
    if(isShowArrange){
        return editArrangeMenu;
    }
    else if (isShowSub1) {
        return editSub1Menu;
    }
    else if (isShowSub2) {
        return editSub2Menu;
    }
    else if (isShowGroup1) {
        return editFolder1Menu;
    }
    else if(isShowGroup2){
        return editFolder2Menu;
    }
    else{
        return editMenu;
    }
    return nil;
}

- (void)currentEditMenuClear{
    
    if(isShowArrange){
        editArrangeMenu = nil;
    }
    else if (isShowSub1) {
        editSub1Menu = nil;
    }
    else if (isShowSub2) {
        editSub2Menu = nil;
    }
    else if (isShowGroup1) {
        editFolder1Menu = nil;
    }
    else if(isShowGroup2){
        editFolder2Menu = nil;
    }
    else{
        editMenu = nil;
    }
}

- (NSMutableDictionary*)currentParentEditMenu{
    NSMutableDictionary *_pare = nil;
    if (isShowArrange) {
        LOG(@"isShowArrange");
        if (isShowSub1) {
            LOG(@"editSub1Menu");
            _pare = editSub1Menu;
        }
        else if (isShowSub2) {
            LOG(@"editSub2Menu");
            _pare = editSub2Menu;
        }
        else if (isShowGroup1) {
            LOG(@"editFolder1Menu");
            _pare = editFolder1Menu;
        }
        else if (isShowGroup2) {
            LOG(@"editFolder2Menu");
            _pare = editFolder2Menu;
        }
        else{
            LOG(@"editMenu");
            _pare = editMenu;
        }
    }
    else if (isShowSub1) {
        LOG(@"isShowSub1");
        if (isShowGroup1) {
            LOG(@"isShowGroup1");
            _pare = editFolder1Menu;
        }
        else if (isShowGroup2) {
            LOG(@"isShowGroup2");
            _pare = editFolder2Menu;
        }
        else{
            LOG(@"editMenu");
            _pare = editMenu;
        }
    }
    else if (isShowSub2) {
        _pare = editSub1Menu;
    }
    LOG(@"_pare:%@",_pare);
    return _pare;
}

- (NSMutableDictionary*)currentEditCategory{
    if(isShowArrange){
        return editArrangeCategory;
    }
    else if (isShowSub1) {
        return editSub1Category;
    }
    else if (isShowSub2) {
        return editSub2Category;
    }
    else if (isShowGroup1) {
        return editFolder1Category;
    }
    else if(isShowGroup2){
        return editFolder2Category;
    }
    else{
        return editCategory;
    }
    return nil;
}

//////////////////////////////////////////////////////////////
#pragma mark self.gmGridViewDataSource
//////////////////////////////////////////////////////////////

- (void)reloadMenuList{
    
    if (isShowArrange) {
        
        LOG(@"isShowArrange");
        
            if (!editArrangeCategory) {
                if (categoryList.count>0) {
                    LOG(@"isShowArrange_2_1");
                    editArrangeCategory = [NSMutableDictionary dictionaryWithDictionary:categoryList[0]];
                }
            }
    
            if (editArrangeCategory) {
                LOG(@"isShowArrange_2_2:%@\n:%@",editMenu,editArrangeCategory);
                if (isShowSub1) {
                    //NSMutableDictionary *_pare = [self currentParentEditMenu];
                    editArrangeCategory[@"Sub1SyohinCD"] = editSub1Menu[@"SyohinCD"];
                    editArrangeCategory[@"TopSyohinCD"] = editSub1Menu[@"TopSyohinCD"];
                }
                else if (isShowGroup1) {
                    editArrangeCategory[@"TopSyohinCD"] = editFolder1Menu[@"SyohinCD"];
                }
                else if (isShowGroup2) {
                    editArrangeCategory[@"TopSyohinCD"] = editFolder2Menu[@"SyohinCD"];
                }
                else{
                    editArrangeCategory[@"TopSyohinCD"] = editMenu[@"SyohinCD"];
                }
                menuList = [orderManager getMenuList:editArrangeCategory];
            }
       // }
    }
    else if (isShowSub1) {
        LOG(@"isShowSub1:%@",editSub1Category);
        menuList = [orderManager getSubMenuList:editSub1Category];
        LOG(@"isShowSub1:%@",menuList);
    }
    else if (isShowSub2) {
        LOG(@"isShowSub2");
        menuList = [orderManager getSubMenuList:editSub2Category];
    }
    else if (isShowGroup1) {
        
        LOG(@"isShowGroup1:%@",editFolder1Category);
        NSInteger index = 0;
        index = [[categoryList valueForKeyPath:@"MstSyohinCD"] indexOfObject:editFolder1Category[@"MstSyohinCD"]];
        if (index == NSNotFound) {//アレンジメニューから復帰の場合
            //index = tempCategoryIndex;
            categoryList = tempCategoryArray;
        }
        else{
            tempCategoryIndex = index;
            tempCategoryArray = categoryList;
        }
        
        index = [[categoryList valueForKeyPath:@"MstSyohinCD"] indexOfObject:editFolder1Category[@"MstSyohinCD"]];
        //2015-12-04 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            //iOSスクロールした場合にページ番号をセット
            menuList = [orderManager getFolderMenuList:editFolder1Category[@"CateCD"]
                                                index1:[NSString stringWithFormat:@"%zd",index]
                                                index2:nil
                                                 layer:1
                                                 page1:saveMenuPage+1
                                                 page2:0];
        } else {
            menuList = [orderManager getFolderMenuList:editFolder1Category[@"CateCD"]
                                                index1:[NSString stringWithFormat:@"%zd",index]
                                                index2:nil
                                                 layer:1
                                                 page1:dat.menuPage+1
                                                 page2:0];
        }
    }
    else if (isShowGroup2) {
        
        LOG(@"isShowGroup2:%@",editFolder2Menu);
        NSInteger index = 0;
        index = [[categoryList valueForKeyPath:@"MstSyohinCD"] indexOfObject:editFolder2Category[@"MstSyohinCD"]];
        if (index == NSNotFound) {//アレンジメニューから復帰の場合
            index = tempCategoryIndex;
            categoryList = tempCategoryArray;
        }
        else{
            tempCategoryIndex = index;
            tempCategoryArray = categoryList;
        }
        
        menuList = [orderManager getFolderMenuList:editFolder2Category[@"CateCD"]
                                             index1:editFolder2Category[@"B1CateCD"]
                                            index2:[NSString stringWithFormat:@"%zd",index]
                                             layer:2
                                              page1:dat.menuPage+1
                                             page2:dat.Folder1MenuPage+1];
    }
    else{
        LOG(@"isTop");
        if (editMenu) {
            menuList = [orderManager getMenuList:editMenu];
        }
        else if (editCategory) {
            menuList = [orderManager getMenuList:editCategory];
        }
        else{
            if (categoryList.count>0) {
                menuList = [orderManager getMenuList:categoryList[0]];
            }
        }
    }
}


- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    
    
    NSInteger count = 0;
    BOOL enableUp = NO;
    BOOL enableDown = NO;
    
    if (isShowArrange) {
        
        LOG(@"isShowArrange");
        
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kSubMenuCount,MAX(0, [menuList count]-kSubMenuCount*dat.ArrangeMenuPage));
            if (kSubMenuCount*dat.ArrangeMenuPage>[menuList count]) {
                count=0;
            }
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kSubMenuCount;
            }
            
            if (dat.ArrangeMenuPage<maxPage)
                enableUp = YES;
            if (0<dat.ArrangeMenuPage)
                enableDown = YES;
        }
    }
    else if (isShowSub1) {
        
        LOG(@"isShowSub1");

        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kSubMenuCount, MAX(0, [menuList count]-kSubMenuCount*dat.Sub1MenuPage));
            if (kSubMenuCount*dat.Sub1MenuPage>[menuList count]) {
                count=0;
            }
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kSubMenuCount;
            }
            
            if (dat.Sub1MenuPage<maxPage)
                enableUp = YES;
            if (0<dat.Sub1MenuPage)
                enableDown = YES;
        }
    }
    else if (isShowSub2) {
        
        LOG(@"isShowSub2");

        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kSubMenuCount,MAX(0, [menuList count]-kSubMenuCount*dat.Sub2MenuPage));
            if (kSubMenuCount*dat.Sub2MenuPage>[menuList count]) {
                count=0;
            }
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kSubMenuCount;
            }
            
            if (dat.Sub2MenuPage<maxPage)
                enableUp = YES;
            if (0<dat.Sub2MenuPage)
                enableDown = YES;
        }
    }
    else if (isShowGroup1) {
        
        LOG(@"isShowGroup1");
        
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kMenuCount,MAX(0, [menuList count]-kMenuCount*dat.Folder1MenuPage));
            if (kMenuCount*dat.Folder1MenuPage>[menuList count]) {
                count=0;
            }
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kMenuCount;
            }
            
            if (dat.Folder1MenuPage<maxPage)
                enableUp = YES;
            if (0<dat.Folder1MenuPage)
                enableDown = YES;
        }
    }
    else if (isShowGroup2) {
        
        LOG(@"isShowGroup2");
        
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kMenuCount,MAX(0, [menuList count]-kMenuCount*dat.Folder2MenuPage));
            if (kMenuCount*dat.Folder2MenuPage>[menuList count]) {
                count=0;
            }
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kMenuCount;
            }
            
            if (dat.Folder2MenuPage<maxPage)
                enableUp = YES;
            if (0<dat.Folder2MenuPage)
                enableDown = YES;
        }
    }
    else{
        
        LOG(@"isTop");
        
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            count = [menuList count];
        } else {
            count = MIN(kMenuCount,MAX(0, [menuList count]-kMenuCount*dat.menuPage));
            if (kMenuCount*dat.menuPage>[menuList count]) {
                count=0;
            }
            
            NSInteger maxPage = 0;
            if ([menuList count]>0) {
                maxPage = MAX(([menuList count]-1), 0)/kMenuCount;
            }
            
            LOG(@"1:%zd:%zd",dat.menuPage,maxPage);
            
            if (dat.menuPage<maxPage)
                enableUp = YES;
            if (0<dat.menuPage)
                enableDown = YES;
        }
    }

    //2015-04-03 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        enableUp = YES;
        enableDown = YES;
    }

    //2016-01-15 ueda ASTERISK
    //アスタリスク版はスクロールありの前提
/*
    if (enableUp) {
        self.bt_up1_1.enabled = YES;
        self.bt_up1_2.enabled = YES;
        self.bt_upArrange.enabled = YES;
        //2014-01-28 ueda
        self.bt_up1_3.enabled = YES;
        self.bt_up1_4.enabled = YES;
    }
    else{
        self.bt_up1_1.enabled = NO;
        self.bt_up1_2.enabled = NO;
        self.bt_upArrange.enabled = NO;
        //2014-01-28 ueda
        self.bt_up1_3.enabled = NO;
        self.bt_up1_4.enabled = NO;
    }
    
    
    if (enableDown) {
        self.bt_down1_1.enabled = YES;
        self.bt_down1_2.enabled = YES;
        self.bt_downArrange.enabled = YES;
        //2014-01-28 ueda
        self.bt_down1_3.enabled = YES;
        self.bt_down1_4.enabled = YES;
    }
    else{
        self.bt_down1_1.enabled = NO;
        self.bt_down1_2.enabled = NO;
        self.bt_downArrange.enabled = NO;
        //2014-01-28 ueda
        self.bt_down1_3.enabled = NO;
        self.bt_down1_4.enabled = NO;
    }
 */

    LOG(@"count=%zd total=%zd",count,[menuList count]);
    
    return count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //return CGSizeMake(117, 86);
    int height = 0;
    if (isShowSub1||isShowSub2||isShowArrange) {
        height = (gridView.bounds.size.height-kSubMenuCount-1)/(kSubMenuCount/2);
    }
    else{
        height = (gridView.bounds.size.height-kMenuCount-1)/(kMenuCount/2);
    }
    return CGSizeMake(117, height);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    LOG(@"Creating view indx %zd", index);
    
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        //cell.deleteButtonIcon = [UIImage imageNamed:@"close_x.png"];
        //cell.deleteButtonOffset = CGPointMake(-15, -15);
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [view setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:forceRectForOrderEntry(view.bounds)]]];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2;
        //2016-02-03 ueda ASTERISK
        if (YES) {
            //商品名と数量の間に線を引く
            CALayer *border = [CALayer layer];
            border.frame = CGRectMake((77.0f)
                                      , 0.0f
                                      , 1.0f
                                      , size.height);
            border.backgroundColor = [UIColor  lightGrayColor].CGColor;
            [view.layer addSublayer:border];
        }
        //2016-02-08 ueda ASTERISK
        if (YES) {
            //数量の下に横線を引く
            CALayer *border = [CALayer layer];
            border.frame = CGRectMake((77.0f)
                                      , size.height*2/3-2
                                      , size.width-77
                                      , 1.0f);
            border.backgroundColor = [UIColor  lightGrayColor].CGColor;
            [view.layer addSublayer:border];
        }
        cell.contentView = view;
    }
    
    cell.tag = index;
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    
    //表示するメニューを取得
    NSMutableDictionary *_menu;
    NSMutableDictionary *_editDic = [self currentEditMenu];
    NSInteger indexTotal = 0;
    if (isShowArrange) {
        indexTotal = index+dat.ArrangeMenuPage*kSubMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
    else if (isShowSub1) {
        indexTotal = index+dat.Sub1MenuPage*kSubMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
    else if (isShowSub2) {
        indexTotal = index+dat.Sub2MenuPage*kSubMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
    else if (isShowGroup1) {
        indexTotal = index+dat.Folder1MenuPage*kMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
    else if (isShowGroup2) {
        indexTotal = index+dat.Folder2MenuPage*kMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
    else{
        indexTotal = index+dat.menuPage*kMenuCount;
        _menu = [menuList objectAtIndex:indexTotal];
    }
   

    //2014-06-23 ueda
    /*
    //背景画像の設定
    UIImage *image = [self imageWithSyohinCD:_menu[@"SyohinCD"]];
    UIImageView *imageView = nil;
    if (image) {
        LOG(@"image check:%d",index);
        imageView = [[UIImageView alloc]initWithFrame:cell.contentView.bounds];
        imageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        imageView.clipsToBounds = YES;
        imageView.image = image;
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.backgroundColor = [UIColor clearColor];
        //2014-02-04 ueda
        imageView.alpha = 0.7f;
        [cell.contentView addSubview:imageView];
        LOG(@"image check:%@",imageView);
    }
     */
    //menuImage = [self imageWithSyohinCD:_menu[@"SyohinCD"]];
    
    //表示色を変更する
    //編集中はブルーにする
    if ([_editDic[@"SyohinCD"] isEqualToString:_menu[@"SyohinCD"]]) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
        if (!isShowArrange) {
            self.topView.backgroundColor = [UIColor whiteColor];
            //2014-07-11 ueda
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.topView.bounds]]];
        }
        else{
            self.topView.backgroundColor = ARRANGERED;
            //2014-07-11 ueda
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:ARRANGERED bounds:self.topView.bounds]]];
        }
        _menu = _editDic;
        
        currentPositon = index;
    }
    else if (([_menu[@"SG1FLG"] isEqualToString:@"1"]&&!isShowSub1&&!isShowSub2)
        ||([_menu[@"SG2FLG"] isEqualToString:@"1"]&&isShowSub1)
        ||[_menu[@"JikaFLG"] isEqualToString:@"1"]) {
        if (!isShowArrange) {//アレンジ商品に時価がある場合は通常色（白）
            cell.contentView.backgroundColor = [UIColor yellowColor];
            self.topView.backgroundColor = [UIColor whiteColor];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor yellowColor] bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.topView.bounds]]];
        }
        else{
            cell.contentView.backgroundColor = [UIColor whiteColor];
            self.topView.backgroundColor = ARRANGERED;
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:ARRANGERED bounds:self.topView.bounds]]];
        }
    }
    else if ([_editDic[@"CD"] isEqualToString:_menu[@"CD"]]) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
        if (!isShowArrange) {
            self.topView.backgroundColor = [UIColor whiteColor];
            //2014-07-11 ueda
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.topView.bounds]]];
        }
        else{
            self.topView.backgroundColor = ARRANGERED;
            //2014-07-11 ueda
            [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:ARRANGERED bounds:self.topView.bounds]]];
        }
        _menu = _editDic;
    }
    else if ([_menu[@"BNGFLG"] isEqualToString:@"1"]) {
        cell.contentView.backgroundColor = BLUE_BNG;
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE_BNG bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
    }
    
    //提供時期の並び替え対応
    if ([_menu[@"MstSyohinCD"]isEqualToString:@"0"]) {
        cell.contentView.backgroundColor = [UIColor clearColor];
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
        return cell;
    }
    
    //欠品チェック
    BOOL isKeppin = [orderManager keppinCheck:_menu[@"SyohinCD"]];
    //商品の無いフォルダ商品
    if ([_menu[@"BFLG"] isEqualToString:@"1"]&&[_menu[@"BNGFLG"] isEqualToString:@"0"]) {
        isKeppin = YES;
    }
    if (isKeppin) {
        cell.contentView.backgroundColor = [UIColor grayColor];
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor grayColor] bounds:forceRectForOrderEntry(cell.contentView.bounds)]]];
    }
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, size.width/4*3-2, size.height)];
    //2014-06-23 ueda
    /*
    //2014-02-04 ueda
    if (image) {
        //画像を表示した場合は品名を表示しない
        label.text = @"";
    } else {
        label.text = [NSString stringWithFormat:@"%@\n%@\n%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
    }
     */
    label.text = [NSString stringWithFormat:@"%@\n%@\n%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
    
    
    label.textAlignment = NSTextAlignmentLeft;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:label];
    

    //2014-03-03 ueda
    UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/4*3-15, 0, size.width/4+10, size.height/3*2)];
    label2.textAlignment = NSTextAlignmentRight;
    label2.backgroundColor = [UIColor clearColor];
    label2.font = [UIFont boldSystemFontOfSize:25];
    [cell.contentView addSubview:label2];
    
    
    //2016-03-31 ueda
/*
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/4*3, size.height/3*1.8, size.width/4*1-5, size.height/3)];
 */
    //2016-03-31 ueda
    UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/4*3-5, size.height/3*1.8, size.width/4*1, size.height/3)];
    label3.textAlignment = NSTextAlignmentRight;
    label3.backgroundColor = [UIColor clearColor];
    label3.font = [UIFont systemFontOfSize:17];
    //2016-03-31 ueda
    if (YES) {
        label3.adjustsFontSizeToFitWidth = YES;
        label3.minimumScaleFactor = 0.5f;
    }
    [cell.contentView addSubview:label3];
    
    
    //インフォメーションマーク
    //2014-06-23 ueda
    BOOL wImageFg = NO;
    UIImage *wImage = [self imageWithSyohinCD:_menu[@"SyohinCD"]];
    if (wImage) {
        wImageFg = YES;
    }
    if (([_menu[@"InfoFLG"] isEqualToString:@"1"]) || (wImageFg)) {
        //2014-03-06 ueda
        //UILabel *label4 = [[UILabel alloc] initWithFrame:CGRectMake(size.width/4*3-15, size.height/3*1.8, size.width/4*1-5, size.height/3)];
        CGRect rect;
        if ([System is568h]) {
            rect = CGRectMake(size.width/4*3-10, size.height/3*1.8+3, 22, 22);
        } else {
            rect = CGRectMake(size.width/4*3-10, size.height/3*1.8  , 22, 22);
        }
        //2014-07-17 ueda
        /*
        UILabel *label4 = [[UILabel alloc] initWithFrame:rect];
        label4.textAlignment = NSTextAlignmentLeft;
        label4.backgroundColor = [UIColor clearColor];
        label4.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:label4];
        label4.text = @"i";
        //2014-02-17 ueda
        label4.textAlignment = NSTextAlignmentCenter;
        label4.font = [UIFont systemFontOfSize:19];
        //2014-03-06 ueda
        label4.text = @"";
        label4.backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"InfoMark.png"]];
         */
        UIImage *image = [UIImage imageNamed:@"InfoMark.png"];
        UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
        imageView.frame = rect;
        imageView.layer.shadowOpacity = 0.8;
        imageView.layer.shadowOffset = CGSizeMake(1, 1);
        [cell.contentView addSubview:imageView];
    }
    
    
    if (self.type==TypeOrderCancel||self.type==TypeOrderDivide) {
        NSArray *divide = [_menu[@"countDivide"] componentsSeparatedByString:@","];
        LOG(@"divide:%@",divide);
        LOG(@"divide:%@",_menu[@"HTDispNMM"]);
        
        if (divide.count>dat.dividePage) {
            if ([divide[dat.dividePage] isEqualToString:@"0"]) {
                label2.text = @"";
            }
            else{
                label2.text = divide[dat.dividePage];
            }
        }
        else{
            label2.text = @"";
        }
        
        //2016-03-17 ueda
/*
         int count3 = [_menu[@"count"]intValue]-[self countFromArray:divide];
 */
        //2016-03-17 ueda
        int count3;
        if (self.type==TypeOrderCancel) {
            //取消
            count3 = [_menu[@"count"]intValue];
        } else {
            //分割
            count3 = [_menu[@"count"]intValue]-[self countFromArray:divide];
        }
        if (count3==0&&label2.text.length==0) {
            label3.text = @"";
        }
        else{
            label3.text = [NSString stringWithFormat:@"%d",count3];
        }
    }
    else{
        if ([_menu[@"count"] isEqualToString:@"0"]) {
            label2.text = @"";
        }
        else{
            NSInteger count = 0;
            //Note:シングルトレイ
            //count = [_menu[@"count"] intValue];
            
            if ([_menu[@"TrayStyle"]isEqualToString:@"1"]) {
                count = [orderManager getTrayTotal:_menu[@"SyohinCD"]];
            }
            else{
                count = [_menu[@"count"] intValue];
            }
            label2.text = [NSString stringWithFormat:@"%zd",count];
        }
        
        NSMutableDictionary *_pare = [self currentParentEditMenu];
        
        if (((!isShowSub1&&!isShowSub2&&!isShowArrange)&&
            ![_menu[@"SG1FLG"] isEqualToString:@"1"]&&
            ![_menu[@"BNGFLG"] isEqualToString:@"1"])||
            [_menu[@"TrayStyle"]isEqualToString:@"1"]||
            [_pare[@"TrayStyle"]isEqualToString:@"1"]){

            if (!isShowArrange) {
                if (!isKeppin&&isArrangeMenuEnable) {
                    
                    if (isShowSub1) {
                        
                        NSDictionary *cate = [self currentEditCategory];
                        if (![cate[@"GroupType"]isEqualToString:@"3"]) {
                            [self performSelector:@selector(checkArrangeSub1:menu:) withObject:label3 withObject:_menu];
                        }
                    }
                    else{
                        [self performSelector:@selector(checkArrange:SyohinCD:) withObject:label3 withObject:_menu[@"SyohinCD"]];
                    }
                }
            }
        }
        else{
            label3.text = @"";
        }
    }
    
    return cell;
}

- (void)checkArrange:(UILabel*)label
            SyohinCD:(NSString*)SyohinCD{
    if ([orderManager checkArangeIsEnable:SyohinCD]) {
        //2016-02-03 ueda ASTERISK
        //label.text = @"A";
        label.text = @"T";
    }
    else{
        //2016-02-03 ueda ASTERISK
        //label.text = @"-";
        label.text = @"";
    }
}

- (void)checkArrangeSub1:(UILabel*)label
            menu:(NSDictionary*)menu{
    if ([orderManager checkArangeIsEnableForSub1:menu[@"TopSyohinCD"]
                                    Sub1SyohinCD:menu[@"Sub1SyohinCD"]]){
        //2016-02-03 ueda ASTERISK
        //label.text = @"A";
        label.text = @"T";
    }
    else{
        //2016-02-03 ueda ASTERISK
        //abel.text = @"-";
        label.text = @"";
    }
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark self.gmGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
             point:(CGPoint)point
{
    LOG(@"editSub1Category:%@",editSub1Category);
    
    //2014-01-29 ueda
    [System tapSound];
    //セルの高さ
    int height = 0;
    if (isShowSub1||isShowSub2||isShowArrange) {
        height = (gridView.bounds.size.height-kSubMenuCount-1)/(kSubMenuCount/2);
        //2014-10-31 ueda 【注意】この値はデバッガーで取得した値
        if ([System is568h]) {
            height = 86;
        } else {
            height = 68;
        }
    }
    else{
        height = (gridView.bounds.size.height-kMenuCount-1)/(kMenuCount/2);
        //2014-10-31 ueda
        if ([System is568h]) {
            height = 85;
        } else {
            height = 68;
        }
    }
    //2014-10-31 ueda
    height += gridView.itemSpacing;
    
    int y = point.y - height * MAX(position/2, 0);
    NSLog(@"Did tap at index :%zd :%f:%zd", position,point.x,y);
    
    pastPosition = currentPositon;
    currentPositon = position;
    

    NSInteger listNo = 0;
    NSMutableDictionary *_menu = nil;
    NSInteger type = 0;
    BOOL isFocus = YES;
    if (isShowArrange) {
        listNo = position + kSubMenuCount * dat.ArrangeMenuPage;
        editArrangeMenu = [menuList objectAtIndex:listNo];
        _menu = editArrangeMenu;
        type = 5;
    }
    else if (isShowSub1) {
        listNo = position + kSubMenuCount * dat.Sub1MenuPage;
        
        if (![editSub1Menu[@"SyohinCD"]isEqualToString:[menuList objectAtIndex:listNo][@"SyohinCD"]]&&
            ![editSub1Menu[@"CD"]isEqualToString:[menuList objectAtIndex:listNo][@"CD"]]) {
            isFocus = NO;
        }
        
        editSub1Menu = [menuList objectAtIndex:listNo];
        _menu = editSub1Menu;
        type = 1;
    }
    else if (isShowSub2) {
        listNo = position + kSubMenuCount * dat.Sub2MenuPage;
        
        if (![editSub2Menu[@"CD"]isEqualToString:[menuList objectAtIndex:listNo][@"CD"]]) {
            isFocus = NO;
        }
        
        editSub2Menu = [menuList objectAtIndex:listNo];
        _menu = editSub2Menu;
        type = 2;
    }
    else if (isShowGroup1) {
        
        listNo = position + kMenuCount * dat.Folder1MenuPage;
        
        if (![editFolder1Menu[@"SyohinCD"]isEqualToString:[menuList objectAtIndex:listNo][@"SyohinCD"]]) {
            isFocus = NO;
        }
        
        editFolder1Menu = [menuList objectAtIndex:listNo];
        _menu = editFolder1Menu;
        type = 3;
    }
    else if (isShowGroup2) {
        
        listNo = position + kMenuCount * dat.Folder2MenuPage;
        
        if (![editFolder2Menu[@"SyohinCD"]isEqualToString:[menuList objectAtIndex:listNo][@"SyohinCD"]]) {
            isFocus = NO;
        }
        
        editFolder2Menu = [menuList objectAtIndex:listNo];
        _menu = editFolder2Menu;
        type = 4;
    }
    else{
        //2014-10-31 ueda
        mainIndex = position;
        
        listNo = position + kMenuCount * dat.menuPage;
        
        if (![editMenu[@"SyohinCD"]isEqualToString:[menuList objectAtIndex:listNo][@"SyohinCD"]]) {
            isFocus = NO;
        }
        
        editMenu = [menuList objectAtIndex:listNo];
        _menu = editMenu;
        type = 0;
    }
    
    //提供時期の並び替え対応
    if ([_menu[@"MstSyohinCD"]isEqualToString:@"0"]) {
        [self currentEditMenuClear];
        return;
    }
    
    //2014-06-23 ueda
    menuImage = [self imageWithSyohinCD:_menu[@"SyohinCD"]];

    
    BOOL isKeppin = [orderManager keppinCheck:_menu[@"SyohinCD"]];
    if ([_menu[@"BFLG"] isEqualToString:@"1"]&&[_menu[@"BNGFLG"] isEqualToString:@"0"]) {
        isKeppin = YES;
    }
    if (isKeppin) {
        [self currentEditMenuClear];
        return;
    }
    
    
    [gridView reloadObjectAtIndex:pastPosition animated:NO];
    
    //2014-07-11 ueda
    [gridView reloadData];
 
    //欠品商品はアクションを起こさない
    if ([orderManager keppinCheck:_menu[@"SyohinCD"]]) {
        return;
    }
    if ([_menu[@"BFLG"] isEqualToString:@"1"]&&[_menu[@"BNGFLG"] isEqualToString:@"0"]) {
        return;
    }
    
    //2014-03-03 ueda 以下のifの座標60を80、180を200に変更（３カ所）、height/2をheight*2/3に変更（２カ所）
    if (point.x<80||(120<point.x&&point.x<200)) {
        
        //2016-02-03 ueda ASTERISK
/*
        //拡張タイプがアレンジの場合は１度目のタップはフォーカスのみ
        if ([[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
            if (!isFocus&&![_menu[@"BFLG"] isEqualToString:@"1"]) {
                [gridView reloadObjectAtIndex:currentPositon animated:NO];
                return;
            }
        }
 */
        
        if ([_menu[@"JikaFLG"] isEqualToString:@"1"]&&!isShowArrange) {
            if ([_menu[@"count"]intValue]==0) {
                [self count:1 type:type];
            }
            [self performSegueWithIdentifier:@"ToJikaView" sender:@"0"];
        }
        else if (([_menu[@"SG1FLG"] isEqualToString:@"1"]&&!isShowSub1&&!isShowSub2)
            ||([_menu[@"SG2FLG"] isEqualToString:@"1"]&&isShowSub1)){
            

            if (self.type==TypeOrderOriginal||self.type==TypeOrderAdd) {
                if ([_menu[@"count"]intValue]==0) {
                    if (![self count:1 type:type]) {
                        return;
                    }
                }
            }
            else{
                [self count:1 type:type];
            }

            
            if (isShowSub1) {
                [self showSub2Table];
            }
            else{
                [self showSub1Table];
            }
        }
        else if ([_menu[@"BFLG"] isEqualToString:@"1"]){
            //2015-12-04 ueda
            //iOSスクロールした場合にページ番号をセット
            //２ページ目以降のフォルダのカテゴリーが正しく表示されるようにする
            if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                dat.menuPage = position / kMenuCount;
                saveMenuPage = dat.menuPage;
            }
             if (!isShowGroup1&&!isShowGroup2) {
                
                isShowGroup1 = YES;
                [self reloadCategoryList];
                [self setCategory:editMenu];

            }
            else{
                
                isShowGroup1 = NO;
                isShowGroup2 = YES;
                [self reloadCategoryList];
                [self setCategory:editFolder1Menu];
            }
            //2015-12-04 ueda
            //iOSスクロールした場合にページ番号をリセット
            if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                dat.menuPage = 0;
            }
            [self reloadBottomControl];
        }
        else{

            [self count:1 type:type];
        }
    }
    else if(((80<point.x&&point.x<120)||200<point.x)&&y<(height*2/3)){
        [self countDown:type];
    }
    else if(((80<point.x&&point.x<120)||200<point.x)&&y>(height*2/3)){
        
        LOG(@"1");
        
        if(isShowArrange){
            return;
        }
        
        LOG(@"2");
        
        NSMutableDictionary *_pare = [self currentParentEditMenu];
        
        //2014-06-23 ueda
        if (([_menu[@"InfoFLG"] isEqualToString:@"1"]) || (menuImage)){
            LOG(@"%@",_menu[@"Info"]);
            
            //アレンジ選択の判定
            if ((((!isShowSub1&&!isShowSub2&&!isShowArrange)&&
                  ![_menu[@"SG1FLG"] isEqualToString:@"1"]&&
                  ![_menu[@"BNGFLG"] isEqualToString:@"1"])||
                 [_menu[@"TrayStyle"]isEqualToString:@"1"]||
                 [_pare[@"TrayStyle"]isEqualToString:@"1"])&&
                [_menu[@"count"]intValue]>0&&
                ![[System sharedInstance].kakucho1Type isEqualToString:@"0"]){
                
                if (isArrangeMenuEnable) {
                    //2014-01-29 ueda
                    /*
                    NSString *title = [NSString stringWithFormat:@"%@%@%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:[NSString stringWithFormat:[String Go_to_modify],_menu[@"Info"]]
                                                                   delegate:self
                                                          cancelButtonTitle:[String Yes]
                                                          otherButtonTitles:[String No],nil];
                    alert.tag = 4;
                    [alert show];
                    if ([alert subviews].count>2) {
                        ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                    }
                     */
                    //2014-01-29 ueda
                    NSString *title = [NSString stringWithFormat:@"%@%@%@",[_menu[@"HTDispNMU"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNMM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNML"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                    alert.title=title;
                    alert.message=[NSString stringWithFormat:[String Go_to_modify],_menu[@"Info"]];
                    alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    if (menuImage) {
                        //2014-06-23 ueda
                        [alert addButtonWithTitle:[String PhotoMsg]];
                        if ([System is568h]) {
                            [alert setMessageString:[NSString stringWithFormat:[String Go_to_modify],_menu[@"Info"]] fontOfSize:18];
                        } else {
                            [alert setMessageString:[NSString stringWithFormat:[String Go_to_modify],_menu[@"Info"]] fontOfSize:15];
                        }
                    }
                    alert.cancelButtonIndex=0;
                    alert.tag=4;
                    [alert show];
                }
                else{
                    //2014-01-29 ueda
                    /*
                    NSString *title = [NSString stringWithFormat:@"%@%@%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
                    
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                    message:_menu[@"Info"]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    [alert show];
                    //((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                     */
                    //2014-01-29 ueda
                    NSString *title = [NSString stringWithFormat:@"%@%@%@",[_menu[@"HTDispNMU"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNMM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNML"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                    
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                    alert.title = title;
                    alert.message = [NSString stringWithFormat:@"　\n%@",_menu[@"Info"]];
                    alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    alert.delegate = self;
                    [alert addButtonWithTitle:@"OK"];
                    if (menuImage) {
                        //2014-06-23 ueda
                        [alert addButtonWithTitle:[String PhotoMsg]];
                    }
                    alert.cancelButtonIndex = 0;
                    alert.tag=45;
                    [alert show];
                }
            }
            else{
                //2014-01-29 ueda
                /*
                NSString *title = [NSString stringWithFormat:@"%@%@%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
                
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                                message:_menu[@"Info"]
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                
                if ([alert subviews].count>2) {
                    ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                }
                */
                //2014-01-29 ueda
                NSString *title = [NSString stringWithFormat:@"%@%@%@",[_menu[@"HTDispNMU"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNMM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]],[_menu[@"HTDispNML"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                alert.title = title;
                alert.message = [NSString stringWithFormat:@"　\n%@",_menu[@"Info"]];
                alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                alert.delegate = self;
                [alert addButtonWithTitle:@"OK"];
                if (menuImage) {
                    //2014-06-23 ueda
                    [alert addButtonWithTitle:[String PhotoMsg]];
                }
                alert.cancelButtonIndex = 0;
                alert.tag=45;
                [alert show];
                
            }
        }
        else if ((((!isShowSub1&&!isShowSub2&&!isShowArrange)&&
                   ![_menu[@"SG1FLG"] isEqualToString:@"1"]&&
                   ![_menu[@"BNGFLG"] isEqualToString:@"1"])||
                  [_menu[@"TrayStyle"]isEqualToString:@"1"]||
                  [_pare[@"TrayStyle"]isEqualToString:@"1"])&&
                 [_menu[@"count"]intValue]>0){

            if (isArrangeMenuEnable) {
                //拡張タイプがアレンジの場合はタップで起動しない
                if (![[System sharedInstance].kakucho1Type isEqualToString:@"0"]) {
                [self showArrangeTable];
                }
            }
        }
    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (void)GMGridView:(GMGridView *)gridView longPressOnItemAtIndex:(NSInteger)position point:(CGPoint)point{
    LOG(@"%zd",position);
    
    if (position>=0&&position<[menuList count]) {
        
        NSInteger listNo = 0;
        if (isShowArrange) {
            listNo = position + kSubMenuCount * dat.ArrangeMenuPage;
        }
        else if (isShowSub1) {
            listNo = position + kSubMenuCount * dat.Sub1MenuPage;
        }
        else if (isShowSub2) {
            listNo = position + kSubMenuCount * dat.Sub2MenuPage;
        }
        else if (isShowGroup1) {
            listNo = position + kMenuCount * dat.Folder1MenuPage;
        }
        else if (isShowGroup2) {
            listNo = position + kMenuCount * dat.Folder2MenuPage;
        }
        else{
            listNo = position + kMenuCount * dat.menuPage;
        }
        
        NSMutableDictionary *_menu = [menuList objectAtIndex:listNo];
        
        if (_menu) {
            //提供時期の並び替え対応
            if ([_menu[@"MstSyohinCD"]isEqualToString:@"0"]) {
                return;
            }
            //2014-06-23 ueda
            /*
            UIImage *image = [self imageWithSyohinCD:_menu[@"SyohinCD"]];
            if (image) {
                [self performSegueWithIdentifier:@"ToImageView" sender:image];
            }
             */
        }
    }
}

- (UIImage*)imageWithSyohinCD:(NSString*)SyohinCD{
    NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *fileName = [NSString stringWithFormat:@"%@.jpg",[SyohinCD stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
    NSString *fileFullPath = [documents stringByAppendingPathComponent:fileName];
    
    LOG(@"%@",fileFullPath);
    
    UIImage *image = [UIImage imageWithContentsOfFile:fileFullPath];
    return image;
}

#pragma mark -
#pragma mark - Data Source Methods

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    //return 44.0f;
    //2015-11-13 ueda ASTERISK_TEST
    //return tableView.bounds.size.height/10;
    //2015-11-13 ueda ASTERISK_TEST
    if (YES) {
        return tableView.bounds.size.height/categoryCount;
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [categoryList count];
}

-(UITableViewCell *)tableView:(UITableView *)tableView
        cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[CategoryCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }

    cell.titleLabel.textColor = [UIColor blackColor];
    //2014-02-28 ueda
    if ([System is568h]) {
    } else {
        CGSize newSize = cell.titleLabel.frame.size;
        newSize.height = 37;
        cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x,
                                           cell.titleLabel.frame.origin.y,
                                           newSize.width, newSize.height);
    }
    //2015-11-13 ueda ASTERISK_TEST
    if (YES) {
        CGSize newSize = cell.titleLabel.frame.size;
        if ([System is568h]) {
            newSize.height = 43 * 10 / categoryCount;
        } else {
            newSize.height = 37 * 10 / categoryCount;
        }
        cell.titleLabel.frame = CGRectMake(cell.titleLabel.frame.origin.x,
                                           cell.titleLabel.frame.origin.y,
                                           newSize.width, newSize.height);
    }
    
    NSMutableDictionary *_category = [categoryList objectAtIndex:indexPath.row];
    
    LOG(@"%@",_category);
    
    if ([_category[@"MstSyohinCD"]isEqualToString:@"0"]) {
        cell.titleLabel.text = @"";
        cell.contentView.backgroundColor = [UIColor clearColor];
        return cell;
    }
    
    NSMutableDictionary *_editCate = nil;
    if (isShowArrange) {
        _editCate = editArrangeCategory;
        cell.titleLabel.text = _category[@"CateNM"];
    }
    else if (isShowSub1) {
        _editCate = editSub1Category;
        NSString *nm = _category[@"HTDispNM"];
        if (!nm) {
            nm = _category[@"CateNM"];
        }
        cell.titleLabel.text = nm;
    }
    else if (isShowSub2) {
        _editCate = editSub2Category;
        cell.titleLabel.text = _category[@"HTDispNM"];
    }
    else if (isShowGroup1) {
        _editCate = editFolder1Category;
        NSString *nm = _category[@"HTDispNM"];
        if (!nm) {
            nm = _category[@"CateNM"];
        }
        cell.titleLabel.text = nm;
        
        if ([_category[@"BNGFLG"]isEqualToString:@"0"]) {
            cell.titleLabel.textColor = [UIColor darkGrayColor];
        }
    }
    else if (isShowGroup2) {
        _editCate = editFolder2Category;
        NSString *nm = _category[@"HTDispNM"];
        if (!nm) {
            nm = _category[@"CateNM"];
        }
        cell.titleLabel.text = nm;
        
        if ([_category[@"BNGFLG"]isEqualToString:@"0"]) {
            cell.titleLabel.textColor = [UIColor darkGrayColor];
        }
    }
    else{
        _editCate = editCategory;
        cell.titleLabel.text = _category[@"CateNM"];
    }

    
    NSString *cate1 = [NSString stringWithFormat:@"%@",_editCate];
    NSString *cate2 = [NSString stringWithFormat:@"%@",_category];
    
    //2014-07-30 ueda
    CGRect rect = cell.contentView.bounds;
    rect.size.height = self.categoryTable.frame.size.height / 10;
    //2015-11-13 ueda ASTERISK_TEST
    if (YES) {
        rect.size.height = self.categoryTable.frame.size.height / categoryCount;
    }

    if (!_editCate&&indexPath.row==0) {
        cell.contentView.backgroundColor = [UIColor orangeColor];
        //2014-07-30 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor orangeColor] bounds:rect]]];
        LOG(@"index1:%zd",indexPath.row);
    }
    else if ([cate1 isEqualToString:cate2]) {
        cell.contentView.backgroundColor = [UIColor orangeColor];
        //2014-07-30 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor orangeColor] bounds:rect]]];
    }
    else if ([_category[@"MstCateCD"] isEqualToString:editArrangeCategory[@"MstCateCD"]]&&isShowArrange) {
        cell.contentView.backgroundColor = [UIColor orangeColor];
        //2014-07-30 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor orangeColor] bounds:rect]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor clearColor];
        //2014-07-30 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor grayColor] bounds:rect]]];
    }
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    LOG(@"didSelectRowAtIndexPath:%@",indexPath);
    //2014-01-29 ueda
    [System tapSound];
    id _category = [categoryList objectAtIndex:indexPath.row];
    
    BOOL isAction = YES;
    
    if (isShowGroup1||isShowGroup2) {
        if ([_category[@"BNGFLG"]isEqualToString:@"0"]) {
            isAction = NO;
        }
    }
    
    if ([_category[@"MstSyohinCD"]isEqualToString:@"0"]) {
        isAction = NO;
    }
    
    
    if (isAction) {
        [self setCategory:_category];
    }
    else{
         [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    }
}

- (void)setCategory:(NSMutableDictionary*)_category{
    //2015-12-14 ueda ASTERISK
    BOOL topCategoryFlag = NO;
    if (isShowArrange) {
        
        LOG(@"isShowArrange");
        if (editArrangeCategory != _category) {
            editArrangeMenu = nil;
            dat.ArrangeMenuPage = 0;
        }
        editArrangeCategory = _category;
        
        [self reloadMenuList];
        [self.subGridView reloadData];
    }
    else if (isShowSub1) {
        
        LOG(@"isShowSub1:%@",_category);
        if (editSub1Category != _category) {
            editSub1Menu = nil;
            dat.Sub1MenuPage = 0;
        }
        editSub1Category = _category;
        
        [self reloadMenuList];
        [self.subGridView reloadData];
        //2015-12-15 ueda ASTERISK
        [self reloadBottomControl];
    }
    else if (isShowSub2) {
        
        LOG(@"isShowSub2");
        if (editSub2Menu != _category) {
        editSub2Menu = nil;
        dat.Sub2MenuPage = 0;
        }
        editSub2Category = _category;
        
        [self reloadMenuList];
        [self.subGridView reloadData];
        //2015-12-15 ueda ASTERISK
        [self reloadBottomControl];
    }
    else if (isShowGroup1) {
        
        LOG(@"isShowGroup1");
        if (editFolder1Category != _category) {
            editFolder1Menu = nil;
            dat.Folder1MenuPage = 0;
        }
        editFolder1Category = _category;
        
        [self reloadMenuList];
        [self.gmGridView reloadData];
    }
    else if (isShowGroup2) {
        LOG(@"isShowGroup2:%@",_category);
        if (editFolder2Category != _category) {
            editFolder2Menu = nil;
            dat.Folder2MenuPage = 0;
        }
        editFolder2Category = _category;
        
        [self reloadMenuList];
        [self.gmGridView reloadData];
    }
    else{
        //2015-12-15 ueda ASTERISK
        topCategoryFlag = YES;
        LOG(@"isTop");
        if (editCategory != _category) {
            editMenu = nil;
            dat.menuPage = 0;
            //2015-12-18 ueda
            mainIndex = 0;
        }
        
        
        //既存カテゴリー移動が「使用しない」の場合は、カテゴリーの呼び出しと保存を行う
        System *sys = [System sharedInstance];
        if ([sys.regularCategory isEqualToString:@"0"]) {
            LOG(@"regularCategory_01");
            if (!_category) {
                LOG(@"regularCategory_01_01");
                int index = [sys.currentCategory intValue];
                //2014-11-06 ueda
                //2015-12-14 ueda ASTERISK
                if (index > 0 && index < 20) {
                    _category = categoryList[index];
                } else {
                    _category = categoryList[0];
                }
            }
        }
        
        if (_category) {
            NSInteger index = [categoryList indexOfObject:_category];
            if ((index >=0) && (index <= 19)) {
                //2016-03-16 ueda
                //とんでもない値になる場合があるのでマスクする
                sys.currentCategory = [NSString stringWithFormat:@"%zd",index];
                [sys saveChacheAccount];
            }
         }
        
        
        editCategory = _category;
        
        [self reloadMenuList];
        //2014-10-31 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            [self.gmGridView reloadData];
            //2015-09-10 ueda
            //[self.gmGridView scrollToObjectAtIndex:mainIndex atScrollPosition:GMGridViewScrollPositionTop animated:NO];
            //2015-12-18 ueda
            //[self.gmGridView scrollToObjectAtIndex:0 atScrollPosition:GMGridViewScrollPositionTop animated:NO];
            [self.gmGridView scrollToObjectAtIndex:mainIndex atScrollPosition:GMGridViewScrollPositionTop animated:NO];
        } else {
            [self.gmGridView reloadData];
        }
    }
    
    [self.categoryTable reloadData];
    //2015-12-14 ueda ASTERISK
    //2015-12-17 ueda ASTERISK
    //2016-03-31 ueda ASTERISK
/*
    if (topCategoryFlag && self.type != TypeOrderCancel) {
 */
    //2016-03-31 ueda ASTERISK
    if (topCategoryFlag && self.type != TypeOrderCancel && self.type != TypeOrderDivide) {
        //カテゴリーを見える位置に表示させる
        NSInteger rowNo = [[editCategory objectForKey:@"MstCateCD"] integerValue];
        NSIndexPath* indexPath = [NSIndexPath indexPathForRow:rowNo inSection:0];
        [self.categoryTable scrollToRowAtIndexPath:indexPath atScrollPosition:UITableViewScrollPositionMiddle animated:NO];
    }
    [self reloadDispCount];
}

#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //NSArray *_tableArray = [(NSArray*)_dataList objectAtIndex:0];
        //LOG(@"_tableArray:%@",_tableArray);
        
        //2015-09-17 ueda
        if (type==RequestTypeOrderRequest) {
            if (_dataList) {
                [orderManager zeroReset];
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
        }
        
        [mbProcess hide:YES];
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }

        //2015-09-17 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
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
                [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
                alert.messageLabel.textAlignment = NSTextAlignmentLeft;
            }
        } else {
            [alert addButtonWithTitle:@"OK"];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
            alert.delegate=self;
            alert.tag=1101;
        }
        [alert show];
        
    });
}


/////////////////////////////////////////////////////////////////
#pragma mark - MBProgressHUD Delegate
/////////////////////////////////////////////////////////////////

//2015-09-17 ueda
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

#pragma mark -
#pragma mark ConfirmViewControllerDelegate methods
- (void)setDispMenu:(NSMutableDictionary*)_menu{

    LOG(@"%@",_menu);
    
    if ([[_menu allKeys] containsObject:@"CondiGCD"]) {//SG1の場合
        editMenu = [orderManager getMenu:_menu[@"TopSyohinCD"]];
        editSub1Menu = _menu;
        isShowSub1 = YES;
        
        NSMutableDictionary *_cate = [orderManager getCategory:editMenu[@"CateCD"]];
        [self setCategory:_cate];
        
        [self showSub1Table];
        
        if ([[menuList valueForKeyPath:@"SyohinCD"] containsObject:_menu[@"SyohinCD"]]) {
            NSInteger index = 0;
            index = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:_menu[@"SyohinCD"]];
            dat.Sub1MenuPage = index/kSubMenuCount;
            //2014-10-29 ueda
            if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                dat.Sub1MenuPage = 0;
                [self.subGridView reloadData];
                [self.subGridView scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionTop animated:NO];
                
            } else {
                [self.subGridView reloadData];
            }
        }
    }
    else if([_menu[@"JikaFLG"] isEqualToString:@"1"]){
        editMenu = _menu;
        isShowSub1 = NO;
        [self performSegueWithIdentifier:@"ToJikaView" sender:nil];
    }
    else{
        
        isShowSub1 = NO;
        NSMutableDictionary *_cate = [orderManager getCategory:_menu[@"CateCD"]];
        [self setCategory:_cate];
        editMenu = _menu;
        
        if ([[menuList valueForKeyPath:@"SyohinCD"] containsObject:_menu[@"SyohinCD"]]) {
            NSInteger index = 0;
            index = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:_menu[@"SyohinCD"]];
            dat.menuPage = index/kMenuCount;
            //2014-10-29 ueda
            if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                dat.menuPage = 0;
                [self.gmGridView reloadData];
                [self.gmGridView scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionTop animated:NO];
            } else {
                [self.gmGridView reloadData];
            }
        }
    }
}

- (void)setDispSub1Menu:(NSMutableDictionary*)_menu
                    sub:(NSMutableDictionary*)_subMenu{
    
    LOG(@"%@",_menu);
    
    editMenu = _menu;
    
    isShowSub1 = NO;
    
    //2015-07-10 ueda
    if (YES) {
        //取り消し時の選択した商品以外の商品が選択される不具合対策の試作
        isShowGroup1 = NO;
        isShowGroup2 = NO;
    }
    
    //グループ内の商品の場合はカテゴリを更新しない
    if (!isShowGroup1&&!isShowGroup2) {
        LOG(@"0");
        NSMutableDictionary *_cate = [orderManager getCategory:editMenu[@"CateCD"]];
        [self setCategory:_cate];
        
        NSInteger menuIndex = 0;
        menuIndex = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:_menu[@"SyohinCD"]];
        dat.menuPage = menuIndex/kMenuCount;
        //2015-12-18 ueda
        mainIndex = menuIndex;
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            dat.menuPage = 0;
        }
    }
    
    LOG(@"1");
    
    editMenu = _menu;
    
    [self showSub1Table];
    
    LOG(@"2");
    
    self.topView.backgroundColor = BLUE;
    //2014-07-11 ueda
    [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
    
    if (_subMenu) {
        if ([[menuList valueForKeyPath:@"SyohinCD"] containsObject:_subMenu[@"SyohinCD"]]) {
            NSInteger index = 0;
            index = [[menuList valueForKeyPath:@"SyohinCD"] indexOfObject:_subMenu[@"SyohinCD"]];
            dat.Sub1MenuPage = index/kSubMenuCount;
            //2014-10-29 ueda
            if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                dat.Sub1MenuPage = 0;
                [self.subGridView reloadData];
                [self.subGridView scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionTop animated:NO];
            } else {
                [self.subGridView reloadData];
            }
            
            LOG(@"3");
        }
    }
}

- (void)setDispGroupMenu:(NSMutableDictionary*)_menu
                    sub:(NSMutableDictionary*)_subMenu{
    
    LOG(@"%@",_menu);
    
    
    //トップ階層を規定する
    isShowGroup1 = NO;
    NSMutableDictionary *_cate = [orderManager getCategory:_menu[@"CateCD"]];
    [self setCategory:_cate];
    dat.menuPage = [_menu[@"PageNo"]intValue]-1;

    
    //第一階層フォルダを規定する
    isShowGroup1 = YES;
    [self reloadCategoryList];
    [self setCategory:categoryList[[_menu[@"B1CateCD"]intValue]]];
    editMenu = editFolder1Category;
    editFolder1Menu = _menu;
    
    if (![[_menu allKeys]containsObject:@"B2CateCD"]) {
        //第一階層フォルダのページを設定する
        for (int ct = 0; ct < [menuList count]; ct++) {
            NSMutableDictionary *menu = menuList[ct];
            if ([menu[@"MstSyohinCD"] isEqualToString:_menu[@"MstSyohinCD"]]) {
                dat.Folder1MenuPage = ct/kMenuCount;
                //2014-10-29 ueda
                if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                    dat.Folder1MenuPage = 0;
                    [self.gmGridView reloadData];
                    [self.gmGridView scrollToObjectAtIndex:ct atScrollPosition:GMGridViewScrollPositionTop animated:NO];
                }
                break;
            }
        }
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        } else {
            [self.gmGridView reloadData];
        }
    }
    else{
        //第二階層フォルダを規定する
        dat.Folder1MenuPage = [_menu[@"B1PageNo"]intValue]-1;
        [self reloadMenuList];

        isShowGroup1 = NO;
        isShowGroup2 = YES;
        
        [self reloadCategoryList];
        [self setCategory:categoryList[[_menu[@"B2CateCD"]intValue]]];
        
        editFolder2Menu = _menu;

        //第二階層フォルダのページを設定する
        for (int ct = 0; ct < [menuList count]; ct++) {
            NSMutableDictionary *menu = menuList[ct];
            if ([menu[@"MstSyohinCD"] isEqualToString:_menu[@"MstSyohinCD"]]) {
                dat.Folder2MenuPage = ct/kMenuCount;
                //2014-10-29 ueda
                if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
                    dat.Folder2MenuPage = 0;
                    [self.gmGridView reloadData];
                    [self.gmGridView scrollToObjectAtIndex:ct atScrollPosition:GMGridViewScrollPositionTop animated:NO];
                }
                break;
            }
        }
        //2014-10-29 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        } else {
            [self.gmGridView reloadData];
        }
    }

    [self reloadBottomControl];

    LOG(@"folder:%@",editFolder2Menu);
    
    //if (_menu!=_subMenu&&_subMenu) {
    if ([_menu[@"SG1FLG"] isEqualToString:@"1"]) {

        [self showSub1Table];
        
        self.topView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
    }

}



/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

//2014-09-17 ueda
- (void)addArrangeData:(NSString*)arrangeInputText{
    [orderManager addMenuExtMt:arrangeInputText];
    categoryList = [orderManager getArrangeCategoryList];
    id _category = [categoryList objectAtIndex:9];
    [self setCategory:_category];
    menuList = [orderManager getMenuList:editArrangeCategory];
    NSMutableDictionary *_menu = [menuList objectAtIndex:[menuList count] - 1];
    [orderManager addArrangeMenu:_menu
                          update:NO];
    editArrangeMenu = [menuList objectAtIndex:[menuList count] - 1];
    [self count:1 type:5];
    dat.ArrangeMenuPage = MAX(([menuList count] - 1), 0) / kSubMenuCount;
    //2014-10-29 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        NSInteger index = dat.ArrangeMenuPage;
        dat.ArrangeMenuPage = 0;
        [self.subGridView reloadData];
        [self.subGridView scrollToObjectAtIndex:index atScrollPosition:GMGridViewScrollPositionTop animated:NO];
    } else {
        [self.subGridView reloadData];
    }
}

//2015-09-17 ueda
- (void)orderSendRetry {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31retryFlag = YES;
    switch (self.type) {
        case TypeOrderOriginal:
            
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendOrderRequest:self retryFlag:YES];
            }
            break;
            
        case TypeOrderAdd:
            
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendOrderAdd:self retryFlag:YES];
            }
            break;
    }
}

//2015-09-17 ueda
- (void)orderSendForce {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31forceFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}

@end
