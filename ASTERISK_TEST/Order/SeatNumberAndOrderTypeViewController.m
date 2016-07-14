//
//  SeatNumberAndOrderTypeViewController.m
//  Order
//
//  Created by UEDA on 2014/07/08.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//

#import "SeatNumberAndOrderTypeViewController.h"
#import "SSGentleAlertView.h"
#import "OrderConfirmViewController.h"

@interface SeatNumberAndOrderTypeViewController () <GMGridViewDataSource, GMGridViewActionDelegate> {
    NSMutableDictionary *_orderTypeSelect;
    NSInteger currentPage;
    NSMutableArray *_orderTypeList;
    
    OrderManager *orderManager;
    DataList *dat;
    
    NSMutableArray *_seatNumberData;
    
    NSInteger selectOrderTypeNo;
    //2014-10-01 ueda
    BOOL isTap;
    NSInteger tapNo;
}
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_back;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet GMGridView *seatNumber;
@property (weak, nonatomic) IBOutlet UITableView *orderType;
- (IBAction)iba_back:(UIButton *)sender;
- (IBAction)iba_next:(UIButton *)sender;


@end

@implementation SeatNumberAndOrderTypeViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        switch (buttonIndex) {
            case 0:
                if([inputText length] > 0) {
                    NSString *convText = [System convertOnlyShiftjisText:inputText];
                    if([convText length] > 0) {
                        [orderManager updateNoteMt:_orderTypeSelect[@"NoteID"] modifyName:convText];
                        [self getNoteMt];
                        [self.orderType reloadData];
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
}

//2014-11-20 ueda
- (void) viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    if ([self.orderType respondsToSelector:@selector(setLayoutMargins:)]) {
        self.orderType.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (![System is568h]) {
        self.seatNumber.frame = CGRectMake(2,  26     , 320, 152 - 25);
        self.orderType.frame  = CGRectMake(3, 151 - 15, 314, 324 - 66);
    }
    
    [self.bt_back setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    
    orderManager = [OrderManager sharedInstance];
    dat = [DataList sharedInstance];
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];

    [self getNoteMt];
    selectOrderTypeNo = appDelegate.typeCpreOrderTypeNo;
    _orderTypeSelect = _orderTypeList[selectOrderTypeNo];
    
    if (appDelegate.typeCeditModeFg) {
        //修正時
        NSString *selectId = [DataList sharedInstance].currentNoteID;
        for (int ct = 0; ct < [_orderTypeList count]; ct++) {
            if ([selectId isEqualToString:_orderTypeList[ct][@"NoteID"]]) {
                selectOrderTypeNo = ct;
                appDelegate.typeCpreOrderTypeNo = ct;
                _orderTypeSelect = _orderTypeList[ct];
                break;
            }
        }
    }
    
    NSString *_str;
    NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //2014-11-18 ueda
    if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
        _str = [NSString stringWithFormat:@"　%@%@  %@",[String Str_t],_no,[String typeCseatAndOrdertypeTitle]];
    } else {
        _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String typeCseatAndOrdertypeTitle]];
    }
    self.lb_title.text = _str;
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    [System adjustStatusBarSpace:self.view];
    
    _seatNumberData = orderManager.getSeatNumberData;

    self.seatNumber.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.seatNumber];
    self.seatNumber.style = GMGridViewStyleSwap;
    int spacing = 2;
    self.seatNumber.itemSpacing = spacing;
    self.seatNumber.minEdgeInsets = UIEdgeInsetsMake(spacing, spacing, spacing, spacing);
    self.seatNumber.centerGrid = NO;
    self.seatNumber.actionDelegate = self;
    self.seatNumber.pagingEnabled = YES;
    self.seatNumber.dataSource = self;
    self.seatNumber.showsVerticalScrollIndicator = NO;
    self.seatNumber.showsHorizontalScrollIndicator = NO;
    self.seatNumber.clipsToBounds = YES;
    [self.seatNumber reloadData];
    
    //2014-10-01 ueda ボタン動作がワンテンポ遅いので変更（0.3秒後にシングルタップが確定するから！？）
/*
    //2014-09-18 ueda
    UITapGestureRecognizer *doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
    doubleTapGesture.numberOfTapsRequired = 2;
    [self.view addGestureRecognizer:doubleTapGesture];
 */
}

//2014-10-01 ueda
/*
//2014-09-18 ueda
- (void)handleDoubleTap:(UIGestureRecognizer *)sender {
    if (sender.state == UIGestureRecognizerStateEnded){
        
        CGPoint tapPoint = [sender locationInView:sender.view];
        int oneHeight = (self.orderType.frame.size.height / 4);
        int posY = self.orderType.frame.origin.y + ((selectOrderTypeNo - 1) * oneHeight);
        CGRect okRect = CGRectMake(self.orderType.frame.origin.x, posY, self.orderType.frame.size.width, oneHeight);
        if (CGRectContainsPoint(okRect, tapPoint)) {
            _orderTypeSelect = [_orderTypeList objectAtIndex:selectOrderTypeNo];
            [self.orderType reloadData];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[String Enter_a_message]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:[String bt_ok],[String bt_cancel], nil];
            [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
            if ([_orderTypeSelect[@"ModifyName"] isEqualToString:@""]) {
                [message textFieldAtIndex:0].text = [_orderTypeSelect[@"HTDispNM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            } else {
                [message textFieldAtIndex:0].text = [_orderTypeSelect[@"ModifyName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            message.tag = 101;
            [message show];
        }
    }
}
*/
 
- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)iba_back:(UIButton *)sender {
    //2015-09-18 ueda
/*
    [self.navigationController popViewControllerAnimated:YES];
 */
    //2015-09-18 ueda
    if (!([[System sharedInstance].useOrderConfirm isEqualToString:@"0"])) {
        //オーダー確認画面を表示する
    } else {
        //直前の画面がオーダー確認画面だったら（Ａ・Ｂタイプどちらも）２つ前に戻る
        NSInteger pointer = self.navigationController.viewControllers.count - 2;
        UIViewController *vc = [self.navigationController.viewControllers objectAtIndex:pointer];
        if ([vc isKindOfClass:[OrderConfirmViewController class]]) {
            vc = [self.navigationController.viewControllers objectAtIndex:pointer - 1];
            [self.navigationController popToViewController:vc animated:YES];
            return;
        }
    }
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_next:(UIButton *)sender {
    [DataList sharedInstance].currentNoteID = _orderTypeSelect[@"NoteID"];
    [[OrderManager sharedInstance] typeCcopyDB];
    [self performSegueWithIdentifier:@"ToOrderSummaryView" sender:nil];
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

//////////////////////////////////////////////////////////////
#pragma mark Seat Number GMGridView
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfItemsInGMGridView:(GMGridView *)gridView
{
    return [_seatNumberData count];
}

- (CGSize)GMGridView:(GMGridView *)gridView sizeForItemsInInterfaceOrientation:(UIInterfaceOrientation)orientation
{
    return CGSizeMake(self.seatNumber.frame.size.width/6-3, self.seatNumber.frame.size.height/2-3);
}
- (GMGridViewCell *)GMGridView:(GMGridView *)gridView cellForItemAtIndex:(NSInteger)index
{
    CGSize size = [self GMGridView:gridView sizeForItemsInInterfaceOrientation:[[UIApplication sharedApplication] statusBarOrientation]];
    
    GMGridViewCell *cell = [self.seatNumber dequeueReusableCell];
    
    if (!cell)
    {
        cell = [[GMGridViewCell alloc] init];
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, size.width, size.height)];
        view.backgroundColor = [UIColor whiteColor];
        view.layer.masksToBounds = NO;
        view.layer.cornerRadius = 2;
        cell.contentView = view;
    }
    
    [[cell.contentView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    NSMutableDictionary *currentData = _seatNumberData[index];
    if ([dat.typeCseatSelect containsObject:currentData]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:cell.contentView.bounds]]];
    } else {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:cell.contentView.bounds]]];
    }

    UILabel *label = [[UILabel alloc] initWithFrame:cell.contentView.bounds];
    label.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    if ([[System sharedInstance].typeCseatCaptionType isEqualToString:@"1"]) {
        //数値バージョン
        label.text = (NSString *)currentData[@"titleText"];
    } else {
        //アルファベットバージョン
        label.text = (NSString *)currentData[@"abcText"];
    }
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor blackColor];
    label.highlightedTextColor = [UIColor blackColor];
    label.font = [UIFont boldSystemFontOfSize:25];
    label.numberOfLines = 1;
    label.adjustsFontSizeToFitWidth = YES;
    [cell.contentView addSubview:label];
    
    return cell;
    
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position point:(CGPoint)point
{
    NSLog(@"Did tap at index %zd", position);
    [System tapSound];
    NSMutableDictionary *selectSeat = [_seatNumberData objectAtIndex:position];
    if ([dat.typeCseatSelect containsObject:selectSeat]) {
        [dat.typeCseatSelect removeObject:selectSeat];
    } else {
        [dat.typeCseatSelect addObject:selectSeat];
    }
    [self.seatNumber reloadData];
}

- (void)GMGridView:(GMGridView *)gridView didTapOnItemAtIndex:(NSInteger)position
{
    NSLog(@"Did tap at index %zd", position);
}

- (void)GMGridViewDidTapOnEmptySpace:(GMGridView *)gridView
{
    NSLog(@"Tap on empty space");
}

- (BOOL)GMGridView:(GMGridView *)gridView canDeleteItemAtIndex:(NSInteger)index
{
    return NO;
}

//////////////////////////////////////////////////////////////
#pragma mark - Order Type TableView
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    return [_orderTypeList count] - 1;
}

//2014-09-22 ueda float -> CGFloat for 64 bit
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.orderType.frame.size.height/([_orderTypeList count] - 1);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:CellIdentifier];
    }
    
    NSDictionary *_menu = [_orderTypeList objectAtIndex:indexPath.row + 1];
    CGRect rect = cell.contentView.bounds;
    rect.size.height = self.orderType.frame.size.height / 4;
    if ([_menu[@"NoteID"]isEqualToString:_orderTypeSelect[@"NoteID"]]) {
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    }
    else{
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
    }
    LOG(@"_menu:%@",_menu);
    
    NSString *HTDispNMU = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if ([_menu[@"ModifyName"] isEqualToString:@""]) {
        HTDispNMU = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    } else {
        HTDispNMU = [_menu[@"ModifyName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    }
    
    if (HTDispNMU.length==0) {
        cell.contentView.backgroundColor = [UIColor blackColor];
    }
    else{
        NSInteger lenByte = [HTDispNMU lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
        if (lenByte > 30) {
            //2014-10-24 ueda
/*
            NSString *upText = [System getByteText:HTDispNMU length:lenByte / 2];
            int upLen = [upText length];
            NSString *btmText = [HTDispNMU substringWithRange:NSMakeRange(upLen, [HTDispNMU length] - upLen)];
 */
            cell.textLabel.adjustsFontSizeToFitWidth = NO;
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
            //2014-10-24 ueda
/*
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                //英語
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = [NSString stringWithFormat:@"%@%@",upText,btmText];
            } else {
                //日本語
                cell.textLabel.text = [NSString stringWithFormat:@"%@\n%@",upText,btmText];
            }
 */
            //2014-10-24 ueda
            cell.textLabel.numberOfLines = 2;
            cell.textLabel.text = HTDispNMU;
        } else {
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:30]];
            cell.textLabel.text = HTDispNMU;
        }
    }
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_menu = [_orderTypeList objectAtIndex:indexPath.row + 1];
    NSString *HTDispNMU = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (HTDispNMU.length>0) {
        //2014-10-01 ueda ダブルタップ検出
        if ((isTap) && (tapNo == indexPath.row + 1)) {
            _orderTypeSelect = [_orderTypeList objectAtIndex:selectOrderTypeNo];
            [self.orderType reloadData];
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[String Enter_a_message]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:[String bt_ok],[String bt_cancel], nil];
            [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
            if ([_orderTypeSelect[@"ModifyName"] isEqualToString:@""]) {
                [message textFieldAtIndex:0].text = [_orderTypeSelect[@"HTDispNM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            } else {
                [message textFieldAtIndex:0].text = [_orderTypeSelect[@"ModifyName"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            }
            message.tag = 101;
            [message show];
        } else {
            isTap = YES;
            tapNo = indexPath.row + 1;
            [self performSelector:@selector(tapIsDisabaled) withObject:nil afterDelay:0.3f];
            //
            [System tapSound];
            if ([_orderTypeSelect[@"NoteID"]isEqualToString:_menu[@"NoteID"]]) {
                _orderTypeSelect = _orderTypeList[0];
            } else {
                _orderTypeSelect = [_orderTypeList objectAtIndex:indexPath.row + 1];
                selectOrderTypeNo = indexPath.row + 1;
                //2014-09-22 ueda
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                appDelegate.typeCpreOrderTypeNo = selectOrderTypeNo;
            }
            [self.orderType reloadData];
        }
    }
}

//2014-10-01 ueda
- (void)tapIsDisabaled{
    isTap = NO;
    tapNo = 0;
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

- (void)getNoteMt {
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Note_MT"];
    
    _orderTypeList = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [_orderTypeList addObject:_dic];
    }
    [results close];
    [_net closeDb];
    //未選択用のデータを挿入　これは画面には表示しない
    [_orderTypeList insertObject:@{@"NoteID": @"00",@"HTDispNM":@"未選択"} atIndex:0];
}

@end
