//
//  OrderStatusViewController.m
//  Order
//
//  Created by mac-sper on 2015/06/01.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "OrderStatusViewController.h"
#import "TableViewCellOrderStatus.h"
#import "TableViewController.h"
#import "SSGentleAlertView.h"
#import "VouchingDetailViewController.h"
#define CellRowHeight 44

@interface OrderStatusViewController () <UITableViewDelegate, UITableViewDataSource, MBProgressHUDDelegate> {
    int defaultHeight;
    int listCount;
    int menuPage;
    MBProgressHUD *mbProcess;
    NSMutableArray *_dataSourceDisp;
    int _sortKbn;
    NSDate *_baseDate;
    NSMutableDictionary *_selectTable;
    BOOL isTap;
    NSInteger tapNo;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_table;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_reserve;
@property (weak, nonatomic) IBOutlet UITableView *orderTableView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextPage;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;

- (IBAction)iba_down:(UIButton *)sender;
- (IBAction)iba_up:(UIButton *)sender;
- (IBAction)iba_table:(UIButton *)sender;
- (IBAction)iba_reserve:(UIButton *)sender;
- (IBAction)iba_prevPage:(UIButton *)sender;
- (IBAction)iba_nextPage:(UIButton *)sender;
- (IBAction)iba_return:(UIButton *)sender;
- (IBAction)iba_next:(UIButton *)sender;

@end

@implementation OrderStatusViewController

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

- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.orderTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.orderTableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        self.lb_title.text = @" Order STATUS";
        [self.bt_table setTitle:@"Table" forState:UIControlStateNormal];
        [self.bt_reserve setTitle:@"Rserve LIST" forState:UIControlStateNormal];
    } else {
        self.lb_title.text = @" オーダー状況";
        [self.bt_table setTitle:@"テーブル" forState:UIControlStateNormal];
        [self.bt_reserve setTitle:@"予約一覧" forState:UIControlStateNormal];
    }
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    self.bt_prevPage.enabled = NO;
    self.bt_nextPage.enabled = NO;

    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];

    [System adjustStatusBarSpace:self.view];
    
    defaultHeight = self.orderTableView.frame.size.height;
    listCount = defaultHeight / CellRowHeight;

    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        self.orderTableView.scrollEnabled = YES;
        self.orderTableView.showsVerticalScrollIndicator = YES;
        self.orderTableView.bounces = YES;
        self.orderTableView.alwaysBounceVertical = YES;
        self.orderTableView.backgroundColor = [UIColor clearColor];
    } else {
        self.orderTableView.scrollEnabled = NO;
        self.orderTableView.showsVerticalScrollIndicator = NO;
        self.orderTableView.bounces = NO;
        self.orderTableView.alwaysBounceVertical = NO;
        self.orderTableView.backgroundColor = [UIColor clearColor];
    }
    self.orderTableView.tableFooterView = [[UIView alloc] init];
    
    menuPage = 0;
    _sortKbn = 1;
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _selectTable = nil;
    //2016-02-03 ueda ASTERISK
    [self.bt_nextPage setTitle:[String bt_nextPage] forState:UIControlStateNormal];
    [self.bt_nextPage setNumberOfLines:0];
    [self.bt_prevPage setTitle:[String bt_prevPage] forState:UIControlStateNormal];
    [self.bt_prevPage setNumberOfLines:0];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    _baseDate = [NSDate date];
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadOrderStatus:_sortKbn];
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
    switch (buttonIndex) {
        case 0:
            break;
            
        case 1:
            break;
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"ToTableView"]){
        TableViewController *view_ = (TableViewController *)[segue destinationViewController];
        view_.type = TypeOrderCheck;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherDetailView"]){
        VouchingDetailViewController *view_ = (VouchingDetailViewController *)[segue destinationViewController];
        view_.type = TypeOrderCheck;
        view_.voucher = (NSMutableDictionary*)sender;
    }
}

- (IBAction)iba_down:(UIButton *)sender {
    isTap = NO;
    menuPage = 0;
    _sortKbn = 1;
    _baseDate = [NSDate date];
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadOrderStatus:_sortKbn];
    [self.orderTableView scrollRectToVisible:CGRectMake(0, 0, 10, self.orderTableView.frame.size.height) animated:NO];
    [self.orderTableView reloadData];
}

- (IBAction)iba_up:(UIButton *)sender {
    isTap = NO;
    menuPage = 0;
    _sortKbn = 0;
    _baseDate = [NSDate date];
    _dataSourceDisp = [[NSMutableArray alloc] init];
    _dataSourceDisp = [[OrderManager sharedInstance] loadOrderStatus:_sortKbn];
    [self.orderTableView scrollRectToVisible:CGRectMake(0, 0, 10, self.orderTableView.frame.size.height) animated:NO];
    [self.orderTableView reloadData];
}

- (IBAction)iba_table:(UIButton *)sender {
    [self performSegueWithIdentifier:@"ToTableView" sender:sender];
}

- (IBAction)iba_reserve:(UIButton *)sender {
    [self showIndicator];
    [[NetWorkManager sharedInstance] getReserveList:self count:1];
}

- (IBAction)iba_prevPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        CGPoint currentPos = self.orderTableView.contentOffset;
        currentPos.y -= self.orderTableView.frame.size.height;
        if (currentPos.y < 0) {
            currentPos.y = 0;
        }
        [self.orderTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, self.orderTableView.frame.size.height) animated:YES];
    } else {
        menuPage--;
        [self.orderTableView reloadData];
    }
}

- (IBAction)iba_nextPage:(UIButton *)sender {
    if ([[System sharedInstance].scrollOnOff isEqualToString:@"1"]) {
        NSInteger maxHeight  = self.orderTableView.contentSize.height;
        NSInteger pageHeight = self.orderTableView.frame.size.height;
        CGPoint currentPos = self.orderTableView.contentOffset;
        currentPos.y += self.orderTableView.frame.size.height;
        if (currentPos.y >= (maxHeight - 10)) {
            currentPos.y = maxHeight - pageHeight;
        }
        [self.orderTableView scrollRectToVisible:CGRectMake(0, currentPos.y, 10, pageHeight) animated:YES];
    } else {
        menuPage++;
        [self.orderTableView reloadData];
    }
}

- (IBAction)iba_return:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:NO];
}

- (IBAction)iba_next:(UIButton *)sender {
    if (_selectTable == nil) {
    } else {
        [DataList sharedInstance].currentVoucher = @{@"EdaNo": [_selectTable[@"DenpyoNo"] substringToIndex:4]};
        [DataList sharedInstance].currentTable = [[NSMutableDictionary alloc]initWithDictionary:@{@"TableNo": _selectTable[@"TableName"]}];
        [self showIndicator];
        [[NetWorkManager sharedInstance] getVoucherCheck:self];
    }
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
        self.orderTableView.frame = CGRectMake(self.orderTableView.frame.origin.x, self.orderTableView.frame.origin.y, self.orderTableView.frame.size.width, MIN(height * count, defaultHeight));
        
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
    TableViewCellOrderStatus *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[TableViewCellOrderStatus alloc] initWithStyle:UITableViewCellStyleValue1
                                                     reuseIdentifier:CellIdentifier];
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;

    NSInteger ptr = indexPath.row + (listCount * menuPage);
    NSMutableDictionary *currentData = _dataSourceDisp[ptr];
    cell.labelDenpyo.text  = currentData[@"DenpyoNo"];
    cell.labelTable.text   = currentData[@"TableName"];
    cell.labelTotal.text   = currentData[@"Kingaku"];
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        //Yen
        NSNumber *number = [NSNumber numberWithInteger:[currentData[@"Kingaku"] integerValue]];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@",###"];
        cell.labelTotal.text = [NSString stringWithFormat:@"%@%@", @"¥",[formatter stringForObjectValue:number]];

    } else {
        //Dollar
        cell.labelTotal.text = [NSString stringWithFormat:@"%@%.2f", @"$",[currentData[@"Kingaku"] integerValue] / 100.0f];
    }
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setDateFormat:@"yyyy/MM/dd HH:mm:ss"];
    NSDate *lastDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@", currentData[@"LastDate"]]];
    //NSDate *lastDate = [dateFormatter dateFromString:currentData[@"LastDate"]];
    float pastSecond =[_baseDate timeIntervalSinceDate:lastDate];
    NSInteger min = (int)(pastSecond / 60);
    if (min > 999) {
        cell.labelTime.text = @"***";
    } else {
        cell.labelTime.text = [NSString stringWithFormat:@"%zd",min];
    }
    if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
        //入力タイプＣ or 小人入力する
        cell.labelNinzu.text = [NSString stringWithFormat:@"M%@ F%@ C%@",currentData[@"ManCount"],currentData[@"WomanCount"],currentData[@"ChildCount"]];
    } else {
        //小人入力しない
        cell.labelNinzu.text = [NSString stringWithFormat:@"M%@ F%@",    currentData[@"ManCount"],currentData[@"WomanCount"]];
    }

    CGRect rect = cell.contentView.bounds;
    rect.size.width = 16;
    rect.size.height = CellRowHeight;

    if ([currentData[@"DenpyoNo"]isEqualToString:_selectTable[@"DenpyoNo"]]) {
        cell.contentView.backgroundColor = BLUE;
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    } else {
        cell.contentView.backgroundColor = [UIColor whiteColor];
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
    }
    
    if ([cell respondsToSelector:@selector(layoutMargins)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }

    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        cell.labelMinStr.text = @"min";
    } else {
        cell.labelMinStr.text = @"分";
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [System tapSound];
    if ((isTap) && (tapNo == indexPath.row + 1)) {
        [self iba_next:self.bt_next];
    } else {
        isTap = YES;
        tapNo = indexPath.row + 1;
        [self performSelector:@selector(tapIsDisabaled) withObject:nil afterDelay:0.3f];

        NSInteger ptr = indexPath.row + (listCount * menuPage);
        _selectTable = [_dataSourceDisp objectAtIndex:ptr];
        [self.orderTableView reloadData];
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
                
            case RequestTypeReserveList:{
                [self performSegueWithIdentifier:@"ToReserveListView" sender:nil];
                break;
            }

            case RequestTypeVoucherCheck:{
                if ([(NSMutableDictionary*)_dataList count]==0) {
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
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
