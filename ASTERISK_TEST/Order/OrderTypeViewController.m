//
//  OrderTypeViewController.m
//  Order
//
//  Created by koji kodama on 13/06/04.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "OrderTypeViewController.h"
#import "CustomerViewController.h"
#import "HomeViewController.h"
#import "ConfirmCell.h"
#import "SSGentleAlertView.h"

@interface OrderTypeViewController ()

@end

@implementation OrderTypeViewController

- (IBAction)iba_back:(id)sender{
    
    //2015-09-17 ueda
    //[self.navigationController popViewControllerAnimated:YES];
    //2015-09-17 ueda
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


- (IBAction)iba_showNext:(id)sender{
    
    [DataList sharedInstance].currentNoteID = editTable[@"NoteID"];
    
    //2014-12-16 ueda
    //BOOL isLoading = NO;
    switch (self.type) {
        case TypeOrderOriginal:
            
            //入力タイプAorBの判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                [self showIndicator];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                //2014-10-29 ueda
                [_net sendOrderRequest:self retryFlag:NO];
            }
            else{
                [self goToBType];
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String New_or_Add] delegate:self cancelButtonTitle:nil otherButtonTitles:[String bt_new],[String bt_add],[String bt_return], nil];
                alert.tag = 604;
                [alert show];
                 */
            }
            break;
            
        case TypeOrderAdd:
            
            //入力タイプAorBの判定
            //2014-07-07 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                [self showIndicator];
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                //2014-10-29 ueda
                [_net sendOrderAdd:self retryFlag:NO];
            }
            else{
                [self goToBType];
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String New_or_Add] delegate:self cancelButtonTitle:nil otherButtonTitles:[String bt_new],[String bt_add],[String bt_return], nil];
                alert.tag = 604;
                [alert show];
                 */
            }
            

            break;
    }

    
    //2014-12-16 ueda
/*
    if(isLoading){
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
        [mbProcess show:YES];
    }
 */
}

- (void)goToBType{
    self.type = TypeOrderOriginal;
    
    //2015-04-07 ueda
/*
    if ([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) {
        [self performSegueWithIdentifier:@"ToCustomerView" sender:nil];
    }
    else if([[System sharedInstance].kakucho2Type isEqualToString:@"1"]){
        if ([[System sharedInstance].tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:nil];
        }
        else{
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
 */
    //2015-04-07 ueda
    if (([[System sharedInstance].kakucho2Type isEqualToString:@"0"]) || ([[System sharedInstance].kakucho2Type isEqualToString:@"1"])) {
        if ([[System sharedInstance].tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:nil];
        }
        else{
            [self performSegueWithIdentifier:@"ToCountView" sender:nil];
        }
    }
    else{
        [self performSegueWithIdentifier:@"SearchView" sender:@"typeKokyaku"];
    }
}

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
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        self.tableView.layoutMargins = UIEdgeInsetsZero;
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    orderManager = [OrderManager sharedInstance];
    dat = [DataList sharedInstance];
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Note_MT"];
    
    noteList = [[NSMutableArray alloc]init];
    while([results next])
    {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [results columnCount]; ct++) {
            NSString *column = [results columnNameForIndex:ct];
            [_dic setValue:[results stringForColumn:column] forKey:column];
        }
        [noteList addObject:_dic];
    }
    [results close];
    [_net closeDb];
    
    if (dat.orderMessage.length>0) {
        [noteList insertObject:@{@"NoteID": @"99",@"HTDispNM":dat.orderMessage} atIndex:0];
    }
    else{
        //2014-06-06 ueda
        if ([[System sharedInstance].lang isEqualToString:@"0"]) {
            [noteList insertObject:@{@"NoteID": @"99",@"HTDispNM":@"指定なし"} atIndex:0];
        }
        else{
            [noteList insertObject:@{@"NoteID": @"99",@"HTDispNM":@"*BLANK"} atIndex:0];
        }
    }
    
    editTable = noteList[0];
    

    NSString *_str;
    NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    //2014-07-07 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
        //2014-11-17 ueda
/*
        //2014-10-23 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Deal]];
        } else {
            //2014-09-22 ueda
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                //英語
                _str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Deal]];
            } else {
                //日本語
                _str = [NSString stringWithFormat:@"　%@%@　M%d F%d %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Deal]];
            }
        }
 */
        //2014-11-18 ueda
        if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
            _str = [NSString stringWithFormat:@"　%@%@  %@",[String Str_t],_no,[String Deal]];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount,[String Deal]];
            } else {
                //小人入力しない
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd  %@",[String Str_t],_no,dat.manCount,dat.womanCount,[String Deal]];
            }
        }
        [self.bt_push setTitle:[String bt_send] forState:UIControlStateNormal];
    }
    else{
        _str = [NSString stringWithFormat:@"　%@",[String Deal]];
        [self.bt_push setTitle:[String bt_next] forState:UIControlStateNormal];
    }
    //2014-03-11 ueda
    [self.bt_back setTitle:[String bt_return] forState:UIControlStateNormal];
    
    self.lb_title.text = _str;
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    [System adjustStatusBarSpace:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    //2014-10-24 ueda
    if (alertView.tag == 101) {
        NSString *inputText = [[alertView textFieldAtIndex:0] text];
        switch (buttonIndex) {
            case 0:
                if([inputText length] > 0) {
                    NSString *convText = [System convertOnlyShiftjisText:inputText];
                    if([convText length] > 0) {
                        dat.orderMessage = convText;
                        [noteList removeObjectAtIndex:0];
                        [noteList insertObject:@{@"NoteID": @"99",@"HTDispNM":dat.orderMessage} atIndex:0];
                        [self.tableView reloadData];
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
                
            case 2:
                break;
        }
    }
    //2014-10-29 ueda
    else if(alertView.tag==1101){
        [self orderSendRetry];
    }
    //2014-12-25 ueda
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if([[segue identifier]isEqualToString:@"ToTableView"]){
        TableViewController *view_ = (TableViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToCountView"]){
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        //view_.entryType = EntryTypeTableAndNinzu;
        if (self.type==TypeOrderAdd) {
            view_.entryType = EntryTypeTableOnly;
        }
        else{
            //2014-12-25 ueda
            if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
                view_.entryType = EntryTypeTableOnly;
            } else {
                view_.entryType = EntryTypeTableAndNinzu;
            }
        }
    }
    else if([[segue identifier]isEqualToString:@"ToEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"SearchView"]){
        EntryViewController *view_ = (EntryViewController *)[segue destinationViewController];
        view_.type = self.type;
        
        if ([(NSString*)sender isEqualToString:@"typeKokyaku"]) {
            view_.entryType = EntryTypeKokyaku;
        }
        else if ([(NSString*)sender isEqualToString:@"typeSearch"]) {//←検索機能はHomeViewControllerでしか呼ばれない
            view_.entryType = EntryTypeSearch;
        }
    }
    else if([[segue identifier]isEqualToString:@"ToCustomerView"]){
        CustomerViewController *view_ = (CustomerViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}


#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    return [noteList count];
}

//2014-09-22 ueda float -> CGFloat for 64 bit
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return self.tableView.frame.size.height/[noteList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    ConfirmCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ConfirmCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        //cell.backgroundColor = [UIColor clearColor];
        //cell.textLabel.backgroundColor = [UIColor clearColor];
        //cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    }
    
    
    NSDictionary *_menu = [noteList objectAtIndex:indexPath.row];
    
    //2014-07-28 ueda
    CGRect rect = cell.contentView.bounds;
    rect.size.height = self.tableView.frame.size.height / 5;

    if ([_menu[@"NoteID"]isEqualToString:editTable[@"NoteID"]]) {
        cell.contentView.backgroundColor = BLUE;
        //2014-07-28 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:rect]]];
    }
    else{
        cell.contentView.backgroundColor = [UIColor whiteColor];
        //2014-07-28 ueda
        [cell.contentView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:rect]]];
    }
    
    LOG(@"_menu:%@",_menu);
    
    NSString *HTDispNMU = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (HTDispNMU.length==0) {
        cell.contentView.backgroundColor = [UIColor blackColor];
    }
    else{
        cell.textLabel.text = HTDispNMU;
        //2014-10-24 ueda
        NSInteger lenByte = [HTDispNMU lengthOfBytesUsingEncoding:NSShiftJISStringEncoding];
        if (lenByte > 30) {
            cell.textLabel.adjustsFontSizeToFitWidth = NO;
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:18]];
            cell.textLabel.numberOfLines = 2;
        } else {
            cell.textLabel.numberOfLines = 1;
            cell.textLabel.adjustsFontSizeToFitWidth = YES;
            [cell.textLabel setFont:[UIFont boldSystemFontOfSize:30]];
        }
    }
    
    //2014-11-20 ueda
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        cell.layoutMargins = UIEdgeInsetsZero;
    }
    
    return cell;
}

- (void)clearTouch{
    isTouch = NO;
}

- (BOOL)alertViewShouldEnableFirstOtherButton:(UIAlertView *)alertView
{
    NSString *inputText = [[alertView textFieldAtIndex:0] text];
    if( [inputText length] < 200)
    {
        return YES;
    }
    else
    {
        return NO;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *_menu = [noteList objectAtIndex:indexPath.row];
    NSString *HTDispNMU = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:
                           [NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if (HTDispNMU.length>0) {
        //2014-01-29 ueda
        [System tapSound];
        editTable = [noteList objectAtIndex:indexPath.row];
        [self.tableView reloadData];
    }

    //2014-10-24 ueda
    if (indexPath.row==0) {
        if (isTouch) {
            UIAlertView *message = [[UIAlertView alloc] initWithTitle:[String Enter_a_message]
                                                              message:nil
                                                             delegate:self
                                                    cancelButtonTitle:nil
                                                    otherButtonTitles:[String bt_ok],[String bt_cancel], nil];
            [message setAlertViewStyle:UIAlertViewStylePlainTextInput];
            NSDictionary *_menu = [noteList objectAtIndex:indexPath.row];
            [message textFieldAtIndex:0].text = [_menu[@"HTDispNM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            message.tag = 101;
            [message show];
        }
        else{
            isTouch = YES;
            [self performSelector:@selector(clearTouch) withObject:nil afterDelay:0.3f];
        }
    }
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
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

        //2014-12-04 ueda
/*
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
            alert.messageLabel.textAlignment = NSTextAlignmentLeft;
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
        } else {
            //2014-01-30 ueda
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
        [alert show];
    
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
    switch (self.type) {
        case TypeOrderOriginal:
            
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendOrderRequest:self retryFlag:YES];
            }
            break;
            
        case TypeOrderAdd:
            
            //入力タイプAorBの判定
            if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
                //2014-12-16 ueda
                //isLoading = YES;
                
                NetWorkManager *_net = [NetWorkManager sharedInstance];
                [_net sendOrderAdd:self retryFlag:YES];
            }
            break;
    }
    
    //2014-12-16 ueda
/*
    if(isLoading){
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
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
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}

@end
