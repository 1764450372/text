//
//  PokeRegiYadokakeOnyViewController.m
//  Order
//
//  Created by mac-sper on 2015/03/24.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "PokeRegiYadokakeOnyViewController.h"
#import "SSGentleAlertView.h"
#import "BarcodeReaderViewController.h"

@interface PokeRegiYadokakeOnyViewController () <MBProgressHUDDelegate , BarcodeReaderViewDelegate> {
    MBProgressHUD *mbProcess;
    NSMutableDictionary *_regiMt;
    BOOL directInput;
    BOOL _useBarcodeReader;
    BOOL _canUseBarcodeReader;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet UIButton *bt_total;
@property (weak, nonatomic) IBOutlet UIButton *bt_customer;
@property (weak, nonatomic) IBOutlet UIButton *bt_customerName;

@property (weak, nonatomic) IBOutlet UILabel *lbt_total;
@property (weak, nonatomic) IBOutlet UILabel *lbt_customer;
@property (weak, nonatomic) IBOutlet UILabel *lbt_customerName;

@property (weak, nonatomic) IBOutlet UILabel *lb_total;
@property (weak, nonatomic) IBOutlet UILabel *lb_customer;
@property (weak, nonatomic) IBOutlet UILabel *lb_customerName;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_dot;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_cancel;
@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

- (IBAction)iba_countUp:(UIButton *)sender;
- (IBAction)iba_dot:(UIButton *)sender;

- (IBAction)iba_backspace:(UIButton *)sender;
- (IBAction)iba_clear:(UIButton *)sender;
- (IBAction)iba_showNext:(UIButton *)sender;
- (IBAction)iba_cancel:(UIButton *)sender;

@end

@implementation PokeRegiYadokakeOnyViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.

    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_cancel setTitle:[String bt_cancel] forState:UIControlStateNormal];
    [self.bt_next setTitle:[String bt_search] forState:UIControlStateNormal];
    [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

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
    self.lbt_customer.text  = [String PayTitleCustomer];
    self.lbt_customerName.text  = [String PayTitleCustomerName];

    self.lb_total.text        = @"";
    self.lb_customer.text     = @"";
    self.lb_customerName.text = @"";
    
    self.lb_title.text = @"";
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    self.bt_total.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_customer.bounds]];
    self.bt_customer.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.bt_customer.bounds]];
    self.bt_customerName.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:self.bt_customer.bounds]];
    
    [System adjustStatusBarSpace:self.view];

    DataList *dat = [DataList sharedInstance];
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        //Yen
        NSNumber *number = [NSNumber numberWithInteger:dat.Pay_Total];
        NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
        [formatter setPositiveFormat:@",###"];
        self.lb_total.text = [formatter stringForObjectValue:number];
        
    } else {
        //Dollar
        self.lb_total.text = [NSString stringWithFormat:@"%.2f", dat.Pay_Total / 100.0f];
    }

    self.bt_cancel.hidden = YES;
    self.bt_dot.enabled = NO;
    directInput = NO;
    _useBarcodeReader = NO;
    _canUseBarcodeReader = NO;
    NSString *useBar = [System sharedInstance].useBarcode;
    if ((useBar.length == 0) || ([useBar isEqualToString:@"0"])) {
        if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
            _canUseBarcodeReader = YES;
            _useBarcodeReader    = YES;
            self.bt_dot.enabled = YES;
            [self.bt_dot.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                [self.bt_dot setTitle:@"Canera" forState:UIControlStateNormal];
            } else {
                [self.bt_dot setTitle:@"カメラ" forState:UIControlStateNormal];
            }
        }
    }
    //2016-02-03 ueda ASTERISK
    [self.bt_clear setTitle:@"CL" forState:UIControlStateNormal];
    UIImage *img = [UIImage imageNamed:@"ButtonYellow.png"];
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

    if (![_regiMt[@"UrikakeFLG1"] isEqualToString:@"1"]) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String urikake1Error]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        alert.tag = 101;
        [alert show];
    } else {
        if (_canUseBarcodeReader) {
            if (_useBarcodeReader) {
                _useBarcodeReader = NO;
                [self cameraViewStart];
            }
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

- (IBAction)iba_countUp:(UIButton *)sender {
    UIButton *button = (UIButton*)sender;
    if (directInput) {
        NSMutableString *str= [[NSMutableString alloc]init];
        [str appendString:self.lb_customer.text];
        [str appendString:[NSString stringWithFormat:@"%zd",button.tag]];
        NSInteger max = 10;
        if (str.length>max) {
            return;
        }
        self.lb_customer.text = str;
    } else {
        self.lb_customer.text = [NSString stringWithFormat:@"%zd",button.tag];
    }
    directInput = YES;
    self.lb_customerName.text = @"";
    [self.bt_next setTitle:[String bt_search] forState:UIControlStateNormal];
    [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)iba_dot:(UIButton *)sender {
    if (_canUseBarcodeReader) {
        [self cameraViewStart];
        return;
    }
}

- (IBAction)iba_backspace:(UIButton *)sender {
    NSMutableString *str= [[NSMutableString alloc]init];
    [str appendString:self.lb_customer.text];
    if (str.length == 0) {
        return;
    }
    [str deleteCharactersInRange:NSMakeRange(str.length - 1, 1)];
    self.lb_customer.text = str;
    self.lb_customerName.text = @"";
    [self.bt_next setTitle:[String bt_search] forState:UIControlStateNormal];
    [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)iba_clear:(UIButton *)sender {
    self.lb_customer.text = @"";
    self.lb_customerName.text = @"";
    [self.bt_next setTitle:[String bt_search] forState:UIControlStateNormal];
    [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (IBAction)iba_showNext:(UIButton *)sender {
    if ([self.bt_next.titleLabel.text isEqualToString:[String bt_search]]) {
        [self showIndicator];
        [DataList sharedInstance].currentKokyakuCD = self.lb_customer.text;
        [[NetWorkManager sharedInstance] getKokyaku:self count:1];
    } else {
        [self showIndicator];
        [DataList sharedInstance].currentKokyakuCD = self.lb_customer.text;
        [[NetWorkManager sharedInstance] pokeRegiFinish:self retryFlag:NO];
    }
    directInput = NO;
}

- (IBAction)iba_cancel:(UIButton *)sender {
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String PokeRegiCancel]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 101;
    [alert show];
}

//////////////////////////////////////////////////////////////
#pragma mark BarcodeReader delegate
//////////////////////////////////////////////////////////////

//iOS7標準のバーコード読み取りデータ
- (void)finishView:(NSString*)returnValue{
    NSInteger maxInputLength = 10;
    if (returnValue.length > maxInputLength) {
        self.lb_customer.text = [returnValue substringToIndex:maxInputLength];
    } else {
        self.lb_customer.text = returnValue;
    }
    self.lb_customerName.text = @"";
    [self.bt_next setTitle:[String bt_search] forState:UIControlStateNormal];
    [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonNext.png"] forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self iba_showNext:nil];
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
            NSDictionary *_dic = (NSDictionary*)_dataList;
            self.lb_customerName.text = _dic[@"KokyakuName"];
            [self.bt_next setTitle:[String bt_checkOut] forState:UIControlStateNormal];
            [self.bt_next setBackgroundImage:[UIImage imageNamed:@"ButtonSend.png"] forState:UIControlStateNormal];
            //2016-02-03 ueda ASTERISK
            [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
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
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                //NOP
            } else {
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1202;
            }
        }
        else if (type == RequestTypePokeRegiFinish) {
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            if ((appDelegate.communication_Step_Status == communication_Step_NotConnect) || (appDelegate.communication_Step_Status == communication_Step_Recieved)) {
                //NOP
            } else {
                alert.message=[NSString stringWithFormat:@"　\n%@\n　\n%@",_msg,[String sendOrderRetry]];
                alert.delegate=self;
                alert.tag=1203;
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
            else if (alertView.tag==1203) {
                [self pokeRegiFinishRetry];
            }
            break;
            
        case 1:
            
            break;
            
    }
}

/////////////////////////////////////////////////////////////////
#pragma mark - UEDA method
/////////////////////////////////////////////////////////////////

- (void)cameraViewStart {
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        BarcodeReaderViewController *barcodeReaderViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BCDVIEW"];
        barcodeReaderViewController.delegate = self;
        barcodeReaderViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
        [self presentViewController:barcodeReaderViewController animated:YES completion:nil];
    }
}

- (void)pokeRegiCancelRetry {
    [self showIndicator];
    [[NetWorkManager sharedInstance] pokeRegiCancel:self retryFlag:YES];
}

- (void)pokeRegiFinishRetry {
    [self showIndicator];
    [[NetWorkManager sharedInstance] pokeRegiFinish:self retryFlag:YES];
}

@end
