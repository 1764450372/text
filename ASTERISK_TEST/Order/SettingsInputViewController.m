//
//  SettingsInputViewController.m
//  Order
//
//  Created by mac-sper on 2015/06/23.
//  Copyright (c) 2015年 SPer. All rights reserved.
//

#import "SettingsInputViewController.h"
#import "SSGentleAlertView.h"
//2016-04-08 ueda
#import "CustomWindow.h"

@interface SettingsInputViewController () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UITextFieldDelegate> {
    System *sys;
    NSString *keyStr;
}

@property (weak, nonatomic) IBOutlet UITableView *settingsTableView;

@property UITextField *inputText;

@end

@implementation SettingsInputViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    sys = [System sharedInstance];
    
    self.settingsTableView.delegate = self;
    self.settingsTableView.dataSource = self;
    
    //2016-04-08 ueda
    if (YES) {
        UILabel *titleLabel = [[UILabel alloc]initWithFrame:CGRectZero];
        titleLabel.backgroundColor = [UIColor clearColor];
        titleLabel.font = [UIFont boldSystemFontOfSize:17];
        titleLabel.text = self.navigationItem.title;
        titleLabel.textColor = [UIColor whiteColor];
        [titleLabel setTextAlignment:NSTextAlignmentCenter];
        [titleLabel sizeToFit];
        titleLabel.adjustsFontSizeToFitWidth = YES;
        titleLabel.minimumScaleFactor = 0.5f;
        self.navigationItem.titleView = titleLabel;
    }

    NSString *btnTitle;
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        btnTitle = @"Save";
    } else {
        btnTitle = @"保存";
    }

    UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:btnTitle
                                                            style:UIBarButtonItemStylePlain
                                                           target:self
                                                           action:@selector(saveSetteing:)];
    self.navigationItem.rightBarButtonItems = [NSArray arrayWithObjects:btn, nil];
    
    switch (self.sectionNo) {
        case 2:
            //1111
            switch (self.rowNo) {
                case 0:
                    keyStr = @"tanmatsuID";
                    break;
                case 1:
                    keyStr = @"hostIP";
                    break;
                case 2:
                    keyStr = @"port";
                    break;
                case 3:
                    keyStr = @"timeout";
                    break;
                    
                default:
                    break;
            }
            break;
        case 3:
            //2222
            if (self.rowNo == 2) {
                keyStr = @"printOut2";
            }
            break;
        case 5:
            //4444
            switch (self.rowNo) {
                case 1:
                    keyStr = @"menuPatternType";
                    break;
                case 2:
                    keyStr = @"sectionCD";
                    break;
                    
                default:
                    break;
            }
            break;
        case 7:
            //7777
            switch (self.rowNo) {
                case 1:
                    keyStr = @"ftp_user";
                    break;
                case 2:
                    keyStr = @"ftp_password";
                    break;
                    
                default:
                    break;
            }
            break;
        case 9:
            //9061
            if (self.rowNo == 2) {
                keyStr = @"home_back";
            }
            break;
        //2016-04-08 ueda
        case 11:
            switch (self.rowNo) {
                case 2:
                    keyStr = @"notOpeCheckSecNormal";
                    break;
                case 3:
                    keyStr = @"notOpeCheckSecAlert";
                    break;
                default:
                    break;
            }
            break;

        default:
            break;
    }

}

- (void)saveSetteing:(id)sender {
    //2015-05-25 eda
    NSString *errMsg;
    switch (self.sectionNo) {
        case 2:
            //1111
            if (self.rowNo == 0) {
                //端末ＩＤ
                if (self.inputText.text.length < 4) {
                    errMsg = [NSString stringWithFormat:[String figure], 4];
                }
            }
            if (self.rowNo == 3) {
                //タイムアウト
                if (self.inputText.text.length == 0) {
                    errMsg = [NSString stringWithFormat:[String To_figure], 1, 2];
                } else {
                    if (([self.inputText.text integerValue] < 1) || ([self.inputText.text integerValue] > 99)) {
                        errMsg = [NSString stringWithFormat:[String Entry], 1, 99];
                    }
                }
            }
            break;
        case 3:
            //2222
            if (self.rowNo == 2) {
                //プリンタ番号
                if (self.inputText.text.length != 1) {
                    errMsg = [NSString stringWithFormat:[String figure], 1];
                } else {
                    //2015-06-26 ueda
                    if (([self.inputText.text integerValue] < 1) || ([self.inputText.text integerValue] > 8)) {
                        errMsg = [NSString stringWithFormat:[String Entry], 1, 8];
                    }
                }
            }
            break;
        case 5:
            //4444
            if (self.rowNo == 1) {
                //パターン番号
                if (self.inputText.text.length != 1) {
                    errMsg = [NSString stringWithFormat:[String figure], 1];
                } else {
                    if (([self.inputText.text integerValue] < 0) || ([self.inputText.text integerValue] > 7)) {
                        errMsg = [NSString stringWithFormat:[String Entry], 0, 7];
                    }
                }
            }
            break;
        case 7:
            //7777
            break;
        case 9:
            //9061
            break;
        //2016-04-08 ueda
        case 11:
            if (self.rowNo == 2) {
                //無操作秒数
                if (([self.inputText.text integerValue] < 30) || ([self.inputText.text integerValue] > 300)) {
                    errMsg = [NSString stringWithFormat:[String Entry], 30, 300];
                } else {
                    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    CustomWindow *cw = (CustomWindow*)appDelegate.window;
                    [cw setExpireTimerSecond:[self.inputText.text floatValue]];
                }
            }
            if (self.rowNo == 3) {
                if (([self.inputText.text integerValue] < 5) || ([self.inputText.text integerValue] > 300)) {
                    errMsg = [NSString stringWithFormat:[String Entry], 5, 300];
                } else {
                    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    CustomWindow *cw = (CustomWindow*)appDelegate.window;
                    [cw setExpireTimerSecond:[self.inputText.text floatValue]];
                }
            }
            break;

        default:
            break;
    }
    if (errMsg != nil) {
        //2015-06-26 ueda
        [System tapSound];
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",errMsg];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    } else {
        [sys setValue:self.inputText.text forKey:keyStr];
        [sys saveChacheAccount];
        [self.navigationController popViewControllerAnimated:YES];
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

//2015-06-26 ueda
-(BOOL) textFieldShouldClear:(UITextField*)theTextField {
    [System tapSound];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    //2015-06-26 ueda
    [System tapSound];
    [theTextField resignFirstResponder];
    return YES;
}

//2015-06-24 ueda
- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    int maxInputLength = 20;    // 最大入力文字数
    BOOL dotOkFg = YES;
    
    switch (self.sectionNo) {
        case 2:
            //1111
            switch (self.rowNo) {
                case 0:
                    maxInputLength = 4;
                    dotOkFg = NO;
                    break;
                case 2:
                    maxInputLength = 5;
                    dotOkFg = NO;
                    break;
                case 3:
                    maxInputLength = 2;
                    dotOkFg = NO;
                    break;
                    
                default:
                    break;
            }
            break;
        case 3:
            //2222
            switch (self.rowNo) {
                case 2:
                    maxInputLength = 1;
                    dotOkFg = NO;
                    break;
                    
                default:
                    break;
            }
            break;
        case 5:
            //4444
            switch (self.rowNo) {
                case 1:
                    maxInputLength = 1;
                    dotOkFg = NO;
                    break;
                case 2:
                    maxInputLength = 2;
                    dotOkFg = NO;
                    break;
                    
                default:
                    break;
            }
            break;
            //2016-04-01 ueda
        case 11:
            switch (self.rowNo) {
                case 2:
                    maxInputLength = 3;
                    dotOkFg = NO;
                    break;
                case 3:
                    maxInputLength = 3;
                    dotOkFg = NO;
                    break;

                default:
                    break;
            }
            break;
            
        default:
            break;
    }
    
    if (!dotOkFg) {
        if ([string isEqualToString:@"."]) {
            return NO;
        }
    }
    
    // 入力済みのテキストを取得
    NSMutableString *str = [textField.text mutableCopy];
    // 入力済みのテキストと入力が行われたテキストを結合
    [str replaceCharactersInRange:range withString:string];
    if ([str length] > maxInputLength) {
        // ※ここに文字数制限を超えたことを通知する処理を追加
        return NO;
    }
    
    //2015-06-26 ueda
    [System tapSound];
    return YES;
}

//////////////////////////////////////////////////////////////
#pragma mark - Settings TableView
//////////////////////////////////////////////////////////////

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1
                                      reuseIdentifier:CellIdentifier];
    }
    
    //UITextField *inputText = [[UITextField alloc] initWithFrame:CGRectMake(3, 5, 314, 34)];
    //2015-06-26 ueda
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        self.inputText = [[UITextField alloc] initWithFrame:CGRectMake(3, 5, 314, 34)];
        self.inputText.clearButtonMode = UITextFieldViewModeWhileEditing;
        //self.inputText.borderStyle = UITextBorderStyleLine;
    } else {
        self.inputText = [[UITextField alloc] initWithFrame:CGRectMake(3, 5, 304, 34)];
    }
    [self.inputText setFont:[UIFont systemFontOfSize:28.0]];
    self.inputText.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.inputText.textAlignment = NSTextAlignmentCenter;
    self.inputText.returnKeyType = UIReturnKeyDone;
    self.inputText.delegate = self;
    [cell.contentView addSubview:self.inputText];
    [self.inputText becomeFirstResponder];
    
//    self.inputText.keyboardType = UIKeyboardTypeDecimalPad;
    self.inputText.keyboardType = UIKeyboardTypeNumberPad;
    if (self.sectionNo == 2) {
        //1111
        if (self.rowNo == 1) {
            self.inputText.keyboardType = UIKeyboardTypeDecimalPad;
        }
    }
    if (self.sectionNo == 7) {
        //7777
        if ((self.rowNo == 1) || (self.rowNo == 2)) {
            self.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        }
    }
    if (self.sectionNo == 9) {
        //9061
        if (self.rowNo == 2) {
            self.inputText.keyboardType = UIKeyboardTypeASCIICapable;
        }
    }
    self.inputText.text = [sys valueForKey:keyStr];
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    NSString *headerStr;
    
    switch (self.sectionNo) {
        case 2:
            //1111
            switch (self.rowNo) {
                case 0:
                    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                        headerStr = @"Four columns";
                    } else {
                        headerStr = @"４桁";
                    }
                    break;
                case 3:
                    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                        headerStr = @"1 - 99 seconds";
                    } else {
                        headerStr = @"１〜９９秒";
                    }
                    break;
                    
                default:
                    headerStr = @"";
                    break;
            }
            break;
        case 3:
            //2222
            //2015-06-26 ueda
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                headerStr = @"1 - 8";
            } else {
                headerStr = @"１〜８";
            }
            break;
        case 5:
            //4444
            switch (self.rowNo) {
                case 1:
                    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                        headerStr = @"0 - 7";
                    } else {
                        headerStr = @"０〜７";
                    }
                    break;
                case 2:
                    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                        headerStr = @"Two columns";
                    } else {
                        headerStr = @"２桁";
                    }
                    break;
                    
                default:
                    headerStr = @"";
                    break;
            }
            break;
        case 7:
            //7777
            headerStr = @"";
            break;
        case 9:
            //9061
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                headerStr = @"Keywords";
            } else {
                headerStr = @"キーワード";
            }
            break;
        //2016-04-08 ueda
        case 11:
            if (self.rowNo == 2) {
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    headerStr = @"30 - 300";
                } else {
                    headerStr = @"３０〜３００";
                }
            }
            if (self.rowNo == 3) {
                if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                    headerStr = @"5 - 300";
                } else {
                    headerStr = @"５〜３００";
                }
            }
            break;

        default:
            break;
    }

    return headerStr;
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        return @"I input a value, and click Save button of the top right corner.";
    } else {
        return @"設定値を入力して右上の保存ボタンをクリックして下さい。";
    }
}

@end
