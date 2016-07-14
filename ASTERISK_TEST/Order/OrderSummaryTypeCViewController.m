//
//  OrderSummaryTypeCViewController.m
//  Order
//
//  Created by UEDA on 2014/07/08.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//

#import "OrderSummaryTypeCViewController.h"
#import "OrderEntryViewController.h"
#import "SSGentleAlertView.h"
#import "TableViewCellOrderSummaryTypeC.h"
#define listCount 10 //リスト行数

@interface OrderSummaryTypeCViewController ()<MBProgressHUDDelegate>{
    MBProgressHUD *mbProcess;
    OrderManager *orderManager;
    BOOL isFinish;
    int menuPage;
    int defaultHeight;
    BOOL sortKbn;
    NSMutableArray *_seatNumberData;
    NSMutableArray *_dataSourceDisp;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UITableView *summaryTableView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_sort;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_addOrder;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;

- (IBAction)iba_sort:(UIButton *)sender;
- (IBAction)iba_prevPage:(UIButton *)sender;
- (IBAction)iba_nextPage:(UIButton *)sender;
- (IBAction)iba_addOrder:(UIButton *)sender;
- (IBAction)iba_next:(UIButton *)sender;

@end

@implementation OrderSummaryTypeCViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//2014-11-20 ueda
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.summaryTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.summaryTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    if ([System is568h]) {
        defaultHeight = 440;
    } else {
        defaultHeight = 350;
        self.summaryTableView.frame  = CGRectMake(3, 26, 314, 370);
    }
    menuPage = 0;
    sortKbn  = NO;

    [self.bt_sort setTitle:[String bt_sort] forState:UIControlStateNormal];
    [self.bt_addOrder setNumberOfLines:0];
    [self.bt_addOrder setTitle:[String bt_addOrder] forState:UIControlStateNormal];
    [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
    //2014-10-24 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_addOrder setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_addOrder setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.type == TypeOrderCancel) {
        //取消の場合
        [self.bt_next setTitle:[String bt_return] forState:UIControlStateNormal];
        [self.bt_addOrder.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
        if ([[System sharedInstance].lang isEqualToString:@"1"]) {
            [self.bt_addOrder setTitle:@"End" forState:UIControlStateNormal];
        } else {
            [self.bt_addOrder setTitle:@"終了" forState:UIControlStateNormal];
        }
    }
    
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        self.lb_title.text = @" Order Summary";
    } else {
        self.lb_title.text = @" 注文一覧";
    }
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];

    self.bt_prevPage.enabled = NO;
    self.bt_nextPage.enabled = NO;

    [System adjustStatusBarSpace:self.view];

    orderManager = [OrderManager sharedInstance];
    _seatNumberData = orderManager.getSeatNumberData;
    
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.summaryTableView.scrollEnabled = YES;
        self.summaryTableView.showsVerticalScrollIndicator = YES;
        self.summaryTableView.bounces = YES;
        self.summaryTableView.alwaysBounceVertical = YES;
        self.summaryTableView.backgroundColor = [UIColor clearColor];
        //2015-04-30 ueda
        //self.summaryTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.summaryTableView.tableFooterView = [[UIView alloc] init];
        
        //2015-04-03 ueda
/*
        self.bt_nextPage.enabled = NO;
        self.bt_prevPage.enabled = NO;
        self.bt_nextPage.hidden = YES;
        self.bt_prevPage.hidden = YES;
 */
    }

    [self reloadDispData];
    //2016-02-03 ueda ASTERISK
    [self.bt_nextPage setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_nextPage setNumberOfLines:0];
    [self.bt_prevPage setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_prevPage setNumberOfLines:0];
    [self.bt_nextPage.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
    [self.bt_prevPage.titleLabel setFont:[UIFont boldSystemFontOfSize:18]];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)iba_sort:(UIButton *)sender {
    sortKbn  = !sortKbn;
    menuPage = 0;
    [self reloadDispData];
    [self.summaryTableView reloadData];
}
- (IBAction)iba_prevPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        CGPoint currentPos = self.summaryTableView.contentOffset;
        currentPos.y -= self.summaryTableView.frame.size.height;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.summaryTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.summaryTableView.frame.size.height) animated:YES];
    } else {
        menuPage--;
        [self.summaryTableView reloadData];
    }
}

- (IBAction)iba_nextPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        NSInteger maxHeight  = self.summaryTableView.contentSize.height;
        NSInteger pageHeight = self.summaryTableView.frame.size.height;
        CGPoint currentPos = self.summaryTableView.contentOffset;
        currentPos.y += self.summaryTableView.frame.size.height;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.summaryTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        menuPage++;
        [self.summaryTableView reloadData];
    }
}

- (IBAction)iba_addOrder:(UIButton *)sender {
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.type == TypeOrderCancel) {
        //取消の場合popToRootViewControllerAnimated
        [self.navigationController popToRootViewControllerAnimated:YES];
    } else {
        //オーダー追加
        appDelegate.typeCeditModeFg   = NO;
        appDelegate.typeCorderIndex ++;
        appDelegate.typeCorderResetFg = YES;
        appDelegate.typeCorderCount   = 0;
        [orderManager zeroReset];
        [DataList sharedInstance].typeCseatSelect = [[NSMutableArray alloc]init];
        
        OrderEntryViewController *oevc = nil;
        for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
            UIViewController *vc = self.navigationController.viewControllers[ct];
            if ([vc isKindOfClass:[OrderEntryViewController class]]) {
                oevc = (OrderEntryViewController*)vc;
            }
        }
        [self.navigationController popToViewController:oevc animated:YES];
    }
}

- (IBAction)iba_next:(UIButton *)sender {
    if ([_dataSourceDisp count] == 0) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_order1]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    } else {
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (appDelegate.type == TypeOrderCancel) {
            //取消の場合
            //３つ前の画面に戻る
            NSInteger count = self.navigationController.viewControllers.count - 4;
            HomeViewController *vc = [self.navigationController.viewControllers objectAtIndex:count];
            [self.navigationController popToViewController:vc animated:YES];
        } else {
            //新規 or 追加
            //2014-12-16 ueda
            //BOOL isLoading = NO;
            NetWorkManager *_net = [NetWorkManager sharedInstance];
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            switch (appDelegate.type) {
                case TypeOrderOriginal:
                    //2014-12-16 ueda
                    //isLoading = YES;
                    [self showIndicator];
                    
                    [_net sendOrderRequestTypeC:self retryFlag:NO];
                    break;
                    
                case TypeOrderAdd:
                    //2014-12-16 ueda
                    //isLoading = YES;
                    [self showIndicator];
                    
                    [_net sendOrderAddTypeC:self retryFlag:NO];
                    break;
                    
                default:
                    break;
            }
            
            //2014-12-16 ueda
/*
            if(isLoading){
                mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
                mbProcess.labelText = @"Sending Data";
                [self.view addSubview:mbProcess];
                [mbProcess setDelegate:self];
                [mbProcess show:YES];
            }
 */
        }
    }
}

- (void)reloadDispData{
    NSMutableArray *list = [orderManager getOrderListTypeCForSummary:0];
    _dataSourceDisp = [[NSMutableArray alloc] init];
    
    NSArray *sortArray;
    //ソート
    if (sortKbn) {
        NSSortDescriptor *sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"SeatNumber" ascending:YES];
        NSSortDescriptor *sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"OrderType"  ascending:YES];
        NSSortDescriptor *sortDesc3 = [[NSSortDescriptor alloc] initWithKey:@"OrderIndex" ascending:YES];
        NSSortDescriptor *sortDesc4 = [[NSSortDescriptor alloc] initWithKey:@"id"         ascending:YES];
        NSArray *sortDescArray;
        sortDescArray = [NSArray arrayWithObjects:sortDesc1, sortDesc2, sortDesc3, sortDesc4, nil];
        sortArray = [list sortedArrayUsingDescriptors:sortDescArray];
        
        NSMutableString *preName = [NSMutableString stringWithString:@""];
        NSMutableDictionary *preData = nil;
        //NSMutableString *preName = [NSMutableString stringWithString:@""];
        
        for (int ct = 0; ct < [sortArray count]; ct++) {
            NSString *seatName = nil;
            NSMutableDictionary *currentData = sortArray[ct];
            
            NSMutableString *checkStr = [NSMutableString string];
            [checkStr appendString:currentData[@"SeatNumber"]];
            [checkStr appendString:currentData[@"OrderType"]];
            
            if ([preName isEqualToString:@""]) {
            } else {
                if ([checkStr isEqualToString:preName]) {
                } else {
                    NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:preData];
                    [tmp setValue:@"" forKey:@"SeatName"];
                    tmp[@"SyohinName"] = tmp[@"OrderTypeName"];
                    tmp[@"count"] = @"";
                    tmp[@"OrderTypeKubun"] = @"1";
                    [_dataSourceDisp addObject:tmp];
                }
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:currentData];
            if ([currentData[@"SeatNumber"] isEqualToString:@"00"]) {
                seatName = @" ";
            } else {
                NSMutableDictionary *search = [_seatNumberData objectAtIndex:[[_seatNumberData valueForKeyPath:@"keyText"] indexOfObject:currentData[@"SeatNumber"]]];
                if ([[System sharedInstance].typeCseatCaptionType isEqualToString:@"1"]) {
                    //数値バージョン
                    seatName = search[@"titleText"];
                } else {
                    //アルファベットバージョン
                    seatName = search[@"abcText"];
                }
            }
            [dic setValue:seatName forKey:@"SeatName"];
            [_dataSourceDisp addObject:dic];
            
            [preName setString:checkStr];
            preData = sortArray[ct];
        }
        NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:preData];
        [tmp setValue:@"" forKey:@"SeatName"];
        tmp[@"SyohinName"] = tmp[@"OrderTypeName"];
        tmp[@"count"] = @"";
        tmp[@"OrderTypeKubun"] = @"1";
        [_dataSourceDisp addObject:tmp];

    } else {
        NSSortDescriptor *sortDesc1 = [[NSSortDescriptor alloc] initWithKey:@"OrderType"  ascending:YES];
        NSSortDescriptor *sortDesc2 = [[NSSortDescriptor alloc] initWithKey:@"SeatNumber" ascending:YES];
        NSSortDescriptor *sortDesc3 = [[NSSortDescriptor alloc] initWithKey:@"OrderIndex" ascending:YES];
        NSSortDescriptor *sortDesc4 = [[NSSortDescriptor alloc] initWithKey:@"id"         ascending:YES];
        NSArray *sortDescArray;
        sortDescArray = [NSArray arrayWithObjects:sortDesc1, sortDesc2, sortDesc3, sortDesc4, nil];
        sortArray = [list sortedArrayUsingDescriptors:sortDescArray];
        
        NSMutableString *preName = [NSMutableString stringWithString:@"Dummy"];
        
        for (int ct = 0; ct < [sortArray count]; ct++) {
            NSString *seatName = nil;
            NSMutableDictionary *currentData = sortArray[ct];
            
            NSMutableString *checkStr = [NSMutableString string];
            [checkStr appendString:currentData[@"OrderType"]];
            if ([checkStr isEqualToString:preName]) {
            } else {
                [preName setString:checkStr];
                NSMutableDictionary *tmp = [NSMutableDictionary dictionaryWithDictionary:currentData];
                [tmp setValue:@"" forKey:@"SeatName"];
                tmp[@"SyohinName"] = tmp[@"OrderTypeName"];
                tmp[@"count"] = @"";
                tmp[@"OrderTypeKubun"] = @"1";
                [_dataSourceDisp addObject:tmp];
            }
            
            NSMutableDictionary *dic = [NSMutableDictionary dictionaryWithDictionary:currentData];
            if ([currentData[@"SeatNumber"] isEqualToString:@"00"]) {
                seatName = @" ";
            } else {
                NSMutableDictionary *search = [_seatNumberData objectAtIndex:[[_seatNumberData valueForKeyPath:@"keyText"] indexOfObject:currentData[@"SeatNumber"]]];
                if ([[System sharedInstance].typeCseatCaptionType isEqualToString:@"1"]) {
                    //数値バージョン
                    seatName = search[@"titleText"];
                } else {
                    //アルファベットバージョン
                    seatName = search[@"abcText"];
                }
            }
            [dic setValue:seatName forKey:@"SeatName"];
            [_dataSourceDisp addObject:dic];
        }
    }
}

//////////////////////////////////////////////////////////////
#pragma mark - Order Summary TableView
//////////////////////////////////////////////////////////////

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return defaultHeight / listCount;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    NSInteger maxPage = 0;
    count = MIN(listCount, [_dataSourceDisp count] - (listCount * menuPage));
    if ([_dataSourceDisp count] > 0) {
        maxPage = ([_dataSourceDisp count] - 1) / listCount;
    }
    
    
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        count = [_dataSourceDisp count];
        //2015-04-08 ueda
        self.bt_nextPage.enabled = YES;
        self.bt_prevPage.enabled = YES;
    } else {
        int height = defaultHeight / listCount;
        self.summaryTableView.frame = CGRectMake(self.summaryTableView.frame.origin.x, self.summaryTableView.frame.origin.y, self.summaryTableView.frame.size.width, MIN(height * count, defaultHeight));
        
        self.bt_nextPage.enabled = NO;
        self.bt_prevPage.enabled = NO;
        
        if (menuPage < maxPage) {
            self.bt_nextPage.enabled = YES;
        }
        if (0 < menuPage) {
            self.bt_prevPage.enabled = YES;
        }
    }
    
    return count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TableViewCellOrderSummaryTypeC *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TableViewCellOrderSummaryTypeC alloc] initWithStyle:UITableViewCellStyleValue1
                                                     reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([System is568h]) {
    } else {
        cell.labelSeat.frame   = CGRectMake(  6, 0,  38, 35);
        cell.labelSyohin.frame = CGRectMake( 54, 0, 222, 35);
        cell.labelCount.frame  = CGRectMake(259, 0,  40, 35);
    }
    NSInteger ptr = indexPath.row + (listCount * menuPage);
    NSMutableDictionary *currentData = _dataSourceDisp[ptr];
    cell.labelSeat.text   = currentData[@"SeatName"];
    cell.labelSyohin.text = currentData[@"SyohinName"];
    cell.labelCount.text  = currentData[@"count"];
    
    CGRect rect = cell.contentView.bounds;
    rect.size.height = defaultHeight / 4;

    cell.contentView.backgroundColor = [UIColor whiteColor];
    if ([currentData[@"OrderTypeKubun"] isEqualToString:@"1"]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:64.0f/255.0f green:64.0f/255.0f blue:64.0f/255.0f alpha:1.0f] bounds:rect]]];
        [cell.labelSyohin setFont:[UIFont boldSystemFontOfSize:17]];
        NSInteger lenByte = [cell.labelSyohin.text lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
        if (lenByte > 30) {
            NSString *upText = [System getByteText:cell.labelSyohin.text length:lenByte / 2];
            NSInteger upLen = [upText length];
            NSString *btmText = [cell.labelSyohin.text substringWithRange:NSMakeRange(upLen, [cell.labelSyohin.text length] - upLen)];
            cell.labelSyohin.numberOfLines = 0;
            cell.labelSyohin.adjustsFontSizeToFitWidth = NO;
            [cell.labelSyohin setFont:[UIFont boldSystemFontOfSize:13]];
            cell.labelSyohin.text = [NSString stringWithFormat:@"%@\n%@",upText,btmText];
        } else {
            cell.labelSyohin.numberOfLines = 1;
            cell.labelSyohin.adjustsFontSizeToFitWidth = YES;
            [cell.labelSyohin setFont:[UIFont boldSystemFontOfSize:17]];
        }
    } else {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
        [cell.labelSyohin setFont:[UIFont systemFontOfSize:17]];
        cell.labelSyohin.numberOfLines = 1;
        cell.labelSyohin.adjustsFontSizeToFitWidth = YES;
    }
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    //NSLog(@"セクション:%d , %d 番目の項目のタップ", indexPath.section + 1, indexPath.row + 1);
    [System tapSound];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSInteger ptr = indexPath.row + (listCount * menuPage);
    NSInteger orderIndex = [_dataSourceDisp[ptr][@"OrderIndex"] intValue];
    NSMutableDictionary *editingDic = _dataSourceDisp[ptr];
    [orderManager zeroReset];
    [orderManager typeCrestoreDB:orderIndex];

    if (appDelegate.type == TypeOrderCancel) {
        //取消の場合
        OrderConfirmViewController *ocvc = nil;
        for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
            UIViewController *vc = self.navigationController.viewControllers[ct];
            if ([vc isKindOfClass:[OrderConfirmViewController class]]) {
                ocvc = (OrderConfirmViewController*)vc;
            }
        }
        [self.navigationController popToViewController:ocvc animated:YES];
    } else {
        //新規 or 追加
        appDelegate.typeCeditModeFg   = YES;
        appDelegate.typeCeditModeFirstFg = YES;
        [DataList sharedInstance].typeCeditSyohin = editingDic;
        appDelegate.typeCorderIndex ++;
        appDelegate.typeCorderResetFg = YES;
        NSMutableArray *orderList = [orderManager getOrderList:0][0];
        appDelegate.typeCorderCount = [orderList count];

        OrderEntryViewController *oevc = nil;
        for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
            UIViewController *vc = self.navigationController.viewControllers[ct];
            if ([vc isKindOfClass:[OrderEntryViewController class]]) {
                oevc = (OrderEntryViewController*)vc;
            }
        }
        [self.navigationController popToViewController:oevc animated:YES];
    }
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
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
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
        if([_msg rangeOfString:[String Out_of_stock_change]].location != NSNotFound){
            //欠品(品切れ)情報
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.messageLabel.textAlignment = NSTextAlignmentLeft;
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
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
 */
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        //2014-12-04 ueda
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
            }
        } else {
            [alert addButtonWithTitle:@"OK"];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
            alert.delegate=self;
            alert.tag=1101;
        }
        [alert show];
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

//////////////////////////////////////////////////////////////
#pragma mark MBProgressHUDDelegate methods
//////////////////////////////////////////////////////////////

- (void)showIndicator{
    if (!mbProcess) {
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
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
#pragma mark - alertView Delegate
/////////////////////////////////////////////////////////////////

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (alertView.tag==1101){
                [self orderSendRetry];
            }
            //2014-12-25 ueda
            else if (alertView.tag==1102){
                [self orderSendForce];
            }
            break;
            
        case 1:
            //2014-12-25 ueda
            if (alertView.tag==1102){
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.OrderRequestN31forceFlag = NO;
            }
            break;
            
    }
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

//2014-10-29 ueda
- (void)orderSendRetry {
    [self showIndicator];
    //2014-12-25 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31retryFlag = YES;
    //2014-12-16 ueda
    //BOOL isLoading = NO;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    switch (appDelegate.type) {
        case TypeOrderOriginal:
            //2014-12-16 ueda
            //isLoading = YES;
            
            [_net sendOrderRequestTypeC:self retryFlag:YES];
            break;
            
        case TypeOrderAdd:
            //2014-12-16 ueda
            //isLoading = YES;
            
            [_net sendOrderAddTypeC:self retryFlag:YES];
            break;
            
        default:
            break;
    }
    //2014-12-16 ueda
/*
    if(isLoading){
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        mbProcess.labelText = @"Sending Data";
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
    [_net sendOrderRequestTypeC:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}

@end
