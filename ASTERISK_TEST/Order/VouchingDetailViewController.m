//
//  VouchingDetailViewController.m
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "VouchingDetailViewController.h"
//2014-02-07 ueda
#define kMenuCount 10
#import "SSGentleAlertView.h"
//2016-01-05 ueda ASTERISK
#import "CountViewController.h"

@interface VouchingDetailViewController ()

@end

@implementation VouchingDetailViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    
    //伝票タイプが詳細の場合は強制的にテーブル画面に遷移
    /*
    if ([[System sharedInstance].voucherType isEqualToString:@"1"]) {
        if (self.type==TypeOrderCheck) {
            UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:1];
            [self.navigationController popToViewController:parent animated:YES];
            return;
        }
    }
     */
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_showNext:(id)sender{
    UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
    [self.navigationController popToViewController:parent animated:YES];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==0) {
        switch (buttonIndex) {
            case 0:
                if (alertView.tag==0){
                    UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                    [self.navigationController popToViewController:parent animated:YES];
                }
                break;
            case 1:
                break;
        }
    }
    else if (alertView.tag==1){
        select1 = buttonIndex;
        //2016-02-02 ueda
        switch (buttonIndex) {
            case 0:
                select1 = 1;
                break;
            case 1:
                select1 = 0;
                break;
            default:
                break;
        }
        
        if (buttonIndex==0||buttonIndex==1) {
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:[String ALL],[String CHOICE],[String Cancel_slip], nil];
            */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=@" ";
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String ALL]];
            [alert addButtonWithTitle:[String CHOICE]];
            [alert addButtonWithTitle:[String Cancel_slip]];
            alert.cancelButtonIndex=0;
            alert.tag = 2;
            [alert show];
        }
    }
    else if (alertView.tag==2){
        select2 = buttonIndex;
        
        if (buttonIndex==0) {
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
            //2016-02-02 ueda
/*
            [[NetWorkManager sharedInstance] sendVoucherPush:self
                                                       edaNo:currentNo
                                                     choice1:select1
                                                     choice2:select2];
 */
            //2016-02-02 ueda
            [[NetWorkManager sharedInstance] sendVoucherPush:self
                                                       edaNo:currentEdaNo
                                                     choice1:select1
                                                     choice2:select2];
        }
        else if (buttonIndex==1) {
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:@"" delegate:self cancelButtonTitle:nil otherButtonTitles:[String CHECK_OUT],[String TICKET],[String Cancel_slip], nil];
            */
            //2014-02-03 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=@" ";
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String CHECK_OUT]];
            [alert addButtonWithTitle:[String TICKET]];
            [alert addButtonWithTitle:[String Cancel_slip]];
            alert.cancelButtonIndex=0;
            alert.tag = 3;
            [alert show];
        }
    }
    else if (alertView.tag==3){
        select2 = buttonIndex+1;
        
        if (buttonIndex==0||buttonIndex==1) {
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
            
            //2016-02-02 ueda
/*
            [[NetWorkManager sharedInstance] sendVoucherPush:self
                                                       edaNo:currentNo
                                                     choice1:select1
                                                     choice2:select2];
 */
            //2016-02-02 ueda
            [[NetWorkManager sharedInstance] sendVoucherPush:self
                                                       edaNo:currentEdaNo
                                                     choice1:select1
                                                     choice2:select2];
        }
    }
}


- (IBAction)iba_prev:(id)sender{
    if (currentNo>0) {
        currentNo--;
        currentPage = 0;
        //2016-02-02 ueda
/*
        //2015-09-11 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
 */
        [self reloadDisp];
        //2016-02-02 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
    }
}

- (IBAction)iba_next:(id)sender{
    NSInteger max = [self.voucher count];
    if (currentNo<max) {
        currentNo++;
        currentPage = 0;
        //2016-02-02 ueda
/*
        //2015-09-11 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
 */
        [self reloadDisp];
        //2016-02-02 ueda
        if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
            [self.tableView setContentOffset:CGPointZero animated:YES];
        }
    }
}

- (IBAction)iba_nextPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        NSInteger maxHeight  = self.tableView.contentSize.height;
        NSInteger pageHeight = self.tableView.frame.size.height;
        CGPoint currentPos = self.tableView.contentOffset;
        currentPos.y += self.tableView.frame.size.height;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.tableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        LOG(@"%zd:%zd:%zd",currentPage,[subList count],kMenuCount);
        if (currentPage<=([subList count]-1)/kMenuCount) {
            currentPage++;
            [self reloadDisp];
        }
    }
}

- (IBAction)iba_prevPage:(id)sender{
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        //2015-04-03 ueda
        CGPoint currentPos = self.tableView.contentOffset;
        currentPos.y -= self.tableView.frame.size.height;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.tableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.tableView.frame.size.height) animated:YES];
    } else {
        if (currentPage>0) {
            currentPage--;
            [self reloadDisp];
        }
    }
}

- (IBAction)iba_print:(id)sender{

    if ([[System sharedInstance].printOut1 isEqualToString:@"0"]) {
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
        
        [[NetWorkManager sharedInstance] sendVoucherPrint:self];
    }
    else{
        [self performSegueWithIdentifier:@"ToPrintView" sender:nil];
    }
}

- (IBAction)iba_push:(id)sender;{
    
    //2014-02-17 ueda
    //NSString *only = [NSString stringWithFormat:@"%@ %@",self.lb_voucherNo.text,[String ONLY]];
    NSString *only = [NSString stringWithFormat:@"%@ %@",[self.lb_voucherNo.text stringByReplacingOccurrencesOfString:@"\n" withString:@""],[String ONLY]];
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Reissue_slip] delegate:self cancelButtonTitle:nil otherButtonTitles:only,[String ALL],[String Cancel_slip], nil];
    */
	//2014-02-03 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Reissue_slip]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:only];
    [alert addButtonWithTitle:[String ALL]];
    [alert addButtonWithTitle:[String Cancel_slip]];
    alert.cancelButtonIndex=0;
    alert.tag = 1;
    [alert show];
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
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([System is568h]) {
        defaultHeight = 380;
    }
    else{
        defaultHeight = 292;
    }
    
    [System adjustStatusBarSpace:self.view];
    
    //2014-02-18 ueda
    NSInteger resultIntWithOption = [[String bt_print2] rangeOfString:@"\n" options:NSBackwardsSearch].location;
    if (resultIntWithOption == NSNotFound) {
        //見つからなかった
        [self.bt_print setNumberOfLines:1];
    } else {
        [self.bt_print setNumberOfLines:0];
    }
    [self.bt_print setTitle:[String bt_print2] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_done setTitle:[String bt_finish] forState:UIControlStateNormal];
    
    //2014-09-19 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_done setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.tableView.scrollEnabled = YES;
        self.tableView.showsVerticalScrollIndicator = YES;
        self.tableView.bounces = YES;
        self.tableView.alwaysBounceVertical = YES;
        self.tableView.backgroundColor = [UIColor clearColor];
        //2015-04-30 ueda
        //self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        self.tableView.tableFooterView = [[UIView alloc] init];
        
        //2015-04-03 ueda
/*
        self.bt_up.enabled = NO;
        self.bt_down.enabled = NO;
        self.bt_up.hidden = YES;
        self.bt_down.hidden = YES;
 */
    }
    
    [self reloadDisp];
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2014-08-05 ueda
    if ([[System sharedInstance].searchType isEqualToString:@"0"]) {
        //「検索キー」を使用する場合は「チェック伝票」ボタンを隠す
        self.bt_print.hidden = YES;
    }
    //2016-01-05 ueda ASTERISK
    if (YES) {
        self.bt_down.hidden = YES;
        self.bt_up.hidden   = YES;
    }
}

- (void)reloadDisp{
    LOG(@"1:%@",self.voucher);

    
    if ([self.voucher.allKeys containsObject:@"header"]) {
        
        NSString *priceStr = self.voucher[@"header"];
        self.lb_total.text = [DataList appendComma:priceStr];
        [self.voucher removeObjectForKey:@"header"];
    }
    
    self.lb_tab.text = [String Total];
    
    DataList *dat = [DataList sharedInstance];
    
    NSInteger index = self.voucher.allKeys.count - 1 + currentNo*-1;
    LOG(@"index:%zd",index);

    NSArray *sorted_array = [self.voucher.allKeys sortedArrayUsingComparator:^NSComparisonResult(NSNumber *a, NSNumber *b) {
        return a.intValue - b.intValue; // ソート
    }];
    
    LOG(@"sorted_array:%@",sorted_array);
    
    NSString *edaNo = sorted_array[index];
    LOG(@"%@",edaNo);
    subList = self.voucher[edaNo];
    LOG(@"%@",subList);
    //2014-02-07 ueda
    self.lb_voucherNo.numberOfLines = 2;
    self.lb_voucherNo.adjustsFontSizeToFitWidth = YES;
    self.lb_voucherNo.text = [NSString stringWithFormat:@"%@%@-  %02d",dat.currentVoucher[@"EdaNo"],@"\n",[edaNo intValue]];
    //self.lb_voucherNo.text = [NSString stringWithFormat:@"%@-  %02d",dat.currentVoucher[@"EdaNo"],[edaNo intValue]];
    /*
    if ([System is568h]) {
        self.lb_voucherNo.font = [UIFont systemFontOfSize:27];
    } else {
        self.lb_voucherNo.font = [UIFont systemFontOfSize:26];
    }
     */

    //2016-02-02 ueda
    currentEdaNo = [edaNo integerValue];

    [self.tableView reloadData];
    
    
    self.bt_left.enabled = NO;
    self.bt_right.enabled = NO;
    if (currentNo>0) {
        self.bt_left.enabled = YES;
    }
    NSInteger max = [self.voucher count]-1;
    if (currentNo<max) {
        self.bt_right.enabled = YES;
    }
    
    self.bt_down.enabled = NO;
    self.bt_up.enabled = NO;
    if (currentPage>0) {
        self.bt_down.enabled = YES;
    }
    if (currentPage<([subList count]-1)/kMenuCount) {
        self.bt_up.enabled = YES;
    }
    
    //2015-04-03 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.bt_up.enabled   = YES;
        self.bt_down.enabled = YES;
    }
    
    NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //2014-11-17 ueda
/*
    //2014-10-23 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
        //入力タイプＣの場合
        NSString *_str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],[dat.currentVoucher[@"womanCount"]intValue],[dat.currentVoucher[@"childCount"]intValue]];
        self.lb_title.text = _str;
    } else {
        //2014-09-22 ueda
        if ([[System sharedInstance].lang isEqualToString:@"1"]) {
            //英語
            NSString *_str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],[dat.currentVoucher[@"womanCount"]intValue]];
            self.lb_title.text = _str;
        } else {
            //日本語
            NSString *_str = [NSString stringWithFormat:@"　%@%@　M%d F%d",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],[dat.currentVoucher[@"womanCount"]intValue]];
            self.lb_title.text = _str;
        }
    }
 */
    NSString *_str;
    //2014-11-18 ueda
    if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
        _str = [NSString stringWithFormat:@"　%@%@",[String Str_t],_no];
    } else {
        //2014-12-12 ueda
        if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //入力タイプＣ or 小人入力する
            _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],[dat.currentVoucher[@"womanCount"]intValue],[dat.currentVoucher[@"childCount"]intValue]];
        } else {
            //小人入力しない
            //2015-12-02 ueda ASTERISK_TEST
            //_str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],[dat.currentVoucher[@"womanCount"]intValue]];
            //なぜかiOSシミュレータで女人数が不正なので資料作りのため変更（実機ではOK）
            NSInteger womanCount = [dat.currentVoucher[@"womanCount"]intValue];
            _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd ",[String Str_t],_no,[dat.currentVoucher[@"manCount"]intValue],womanCount];
        }
    }
    self.lb_title.text = _str;
    
    LOG(@"page:%zd",currentPage);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
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
    [self setBt_left:nil];
    [self setBt_right:nil];
    [self setLb_voucherNo:nil];
    [self setLb_total:nil];
    [self setTableView:nil];
    [self setBt_up:nil];
    [self setBt_down:nil];
    [self setBt_print:nil];
    [self setBt_return:nil];
    [self setBt_done:nil];
    [self setLb_tab:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*
     if([[segue identifier]isEqualToString:@"VtoD"]){
     NSDictionary *_dic = (NSDictionary*)sender;
     DetailViewController *view_ = (DetailViewController *)[segue destinationViewController];
     NSString *aImagePath = [[NSBundle mainBundle] pathForResource:[_dic valueForKey:@"thumbnail"] ofType:@"jpg"];
     UIImage *image = [[UIImage alloc]initWithContentsOfFile:aImagePath];
     view_.image = image;
     [image release];
     }
     */
    
    //2016-01-05 ueda ASTERISK
    if([[segue identifier]isEqualToString:@"ToCountView"]){
        DataList *data = [DataList sharedInstance];
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.man_count = [data.currentVoucher[@"manCount"]intValue];
        view_.woman_count = [data.currentVoucher[@"womanCount"]intValue];
        view_.child_count = [data.currentVoucher[@"childCount"]intValue];
        view_.entryType = EntryTypeTableNot;
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger count = MAX([subList count]-currentPage*kMenuCount,0);
    
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        count = [subList count];
    } else {
        //2014-02-07 ueda
        NSInteger height = defaultHeight/kMenuCount;
        self.tableView.frame = CGRectMake(self.tableView.frame.origin.x, self.tableView.frame.origin.y, self.tableView.frame.size.width, MIN(height*count, defaultHeight));
    }
    
    return count;
}

//2014-09-22 ueda float -> CGFloat for 64 bit
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    //return 54.0f;
    //2014-02-07 ueda
    return defaultHeight/kMenuCount;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    NSDictionary *_menu = [subList objectAtIndex:indexPath.row+currentPage*kMenuCount];
    
    LOG(@"_menu:%@",_menu);
    
    [cell.contentView setBackgroundColor:[UIColor whiteColor]];
    //2014-07-11 ueda
    [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:cell.contentView.bounds]]];
    
     NSMutableString *text = [[NSMutableString alloc]init];
    if([_menu[@"layer"]isEqualToString:@"0"]){
         
        //2016-02-23 ueda ASTERISK
/*
        if ([_menu[@"PatternCD"]isEqualToString:@"9"]) {
 */
        //2016-02-23 ueda ASTERISK
        if (([_menu[@"type"]isEqualToString:@"4"]) || ([_menu[@"type"]isEqualToString:@"5"])) {
            //2016-02-23 ueda ASTERISK
/*
            [text appendString:@"["];
 */
            //2016-02-23 ueda ASTERISK
            [text appendString:@"  TP "];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0] bounds:cell.contentView.bounds]]];
        }
        else{
            [text appendString:@"■"];
        }
    }
    else {
        if ([[_menu allKeys]containsObject:@"MstOfferCD"]||[[_menu allKeys]containsObject:@"MstCommentCD"]) {
            [text appendString:@"    ("];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:0.7 green:0.7 blue:1.0 alpha:1.0] bounds:cell.contentView.bounds]]];
        }
        //2016-02-23 ueda ASTERISK
/*
        else if ([_menu[@"PatternCD"]isEqualToString:@"9"]) {
 */
        //2016-02-23 ueda ASTERISK
        else if (([_menu[@"type"]isEqualToString:@"4"]) || ([_menu[@"type"]isEqualToString:@"5"])) {
            //2016-02-23 ueda ASTERISK
/*
            [text appendString:@"    ["];
 */
            //2016-02-23 ueda ASTERISK
            [text appendString:@"    TP "];
            [cell.contentView setBackgroundColor:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0]];
            //2014-07-11 ueda
            [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0 green:0.7 blue:0.7 alpha:1.0] bounds:cell.contentView.bounds]]];
        }
        else{
            [text appendString:@" >>"];
        }
    }
    
    
    NSString *HTDispNMU = [_menu[@"HTDispNMU"] stringByTrimmingCharactersInSet:
          [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *HTDispNMM = [_menu[@"HTDispNMM"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *HTDispNML = [_menu[@"HTDispNML"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    [text appendString:[NSString stringWithFormat:@"%@%@%@",HTDispNMU,HTDispNMM,HTDispNML]];
    
    
    if ([[_menu allKeys]containsObject:@"MstOfferCD"]||[[_menu allKeys]containsObject:@"MstCommentCD"]) {
        [text appendString:@")"];
    }
    //2016-02-23 ueda ASTERISK
/*
    else if ([_menu[@"PatternCD"]isEqualToString:@"9"]) {
        [text appendString:@"]"];
    }
 */
    
    
     cell.textLabel.text = text;
     cell.detailTextLabel.text = _menu[@"count"];
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mbProcess hide:YES];
        
        if (type==RequestTypeVoucherPush) {
            //No action
        }
        else{
            UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
            [self.navigationController popToViewController:parent animated:YES];
        }
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
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

//2016-01-05 ueda ASTERISK
- (IBAction)iba_ninzu:(id)sender {
    [self performSegueWithIdentifier:@"ToCountView" sender:sender];
}
@end
