//
//  ReserveListViewController.m
//  Order
//
//  Created by mac-sper on 2015/06/01.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "ReserveListViewController.h"
#import "TableViewCellReserveList.h"
#import "SSGentleAlertView.h"
#define CellRowHeight 44

@interface ReserveListViewController () <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    NSTimer  *timer1s;
    int defaultHeight;
    int listCount;
    int menuPage;
    MBProgressHUD *mbProcess;
    NSMutableArray *_dataSourceDisp;
    int _sortKbn;
    NSMutableDictionary *_selectTable;
    BOOL isTap;
    NSInteger tapNo;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up;
@property (weak, nonatomic) IBOutlet UILabel *lb_now;
@property (weak, nonatomic) IBOutlet UITableView *reserveTableView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;

- (IBAction)iba_down:(UIButton *)sender;
- (IBAction)iba_up:(UIButton *)sender;
- (IBAction)iba_prevPage:(UIButton *)sender;
- (IBAction)iba_nextPage:(UIButton *)sender;
- (IBAction)iba_return:(UIButton *)sender;
- (IBAction)iba_next:(UIButton *)sender;

@end

@implementation ReserveListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.reserveTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.reserveTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        self.lb_title.text = @" Reserve LIST";
    } else {
        self.lb_title.text = @" 予約一覧";
    }
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    self.bt_prevPage.enabled = NO;
    self.bt_nextPage.enabled = NO;
    
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    [System adjustStatusBarSpace:self.view];
    
    defaultHeight = self.reserveTableView.frame.size.height;
    listCount = defaultHeight / CellRowHeight;

    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.reserveTableView.scrollEnabled = YES;
        self.reserveTableView.showsVerticalScrollIndicator = YES;
        self.reserveTableView.bounces = YES;
        self.reserveTableView.alwaysBounceVertical = YES;
        self.reserveTableView.backgroundColor = [UIColor clearColor];
    } else {
        self.reserveTableView.scrollEnabled = NO;
        self.reserveTableView.showsVerticalScrollIndicator = NO;
        self.reserveTableView.bounces = NO;
        self.reserveTableView.alwaysBounceVertical = NO;
        self.reserveTableView.backgroundColor = [UIColor clearColor];
    }
    self.reserveTableView.tableFooterView = [[UIView alloc] init];
    timer1s = [NSTimer scheduledTimerWithTimeInterval:(1.0)
                                               target:self
                                             selector:@selector(onTimer:)
                                             userInfo:nil
                                              repeats:YES];
    self.lb_now.text = @"";
    self.lb_now.adjustsFontSizeToFitWidth = YES;
    [self onTimer:nil];
    
    menuPage = 0;
    _sortKbn = 0;
    self.bt_next.hidden = YES;
    _selectTable = nil;
    //2016-02-03 ueda ASTERISK
    [self.bt_nextPage setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_nextPage setNumberOfLines:0];
    [self.bt_prevPage setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_prevPage setNumberOfLines:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadReserveList:_sortKbn];
    [self.reserveTableView reloadData];
    if (_selectTable == nil) {
        if ([_dataSourceDisp count] != 0) {
            _selectTable = _dataSourceDisp[0];
        }
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==1) {
        switch (buttonIndex) {
            case 0: {
                NSString *telNo = [NSString stringWithFormat:@"tel:%@",_selectTable[@"ReserveTel"]];
                NSURL* url = [NSURL URLWithString:[telNo stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
                [[UIApplication sharedApplication] openURL:url];
                break;
            }
                
            case 1:
                break;
        }
    }
}

-(void)onTimer:(NSTimer*)timer1s {
    NSDate *now = [NSDate date];
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"us"]];
        formatter.dateFormat = @"M/d/yy(E) H:mm";
    } else {
        [formatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"ja"]];
        formatter.dateFormat = @"yy/M/d(E) H:mm";
    }
    self.lb_now.text = [formatter stringFromDate:now];
}

- (IBAction)iba_down:(UIButton *)sender {
    isTap = NO;
    menuPage = 0;
    _sortKbn = 1;
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadReserveList:_sortKbn];
    [self.reserveTableView scrollRectToVisible:CGRectMake(0, 0, 10, self.reserveTableView.frame.size.height) animated:NO];
    [self.reserveTableView reloadData];
}

- (IBAction)iba_up:(UIButton *)sender {
    isTap = NO;
    menuPage = 0;
    _sortKbn = 0;
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadReserveList:_sortKbn];
    [self.reserveTableView scrollRectToVisible:CGRectMake(0, 0, 10, self.reserveTableView.frame.size.height) animated:NO];
    [self.reserveTableView reloadData];
}

- (IBAction)iba_table:(UIButton *)sender {
}

- (IBAction)iba_reserve:(UIButton *)sender {
}

- (IBAction)iba_prevPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        CGPoint currentPos = self.reserveTableView.contentOffset;
        currentPos.y -= self.reserveTableView.frame.size.height;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.reserveTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.reserveTableView.frame.size.height) animated:YES];
    } else {
        menuPage--;
        [self.reserveTableView reloadData];
    }
}

- (IBAction)iba_nextPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        NSInteger maxHeight  = self.reserveTableView.contentSize.height;
        NSInteger pageHeight = self.reserveTableView.frame.size.height;
        CGPoint currentPos = self.reserveTableView.contentOffset;
        currentPos.y += self.reserveTableView.frame.size.height;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.reserveTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        menuPage++;
        [self.reserveTableView reloadData];
    }
}

- (IBAction)iba_return:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)iba_next:(UIButton *)sender {
}

//////////////////////////////////////////////////////////////
#pragma mark - Order TableView
//////////////////////////////////////////////////////////////


-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSInteger count = 0;
    NSInteger maxPage = 0;
    /*
     count = MIN(listCount, [_dataSourceDisp count] - (listCount * menuPage));
     if ([_dataSourceDisp count] > 0) {
     maxPage = ([_dataSourceDisp count] - 1) / listCount;
     }
     */
    count = MIN(listCount, [_dataSourceDisp count] - (listCount * menuPage));
    if ([_dataSourceDisp count] > 0) {
        maxPage = ([_dataSourceDisp count] - 1) / listCount;
    }
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        count = [_dataSourceDisp count];
        self.bt_nextPage.enabled = YES;
        self.bt_prevPage.enabled = YES;
    } else {
        int height = defaultHeight / listCount;
        self.reserveTableView.frame = CGRectMake(self.reserveTableView.frame.origin.x, self.reserveTableView.frame.origin.y, self.reserveTableView.frame.size.width, MIN(height * count, defaultHeight));
        
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    TableViewCellReserveList *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TableViewCellReserveList alloc] initWithStyle:UITableViewCellStyleValue1
                                               reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSInteger ptr = indexPath.row + (listCount * menuPage);
    NSMutableDictionary *currentData = _dataSourceDisp[ptr];
    cell.labelTime.text    = currentData[@"ReserveTime"];
    cell.labelKokyaku.text = currentData[@"ReserveName"];
    cell.labelTelNo.text   = currentData[@"ReserveTel"];
    cell.labelTable.text   = currentData[@"ReserveTable"];

    CGRect rect = cell.contentView.bounds;
    rect.size.width = 16;
    rect.size.height = CellRowHeight;
    
    if ([currentData[@"ReserveID"]isEqualToString:_selectTable[@"ReserveID"]]) {
        cell.contentView.backgroundColor = BLUE;
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
    }
    
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [System tapSound];
    if ((isTap) && (tapNo == indexPath.row + 1)) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String TellCall]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 1;
        [alert show];
    } else {
        isTap = YES;
        tapNo = indexPath.row + 1;
        [self performSelector:@selector(tapIsDisabaled) withObject:nil afterDelay:0.3f];
        
        NSInteger ptr = indexPath.row + (listCount * menuPage);
        _selectTable = [_dataSourceDisp objectAtIndex:ptr];
        [self.reserveTableView reloadData];
    }
}

- (void)tapIsDisabaled{
    isTap = NO;
    tapNo = 0;
}

/////////////////////////////////////////////////////////////////
#pragma mark - NetWorkManager Delegate
/////////////////////////////////////////////////////////////////

-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(NSInteger)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        switch (type) {
                
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
                         type:(NSInteger)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        alert.cancelButtonIndex=0;
        [alert addButtonWithTitle:@"OK"];
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
