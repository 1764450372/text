//
//  VouchingListViewController.m
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "VouchingListViewController.h"
#import "SSGentleAlertView.h"
#import "TypeCCountViewController.h"
//2015-03-24 ueda
#import "PokeRegiYadokakeOnyViewController.h"

@interface VouchingListViewController () {
    BOOL cancelBtCountFg;   //取消時の「人数」ボタンかどうか
}

@end

@implementation VouchingListViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    if (self.type == TypeOrderCheck) {
        [DataList sharedInstance].typeOrder = TypeOrderCheck;
    }
    [self.navigationController popViewControllerAnimated:YES];
    DataList *_data = [DataList sharedInstance];
    _data.currentVoucher = nil;
}

- (IBAction)iba_showNext:(id)sender{
    
    System *sys = [System sharedInstance];
    DataList *data = [DataList sharedInstance];
    
    if (!editVoucher) {
        //Bタイプの追加時以外は、伝票選択がされていないとアラートを表示
        //2014-07-07 ueda
        if (self.type!=TypeOrderAdd &&
            ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"])) {
            //2014-01-31 ueda
            //Alert([String Order_Station],[String Choose_split]);
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Choose_split]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
    }
    else{
        data.currentVoucher = editVoucher;
    }

    UIButton *button = (UIButton*)sender;
    LOG(@"iba_showNext1:%d",self.type);
    switch (self.type) {
        case TypeOrderOriginal:

            break;
            
        case TypeOrderAdd:
            if (button==self.bt_next) {
                
                if (!editVoucher) {
                    return;
                }
                
                data.manCount = [data.currentVoucher[@"manCount"]intValue];
                data.womanCount = [data.currentVoucher[@"womanCount"]intValue];
                //2014-10-23 ueda
                data.childCount = [data.currentVoucher[@"childCount"]intValue];
                
                //2014-07-07 ueda
                if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:button];
                }
                else{
                    [self showIndicator];
                    
                    NetWorkManager *_net = [NetWorkManager sharedInstance];
                    
                    if (editVoucher) {
                        //2014-10-29 ueda
                        [_net sendOrderAdd:self retryFlag:NO];
                    }
                    else{
                        //2014-10-29 ueda
                        [_net sendOrderRequest:self retryFlag:NO];
                    }
                }
            }
            else if (button==self.bt_count){
                //相席設定にて判定 0:確認　1:許可　2:禁止
                if (!editVoucher&&[sys.aiseki isEqualToString:@"0"]) {
                    //2014-01-30 ueda
                    /*
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Split_Table_for_New_Customer] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                    */
                    //2014-01-30 ueda
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                  //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Split_Table_for_New_Customer]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=self;
                    [alert addButtonWithTitle:[String Yes]];
                    [alert addButtonWithTitle:[String No]];
                    alert.cancelButtonIndex=0;
                    alert.tag = 501;
                    [alert show];
                }
                else{
                    data.manCount = [data.currentVoucher[@"manCount"]intValue];
                    data.womanCount = [data.currentVoucher[@"womanCount"]intValue];
                    //2014-11-17 ueda
                    data.childCount = [data.currentVoucher[@"childCount"]intValue];
                    //2014-10-23 ueda
                    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                        //入力タイプＣの場合
                        [self performSegueWithIdentifier:@"ToTypeCCountView" sender:button];
                    } else {
                        [self performSegueWithIdentifier:@"ToCountView" sender:button];
                    }
                }

            }
            break;
            
        case TypeOrderCancel:
            
            //2016-02-16 ueda ASTERISK
            if (YES) {
                if (!editVoucher) {
                    return;
                }
                if (button == self.bt_count) {
                    //人数ボタン
                    cancelBtCountFg = YES;
                } else {
                    //次へボタン
                    cancelBtCountFg = NO;
                }
            }
            [self showIndicator];
            [[OrderManager sharedInstance] zeroReset];
            
            //2014-09-11 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣ
                [[NetWorkManager sharedInstance] getVoucherDetailTypeC:self];
            } else {
                [[NetWorkManager sharedInstance] getVoucherDetail:self];
            }
            break;
            
        case TypeOrderCheck:
            
            [self showIndicator];
            [[OrderManager sharedInstance] zeroReset];
            
            [[NetWorkManager sharedInstance] getVoucherCheck:self];
            break;
            
        case TypeOrderDivide:
            
            [self showIndicator];
            [[OrderManager sharedInstance] zeroReset];
            
            //2014-10-02 ueda 分割はとりあえず通常の機能で行う → 商品単位でまとまっていないと分割できないため
/*
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣ
                [[NetWorkManager sharedInstance] getVoucherDetailTypeC:self];
            } else {
                [[NetWorkManager sharedInstance] getVoucherDetail:self];
            }
 */
            [[NetWorkManager sharedInstance] getVoucherDetail:self];
            break;
            
        case TypeOrderMove:
            [self.navigationController popViewControllerAnimated:YES];
            break;
            
        case TypeOrderDirection:
            [self showIndicator];
            [[OrderManager sharedInstance] zeroReset];
             [[NetWorkManager sharedInstance] getVoucherDirection:self];
    
            break;
            
        default:
            break;
    }
}

- (IBAction)iba_slip:(id)sender{
    if (editVoucher) {
        //2015-03-24 ueda
        if ([self.bt_check.currentTitle isEqualToString:[String bt_checkOut]]) {
            [self showIndicator];
            [DataList sharedInstance].currentVoucher = editVoucher;
            [[NetWorkManager sharedInstance] pokeRegiStart:self retryFlag:NO];
        } else {
            //2014-01-30 ueda
            /*
             UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Reissue_slip2] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
             */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Reissue_slip2]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 2;
            [alert show];
        }
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
    
    isAutoSend = NO;

    [System adjustStatusBarSpace:self.view];
    
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_count setTitle:[String bt_count] forState:UIControlStateNormal];
    //2014-02-18 ueda
    NSInteger resultIntWithOption = [[String bt_print3] rangeOfString:@"\n" options:NSBackwardsSearch].location;
    if (resultIntWithOption == NSNotFound) {
        //見つからなかった
        [self.bt_print setNumberOfLines:1];
    } else {
        [self.bt_print setNumberOfLines:0];
    }
    [self.bt_print setTitle:[String bt_print3] forState:UIControlStateNormal];
    
    switch (self.type) {
        case TypeOrderOriginal:
            break;
            
        case TypeOrderAdd:
            if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
            }
            self.bt_check.hidden = YES;
        
            break;
            
        case TypeOrderCancel:
            //2016-02-16 ueda ASTERISK
/*
            self.bt_count.hidden = YES;
 */
            self.bt_check.hidden = YES;
            break;
            
        case TypeOrderCheck:
        {
            self.bt_count.hidden = YES;
            //2015-03-24 ueda
            NSString *registerType = [System sharedInstance].RegisterType;
            if ((registerType.length == 0) || ([registerType isEqualToString:@"0"])) {
            } else {
                [self.bt_check setTitle:[String bt_checkOut] forState:UIControlStateNormal];
            }
        }
            break;
            
        case TypeOrderDivide:
            self.bt_count.hidden = YES;
            self.bt_check.hidden = YES;
            break;
            
        case TypeOrderMove:
            self.bt_count.hidden = YES;
            self.bt_check.hidden = YES;
            break;
            
        case TypeOrderDirection:
            self.bt_count.hidden = YES;
            self.bt_check.hidden = YES;
            break;
            
        default:
            break;
    }

    //gmGridView = [[GMGridView alloc] initWithFrame:CGRectMake(3, 26, 314, 352)];
    self.gmGridView.backgroundColor = [UIColor clearColor];
    //[self.view addSubview:self.gmGridView];
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
    }
    
    DataList *dat = [DataList sharedInstance];
    NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *_str = [NSString stringWithFormat:[String tableNo],_no];
    self.lb_title.text = _str;
    
    
    //人数入力設定 0:しない　1:する
    System *sys = [System sharedInstance];
    if ([sys.ninzu isEqualToString:@"0"]) {
        self.bt_count.hidden = YES;
    }
    
    if ([self.voucherList count]>0) {
        //2014-07-07 ueda
        if (([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) ||(self.type!=TypeOrderOriginal&&self.type!=TypeOrderAdd)) {
            editVoucher = self.voucherList[0];
        }
        else{
            if ([sys.aiseki isEqualToString:@"2"]) {
                //2014-12-01 ueda 相席禁止の場合でも人数入力可能にするため、伝票を選択できるようにする
/*
                editVoucher = self.voucherList[0];
                
                //相席不可の場合は伝票に追加
                if (self.type==TypeOrderAdd&&[sys.entryType isEqualToString:@"1"]) {
                    isAutoSend = YES;
                }
 */
                editVoucher = nil;
            }
            else{
                editVoucher = nil;
            }
        }
        //2015-04-07 ueda
        if ([sys.entryType isEqualToString:@"1"]) {
            //Bタイプ
            editVoucher = self.voucherList[0];
        }
    }
    else{
        editVoucher = nil;
    }
    
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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    [DataList sharedInstance].divideCount = 1;
    [DataList sharedInstance].dividePage = 0;
    
    //2015-04-10 ueda
/*
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 */
    
    //2016-02-16 ueda ASTERISK
    BOOL reloadVoucherListFg = NO;
    
    //2015-04-16 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (self.type != appDelegate.type) {
        //取消後に追加の入力を行う場合
        //2015-06-30
        if ((self.type == TypeOrderCancel) && (appDelegate.type == TypeOrderAdd)) {
            self.type = appDelegate.type;
            //2016-02-16 ueda ASTERISK
            reloadVoucherListFg = YES;
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
    
    if (self.voucherList.count>0) {
        if (![self.voucherList containsObject:editVoucher]) {
            System *sys = [System sharedInstance];
            //2014-07-07 ueda
            if (([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"])||(self.type!=TypeOrderOriginal&&self.type!=TypeOrderAdd)) {
                editVoucher = self.voucherList[0];
            }
            else{
                //相席設定にて判定 0:確認　1:許可　2:禁止
                if ([sys.aiseki isEqualToString:@"2"]) {
                    editVoucher = self.voucherList[0];
                }
                else{
                    editVoucher = nil;
                }
            }
        }
    }
    //2016-02-16 ueda ASTERISK
    if (reloadVoucherListFg) {
        self.voucherList = nil;
    }
    [self.gmGridView reloadData];
    
    
    if (isAutoSend) {
        [self iba_showNext:self.bt_next];
    }
    //2016-02-16 ueda ASTERISK
    if (reloadVoucherListFg) {
        if ([[DataList sharedInstance] tableCheck:self type:self.type]) {
            [self showIndicator];
        }
    }
}

- (void)setVoucher:(NSDictionary*)dic{
    editVoucher = dic;
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
    [self setBt_check:nil];
    [self setBt_count:nil];
    [self setBt_next:nil];
    [self setGmGridView:nil];
    [self setBt_return:nil];
    [self setBt_print:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    LOG(@"%@",[segue identifier]);
    
    if([[segue identifier]isEqualToString:@"ToCountView"]){
        
        [DataList sharedInstance].currentVoucher = editVoucher;
        
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        //2014-11-18 ueda
        view_.man_count = [editVoucher[@"manCount"]intValue];
        view_.woman_count = [editVoucher[@"womanCount"]intValue];
        view_.child_count = [editVoucher[@"childCount"]intValue];
        view_.entryType = EntryTypeTableNot;
    }
    else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToOrderConfirmView"]){
        OrderConfirmViewController *view_ = (OrderConfirmViewController *)[segue destinationViewController];        
        view_.type = self.type;
        view_.orderList = [NSMutableArray arrayWithArray:(NSArray*)sender];
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherDetailView"]){
        VouchingDetailViewController *view_ = (VouchingDetailViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucher = (NSMutableDictionary*)sender;
    }
    //2014-10-23 ueda
    else if([[segue identifier]isEqualToString:@"ToTypeCCountView"]){
        [DataList sharedInstance].currentVoucher = editVoucher;
        TypeCCountViewController *view_ = (TypeCCountViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}


//////////////////////////////////////////////////////////////
#pragma mark GMGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [self.voucherList count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    LOG(@"sizeForItemsInInterfaceOrientation");
    //return CGSizeMake(self.gmGridView.frame.size.width/2-3, 86);
    int height = (gridView.bounds.size.height-10)/(10/2);
    return CGSizeMake(gridView.frame.size.width/2-3, height);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [gridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [view setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:view.bounds]]];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2;
        cell.contentView = view;
    }
    
    cell.tag = index;
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    LOG(@"Creating view size :%f:%f",cell.bounds.size.width,cell.bounds.size.height);
    
    
    NSDictionary *_voucher = [self.voucherList objectAtIndex:index];
    
    CGRect rect;
    
    //2014-10-23 ueda
    int maxCt;
    //2014-11-17 ueda
/*
    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
        //入力タイプＣの場合
        maxCt = 4;
    } else {
        maxCt = 3;
    }
 */
    //2014-12-12 ueda
    if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
        //入力タイプＣ or 小人入力する
        maxCt = 4;
    } else {
        //小人入力しない
        maxCt = 3;
    }
    //2014-10-24 ueda
    if (self.type == TypeOrderCheck) {
        if ([_voucher[@"manCount"] isEqualToString:@""]) {
            //分割後の画面表示
            maxCt = 1;
        }
    }
    //2014-11-14 ueda
    if (self.type == TypeOrderDirection) {
        //調理指示の伝票選択
        maxCt = 1;
    }
    //2015-09-10 ueda
    if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
        //人数入力しない
        maxCt = 1;
    }
    for (int ct = 0; ct < maxCt; ct++) {
        rect = CGRectMake(0, size.height / maxCt * ct, size.width,size.height / maxCt);
        
        UILabel *textLabel = [[UILabel alloc] initWithFrame:rect];
        //textLabel.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        //2014-02-07 ueda
        textLabel.textAlignment = NSTextAlignmentCenter;
        textLabel.backgroundColor = [UIColor clearColor];
        if (maxCt == 4) {
            textLabel.font = [UIFont systemFontOfSize:18];
        } else {
            textLabel.font = [UIFont systemFontOfSize:25];
        }
        textLabel.adjustsFontSizeToFitWidth=YES;
        [cell.contentView addSubview:textLabel];
        
        switch (ct) {
            case 0:
                textLabel.text = [NSString stringWithFormat:@"%@ : %@",[String slipNo],_voucher[@"EdaNo"]];
                break;
                
            case 1:
                //2014-10-24 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    textLabel.text = [NSString stringWithFormat:@"%@ : %2d",[String manTypeC],[_voucher[@"manCount"]intValue]];
                } else {
                    textLabel.text = [NSString stringWithFormat:@"%@ : %2d",[String man],[_voucher[@"manCount"]intValue]];
                }
                break;
                
            case 2:
                //2014-10-24 ueda
                if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                    //入力タイプＣの場合
                    textLabel.text = [NSString stringWithFormat:@"%@ : %2d",[String womanTypeC],[_voucher[@"womanCount"]intValue]];
                } else {
                    textLabel.text = [NSString stringWithFormat:@"%@ : %2d",[String woman],[_voucher[@"womanCount"]intValue]];
                }
                break;
                
            case 3://2014-10-24 ueda
                textLabel.text = [NSString stringWithFormat:@"%@ : %2d",[String childTypeC],[_voucher[@"childCount"]intValue]];
                break;
                
            default:
                break;
        }
    }
    
    if (editVoucher == _voucher) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:cell.contentView.bounds]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:cell.contentView.bounds]]];
    }
    
    return cell;
}


- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return YES; //index % 2 == 0;
}

//////////////////////////////////////////////////////////////
#pragma mark GMGridViewActionDelegate
//////////////////////////////////////////////////////////////

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
point:(CGPoint)point
{
    NSLog(@"Did tap at index %zd", position);
    //2014-02-18 ueda
    [System tapSound];
    
    NSDictionary *_dic = [self.voucherList objectAtIndex:position];
    if (editVoucher==_dic) {
        //editVoucher = nil;
        [self iba_showNext:self.bt_next];
    }
    else{
        editVoucher = _dic;
    }
    
    
    [self.gmGridView reloadData];
    
    if (self.type == TypeOrderMove) {
        [DataList sharedInstance].isMove = YES;
    }
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}



#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type==RequestTypeOrderRequest) {
            if (_dataList) {
                
                LOG(@"Order success.So,return top view.");
                
                //AlertSelf([String Order_Station], [String Order_send]);
                [[OrderManager sharedInstance] zeroReset];
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
        }
        else if(type==RequestTypeVoucherDetail){
            //2016-02-16 ueda ASTERISK
            if (YES) {
                if ((self.type == TypeOrderCancel) && (cancelBtCountFg)) {
                    //取消時の「人数ボタンの場合」
                    if (mbProcess) {
                        [mbProcess hide:YES];
                    }
                    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                        //入力タイプＣの場合
                        [self performSegueWithIdentifier:@"ToTypeCCountView" sender:nil];
                    } else {
                        [self performSegueWithIdentifier:@"ToCountView" sender:nil];
                    }
                    return;
                }
            }
            if (SYSTEM_VERSION_LESS_THAN(@"7")) {
                [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
            }
            else{
                OrderEntryViewController *controller1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"OrderEntryViewController"];
                controller1.type = self.type;
                [self.navigationController pushViewController:controller1 animated:NO];
            }
        }
        //2014-09-12 ueda
        else if(type==RequestTypeVoucherDetailTypeC){
            if (SYSTEM_VERSION_LESS_THAN(@"7")) {
                [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
            }
            else{
                OrderEntryViewController *controller1 = [[self storyboard] instantiateViewControllerWithIdentifier:@"OrderEntryViewController"];
                controller1.type = self.type;
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.typeCcancelStartFg = YES;
                [self.navigationController pushViewController:controller1 animated:NO];
            }
        }
        else if(type==RequestTypeVoucherDirection){
            [self performSegueWithIdentifier:@"ToOrderConfirmView" sender:_dataList];
        }
        else if(type==RequestTypeVoucherCheck){
            if ([(NSMutableDictionary*)_dataList count]==0) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String not_possible_to_confirm])
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String not_possible_to_confirm]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
            else{
                [self performSegueWithIdentifier:@"ToVoucherDetailView" sender:_dataList];
            }
        }
        else if (type==RequestTypeVoucherPush) {
            //No action
        }
        //2015-03-24 ueda
        else if (type==RequestTypePokeRegiStart) {
            if ([[System sharedInstance].PaymentType intValue] == 1) {
                //0:通常 , 1:宿掛専用
                [self performSegueWithIdentifier:@"ToPokeRegiYadokakeOnlyView" sender:_dataList];
            } else {
                [self performSegueWithIdentifier:@"ToPokeRegiView" sender:_dataList];
            }
        }
        //2016-02-16 ueda ASTERISK
        else if (type==RequestTypeVoucherList) {
            self.voucherList = _dataList;
            for (int ct = 0; ct < [self.voucherList count]; ct++) {
                NSDictionary *_dic = [self.voucherList objectAtIndex:ct];
                if (editVoucher[@"EdaNo"] == _dic[@"EdaNo"]) {
                    editVoucher = _dic;
                    break;
                }
            }
            [self.gmGridView reloadData];
        }

        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{

        //2014-12-04 ueda
/*
        if (type==RequestTypeOrderRequest) {
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            //2014-10-29 ueda
            alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            //2014-10-29 ueda
            alert.delegate=self;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            //2014-10-29 ueda
            alert.tag=1101;
            [alert show];
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
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        if (type==RequestTypeOrderRequest) {
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                //NOP
            } else {
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1101;
            }
        }
        else if (type == RequestTypePokeRegiStart) {
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                //NOP
            } else {
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1201;
            }
        }
        //2016-02-16 ueda ASTERISK
        else if(type==RequestTypeVoucherList){
            alert.delegate=self;
            alert.tag=1301;
        }
        
        [alert show];
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

/////////////////////////////////////////////////////////////////
#pragma mark - alertView Delegate
/////////////////////////////////////////////////////////////////

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if(alertView.tag==0){
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
            else if(alertView.tag==2){
                [self showIndicator];
                DataList *_data = [DataList sharedInstance];
                _data.currentVoucher = editVoucher;
                [[NetWorkManager sharedInstance] sendVoucherPush:self
                                                           edaNo:0
                                                         choice1:0
                                                         choice2:3];
            }
            else if(alertView.tag==501){
                [self performSegueWithIdentifier:@"ToCountView" sender:nil];
            }
            //2014-10-29 ueda
            else if(alertView.tag==1101){
                [self orderSendRetry];
            }
            //2015-03-24 ueda
            else if (alertView.tag==1201) {
                [self pokeRegiStartRetry];
            }
            //2016-02-16 ueda ASTERISK
            else if (alertView.tag==1301) {
                [self iba_back:self.bt_return];
            }
            break;
            
        case 1:
            
            break;
    }
}


/////////////////////////////////////////////////////////////////
#pragma mark - MBProgressHUD Delegate
/////////////////////////////////////////////////////////////////

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
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

//2014-10-29 ueda
- (void)orderSendRetry {
    [self showIndicator];
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    if (editVoucher) {
        [_net sendOrderAdd:self retryFlag:YES];
    }
    else{
        [_net sendOrderRequest:self retryFlag:YES];
    }
}

//2015-03-24 ueda
- (void)pokeRegiStartRetry {
    [self showIndicator];
    [[NetWorkManager sharedInstance] pokeRegiStart:self retryFlag:YES];
}

@end
