//
//  TableViewController.m
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "TableViewController.h"
#import "ExtensionViewController.h"
#define TABLECOUNT 40
#import "SSGentleAlertView.h"
#import "TypeCCountViewController.h"
#import "CustomerViewController.h"

@interface TableViewController () {
    //2014-07-16 ueda
    NSMutableDictionary *_ColorCode;
    BOOL _fileFg;
}

@end

@implementation TableViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    if (dat.isMove) {
        //2014-12-09 ueda
        [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
        dat.isMove = NO;
        dat.currentVoucher = nil;
        [self buttonStateChange];
        [dat.moveToTable removeAllObjects];
        //2015-11-05 ueda
        editTable = [DataList sharedInstance].currentTable;
        [self.gmGridView reloadData];
        return;
    }
    else if((self.type == TypeOrderOriginal||self.type == TypeOrderAdd)&&
            [sys.entryType isEqualToString:@"1"]){
        //2015-09-17 ueda
/*
        [self.navigationController popViewControllerAnimated:YES];
 */
        //2015-09-17 ueda
        //Ｂタイプ
        if (!([[System sharedInstance].useOrderConfirm isEqualToString:@"0"])) {
            //オーダー確認画面を表示する
        } else {
            //直前の画面がオーダー確認画面だったら２つ前に戻る
            NSInteger pointer = self.navigationController.viewControllers.count - 2;
            UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:pointer];
            if ([vc isKindOfClass:[OrderConfirmViewController class]]) {
                vc = [self.navigationController.viewControllers objectAtIndex:pointer - 1];
                [self.navigationController popToViewController:vc animated:YES];
                return;
            }
        }
        [self.navigationController popViewControllerAnimated:YES];
        return;
    }
    
    if(self.type == TypeOrderOriginal||self.type == TypeOrderAdd){
        NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
        //2014-09-10 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        if (([sys.entryType isEqualToString:@"0"] && [orderList count]>0) || ([sys.entryType isEqualToString:@"2"] && [orderList count]>0) || ([sys.entryType isEqualToString:@"2"] && appDelegate.typeCorderIndex>1)) {
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
             alert.tag = 504;
            [alert show];
        }
        else{
            //2014-6-25 ueda
            if(self.type == TypeOrderOriginal){
                //2014-07-07 ueda
                if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                    //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                    [self.navigationController popToRootViewControllerAnimated:YES];
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            } else {
                [self.navigationController popViewControllerAnimated:YES];
            }
        }
        return;
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_showNext:(id)sender{
    dat.currentTable = editTable;
    
    //入力タイプB時の新規／追加の判定
    if (self.type==TypeOrderOriginal&&[[System sharedInstance].entryType isEqualToString:@"1"]) {
        
        //伝票の判定
        BOOL isAiseki = NO;
        
        LOG(@"%@",dat.currentTable);
        for (int ct = 0; ct < [dat.selectTable count]; ct++) {
            //2014-12-18 ueda
            //if ([dat.selectTable[ct][@"status"] intValue]>3){
            if (([dat.selectTable[ct][@"status"] intValue] >= 5) && ([dat.selectTable[ct][@"status"] intValue] != 11)){
                isAiseki = YES;
                dat.currentTable = dat.selectTable[ct];
            }
        }
        if (isAiseki) {
            self.type = TypeOrderAdd;
            LOG(@"注文Bタイプで追加");
            if ([dat tableCheck:self type:TypeOrderAdd]) {
                [self showIndicator];
            }
            return;
        }
        else{
            LOG(@"注文Bタイプで新規");
            self.type = TypeOrderOriginal;
        }
    }


    if ([dat tableCheck:self type:self.type]) {
        [self showIndicator];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (alertView.tag==501) {
                //人数入力設定 0:しない　1:する
                if ([sys.ninzu isEqualToString:@"0"]) {
                    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                }
                else{
                    //2014-11-17 ueda
                    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                        //入力タイプＣの場合
                        [self performSegueWithIdentifier:@"ToTypeCCountView" sender:nil];
                    } else {
                        [self performSegueWithIdentifier:@"ToCountView" sender:nil];
                    }
                }
            }
            else if(alertView.tag==502){
                //2014-12-04 ueda
                //[self reloadDispData];
                [self.navigationController popViewControllerAnimated:YES];
            }
            //2014-12-04 ueda
/*
            else if(alertView.tag==503){
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [parent iba_getMaster:nil];
                [self.navigationController popToViewController:parent animated:YES];
            }
 */
            else if(alertView.tag==504){
                [[OrderManager sharedInstance] zeroReset];
                //2016-02-02 ueda
                [[OrderManager sharedInstance] typeCclearDB];
                //2014-6-25 ueda
                if(self.type == TypeOrderOriginal){
                    //2014-07-07 ueda
                    if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                        //[self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:0] animated:YES];
                        [self.navigationController popToRootViewControllerAnimated:YES];
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                } else {
                    [self.navigationController popViewControllerAnimated:YES];
                }
            }
            else if(alertView.tag==12){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableReadyFinish:self];
            }
            else if(alertView.tag==16){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableTaiki:self];
            }
            else if(alertView.tag==17){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableInShow:self];
            }
            else if(alertView.tag==172){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableInShow2:self];
            }
            else if(alertView.tag==18){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableEmpty:self];
            }
            else if(alertView.tag==19){
                [self showIndicator];
                [[NetWorkManager sharedInstance] getTableKeyID:self];
            }
            //2014-10-29 ueda
            else if (alertView.tag==1101){
                [self orderSendRetry];
            }
            //2014-12-25 ueda
            else if (alertView.tag==1102){
                [self orderSendForce];
            }
            //2015-02-04 ueda
            else if(alertView.tag==311){
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableDeleteCalled:self];
            }
            
            break;
            
        case 1:
            //2014-12-04
/*
            if(alertView.tag==502){
                [self.navigationController popViewControllerAnimated:YES];
            }
 */
            //2014-12-25 ueda
            if (alertView.tag==1102){
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.OrderRequestN31forceFlag = NO;
            }
            break;
    }
}


//TouchView
- (IBAction)iba_nextPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        NSInteger maxHeight  = self.gmGridView.contentSize.height;
        NSInteger pageHeight = self.gmGridView.frame.size.height;
        CGPoint currentPos = self.gmGridView.contentOffset;
        currentPos.y += self.gmGridView.frame.size.height;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.gmGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        NSInteger maxPage = [tableArray count]/TABLECOUNT;
        if ((maxPage*TABLECOUNT)==[tableArray count]) {
            maxPage--;
        }
        
        if (currentPage < maxPage) {
            currentPage ++;
            [self.gmGridView reloadData];
        }
        //2014-08-08 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tableViewCurrentPageNo = currentPage;
    }
}
- (IBAction)iba_prevPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        CGPoint currentPos = self.gmGridView.contentOffset;
        currentPos.y -= self.gmGridView.frame.size.height;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.gmGridView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.gmGridView.frame.size.height) animated:YES];
    } else {
        if (currentPage > 0) {
            currentPage --;
            [self.gmGridView reloadData];
        }
        //2014-08-08 ueda
        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        appDelegate.tableViewCurrentPageNo = currentPage;
    }
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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //2014-07-16 ueda
    [self loadColorCode];
    _fileFg = NO;
    
    //iOS7対応
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];

    sys = [System sharedInstance];
    dat = [DataList sharedInstance];
    
    currentPage = 0;
    //2014-08-08 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    currentPage = appDelegate.tableViewCurrentPageNo;
    
    self.gmGridView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.gmGridView];
    self.gmGridView.style = GMGridViewStyleSwap;
    int spacing = 2;
    self.gmGridView.itemSpacing = spacing;
    self.gmGridView.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.gmGridView.centerGrid = NO;
    self.gmGridView.actionDelegate = self;
    self.gmGridView.pagingEnabled = YES;
    self.gmGridView.dataSource = self;
    self.gmGridView.showsVerticalScrollIndicator = NO;
    self.gmGridView.showsHorizontalScrollIndicator = NO;
    self.gmGridView.clipsToBounds = YES;
    
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.gmGridView.showsVerticalScrollIndicator = YES;
        self.gmGridView.scrollEnabled = YES;
        self.gmGridView.pagingEnabled = NO;
        self.gmGridView.bounces = YES;
        self.gmGridView.alwaysBounceVertical = YES;

        self.gmGridView.pagingEnabled = YES;
        currentPage = 0;

        //2015-04-03 ueda
/*
        self.bt_up.enabled = NO;
        self.bt_down.enabled = NO;
        self.bt_up.hidden = YES;
        self.bt_down.hidden = YES;
 */

        //int orgHgt = self.gmGridView.frame.size.height;
        int wHeight;
        if ([System is568h]) {
            wHeight = (52 * 8) + (spacing * 18);
        } else {
            wHeight = (41 * 8) + (spacing * 18);
        }
        self.gmGridView.frame = CGRectMake(self.gmGridView.frame.origin.x,self.gmGridView.frame.origin.y,self.gmGridView.frame.size.width,wHeight);
    }
    
    [self reloadDispData];
    
    //2015-12-24 ueda ASTERISK
/*
    //取消後の追加で戻った場合の為にviewWillAppearに移動
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2015-12-17 ueda ASTERISK
    if (self.type == TypeOrderCancel) {
        //取消の場合は赤色
        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
    }
 */

    [System adjustStatusBarSpace:self.view];
    
    //2014-12-04 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
        //Ｂタイプ
        if (self.type == TypeOrderOriginal) {
            //2015-04-07 ueda
            if (([sys.ninzu isEqualToString:@"0"]) && !([sys.kakucho2Type isEqualToString:@"0"])) {
                //人数入力しない 2015-04-07 客層入力しない
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
                UIImage *img = [UIImage imageNamed:@"ButtonSend.png"];
                [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
                //2016-02-03 ueda ASTERISK
                [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
        }
    }
    
    //2015-04-08 ueda
    if ([[System sharedInstance].transitionOnOff isEqualToString:@"1"]) {
        // 元ネタ  http://funkit.blog.fc2.com/blog-entry-30.html
        // スワイプジェスチャーを作成する
        [self view].userInteractionEnabled = YES;
        UISwipeGestureRecognizer *swipe
        = [[UISwipeGestureRecognizer alloc]
           initWithTarget:self action:@selector(swipe:)];
        // スワイプの方向は右方向を指定
        swipe.direction = UISwipeGestureRecognizerDirectionRight;
        // スワイプ動作に必要な指は1本と指定
        swipe.numberOfTouchesRequired = 1;
        // スワイプを登録する
        [[self view] addGestureRecognizer:swipe];
    }
    
    //2016-02-03 ueda ASTERISK
    [self.bt_up setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_up setNumberOfLines:0];
    [self.bt_down setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_down setNumberOfLines:0];
}

//2015-04-08 ueda
-(void)swipe:(UISwipeGestureRecognizer *)gesture {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.navigationController popViewControllerAnimated:YES];
    });
}

- (void)reloadDispData{
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    
    [self showIndicator];
    if (self.type!=TypeOrderDirection) {
        [_net getTableStatus:self];
    }
    else{
        [_net getTableStatusDirection:self];
    }
}

- (void)buttonStateChange{
    switch (self.type) {
        case TypeOrderOriginal:
                    
            //入力タイプB時の新規／追加の判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                self.lb_title.text = [String tableNew];
            }
            else{
                self.lb_title.text = [String tableOrder];
            }
            break;
            
        case TypeOrderAdd:
            
            //入力タイプB時の新規／追加の判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                self.lb_title.text = [String tableAdd];
            }
            else{
                self.lb_title.text = [String tableOrder];
            }
            
            break;
            
        case TypeOrderCancel:
            self.lb_title.text = [String tableCancel];
            break;
            
        case TypeOrderCheck:
            self.lb_title.text = [String tableConfirm];
            break;
            
        case TypeOrderDivide:
            self.lb_title.text = [String tableDivide];
            break;
            
        case TypeOrderMove:{
            if (dat.currentVoucher) {
                dat.isMove = YES;
            }
            else{
                dat.isMove = NO;
            }
            
            if (dat.isMove) {
                NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *_str = [NSString stringWithFormat:[String tableMove2],_no];
                //2014-12-09 ueda
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
                self.lb_title.text = _str;
                if ([dat.moveToTable count]>0) {
                    self.bt_next.enabled = YES;
                }
                else{
                    self.bt_next.enabled = NO;
                }
            }
            else{
                self.lb_title.text = [String tableMove1];
                if (editTable) {
                    self.bt_next.enabled = YES;
                    
                }
                else{
                    self.bt_next.enabled = NO;
                }
            }
            break;
        }
            
        case TypeOrderDirection:
            self.lb_title.text = [String tableCook];
            break;
            
        default:
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //2015-04-16 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.type != appDelegate.type) {
        //取消後に追加の入力を行う場合
        //2015-06-30
        if ((self.type == TypeOrderCancel) && (appDelegate.type == TypeOrderAdd)) {
            self.type = appDelegate.type;
        }
    }
    //2015-12-24 ueda ASTERISK
    if (YES) {
        if (self.type == TypeOrderCancel) {
            //取消の場合は赤色
            self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
        } else {
            self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
        }
    }
    
    if ([DataList sharedInstance].typeOrder == TypeOrderCheck) {
        self.type = TypeOrderCheck;
    }
    
    //注文Bタイプの場合の次画面からの遷移時のさいにステータスを新規に戻す
    if ([sys.entryType isEqualToString:@"1"]&&self.type == TypeOrderAdd){
        self.type = TypeOrderOriginal;
    }
    
    [self buttonStateChange];
    [self.gmGridView reloadData];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
    [self setBt_next:nil];
    [self setBt_down:nil];
    [self setBt_up:nil];
    [self setGmGridView:nil];
    [self setBt_return:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LOG(@"%@",[segue identifier]);
    
    if([[segue identifier]isEqualToString:@"ToCountView"]){
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.entryType = EntryTypeTableNot;
    }
    else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherListView"]){
        VouchingListViewController *view_ = (VouchingListViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucherList = (NSMutableArray*)sender;
    }
    else if([[segue identifier]isEqualToString:@"ToOrderConfirmView"]){
        OrderConfirmViewController *view_ = (OrderConfirmViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherDetailView"]){
        VouchingDetailViewController *view_ = (VouchingDetailViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucher = (NSMutableDictionary*)sender;
    }
    else if([[segue identifier]isEqualToString:@"ToExtensionView"]){
        NSMutableDictionary *dic = (NSMutableDictionary*)sender;
        ExtensionViewController *view_ = (ExtensionViewController *)[segue destinationViewController];
        view_.defaultTime = dic[@"time"];
        view_.KeyID = dic[@"KeyID"];
    }
    //2014-10-23 ueda
    if([[segue identifier]isEqualToString:@"ToTypeCCountView"]){
        TypeCCountViewController *view_ = (TypeCCountViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    //2015-04-07 ueda
    else if([[segue identifier]isEqualToString:@"ToCustomerView"]){
        CustomerViewController *view_ = (CustomerViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}


//////////////////////////////////////////////////////////////
#pragma mark self.gmGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    NSInteger count = MIN(TABLECOUNT, [tableArray count]-TABLECOUNT*currentPage);
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        count = [tableArray count];
    } else {
        self.bt_up.enabled = YES;
        self.bt_down.enabled = YES;
        
        NSInteger maxPage = ([tableArray count]-1)/TABLECOUNT;
        if (currentPage >= maxPage) {
            self.bt_up.enabled = NO;
        }
        if(currentPage <= 0){
            self.bt_down.enabled = NO;
        }
    }
    
    [self buttonStateChange];
    
    return count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //2014-10-28 ueda
    //return CGSizeMake(self.gmGridView.frame.size.width/5-3, self.gmGridView.frame.size.height/8-3);
    int wHeight;
    if ([System is568h]) {
        wHeight = 52;
    } else {
        wHeight = 41;
    }
    return CGSizeMake(self.gmGridView.frame.size.width/5-3, wHeight);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [self.gmGridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        //2014-07-16 ueda
        //view.backgroundColor = [UIColor whiteColor];
        view.backgroundColor = [UIColor clearColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2;
        cell.contentView = view;
    }
    
    cell.tag = index+currentPage*TABLECOUNT;
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableDictionary *_id = [tableArray objectAtIndex:cell.tag];
    
    int status = [_id[@"status"] intValue];
    
    NSString *_no = [_id[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //空席商品はステータスがとれないためTableStatusEmptyを代入
    if ([_no length]>0 && status == 0) {
        status = TableStatusEmpty;
        _id[@"status"] = @"1";
    }
    
    //LOG(@"index:%@:%d",_no,status);

    BOOL NUMBURING = YES;
    switch (status) {
        case TableStatusNone:
            NUMBURING = NO;
            [cell.contentView setBackgroundColor:[UIColor clearColor]];
            break;
           
/*
        case TableStatusEmpty:
            [cell.contentView setBackgroundColor:[UIColor whiteColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusReserve:
            [cell.contentView setBackgroundColor:[UIColor greenColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor greenColor] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusInReady:
            [cell.contentView setBackgroundColor:[UIColor yellowColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor yellowColor] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusInShow:
            [cell.contentView setBackgroundColor:[UIColor grayColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor grayColor] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusNormal:
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0] bounds:cell.contentView.bounds]]];
           break;
            
        case TableStatusTimely:
            [cell.contentView setBackgroundColor:BLUE_BNG];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE_BNG bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusControl:
            [cell.contentView setBackgroundColor:[UIColor redColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusNotice:
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.4 blue:0.6 alpha:1.0] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusTimeOver:
            [cell.contentView setBackgroundColor:[UIColor purpleColor]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor purpleColor] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusInShow1:
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.3 blue:0.5 alpha:1.0] bounds:cell.contentView.bounds]]];
            break;
            
        case TableStatusInShow2:
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.8 blue:0.3 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.8 blue:0.3 alpha:1.0] bounds:cell.contentView.bounds]]];
            break;
*/
        default:
            //2014-07-17 ueda
            if (YES) {
                //グラデーション
                CGRect rect = cell.contentView.bounds;
                if (rect.size.height == 0) {
                    if ([System is568h]) {
                        rect.size.width  = 61;
                        rect.size.height = 52;
                    } else {
                        rect.size.width  = 61;
                        rect.size.height = 41;
                    }
                }
                //2015-02-04 ueda
                if (status == TableStatusCall) {
                    //CLL
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.0 blue:0.0 alpha:1.0] bounds:rect]]];
                } else {
                    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[_ColorCode objectForKey:[NSString stringWithFormat:@"%d",status]] bounds:rect]]];
                }
            } else {
                //単色
                [cell.contentView setBackgroundColor:[_ColorCode objectForKey:[NSString stringWithFormat:@"%d",status]]];
            }
            break;
    }
    
    
    if (!dat.isMove) {
        if (editTable == _id && editTable) {
            [cell.contentView setBackgroundColor:BLUE];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:cell.contentView.bounds]]];
        }
        //LOG(@"1:%@\n:%@",dat.selectTable,_id);
        if ([dat.selectTable containsObject:_id]) {
            [cell.contentView setBackgroundColor:BLUE];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:cell.contentView.bounds]]];
        }
    }
    else{
        if ([dat.moveToTable containsObject:_id]) {
            [cell.contentView setBackgroundColor:BLUE];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:cell.contentView.bounds]]];
        }
    }

    if (NUMBURING) {
        UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
        label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        label.text = [NSString stringWithFormat:@"%@",_no];
        //2015-02-04 ueda
        if (status == TableStatusCall) {
            //CLL
            CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
            UILabel *label3;
            if ([System is568h]) {
                label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height * 3 / 4 - 1, size.width, size.height / 4)];
                label3.font = [UIFont boldSystemFontOfSize:13];
            } else {
                label3 = [[UILabel alloc] initWithFrame:CGRectMake(0, size.height * 3 / 4 - 0, size.width, size.height / 4)];
                label3.font = [UIFont boldSystemFontOfSize:11];
            }
            label3.textAlignment = NSTextAlignmentCenter;
            label3.textColor = [UIColor whiteColor];
            label3.backgroundColor = [UIColor clearColor];
            label3.text = @"CALL";
            [cell.contentView addSubview:label3];
            //2015-03-13 ueda
            //iPod Touchではダブルクリックの処理でポップアップが無限ループになるっぽい
/*
            //ラベルブリンク
            [UIView animateWithDuration: 0.5
                                  delay: 0.0
                                options: UIViewAnimationOptionAutoreverse | UIViewAnimationOptionRepeat
                             animations: ^{
                                 label3.alpha = 0;
                             }
                             completion: ^(BOOL finished){
                                 label3.alpha = 0;
                             }
             ];
 */
        }

        label.textAlignment = NSTextAlignmentCenter;
        label.backgroundColor = [UIColor clearColor];
        label.numberOfLines = 3;
        //2014-01-29 ueda
        label.font = [UIFont boldSystemFontOfSize:25];
        label.numberOfLines = 1;
        label.adjustsFontSizeToFitWidth = YES;
        [cell.contentView addSubview:label];
    }

    
    return cell;
}
- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}



#pragma mark self.gmGridViewActionDelegate

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
point:(CGPoint)point
{
    NSLog(@"Did tap at index %zd", position);
    
    editTable = nil;
    
    NSMutableDictionary *_table = [tableArray objectAtIndex:position+TABLECOUNT*currentPage];
    int status = [_table[@"status"]intValue];
    switch (status) {
        case TableStatusNone:
            break;
            
        case TableStatusEmpty:
            if (self.type==TypeOrderOriginal){
                [self addOrRemoveTable:_table];
            }
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            //検索機能が有効で追加の際は、全てのテーブルを選択可能にするためテーブル状況を表示しない
            else if ([sys.searchType isEqualToString:@"0"]&&self.type==TypeOrderAdd) {
                 [self addOrRemoveTable:_table];
            }
            break;
            
        case TableStatusReserve:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            break;
            
        case TableStatusInReady:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            break;
            
        case TableStatusInShow:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            break;
            
        case TableStatusNormal:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusTimely:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusControl:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusNotice:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusTimeOver:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusInShow1:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            //2014-06-02 ueda 「オーダー終了」が選択できない
            else{
                editTable = _table;
            }
            break;
            
        case TableStatusInShow2:
            if (self.type==TypeOrderOriginal){
                /*
                if ([[System sharedInstance].entryType isEqualToString:@"0"]) {
                    [self addOrRemoveTable:_table];
                }
                else{
                    editTable = _table;
                }
                 */
                [self addOrRemoveTable:_table];
            }
            //2015-01-27 ueda
/*
            else{
                editTable = _table;
            }
 */
            //2015-03-03 ueda
            else if (self.type == TypeOrderDirection) {
                //調理指示
                editTable = _table;
            }
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
            break;
            
        case TableStatusCall:
            //2015-02-04 ueda
            //CLL
            // 「case TableStatusEmpty:」部分を丸々コピー
            if (self.type==TypeOrderOriginal){
                [self addOrRemoveTable:_table];
            }
            //2015-11-05 ueda
/*
            else if(self.type==TypeOrderMove){
                if (dat.isMove) {
                    editTable = _table;
                }
            }
 */
            //検索機能が有効で追加の際は、全てのテーブルを選択可能にするためテーブル状況を表示しない
            else if ([sys.searchType isEqualToString:@"0"]&&self.type==TypeOrderAdd) {
                [self addOrRemoveTable:_table];
            }
            //2015-11-05 ueda
            else {
                editTable = _table;
            }
            break;
            
        default:
            break;
    }
    
    if (editTable) {
        //2014-02-03 ueda
        [System tapSound];
        if (self.type==TypeOrderMove) {
            if (dat.isMove) {
                
                if ([dat.moveToTable containsObject:editTable]) {
                    [dat.moveToTable removeObject:editTable];
                }
                else{
                    [dat.moveToTable addObject:editTable];
                }
            }
            else{
                self.lb_title.text = [String tableMove1];
            }
        }
    }
    [self.gmGridView reloadData];
}

- (void)addOrRemoveTable:(NSDictionary*)_table{
    //2014-01-29 ueda
    [System tapSound];
    if ([dat.selectTable containsObject:_table]) {
        [dat.selectTable removeObject:_table];
    }
    else{
        if ([[System sharedInstance].tableMultiSelect isEqualToString:@"1"]) {
            //2015-04-14 ueda
            //単一の場合
            [dat.selectTable removeAllObjects];
        }
        if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
            
            //選択テーブルが稼働中であれば、前選択テーブルを削除する
            //2015-11-02 ueda
            //if ([_table[@"status"] intValue]>3){
            if (([_table[@"status"] intValue] >= 5) && ([_table[@"status"] intValue] != 11)){
                [dat.selectTable removeAllObjects];
            }
            
            //選択テーブルが空席で、前選択テーブルが稼働中であれば削除する
            else{
                if ([dat.selectTable count]>0) {
                    //2015-11-02 ueda
                    //if ([dat.selectTable[0][@"status"] intValue]>3){
                    if (([dat.selectTable[0][@"status"] intValue] >= 5) && ([dat.selectTable[0][@"status"] intValue] != 11)){
                        [dat.selectTable removeAllObjects];
                    }
                }
            }
        }
        [dat.selectTable addObject:_table];
    }
}

- (void)GMGridView:(GMGridView *)gridView didDoubleTapOnItemAtIndex:(NSInteger)position
             point:(CGPoint)point{
    NSLog(@"Did tap at index %zd", position);
    
    if (dat.isMove) {
        return;
    }
    
    //2015-03-03 ueda
    if (self.type == TypeOrderDirection) {
        //調理指示
    } else {
        NSMutableDictionary *_table = [tableArray objectAtIndex:position+TABLECOUNT*currentPage];
        int status = [_table[@"status"]intValue];
        switch (status) {
            case TableStatusNone:
                
                break;
                
            case TableStatusEmpty:{
                //2014-12-18 ueda
                //if (self.type!=TypeOrderAdd&&self.type!=TypeOrderOriginal) {
                if (YES) {
                    [[DataList sharedInstance] setCurrentTable:_table];
                    //2014-01-30 ueda
                    /*
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_table] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                     */
                    //2014-01-30 ueda
                    
                    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
                        //2015-01-26 ueda
                        //デモモード以外の場合
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_table]];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=self;
                        [alert addButtonWithTitle:[String Yes]];
                        [alert addButtonWithTitle:[String No]];
                        alert.cancelButtonIndex=0;
                        alert.tag = 17;
                        [alert show];
                        //2015-01-26 ueda
                        if ([dat.selectTable containsObject:_table]) {
                            [dat.selectTable removeObject:_table];
                        }
                        editTable = nil;
                        //2015-01-26 ueda
                        [self.gmGridView reloadData];
                    }
                }
                break;
            }
            case TableStatusReserve:
                //ダブルタップで予約情報を表示
                [self showIndicator];
                [[DataList sharedInstance] setCurrentTable:_table];
                [[NetWorkManager sharedInstance] getTableReserve:self];
                //2015-01-26 ueda
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                //2015-01-26 ueda
                [self.gmGridView reloadData];
                
                break;
                
            case TableStatusInReady:{
                [[DataList sharedInstance] setCurrentTable:_table];
                //2014-01-30 ueda
                /*
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Kept_already] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                 */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Kept_already]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 12;
                [alert show];
                //2015-01-26 ueda
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                //2015-01-26 ueda
                [self.gmGridView reloadData];
                
                break;
            }
            case TableStatusInShow:{
                //2014-12-18 ueda
                //if (self.type!=TypeOrderAdd&&self.type!=TypeOrderOriginal) {
                if (YES) {
                    [[DataList sharedInstance] setCurrentTable:_table];
                    //2014-01-30 ueda
                    /*
                     UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_table2] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                     */
                    //2014-01-30 ueda
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_table2]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 172;
                    [alert show];
                    //2015-01-26 ueda
                    if ([dat.selectTable containsObject:_table]) {
                        [dat.selectTable removeObject:_table];
                    }
                    editTable = nil;
                    //2015-01-26 ueda
                    [self.gmGridView reloadData];
                }
                
                break;
            }
            case TableStatusNormal:
                break;
                
            case TableStatusTimely:{
                //2015-07-09 ueda
/*
                LOG(@"time");
                
                [[DataList sharedInstance] setCurrentTable:_table];
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Extra_time]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 19;
                [alert show];
                //2015-01-26 ueda
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                //2015-01-26 ueda
                [self.gmGridView reloadData];
*/
                break;
            }
            case TableStatusControl:{
                //ダブルタップで商品情報を表示
                [self showIndicator];
                [[DataList sharedInstance] setCurrentTable:_table];
                [[NetWorkManager sharedInstance] getTableSyohin:self];
                //2015-01-26 ueda
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                //2015-01-26 ueda
                [self.gmGridView reloadData];
                break;
            }
            case TableStatusNotice:
                break;
                
            case TableStatusTimeOver:
                break;
                
            case TableStatusInShow1:
                break;
                
            case TableStatusInShow2:{
                [[DataList sharedInstance] setCurrentTable:_table];
                //2014-01-30 ueda
                /*
                 UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Vacant] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                 */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Vacant]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 18;
                [alert show];
                //2015-01-26 ueda
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                //2015-01-26 ueda
                [self.gmGridView reloadData];
                break;
            }
                
            case TableStatusCall: {
                //2014-02-04 ueda
                //CLL
                [[DataList sharedInstance] setCurrentTable:_table];
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Delete_Called]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 311;
                [alert show];
                if ([dat.selectTable containsObject:_table]) {
                    [dat.selectTable removeObject:_table];
                }
                editTable = nil;
                [self.gmGridView reloadData];
                break;
            }
                
            default:
                break;
        }
    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(NSInteger)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        LOG(@"_dataList:%@",_dataList);
        BOOL isReload = NO;
            switch (type) {
                    
                case RequestTypeOrderRequest:{
                    [[OrderManager sharedInstance] zeroReset];
                    HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                    [self.navigationController popToViewController:parent animated:YES];
                    break;
                }
                case RequestTypeVoucherList:
                    if (self.type==TypeOrderMove) {
                            [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                    }
                    //追加で伝票タイプが詳細の場合は強制的にオーダーエントリー画面に遷移
                    //2014-07-07 ueda
                    else if (([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) &&
                             (([(NSArray*)_dataList count]==1&&[sys.voucherType isEqualToString:@"1"])||[sys.voucherType isEqualToString:@"2"])) {
                        dat.currentVoucher = _dataList[0];
                        dat.manCount = [dat.currentVoucher[@"manCount"]intValue];
                        dat.womanCount = [dat.currentVoucher[@"womanCount"]intValue];
                        //2014-11-17 ueda
                        dat.childCount = [dat.currentVoucher[@"childCount"]intValue];
                        [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                    }
                    else{
                        
                        [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                    }
                    break;
                    
                //2014-09-11 ueda
                case RequestTypeVoucherListTypeC:
                    [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                    break;
                    
                case RequestTypeVoucherTable:
                    if (self.type==TypeOrderMove) {
                        if ([(NSArray*)_dataList count]==1) {
                            dat.currentVoucher = _dataList[0];
                            dat.manCount = [dat.currentVoucher[@"manCount"]intValue];
                            dat.womanCount = [dat.currentVoucher[@"womanCount"]intValue];
                            //2014-11-17 ueda
                            dat.childCount = [dat.currentVoucher[@"childCount"]intValue];
                            
                            dat.isMove = YES;
                            [self.gmGridView reloadData];
                        }
                        else if([(NSArray*)_dataList count]>1){
                            [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                        }
                    }
                    break;
                    
                case RequestTypeVoucherNo:
                    if ([(NSArray*)_dataList count]>0) {
                        
                        LOG(@"%@",_dataList);
                        
                        if (self.type==TypeOrderCheck) {
                            [self performSegueWithIdentifier:@"ToVoucherDetailView" sender:_dataList];
                        }
                    }
                    break;
                    
                case RequestTypeVoucherDetail:{
                    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
                    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                    break;
                }
                
                //2014-09-12 ueda
                case RequestTypeVoucherDetailTypeC:{
                    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
                    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.typeCcancelStartFg = YES;
                    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                    break;
                }
                    
                case RequestTypeTableStatus:{//[N11]
                    LOG(@"RequestTypeTableStatus");
                    if ([(NSArray*)_dataList count]>0) {

                        //検索機能が有効で追加の際は、全てのテーブルを選択可能にするためテーブル状況を表示しない
                        if ([sys.searchType isEqualToString:@"0"]&&self.type==TypeOrderAdd) {
                            LOG(@"%@",tableArray);
                            tableArray = [[NSMutableArray alloc]init];
                            NSArray *origin = (NSArray*)_dataList[0];
                            for (int ct = 0; ct < origin.count; ct++) {
                                NSMutableDictionary *table = [origin objectAtIndex:ct];
                                if ([table[@"status"]intValue]>0) {
                                    table[@"status"] = @"1";
                                }
                                [tableArray addObject:table];
                            }
                        }
                        else{
                            tableArray = [[NSMutableArray alloc]initWithArray:(NSArray*)_dataList[0]];
                        }
                        
                        [self.gmGridView reloadData];
                    }
                    break;
                }
                case RequestTypeTableReadyFinish://[N12]
                    editTable = nil;
                    isReload = YES;
                    break;
                    
                case RequestTypeTableReadyDirection:{//[C12]
                    LOG(@"%@",(NSString*)_dataList);
                    [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                    break;
                }
                case RequestTypeTableMove:{//[N13]
                    dat.isMove = NO;
                    [dat.moveToTable removeAllObjects];
                    //isReload = YES;
                    [self iba_back:nil];
                    break;
                }
                case RequestTypeTableReserve:{//[N14]
                    NSDictionary *_st = (NSDictionary*)_dataList;
                    NSString *_msg = [NSString stringWithFormat:[String Reserve],_st[@"time1"],_st[@"time2"],_st[@"name"],_st[@"count"]];
                    //2014-01-30 ueda
                    /*
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station]
                                                                    message:_msg
                                                                   delegate:nil
                                                          cancelButtonTitle:@"OK"
                                                          otherButtonTitles:nil];
                    */
                    //2014-01-30 ueda
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    alert.delegate=nil;
                    [alert addButtonWithTitle:@"OK"];
                    alert.cancelButtonIndex=0;
                    [alert show];
                    //2014-01-30 ueda
                    //if ([alert subviews].count>2) {
                    //    ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                    //}
                    break;
                }
                case RequestTypeTableSyohin:{//[N15]
                    //商品を表示
                    
                    //2014-02-07 ueda
                    /*
                    NSArray *_array = (NSArray*)_dataList;
                    NSMutableArray *syohins = [[NSMutableArray alloc]init];
                    NSMutableArray *counts = [[NSMutableArray alloc]init];
                    for (int ct = 0; ct<[_array count]; ct++) {
                        NSDictionary *_menu = _array[ct];
                        [syohins addObject:_menu[@"HTDispNM"]];
                        [counts addObject:[NSString stringWithFormat:@" %5d",[_menu[@"count"]intValue]]];
                    }

                    CBAlertTableView *alertTabView = [CBAlertTableView alertTabaleViewWithStringArray:syohins
                                                      stringArray2:counts
                                                                                               titile:[String Served_already]
                                                                                    cancelButtonTitle:nil
                                                                                             delegate:self];
                    [alertTabView show];
                     */

                    NSMutableString *str = [[NSMutableString alloc]init];
                    NSArray *_array = (NSArray*)_dataList;
                    for (int ct = 0; ct<[_array count]; ct++) {
                        NSDictionary *_menu = _array[ct];
                        [str appendString:[_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                        [str appendString:@"\t"];
                        [str appendString:[NSString stringWithFormat:@"(%2d)",[_menu[@"count"]intValue]]];
                        [str appendString:@"\n"];
                    }
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　%@\n　",str,[String Served_already]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    //alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 16;
                    [alert show];

                    break;
                }
                case RequestTypeTableTaiki://[N16]
                    editTable = nil;
                    isReload = YES;
                    break;
                    
                case RequestTypeTableInShow://[N17]
                    editTable = nil;
                    isReload = YES;
                    break;
                    
                case RequestTypeTableInShow2://[N17]その2
                    editTable = nil;
                    isReload = YES;
                    break;
                    
                case RequestTypeTableEmpty:{//[N18]
                    editTable = nil;
                    isReload = YES;
                    break;
                }
                    
                case RequestTypeTableKeyID:{//[N23]
                    editTable = nil;
                    //isReload = YES;
                    [self performSegueWithIdentifier:@"ToExtensionView" sender:_dataList];
                    break;
                }
                    
                case RequestTypeVoucherDirection:{//[C21]
                    editTable = nil;
                    [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:nil];
                    break;
                }
                    
                default:
                    break;
            }
            
        
        if (isReload) {
            [self reloadDispData];
        }
        else{
            if (mbProcess) {
                [mbProcess hide:YES];
            }
        }
    });
}

//提供商品用のデリゲート
- (void)canceled{
    [self showIndicator];
    [[NetWorkManager sharedInstance] sendTableTaiki:self];
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(NSInteger)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //2014-12-04 ueda
/*
        if (type == RequestTypeTableStatus) {
            //2014-10-30 ueda
            if (([_msg rangeOfString:@"マスターダウンロード"].location != NSNotFound) ||
                ([_msg rangeOfString:@"Execute Master download"].location != NSNotFound)){
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                alert.cancelButtonIndex=0;
                alert.tag = 503;
                [alert show];
            }
            else{
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Table_status_did_not]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 502;
                [alert show];
            }
        }
        else if (type == RequestTypeOrderRequest) {
            //2014-10-30 ueda
            if([_msg rangeOfString:[String Out_of_stock_change]].location != NSNotFound){
                //欠品(品切れ)情報
                OrderConfirmViewController *ovc = nil;
                for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
                    UIViewController *vc = self.navigationController.viewControllers[ct];
                    if ([vc isKindOfClass:[OrderConfirmViewController class]]) {
                        ovc = (OrderConfirmViewController*)vc;
                    }
                }
                [self.navigationController popToViewController:ovc animated:NO];
                [ovc.table reloadData];
                
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                if ([alert subviews].count>2) {
                    ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                }
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
                if ([alert subviews].count>2) {
                    ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                }
            }
        }
        else{
            NSRange range = [_msg rangeOfString:@"該当する"];
            if (range.location != NSNotFound) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [[_msg substringFromIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[[_msg substringFromIndex:range.location] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
            else{
                //2014-01-31 ueda
                //Alert([String Order_Station], _msg);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
        }
 */
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        if (type == RequestTypeTableStatus) {
            [alert addButtonWithTitle:@"OK"];
            alert.delegate=self;
            alert.tag = 502;
        }
        else if (type == RequestTypeOrderRequest) {
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
                    OrderConfirmViewController *ovc = nil;
                    for (int ct = 0; ct < [self.navigationController.viewControllers count]; ct++) {
                        UIViewController *vc = self.navigationController.viewControllers[ct];
                        if ([vc isKindOfClass:[OrderConfirmViewController class]]) {
                            ovc = (OrderConfirmViewController*)vc;
                        }
                    }
                    [self.navigationController popToViewController:ovc animated:NO];
                    [ovc.table reloadData];
                    alert.messageLabel.textAlignment = NSTextAlignmentLeft;
                }
            } else {
                [alert addButtonWithTitle:@"OK"];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1101;
            }
        }
        //2015-01-08 ueda
        else {
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
    LOG(@"");
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

//////////////////////////////////////////////////////////////
#pragma mark - UEDA local method
//////////////////////////////////////////////////////////////

- (void)loadColorCode {
    _ColorCode = [[NSMutableDictionary alloc] init];
    for (int i = 1; i <= 20; i++) {
        [_ColorCode setObject:[UIColor whiteColor] forKey:[NSString stringWithFormat:@"%d", i]];
    }
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results = nil;
    results = [_net.db executeQuery:@"SELECT * FROM Color_MT"];
    while( [results next] ){
        NSString *colorID = [results stringForColumn:@"ColorID"];
        NSString *colorCD = nil;
        if ([[results stringForColumn:@"ColorCD"] isEqualToString:@"ffffff"]) {
            colorCD = @"e6e6e6";
        } else {
            colorCD = [results stringForColumn:@"ColorCD"];
        }
        [_ColorCode setObject:[self getUIColorFromHex:colorCD] forKey:colorID];
    }
    [results close];
}

- (UIColor*)getUIColorFromHex:(NSString*)hex{
    return
    [UIColor
     colorWithRed:[self getNumberFromHex:hex rangeFrom:4]/255.0
     green:[self getNumberFromHex:hex rangeFrom:2]/255.0
     blue:[self getNumberFromHex:hex rangeFrom:0]/255.0
     alpha:1.0f];
}

- (unsigned int)getNumberFromHex:(NSString*)hex rangeFrom:(int)from{
    NSString *hexString = [hex substringWithRange:NSMakeRange(from, 2)];
    NSScanner* hexScanner = [NSScanner scannerWithString:hexString];
    unsigned int intColor;
    [hexScanner scanHexInt:&intColor];
    return intColor;
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
    [[NetWorkManager sharedInstance]sendOrderRequest:self  retryFlag:YES];
}

//2014-12-25 ueda
- (void)orderSendForce {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31forceFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}
@end
