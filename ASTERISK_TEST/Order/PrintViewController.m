//
//  PrintViewController.m
//  Order
//
//  Created by koji kodama on 13/05/15.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "PrintViewController.h"
#import "SSGentleAlertView.h"

#define TABLECOUNT 10

@interface PrintViewController ()

@end

@implementation PrintViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_showNext:(id)sender{
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
    
    //2014-07-28 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.printerNumberOfCheckoutSlip = [editTable intValue];
    
    [[NetWorkManager sharedInstance] sendVoucherPrint:self];
}


//TouchView
- (IBAction)iba_nextPage:(id)sender{
    //2015-06-01 ueda
/*
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
 */
}
- (IBAction)iba_prevPage:(id)sender{
    //2015-06-01 ueda
/*
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
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.bt_next setTitle:[String bt_print1] forState:UIControlStateNormal];
    //2015-06-01 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    //2014-07-28 ueda
    //sys = [System sharedInstance];
    dat = [DataList sharedInstance];
    
    currentPage = 0;
    //editTable = sys.printOut2;
    
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
    
    //2015-06-01 ueda
/*
    //2014-10-28 ueda
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.gmGridView.showsVerticalScrollIndicator = YES;
        self.gmGridView.scrollEnabled = YES;
        self.gmGridView.pagingEnabled = NO;
        self.gmGridView.bounces = YES;
        self.gmGridView.alwaysBounceVertical = YES;
        
    }
 */
    //2015-06-01 ueda
    self.bt_up.hidden = YES;
    self.bt_down.hidden = YES;

    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2015-06-01 ueda
    self.lb_title.text = [String Select_Printer];
    
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

    tableArray = [[NSMutableArray alloc]init];
    for (int ct = 0; ct<[[DataList sharedInstance].printMax intValue]; ct++) {
        [tableArray addObject:[NSString stringWithFormat:@"%d",ct+1]];
    }
    editTable = tableArray[[[DataList sharedInstance].printDefault intValue]-1];
    
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
    /*
     if([[segue identifier]isEqualToString:@"ToCountView"]){
     CountViewController *view_ = (CountViewController *)[segue destinationViewController];
     view_.type = self.type;
     }
     else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
     CountViewController *view_ = (CountViewController *)[segue destinationViewController];
     view_.type = self.type;
     }
     else if([[segue identifier]isEqualToString:@"ToVoucherListView"]){
     VouchingListViewController *view_ = (VouchingListViewController *)[segue destinationViewController];
     view_.type = self.type;
     view_.voucherList = (NSMutableArray*)sender;
     }
     */
}


//////////////////////////////////////////////////////////////
#pragma mark self.gmGridViewDataSource
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    NSInteger count = MIN(TABLECOUNT, [tableArray count]-TABLECOUNT*currentPage);
    
    //2015-06-01 ueda
/*
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
 */

    return count;
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    LOG(@"sizeForItemsInInterfaceOrientation");
    //return CGSizeMake(self.gmGridView.frame.size.width/2-3, 86);
    //2015-06-01 ueda
    //int height = (gridView.bounds.size.height-10)/(10/2);
    int height = (gridView.bounds.size.height-10)/(8/2);
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
    
    NSString *_id = [tableArray objectAtIndex:cell.tag];
    UILabel *label = [[UILabel alloc] initWithFrame:cell.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    label.text = _id;
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [UIColor clearColor];
    label.numberOfLines = 3;
    label.font = [UIFont boldSystemFontOfSize:20];
    //2014-10-28 ueda
    label.font = [UIFont boldSystemFontOfSize:50];
    //2015-06-01 ueda
    label.font = [UIFont boldSystemFontOfSize:60];

    [cell.contentView addSubview:label];
    
    //2014-07-28 ueda
    CGRect rect = cell.contentView.bounds;
    if (rect.size.height == 0) {
        if ([System is568h]) {
            rect.size.width  = 154;
            rect.size.height = 86;
            //2015-06-01 ueda
            rect.size.height = 107;
        } else {
            rect.size.width  = 154;
            rect.size.height = 68;
            //2015-06-01 ueda
            rect.size.height = 86;
        }
    }
    if ([_id isEqualToString:editTable]) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-28 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        //2014-07-28 ueda
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
    
    //2014-07-28 ueda
    //[System sharedInstance].printOut2 = [NSString stringWithFormat:@"%d",position];
    [System tapSound];
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
        [mbProcess hide:YES];
        
        UIViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
        [self.navigationController popToViewController:parent animated:YES];
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

@end
