//
//  PokeRegiViewController.m
//  Order
//
//  Created by mac-sper on 2015/03/24.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "PokeRegiViewController.h"
#import "SSGentleAlertView.h"

@interface PokeRegiViewController ()<MBProgressHUDDelegate> {
    MBProgressHUD *mbProcess;
    NSMutableDictionary *_regiMt;
    BOOL directInput;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet UIButton *bt_total;
@property (weak, nonatomic) IBOutlet UIButton *bt_receive;
@property (weak, nonatomic) IBOutlet UIButton *bt_cash;
@property (weak, nonatomic) IBOutlet UIButton *bt_card;
@property (weak, nonatomic) IBOutlet UIButton *bt_siharai1;
@property (weak, nonatomic) IBOutlet UIButton *bt_siharai2;
@property (weak, nonatomic) IBOutlet UIButton *bt_change;
@property (weak, nonatomic) IBOutlet UIButton *bt_customer;
@property (weak, nonatomic) IBOutlet UIButton *bt_ryosyusyo;

@property (weak, nonatomic) IBOutlet UILabel *lbt_total;
@property (weak, nonatomic) IBOutlet UILabel *lbt_receive;
@property (weak, nonatomic) IBOutlet UILabel *lbt_cash;
@property (weak, nonatomic) IBOutlet UILabel *lbt_card;
@property (weak, nonatomic) IBOutlet UILabel *lbt_siharai1;
@property (weak, nonatomic) IBOutlet UILabel *lbt_siharai2;
@property (weak, nonatomic) IBOutlet UILabel *lbt_change;
@property (weak, nonatomic) IBOutlet UILabel *lbt_customer;
@property (weak, nonatomic) IBOutlet UILabel *lbt_ryosyusyo;

@property (weak, nonatomic) IBOutlet UILabel *lb_total;
@property (weak, nonatomic) IBOutlet UILabel *lb_receive;
@property (weak, nonatomic) IBOutlet UILabel *lb_cash;
@property (weak, nonatomic) IBOutlet UILabel *lb_card;
@property (weak, nonatomic) IBOutlet UILabel *lb_siharai1;
@property (weak, nonatomic) IBOutlet UILabel *lb_siharai2;
@property (weak, nonatomic) IBOutlet UILabel *lb_change;
@property (weak, nonatomic) IBOutlet UILabel *lb_customer;
@property (weak, nonatomic) IBOutlet UILabel *lb_ryosyusyo;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_num000;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

- (IBAction)iba_selectInputField:(UIButton *)sender;

- (IBAction)iba_countUp:(UIButton *)sender;
- (IBAction)iba_count000:(UIButton *)sender;

- (IBAction)iba_back:(UIButton *)sender;
- (IBAction)iba_backspace:(UIButton *)sender;
- (IBAction)iba_clear:(UIButton *)sender;
- (IBAction)iba_showNext:(UIButton *)sender;
- (IBAction)iba_cancel:(UIButton *)sender;

@end

@implementation PokeRegiViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.bt_next setTitle:[String bt_checkOut] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_cancel setTitle:[String bt_cancel] forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self resetBackgroundImage];
    self.bt_siharai1.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_siharai1.bounds]];
    [self resetInputField];
    [self.bt_siharai1 setSelected:YES];

    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    _regiMt = [[NSMutableDictionary alloc]init];
    FMResultSet *results = [_net.db executeQuery:@"SELECT * FROM Regi_MT"];
    [results next];
    for (int ct = 0; ct < [results columnCount]; ct++) {
        NSString *column = [results columnNameForIndex:ct];
        [_regiMt setValue:[results stringForColumn:column] forKey:column];
    }
    [results close];
    
    self.lbt_total.text     = [String PayTitleTotal];
    self.lbt_receive.text   = @"";
    self.lbt_cash.text      = @"";
    self.lbt_card.text      = @"";
    if ([[System sharedInstance].PaymentType intValue] == 0) {
        //0:通常 , 1:宿掛専用
        self.lbt_receive.text   = [_regiMt[@"ReceiveKBN"] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
        self.lbt_cash.text      = [String PayTitleCash];
        if ([_regiMt[@"CardFLG"] isEqualToString:@"1"]) {
            self.lbt_card.text  = [String PayTitleCard];
        }
    }
    self.lbt_siharai1.text  = [_regiMt[@"PayKBN1"] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    self.lbt_siharai2.text  = @"";
    if ([[System sharedInstance].PaymentType intValue] == 0) {
        //0:通常 , 1:宿掛専用
        self.lbt_siharai2.text  = [_regiMt[@"PayKBN2"] stringByTrimmingCharactersInSet:[NSCharacterSet newlineCharacterSet]];
    }
    self.lbt_change.text    = [String PayTitleChange];
    self.lbt_customer.text  = @"";
    if ([_regiMt[@"MemberFLG"] isEqualToString:@"1"]) {
        self.lbt_customer.text  = [String PayTitleCustomer];
    }
    self.lbt_ryosyusyo.text = [String PayTitleRyosyusyo];

    self.lb_total.text     = @"";
    self.lb_receive.text   = @"";
    self.lb_cash.text      = @"";
    self.lb_card.text      = @"";
    self.lb_siharai1.text  = @"";
    self.lb_siharai2.text  = @"";
    self.lb_change.text    = @"";
    self.lb_customer.text  = @"";
    self.lb_ryosyusyo.text = @"";
    
    self.bt_ryosyusyo.hidden  = YES;
    self.lbt_ryosyusyo.hidden = YES;
    self.lb_ryosyusyo.hidden  = YES;
    
    if ([[System sharedInstance].PaymentType intValue] == 1) {
        //0:通常 , 1:宿掛専用
        self.lbt_receive.text   = @"";
        self.lbt_cash.text      = @"";
        self.lbt_card.text      = @"";
        self.lbt_change.text    = @"";
        self.lbt_siharai1.text  = @"";
        self.lbt_siharai2.text  = @"";

        self.lb_siharai1.hidden = YES;
        
        self.bt_receive.hidden  = YES;
        self.bt_cash.hidden     = YES;
        self.bt_card.hidden     = YES;
        self.bt_change.hidden   = YES;
        self.bt_siharai2.hidden = YES;
    }

    self.lb_title.text = @"";
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    DataList *dat = [DataList sharedInstance];
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        //Yen
        [self.bt_num000 setTitle:@"000" forState:UIControlStateNormal];
        NSNumber *number = [NSNumber numberWithInteger:dat.Pay_Total];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@",###"];
        self.lb_total.text = [formatter stringForObjectValue:number];
        
    } else {
        //Dollar
        [self.bt_num000 setTitle:@"00" forState:UIControlStateNormal];
        self.lb_total.text = [NSString stringWithFormat:@"%.2f", dat.Pay_Total / 100.0f];
    }

    [System adjustStatusBarSpace:self.view];

    //2016-02-03 ueda ASTERISK
    [self.bt_clear setTitle:@"CL" forState:UIControlStateNormal];
    img = [UIImage imageNamed:@"ButtonYellow.png"];
    [self.bt_clear setBackgroundImage:img forState:UIControlStateNormal];
    //2016-04-08 ueda ASTERISK
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        //英語
    } else {
        [self.bt_clear.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
        [self.bt_clear setTitle:@"クリア" forState:UIControlStateNormal];
    }
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"現在使用できません。\n処理を中止します。"];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:@"OK"];
    alert.cancelButtonIndex=0;
    alert.tag = 101;
    [alert show];
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

- (IBAction)iba_selectInputField:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (button == self.bt_total) {
        return;
    }
    if (button == self.bt_change) {
        return;
    }

    if (button == self.bt_receive) {
        if (self.lbt_receive.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_receive.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_receive.bounds]];
        [self resetInputField];
        [self.bt_receive setSelected:YES];
    }
    if (button == self.bt_cash) {
        if (self.lbt_cash.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_cash.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_cash.bounds]];
        [self resetInputField];
        [self.bt_cash setSelected:YES];
    }
    if (button == self.bt_card) {
        if (self.lbt_card.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_card.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_card.bounds]];
        [self resetInputField];
        [self.bt_card setSelected:YES];
    }
    if (button == self.bt_siharai1) {
        if (self.lbt_siharai1.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_siharai1.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_siharai1.bounds]];
        [self resetInputField];
        [self.bt_siharai1 setSelected:YES];
    }
    if (button == self.bt_siharai2) {
        if (self.lbt_siharai2.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_siharai2.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_siharai2.bounds]];
        [self resetInputField];
        [self.bt_siharai2 setSelected:YES];
    }
    if (button == self.bt_customer) {
        if (self.lbt_customer.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_customer.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_customer.bounds]];
        [self resetInputField];
        [self.bt_customer setSelected:YES];
    }
    if (button == self.bt_ryosyusyo) {
        if (self.lbt_ryosyusyo.text.length == 0) {
            return;
        }
        [self resetBackgroundImage];
        self.bt_ryosyusyo.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_ryosyusyo.bounds]];
        [self resetInputField];
        [self.bt_ryosyusyo setSelected:YES];
    }
    
    [System tapSound];
    directInput = NO;
}

- (IBAction)iba_countUp:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSInteger max = 0;
    NSInteger count = 0;
    if (self.bt_siharai1.selected){
        if (directInput) {
            count = [self.lb_siharai1.text integerValue] * 10 + button.tag;
        } else {
            count = 0 + button.tag;
        }
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        max = 7;
    }
    if (str.length>max) {
        return;
    }
    if (self.bt_siharai1.selected){
        self.lb_siharai1.text = str;
    }
    directInput = YES;
}

- (IBAction)iba_count000:(UIButton *)sender {
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        //Yen
    } else {
        //Dollar
    }
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSInteger max = 0;
    if (self.bt_siharai1.selected){
        if (directInput) {
            [str appendString:self.lb_siharai1.text];
            [str appendString:button.titleLabel.text];
        } else {
            [str appendString:@"0"];
        }
        max = 7;
    }
    if (str.length>max) {
        return;
    }
    if (self.bt_siharai1.selected){
        self.lb_siharai1.text = str;
    }
    directInput = YES;
}

- (IBAction)iba_back:(UIButton *)sender {
}

- (IBAction)iba_backspace:(UIButton *)sender {
    NSInteger count = 0;
    NSMutableString *str= [[NSMutableString alloc]init];
    if (self.bt_siharai1.selected){
        count = [self.lb_siharai1.text integerValue] / 10;
        [str appendString:[NSString stringWithFormat:@"%zd",count]];
        self.lb_siharai1.text = str;
    }
    directInput = YES;
}

- (IBAction)iba_clear:(UIButton *)sender {
    if (self.bt_siharai1.selected){
        self.lb_siharai1.text = @"0";
    }
    directInput = YES;
}

- (IBAction)iba_showNext:(UIButton *)sender {
}

- (IBAction)iba_cancel:(UIButton *)sender {
    [self showIndicator];
    [[NetWorkManager sharedInstance] pokeRegiCancel:self retryFlag:NO];
}

//////////////////////////////////////////////////////////////
#pragma mark NetWorkManagerDelegate
//////////////////////////////////////////////////////////////

-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if (type==RequestTypePokeRegiFinish) {
            NSString *_msg = (NSString*)_dataList;
            NetWorkManager *_net = [NetWorkManager sharedInstance];
            NSLog(@"伝票番号：%@",[_net getShiftJisMid:_msg startPos:4 length:4]);
            NSLog(@"残ありフラグ：%@",[_net getShiftJisMid:_msg startPos:8 length:1]);
            NSLog(@"KeyID_KBT：%@",[_net getShiftJisMid:_msg startPos:9 length:18]);
            [self.navigationController popToRootViewControllerAnimated:YES];
        }
        else if (type==RequestTypePokeRegiCancel) {
            [self.navigationController popViewControllerAnimated:YES];
        }
        else if (type==RequestTypeKokyakuInfoGet) {
            //NSDictionary *_dic = (NSDictionary*)_dataList;
            //self.lb_customerName.text = _dic[@"KokyakuName"];
            //[self.bt_next setTitle:[String bt_checkOut] forState:UIControlStateNormal];
            //[self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonSend.png"] forState:UIControlStateNormal];
        }
        [mbProcess hide:YES];
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_msg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        if (type == RequestTypePokeRegiCancel) {
            if (YES) {
                //現在未使用のため、すべて再送信
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1202;
            } else {
                //本来はこちら
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                    //NOP
                } else {
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                    alert.delegate=self;
                    alert.tag=1202;
                }
            }
        }
        [alert show];

        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

//////////////////////////////////////////////////////////////
#pragma mark MBProgressHUDDelegate methods
//////////////////////////////////////////////////////////////

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


/////////////////////////////////////////////////////////////////
#pragma mark - alertView Delegate
/////////////////////////////////////////////////////////////////

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (alertView.tag == 101) {
                [self showIndicator];
                [[NetWorkManager sharedInstance] pokeRegiCancel:self retryFlag:NO];
            }
            else if (alertView.tag==1202) {
                [self pokeRegiCancelRetry];
            }
            break;
            
        case 1:

            break;
            
    }
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

- (void)resetBackgroundImage {
    self.bt_total.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0f green:1.0f blue:128/255.0f alpha:1.0f] bounds:self.bt_total.bounds]];
    self.bt_receive.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_receive.bounds]];
    self.bt_cash.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_cash.bounds]];
    self.bt_card.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_card.bounds]];
    self.bt_siharai1.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_siharai1.bounds]];
    self.bt_siharai2.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_siharai2.bounds]];
    self.bt_change.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor colorWithRed:1.0f green:128/255.0f blue:128/255.0f alpha:1.0f] bounds:self.bt_change.bounds]];
    self.bt_customer.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_customer.bounds]];
    self.bt_ryosyusyo.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_ryosyusyo.bounds]];
}

- (void)resetInputField {
    [self.bt_total     setSelected:NO];
    [self.bt_receive   setSelected:NO];
    [self.bt_cash      setSelected:NO];
    [self.bt_card      setSelected:NO];
    [self.bt_siharai1  setSelected:NO];
    [self.bt_siharai2  setSelected:NO];
    [self.bt_change    setSelected:NO];
    [self.bt_customer  setSelected:NO];
    [self.bt_ryosyusyo setSelected:NO];
}

- (void)pokeRegiCancelRetry {
    [self showIndicator];
    [[NetWorkManager sharedInstance] pokeRegiCancel:self retryFlag:YES];
}

@end
