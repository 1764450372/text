//
//  CustomerViewController.m
//  Order
//
//  Created by koji kodama on 13/05/13.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "CustomerViewController.h"
#import "CountViewController.h"
#define TABLECOUNT 10
//2014-10-23 ueda
#import "TypeCCountViewController.h"
//2015-08-24 ueda
#import "SSGentleAlertView.h"

@interface CustomerViewController ()

@end

@implementation CustomerViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_showNext:(id)sender{
    //2015-04-07 ueda
    if ([sys.entryType isEqualToString:@"1"]) {
        //Ｂタイプ
        //2015-08-24 ueda
        if (([sys.ninzu isEqualToString:@"0"]) || ([sys.tableType isEqualToString:@"1"])) {
            //人数入力しない or テーブル：コード入力
            [[NetWorkManager sharedInstance]sendOrderRequest:self retryFlag:NO];
        } else {
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
    else if ([sys.tableType isEqualToString:@"0"]) {
        [self performSegueWithIdentifier:@"ToTableView" sender:nil];
    }
    else{
        //2014-10-23 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            [self performSegueWithIdentifier:@"ToTypeCCountView" sender:sender];
        } else {
            [self performSegueWithIdentifier:@"ToCountView" sender:sender];
        }
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
    
    self.lb_title.text = [String Layer];
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    
    sys = [System sharedInstance];
    dat = [DataList sharedInstance];
    
    currentPage = 0;
    
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

        //2015-04-03 ueda
/*
        self.bt_up.enabled = NO;
        self.bt_down.enabled = NO;
        self.bt_up.hidden = YES;
        self.bt_down.hidden = YES;
 */
    }
        
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];

    //2015-04-07 ueda
    if ([sys.entryType isEqualToString:@"1"]) {
        //Ｂタイプ
        //2015-08-24 ueda
        if (([sys.ninzu isEqualToString:@"0"]) || ([sys.tableType isEqualToString:@"1"])) {
            //人数入力しない or テーブル：コード入力
            [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
            UIImage *img = [UIImage imageNamed:@"ButtonSend.png"];
            [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
            //2016-02-03 ueda ASTERISK
            [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        }
    }

    [System adjustStatusBarSpace:self.view];
    //2016-02-03 ueda ASTERISK
    [self.bt_up setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_up setNumberOfLines:0];
    [self.bt_down setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_down setNumberOfLines:0];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];

    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    
    //2014-06-25 ueda
    //2015-12-10 ueda ASTERISK
    //FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Kyakuso_MT ORDER BY KyakusoID"];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Kyakuso_MT ORDER BY DispOrder,KyakusoID"];
    tableArray = [[NSMutableArray alloc]init];
    tableArray[0] = @{@"KyakusoID":@"  ",@"HTDispNM":[String Normal]};
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            //2014-06-25 ueda
            if ([column isEqualToString:@"HTDispNM"]) {
                //客層名のスペースを除去
                [_dic setValue:[[results stringForColumn:column]stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]] forKey:column];
            } else {
                [_dic setValue:[results stringForColumn:column] forKey:column];
            }
        }
        [tableArray addObject:_dic];
    }
    [results close];
    [_net closeDb];
    
    editTable = tableArray[0];
    
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
    if([[segue identifier]isEqualToString:@"ToTableView"]){
        TableViewController *view_ = (TableViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToCountView"]){
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        
        //2015-08-21 ueda
/*
        //2015-04-07 ueda
        //Bタイプの人数入力のみ
        view_.entryType = EntryTypeTableNot;
 */
        if ([sys.entryType isEqualToString:@"1"]) {
            //Bタイプの人数入力のみ
            view_.entryType = EntryTypeTableNot;
        } else {
            if ([sys.ninzu isEqualToString:@"0"]) {
                view_.entryType = EntryTypeTableOnly;
            } else {
                view_.entryType = EntryTypeTableAndNinzu;
            }
        }
    }
    //2014-10-23 ueda
    else if([[segue identifier]isEqualToString:@"ToTypeCCountView"]){
        TypeCCountViewController *view_ = (TypeCCountViewController *)[segue destinationViewController];
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
    
    return count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    //return CGSizeMake(self.gmGridView.frame.size.width/2-3, 86);
    int height = (gridView.bounds.size.height-10)/(10/2);
    return CGSizeMake(gridView.frame.size.width/2-3, height);
}

- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [self.gmGridView dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2;
        cell.contentView = view;
    }
    
    cell.tag = index+currentPage*TABLECOUNT;
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableDictionary *_id = [tableArray objectAtIndex:cell.tag];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = _id[@"HTDispNM"];
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.font = [UIFont boldSystemFontOfSize:20];
    [cell.contentView addSubview:label];
    
    //2014-07-28 ueda
    CGRect rect = cell.contentView.bounds;
    if (rect.size.height == 0) {
        if ([System is568h]) {
            rect.size.width  = 154;
            rect.size.height = 86;
        } else {
            rect.size.width  = 154;
            rect.size.height = 68;
        }
    }
    if (_id==editTable) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
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
    
    editTable = [tableArray objectAtIndex:position+TABLECOUNT*currentPage];
    [self.gmGridView reloadData];
    
    [DataList sharedInstance].currentKyakusoID = editTable[@"KyakusoID"];
    //2014-6-25 ueda
    [System tapSound];
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

//2015-08-24 ueda
//////////////////////////////////////////////////////////////
#pragma mark NetWorkManagerDelegate
//////////////////////////////////////////////////////////////
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        switch (type) {
            case RequestTypeOrderRequest:{
                [[OrderManager sharedInstance] zeroReset];
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
                break;
            }
            default:
                break;
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
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        if (type == RequestTypeOrderRequest) {
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
        else {
            [alert addButtonWithTitle:@"OK"];
        }
        [alert show];
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (mbProcess) {
        [mbProcess hide:YES];
    }
    
    switch (buttonIndex) {
        case 0:
            if(alertView.tag==1101){
                [self orderSendRetry];
            }
            else if (alertView.tag==1102){
                [self orderSendForce];
            }
            
            break;
            
        case 1:
            if (alertView.tag==1102){
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.OrderRequestN31forceFlag = NO;
            }
            
            break;
    }
}

- (void)orderSendRetry {
    [self showIndicator];
    //2014-12-25 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31retryFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    if (!dat.currentVoucher) {
        [_net sendOrderRequest:self retryFlag:YES];
    }
    else{
        [_net sendOrderAdd:self retryFlag:YES];
    }
}

- (void)orderSendForce {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31forceFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
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

@end
