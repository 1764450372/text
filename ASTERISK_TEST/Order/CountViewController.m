//
//  CountViewController.m
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "CountViewController.h"
#import "SSGentleAlertView.h"

@interface CountViewController (){
    //2014-11-11 ueda
    BOOL directInput;

}

@property (weak, nonatomic) IBOutlet UIButton *bt_table;
@property (weak, nonatomic) IBOutlet UIButton *bt_man;
@property (weak, nonatomic) IBOutlet UIButton *bt_man_down;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman;
@property (weak, nonatomic) IBOutlet UIButton *bt_woman_down;
@property (weak, nonatomic) IBOutlet UIButton *bt_child;
@property (weak, nonatomic) IBOutlet UIButton *bt_child_down;

@property (weak, nonatomic) IBOutlet UIButton *bt_A;
@property (weak, nonatomic) IBOutlet UIButton *bt_B;
@property (weak, nonatomic) IBOutlet UIButton *bt_C;
@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

@property (weak, nonatomic) IBOutlet UILabel *lb_table;
@property (weak, nonatomic) IBOutlet UILabel *lb_man;
@property (weak, nonatomic) IBOutlet UILabel *lb_woman;
@property (weak, nonatomic) IBOutlet UILabel *lb_child;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_table;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_man;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_woman;
@property (weak, nonatomic) IBOutlet UILabel *lb_count_child;

- (IBAction)iba_selectInputField:(UIButton *)sender;

@end

@implementation CountViewController

/////////////////////////////////////////////////////////////////
#pragma mark - Control object action
/////////////////////////////////////////////////////////////////
- (IBAction)iba_back:(id)sender{
    
    //2015-09-17 ueda
    if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
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
    }
    
    if ([sys.tableType isEqualToString:@"0"]) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else{        
        if (dat.isMove) {
            dat.isMove = NO;
            dat.currentVoucher = nil;
            [self buttonStateChange];
            [dat.moveToTable removeAllObjects];
            //[self.gmGridView reloadData];
            return;
        }
        else if((self.type == TypeOrderOriginal||self.type == TypeOrderAdd)&&
                [sys.entryType isEqualToString:@"1"]){
            [self.navigationController popViewControllerAnimated:YES];
            return;
        }
        
        if(self.type == TypeOrderOriginal||self.type == TypeOrderAdd){
            NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
            //2014-07-07 ueda
            if (([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) && [orderList count]>0) {
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
                //2016-02-02 ueda
/*
                [self.navigationController popViewControllerAnimated:YES];
 */
                //2016-02-02 ueda
                if (YES) {
                    if(self.type == TypeOrderOriginal){
                        if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        } else {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            return;
        }
        
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)iba_showNext:(id)sender{

    LOG(@"Speed test 01");
    
    //テーブルが存在するかの判定
    if (self.entryType!=EntryTypeTableNot) {
    //if ([sys.tableType isEqualToString:@"1"]&&!dat.currentVoucher) {//テーブルコード入力時で、伝票が選択されていればテーブルチェックを行わない
        
        if ([self.lb_count_table.text length]==0) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Input_the_table]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
    
        BOOL isExistence = NO;
        for (int ct = 0; ct < [tableArray count]; ct++) {
            NSDictionary *dic = tableArray[ct];
            NSString *_no1 = [dic[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            NSString *_no2 = [self.lb_count_table.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
            
            LOG(@"%@:%@",dic[@"TableNo"],self.lb_table.text);
            
            if ([_no1 isEqualToString:_no2]) {
                
                LOG(@"TRUE");
                
                isExistence = YES;
                
                
                if (self.type == TypeOrderMove&&dat.isMove) {
                    LOG(@"1");
                    if (!dat.moveToTable) {
                        dat.moveToTable = [[NSMutableArray alloc]init];
                    }
                    [dat.moveToTable addObject:dic];
                    LOG(@"2:%@",dat.moveToTable);
                }
                else{
                    dat.selectTable[0] = [NSMutableDictionary dictionaryWithDictionary:dic];
                    dat.currentTable = dat.selectTable[0];
                }
                break;
            }
        }
        
        if (!isExistence) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String The_Table_which]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
    }
    
    
    //テーブルの取得
    if (!dat.currentTable) {
        if ([dat.selectTable count]>0) {
            dat.currentTable = dat.selectTable[0];
        }
    }
    
    
    //RCV 00,30,0039=0030130604210303911 A0101N132 001500000
    //RCV 00,30,0043=0030130604210308911 A0101N132 0015000010005
    
    
    LOG(@"dat.currentTable:%@",dat.currentTable);
    LOG(@"dat.currentVoucher:%@",dat.currentVoucher);
    
    //人数入力が伴う場合
    if (self.entryType != EntryTypeTableOnly) {
        //0人設定にて判定 0:確認　1:許可　2:禁止
        //2014-12-01 ueda
        if ([sys.zeronin isEqualToString:@"0"]&&(self.man_count+self.woman_count+self.child_count==0)) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String The_number]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 701;
            [alert show];
            return;
        }
        
        //2014-12-01 ueda
        if ([sys.zeronin isEqualToString:@"2"]&&(self.man_count+self.woman_count+self.child_count==0)) {
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Input_the_number]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=nil;
            [alert addButtonWithTitle:[String bt_confirm]];
            alert.cancelButtonIndex=0;
            [alert show];
            return;
        }
    }
    
    [self finishEntryCount];
}

- (void)finishEntryCount{

    dat.manCount = self.man_count;
    dat.womanCount = self.woman_count;
    //2014-11-17 ueda
    dat.childCount = self.child_count;
    
    //テーブル入力を伴う場合の判定
    if (self.entryType != EntryTypeTableNot) {
        
        if ([[System sharedInstance].searchType isEqualToString:@"0"]) {
            //2015-04-06 ueda
            //検索機能が有効
            //伝票番号をクリアしない
        } else {
            if (self.type != TypeOrderMove) {
                dat.currentVoucher = nil;
            }
        }
        
        //入力タイプB時の新規／追加の判定
        if (self.type == TypeOrderOriginal&&
            [[System sharedInstance].entryType isEqualToString:@"1"]) {
            
            //伝票の判定
            BOOL isAiseki = NO;
            if ([dat.currentTable[@"status"] intValue]>3){
                isAiseki = YES;
            }
            if (isAiseki) {
                self.type = TypeOrderAdd;
                if ([dat tableCheck:self type:TypeOrderAdd]) {
                    [self showIndicator];
                }
                return;
            }
            else{
                self.type = TypeOrderOriginal;
            }
        }
        
        if ([dat tableCheck:self type:self.type]) {
            [self showIndicator];
        }
        
        return;
    }
    
    //2016-01-05 ueda ASTERISK
    if (self.type == TypeOrderCheck) {
        [self showIndicator];
        NetWorkManager *_net = [NetWorkManager sharedInstance];
        [_net sendOrderNinzu:self];
    } else {
        //ABパターン判定
        //A = オーダー入力画面に遷移する
        //2014-07-07 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"0"] || [[System sharedInstance].entryType isEqualToString:@"2"]) {
            [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
        }
        
        //B = オーダーを送信する
        else{
            [self showIndicator];
            NetWorkManager *_net = [NetWorkManager sharedInstance];
            if (!dat.currentVoucher) {
                [_net sendOrderRequest:self retryFlag:NO];
            }
            else{
                [_net sendOrderAdd:self retryFlag:NO];
            }
        }
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (mbProcess) {
        [mbProcess hide:YES];
    }
    
    switch (buttonIndex) {
        case 0:
            if (alertView.tag==701) {
                [self finishEntryCount];
            }
            else if(alertView.tag==0){
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
            }
            else if (alertView.tag==501) {
                
                //エントリータイプAorB
                //2014-07-07 ueda
                if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                    [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                }
                else{
                    [self showIndicator];
                    //2014-10-29 ueda
                    [[NetWorkManager sharedInstance] sendOrderRequest:self retryFlag:NO];
                }
            }
            else if(alertView.tag==502){
                //2014-12-04 ueda
                //[self reloadTableStatus];
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
/*
                [self.navigationController popViewControllerAnimated:YES];
 */
                //2016-02-02 ueda
                if (YES) {
                    [[OrderManager sharedInstance] typeCclearDB];
                    if(self.type == TypeOrderOriginal){
                        if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                            [self.navigationController popToRootViewControllerAnimated:YES];
                        } else {
                            [self.navigationController popViewControllerAnimated:YES];
                        }
                    } else {
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            //2014-10-29 ueda
            if(alertView.tag==1101){
                [self orderSendRetry];
            }
            //2014-12-25 ueda
            else if (alertView.tag==1102){
                [self orderSendForce];
            }
            
            break;
            
        case 1:
            //2014-12-04 ueda
/*
            //2014-10-22 ueda
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

- (IBAction)iba_selectInputField:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (button == self.bt_table) {
        [self.bt_table setSelected:YES];
        [self.bt_man   setSelected:NO];
        [self.bt_woman setSelected:NO];
        [self.bt_child setSelected:NO];
    }
    else if (button == self.bt_man) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:YES];
        [self.bt_woman setSelected:NO];
        [self.bt_child setSelected:NO];
        self.man_count = MIN(99, self.man_count + 1);
    }
    else if (button == self.bt_woman) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:NO];
        [self.bt_woman setSelected:YES];
        [self.bt_child setSelected:NO];
        self.woman_count = MIN(99, self.woman_count + 1);
    }
    else if (button == self.bt_child) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:NO];
        [self.bt_woman setSelected:NO];
        [self.bt_child setSelected:YES];
        self.child_count = MIN(99, self.child_count + 1);
    }
    [self setBackgroudPng];
    [self dispNumVal];
    [System tapSound];
    directInput = NO;
    //2015-12-08 ueda ASTERISK
    [self alphabetButtonControl];
}


- (IBAction)iba_countUp:(id)sender{
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSInteger max = 0;
    NSInteger count = 0;
    if (self.bt_table.selected){
        [str appendString:self.lb_count_table.text];
        [str appendString:[NSString stringWithFormat:@"%zd",button.tag]];
        max = 3;
    }
    else if (self.bt_man.selected) {
        if (directInput) {
            count = self.man_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    else if(self.bt_woman.selected){
        if (directInput) {
            count = self.woman_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    else if(self.bt_child.selected){
        if (directInput) {
            count = self.child_count * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 2;
    }
    if (str.length>max) {
        return;
    }
    if (self.bt_table.selected){
        self.lb_count_table.text = str;
    }
    else if (self.bt_man.selected) {
        self.man_count = count;
    }
    else if(self.bt_woman.selected){
        self.woman_count = count;
    }
    else if(self.bt_child.selected){
        self.child_count = count;
    }
    [self dispNumVal];
    directInput = YES;
}

- (IBAction)iba_alphabet:(UIButton *)sender {
    //2015-12-08 ueda ASTERISK
    if (self.bt_table.selected){
        UIButton *button = (UIButton *)sender;
        NSMutableString *str= [[NSMutableString alloc]init];
        [str appendString:self.lb_count_table.text];
        if (button == self.bt_A) {
            [str appendString:@"A"];
        }
        else if (button == self.bt_B) {
            [str appendString:@"B"];
        }
        else if (button == self.bt_C) {
            [str appendString:@"C"];
        }
        if (str.length <= 3) {
            self.lb_count_table.text = str;
        }
    }
}

- (IBAction)iba_countDown:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (button == self.bt_man_down) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:YES];
        [self.bt_woman setSelected:NO];
        [self.bt_child setSelected:NO];
        self.man_count = MAX(0, self.man_count - 1);
    }
    else if (button == self.bt_woman_down) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:NO];
        [self.bt_woman setSelected:YES];
        [self.bt_child setSelected:NO];
        self.woman_count = MAX(0, self.woman_count - 1);
    }
    else if (button == self.bt_child_down) {
        [self.bt_table setSelected:NO];
        [self.bt_man   setSelected:NO];
        [self.bt_woman setSelected:NO];
        [self.bt_child setSelected:YES];
        self.child_count = MAX(0, self.child_count - 1);
    }
    [self setBackgroudPng];
    [self dispNumVal];
    [System tapSound];
    directInput = NO;
    //2015-12-08 ueda ASTERISK
    [self alphabetButtonControl];
}

- (IBAction)iba_clear:(id)sender{
    if (self.bt_table.selected){
        self.lb_count_table.text = @"";
    }
    else if (self.bt_man.selected) {
        self.man_count = 0;
    }
    else if(self.bt_woman.selected){
        self.woman_count = 0;
    }
    else if(self.bt_child.selected){
        self.child_count = 0;
    }
    [self dispNumVal];
    directInput = YES;
}

- (IBAction)iba_backspace:(id)sender{
    if (self.bt_table.selected){
        NSMutableString *str= [[NSMutableString alloc]init];
        [str appendString:self.lb_count_table.text];
        if (str.length==0) {
            return;
        }
        [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
        self.lb_count_table.text = str;
    }
    else if (self.bt_man.selected) {
        self.man_count = self.man_count / 10;
    }
    else if(self.bt_woman.selected){
        self.woman_count = self.woman_count / 10;
    }
    else if(self.bt_child.selected){
        self.child_count = self.child_count / 10;
    }
    [self dispNumVal];
    directInput = YES;
}

//==============================================================================


#pragma mark -
#pragma mark - Lifecycle delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        self.man_count   = 0;
        self.woman_count = 0;
        self.child_count = 0;
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
    
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];

    sys = [System sharedInstance];
    dat = [DataList sharedInstance];
    
    LOG(@"dat.currentVoucher=%@",dat.currentVoucher);
    
    //2014-12-16 ueda
/*
    mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
    //2014-10-30 ueda
    //mbProcess.labelText = @"Loading Data";
    [self.view addSubview:mbProcess];
    [mbProcess setDelegate:self];
 */
    
    self.lb_count_table.text = @"";
    self.lb_table.text = [String table];
    self.lb_man.text   = [String manTypeC];
    self.lb_woman.text = [String womanTypeC];
    self.lb_child.text = [String childTypeC];

    [self.bt_man_down setTitle:@"" forState:UIControlStateNormal];
    [self.bt_woman_down setTitle:@"" forState:UIControlStateNormal];
    [self.bt_child_down setTitle:@"" forState:UIControlStateNormal];
    self.bt_man_down.backgroundColor = [UIColor clearColor];
    self.bt_woman_down.backgroundColor = [UIColor clearColor];
    self.bt_child_down.backgroundColor = [UIColor clearColor];

    //人数入力のみの場合
    if (self.entryType == EntryTypeTableNot) {
    //if ([sys.tableType isEqualToString:@"0"]||dat.currentVoucher) {
        self.bt_table.selected = NO;
        self.bt_man.selected = YES;
        self.bt_woman.selected = NO;
        self.bt_child.selected = NO;

        self.bt_table.hidden  = YES;
        self.bt_table.enabled = NO;
        
        //self.bt_man.frame =CGRectMake(self.bt_table.l, <#CGFloat y#>, <#CGFloat width#>, <#CGFloat height#>)

        self.bt_woman.frame = self.bt_man.frame;
        self.lb_woman.frame = self.lb_man.frame;
        self.bt_woman_down.frame  = CGRectMake(self.bt_man_down.frame.origin.x, self.bt_woman_down.frame.origin.y, self.bt_woman_down.frame.size.width, self.bt_woman_down.frame.size.height);
        self.lb_count_woman.frame = CGRectMake(self.lb_count_man.frame.origin.x, self.lb_count_woman.frame.origin.y, self.lb_count_woman.frame.size.width, self.lb_count_woman.frame.size.height);

        self.bt_man.frame = self.bt_table.frame;
        self.lb_man.frame = self.lb_table.frame;
        self.bt_man_down.frame  = CGRectMake(self.bt_man_down.frame.origin.x, self.bt_child_down.frame.origin.y, self.bt_man_down.frame.size.width, self.bt_man_down.frame.size.height);
        self.lb_count_man.frame = CGRectMake(self.lb_count_man.frame.origin.x, self.lb_count_child.frame.origin.y, self.lb_count_man.frame.size.width, self.lb_count_man.frame.size.height);
        
        self.bt_child.frame = CGRectMake(self.bt_child.frame.origin.x, (self.bt_child.frame.origin.y + self.bt_child.frame.size.height) / 2, self.bt_child.frame.size.width, self.bt_child.frame.size.height);
        self.lb_child.frame = CGRectMake(self.lb_child.frame.origin.x, (self.lb_child.frame.origin.y + self.lb_child.frame.size.height) / 2, self.lb_child.frame.size.width, self.lb_child.frame.size.height);
        self.bt_child_down.frame = CGRectMake(self.bt_child_down.frame.origin.x, (self.bt_child_down.frame.origin.y + self.bt_child_down.frame.size.height) / 2, self.bt_child_down.frame.size.width, self.bt_child_down.frame.size.height);
        self.lb_count_child.frame = CGRectMake(self.lb_count_child.frame.origin.x, (self.lb_count_child.frame.origin.y + self.lb_count_child.frame.size.height) / 2, self.lb_count_child.frame.size.width, self.lb_count_child.frame.size.height);
        //2014-12-12 ueda
        if (([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
            //小人入力する(タイプＣは別ViewController)
            //NOP
        } else {
            //小人
            self.bt_child.hidden = YES;
            self.bt_child.enabled = NO;
            self.lb_child.hidden = YES;
            self.lb_count_child.hidden = YES;
            self.bt_child_down.hidden = YES;
            self.bt_child_down.enabled = NO;
            //男
            self.bt_man.frame = CGRectMake(self.bt_man.frame.origin.x, self.bt_man.frame.origin.y, self.bt_man.frame.size.width * 2 + 2, self.bt_man.frame.size.height);
            self.lb_man.frame = CGRectMake(self.lb_man.frame.origin.x, self.lb_man.frame.origin.y, self.lb_man.frame.size.width + 50, self.lb_man.frame.size.height);
            self.lb_man.font = [UIFont boldSystemFontOfSize:40.0f];
            self.lb_count_man.frame = CGRectMake(self.lb_count_man.frame.origin.x + self.bt_child.frame.size.width - 100, self.lb_count_man.frame.origin.y, self.lb_count_man.frame.size.width + 50, self.lb_count_man.frame.size.height);
            self.lb_count_man.font = [UIFont boldSystemFontOfSize:40.0f];
            self.bt_man_down.frame = CGRectMake(self.bt_man_down.frame.origin.x + self.bt_child.frame.size.width - 100, self.bt_man_down.frame.origin.y, self.bt_man_down.frame.size.width + 80, self.bt_man_down.frame.size.height);
            //女
            self.bt_woman.frame = CGRectMake(self.bt_woman.frame.origin.x, self.bt_woman.frame.origin.y, self.bt_woman.frame.size.width * 2 + 2, self.bt_woman.frame.size.height);
            self.lb_woman.frame = CGRectMake(self.lb_woman.frame.origin.x, self.lb_woman.frame.origin.y, self.lb_woman.frame.size.width + 50, self.lb_woman.frame.size.height);
            self.lb_woman.font = [UIFont boldSystemFontOfSize:40.0f];
            self.lb_count_woman.frame = CGRectMake(self.lb_count_woman.frame.origin.x + self.bt_child.frame.size.width - 100, self.lb_count_woman.frame.origin.y, self.lb_count_woman.frame.size.width + 50, self.lb_count_woman.frame.size.height);
            self.lb_count_woman.font = [UIFont boldSystemFontOfSize:40.0f];
            self.bt_woman_down.frame = CGRectMake(self.bt_woman_down.frame.origin.x + self.bt_child.frame.size.width - 100, self.bt_woman_down.frame.origin.y, self.bt_woman_down.frame.size.width + 80, self.bt_woman_down.frame.size.height);
        }
    }
    
    //人数入力兼テーブル入力の場合
    else if (self.entryType == EntryTypeTableAndNinzu||self.entryType == EntryTypeTableOnly) {
        [self reloadTableStatus];

        self.bt_table.selected = YES;
        self.bt_man.selected = NO;
        self.bt_woman.selected = NO;
        self.bt_child.selected = NO;
        if (self.entryType == EntryTypeTableOnly) {
        //if (self.type != TypeOrderOriginal) {
            self.bt_table.frame = CGRectMake(self.bt_table.frame.origin.x, self.bt_table.frame.origin.y, self.bt_table.frame.size.width * 2 + 2, self.bt_table.frame.size.height);
            self.lb_count_table.frame = CGRectMake(self.lb_count_table.frame.origin.x + self.bt_man.frame.size.width, self.lb_count_table.frame.origin.y, self.lb_count_table.frame.size.width, self.lb_count_table.frame.size.height);
            self.bt_man.hidden   = YES;
            self.bt_woman.hidden = YES;
            self.bt_child.hidden = YES;
            self.bt_man.enabled        = NO;
            self.bt_man_down.enabled   = NO;
            self.bt_woman.enabled      = NO;
            self.bt_woman_down.enabled = NO;
            self.bt_child.enabled      = NO;
            self.bt_child_down.enabled = NO;
            self.lb_man.hidden   = YES;
            self.lb_woman.hidden = YES;
            self.lb_child.hidden = YES;
            self.lb_count_man.hidden   = YES;
            self.lb_count_woman.hidden = YES;
            self.lb_count_child.hidden = YES;
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //小人入力する(タイプＣは別のViewController)
                //NOP
            } else {
                //テーブル
                self.bt_table.frame = CGRectMake(self.bt_table.frame.origin.x, self.bt_table.frame.origin.y, self.bt_table.frame.size.width * 2 + 2, self.bt_table.frame.size.height);
                self.lb_count_table.frame = CGRectMake(self.lb_count_table.frame.origin.x + self.bt_man.frame.size.width, self.lb_count_table.frame.origin.y, self.lb_count_table.frame.size.width, self.lb_count_table.frame.size.height);
                //小人
                self.bt_child.hidden = YES;
                self.bt_child.enabled = NO;
                self.lb_child.hidden = YES;
                self.lb_count_child.hidden = YES;
                self.bt_child_down.hidden = YES;
                self.bt_child_down.enabled = NO;
            }
        }
    }
    //2015-12-24 ueda ASTERISK
/*
    //取消後の追加で戻った場合の為にviewWillAppearに移動
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    //2015-12-17 ueda ASTERISK
    if (self.type == TypeOrderCancel) {
        //取消の場合は赤色
        self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:self.lb_title.bounds]];
    }
 */

    [System adjustStatusBarSpace:self.view];
    [self setBackgroudPng];
    [self dispNumVal];
    //2015-12-08 ueda ASTERISK
    [self alphabetButtonControl];
    //2016-02-03 ueda ASTERISK
    UIImage *img = [UIImage imageNamed:@"ButtonYellow.png"];
    [self.bt_clear setBackgroundImage:img forState:UIControlStateNormal];
    //2016-04-08 ueda ASTERISK
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        //英語
        [self.bt_clear setTitle:@"CL" forState:UIControlStateNormal];
    } else {
        [self.bt_clear.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
        [self.bt_clear setTitle:@"クリア" forState:UIControlStateNormal];
    }
}

- (void)reloadTableStatus{
    [self showIndicator];
    
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net getTableStatus:self];
}

- (void)buttonStateChange{
    switch (self.type) {
            
        case TypeOrderOriginal:
            if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
                //Ｂタイプ
                //2015-08-24 ueda
                if (!([[System sharedInstance].kakucho2Type isEqualToString:@"0"])) {
                    //客層入力ではない
                    [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
                }
            }
            
            if (!dat.currentTable) {
                self.lb_title.text = [String tableNew];
            }
            else{
                NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *_str = [NSString stringWithFormat:[String tableNo],_no];
                self.lb_title.text = _str;
            }
            break;
            
        case TypeOrderAdd:
            if ([[System sharedInstance].entryType isEqualToString:@"1"]) {
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
            }
            
            if (!dat.currentTable) {
                self.lb_title.text = [String tableAdd];
            }
            else{
                NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *_str = [NSString stringWithFormat:[String tableNo],_no];
                self.lb_title.text = _str;
            }
            break;
            
        case TypeOrderCancel:
            self.lb_title.text = [String tableCancel];
            break;
            
        case TypeOrderCheck:
            self.lb_title.text = [String tableConfirm];
            //2016-01-05 ueda ASTERISK
            if (self.entryType == EntryTypeTableNot) {
                NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                NSString *_str = [NSString stringWithFormat:@"　%@%@　%@",[String Str_t],_no,@"人数変更"];
                self.lb_title.text = _str;
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
                UIImage *img = [UIImage imageNamed:@"ButtonSend.png"];
                [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
                //2016-02-03 ueda ASTERISK
                [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            }
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
                self.lb_title.text = _str;
                //2014-12-09 ueda
                [self.bt_next setTitle:[String bt_send] forState:UIControlStateNormal];
            }
            else{
                self.lb_title.text = [String tableMove1];
                //2014-12-09 ueda
                [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
            }
            //2014-12-09 ueda
            //self.lb_table.text = @"";
            self.lb_count_table.text = @"";
            
            break;
        }
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

    //注文Bタイプの場合の次画面からの遷移時のさいにステータスを新規に戻す
    if ([[System sharedInstance].entryType isEqualToString:@"1"]&&self.type == TypeOrderAdd) {
        if (self.entryType != EntryTypeTableNot) {
            self.type = TypeOrderOriginal;
        }
    }
    
     [self buttonStateChange];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    if (mbProcess) {
        [mbProcess hide:YES];
    }
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

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    LOG(@"Speed test 02");
    if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherListView"]){
        VouchingListViewController *view_ = (VouchingListViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucherList = (NSMutableArray*)sender;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherDetailView"]){
        VouchingDetailViewController *view_ = (VouchingDetailViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucher = (NSMutableDictionary*)sender;
    }
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    dispatch_async(dispatch_get_main_queue(), ^{

        BOOL isReload = NO;
        switch (type) {
                
            case RequestTypeOrderRequest:{
                [[OrderManager sharedInstance] zeroReset];
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
                break;
            }
            //2014-09-12 ueda
            case RequestTypeVoucherListTypeC:
            case RequestTypeVoucherList:
                if (self.type==TypeOrderMove) {
                    [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                }
                //追加で伝票タイプが詳細の場合は強制的にオーダーエントリー画面に遷移
                //2014-07-07 ueda
                else if (([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"] )&&
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
                
            case RequestTypeVoucherTable:
                if (self.type==TypeOrderMove) {
                    if ([(NSArray*)_dataList count]==1) {
                        dat.currentVoucher = _dataList[0];
                        dat.manCount = [dat.currentVoucher[@"manCount"]intValue];
                        dat.womanCount = [dat.currentVoucher[@"womanCount"]intValue];
                        //2014-11-17 ueda
                        dat.childCount = [dat.currentVoucher[@"childCount"]intValue];
                        
                        dat.isMove = YES;
                        //[self.gmGridView reloadData];
                    }
                    else if([(NSArray*)_dataList count]>1){
                        [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                    }
                }
                break;
                
                
            case RequestTypeVoucherNo:
                if ([(NSArray*)_dataList count]>0) {
                    if (self.type==TypeOrderCheck) {
                        [self performSegueWithIdentifier:@"ToVoucherDetailView" sender:_dataList];
                    }
                }
                break;
                
            case RequestTypeVoucherDetail:{
                [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
                break;
            }
                
            case RequestTypeTableStatus:{//[N11]
                if ([(NSArray*)_dataList count]>0) {
                    tableArray = [[NSMutableArray alloc]initWithArray:(NSArray*)_dataList[0]];
                    //[self.gmGridView reloadData];
                }
                break;
            }/*
            case RequestTypeTableReadyFinish://[N12]
                editTable = nil;
                [self reloadTableStatus];
                break;
               */ 
            case RequestTypeTableMove:{//[N13]
                dat.isMove = NO;
                [dat.moveToTable removeAllObjects];
                //isReload = YES;
                [self iba_back:nil];
                break;
            }/*
            case RequestTypeTableReserve:{//[N14]
                NSDictionary *_st = (NSDictionary*)_dataList;
                NSString *_msg = [NSString stringWithFormat:@"予約時刻:%@時%@分\n予約者名:%@\n人数:%@",_st[@"time1"],_st[@"time2"],_st[@"name"],_st[@"count"]];
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station]
                                                                message:_msg
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                break;
            }
            case RequestTypeTableSyohin:{//[N15]
                //商品を表示
                NSMutableString *str = [[NSMutableString alloc]init];
                NSArray *_array = (NSArray*)_dataList;
                for (int ct = 0; ct<[_array count]; ct++) {
                    NSDictionary *_menu = _array[ct];
                    [str appendString:_menu[@"HTDispNM"]];
                    [str appendString:[NSString stringWithFormat:@" %5d",[_menu[@"count"]intValue]]];
                    [str appendString:@"\n"];
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提供完了？" message:str delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                alert.tag = 16;
                [alert show];
                ((UILabel *)[[alert subviews] objectAtIndex:2]).textAlignment = NSTextAlignmentLeft;
                break;
            }
            case RequestTypeTableTaiki://[N16]
                editTable = nil;
                [self reloadTableStatus];
                break;
                
            case RequestTypeTableInShow://[N17]
                editTable = nil;
                [self reloadTableStatus];
                break;
                
            case RequestTypeTableInShow2://[N17]その2
                editTable = nil;
                [self reloadTableStatus];
                break;
                
            case RequestTypeTableEmpty:{//[N18]
                editTable = nil;
                [self reloadTableStatus];
                break;
            }*/
                
            //2015-12-08 ueda ASTERISK
            //調理指示もテーブル入力
            case RequestTypeTableReadyDirection:{//[C12]
                LOG(@"%@",(NSString*)_dataList);
                [self performSegueWithIdentifier:@"ToVoucherListView" sender:_dataList];
                break;
            }
            
            //2016-01-05 ueda ASTERISK
            case RequestTypeOrderNinzu:{
                [[OrderManager sharedInstance] zeroReset];
                HomeViewController *parent = [self.navigationController.viewControllers objectAtIndex:0];
                [self.navigationController popToViewController:parent animated:YES];
                break;
            }
                
            default:
                break;
        }
        
        [self buttonStateChange];
        
        if (isReload) {
            [self reloadTableStatus];
        }
        else{
            if (mbProcess) {
                [mbProcess hide:YES];
            }
        }
    });
}

    
-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
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
        } else if (type == RequestTypeTableStatus) {
            [alert addButtonWithTitle:@"OK"];
            alert.delegate=self;
            alert.tag = 502;
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
#pragma mark - Local Method
/////////////////////////////////////////////////////////////////

- (void)setBackgroudPng {
    if (self.bt_table.selected) {
        self.bt_table.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_table.bounds]];
    } else {
        self.bt_table.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_table.bounds]];
    }
    if (self.bt_man.selected) {
        self.bt_man.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_man.bounds]];
    } else {
        self.bt_man.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_man.bounds]];
    }
    if (self.bt_woman.selected) {
        self.bt_woman.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_woman.bounds]];
    } else {
        self.bt_woman.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_woman.bounds]];
    }
    if (self.bt_child.selected) {
        self.bt_child.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_child.bounds]];
    } else {
        self.bt_child.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_child.bounds]];
    }
}

- (void)dispNumVal {
    self.lb_count_man.text   = [NSString stringWithFormat:@"%zd",self.man_count];
    self.lb_count_woman.text = [NSString stringWithFormat:@"%zd",self.woman_count];
    self.lb_count_child.text = [NSString stringWithFormat:@"%zd",self.child_count];
}

//2014-10-29 ueda
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

//2014-12-25 ueda
- (void)orderSendForce {
    [self showIndicator];
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31forceFlag = YES;
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net sendOrderRequest:self retryFlag:appDelegate.OrderRequestN31retryFlag];
}

//2015-12-08 ueda ASTERISK
- (void)alphabetButtonControl {
    if (self.bt_table.selected){
        self.bt_A.enabled = YES;
        self.bt_B.enabled = YES;
        self.bt_C.enabled = YES;
    } else {
        self.bt_A.enabled = NO;
        self.bt_B.enabled = NO;
        self.bt_C.enabled = NO;
    }
}

@end
