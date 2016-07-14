//
//  SettingEntryViewController.m
//  Order
//
//  Created by koji kodama on 13/04/28.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "SettingEntryViewController.h"
#import "SSGentleAlertView.h"

@interface SettingEntryViewController ()

@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

@end

@implementation SettingEntryViewController

#pragma mark -
#pragma mark - Control object action

- (IBAction)iba_back:(id)sender{
    UIButton *_bt = (UIButton*)sender;
    
    if ([currentStep isEqualToString:@"9999"]||_bt.tag==9999) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if ([currentStep isEqualToString:@"0"]) {
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                       message:[String Setting_cancel]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[String Yes],[String No], nil];
        */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Setting_cancel]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        //alert.messageLabel.textAlignment = NSTextAlignmentLeft;
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 1;
        [alert show];
    }
    else{

        if ([sys.menuPatternEnable isEqualToString:@"1"]&&
            [currentStep isEqualToString:@"2"]&&[passkey isEqualToString:@"4444"]) {
            currentStep = [NSString stringWithFormat:@"%d",[currentStep intValue]-2];
            [self reloadDispStep];
        }
        else{
            currentStep = [NSString stringWithFormat:@"%d",[currentStep intValue]-1];
            [self reloadDispStep];
        }
    
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==1) {
        switch (buttonIndex) {
            case 0:
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==2) {
        switch (buttonIndex) {
            case 0:
                //2015-06-17
                if ([passkey isEqualToString:@"4444"]) {
                    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                    appDelegate.getMasterSetFg = 1;
                }
                [sys saveChacheAccount];
                [self.navigationController popViewControllerAnimated:YES];
                break;
                
            case 1:
                break;
        }
    }
}

- (IBAction)iba_showNext:(id)sender{
    LOG(@"%zd",self.lb_counter.text.length);
    
    //2014-01-31 ueda
    //2014-10-30 ueda
    if ([currentStep isEqualToString:@"1"]&&[passkey isEqualToString:@"7777"]) {
        //FTP-User
        self.lb_counter.text = self.textField.text;
        [sys setValue:self.lb_counter.text forKey:currentSetting[[currentStep intValue]][@"key"]];
    }
    if ([currentStep isEqualToString:@"2"]&&[passkey isEqualToString:@"7777"]) {
        //FTP-Password
        self.lb_counter.text = self.textField.text;
        [sys setValue:self.lb_counter.text forKey:currentSetting[[currentStep intValue]][@"key"]];
    }
    if ([currentStep isEqualToString:@"2"]&&[passkey isEqualToString:@"9061"]) {
        //home_back
        self.lb_counter.text = self.textField.text;
        [sys setValue:self.lb_counter.text forKey:currentSetting[[currentStep intValue]][@"key"]];
    }
    
    BOOL isFinish = NO;
    
    if (![currentStep isEqualToString:@"9999"]) {
        
        if ([currentStep intValue]<[currentSetting count]) {
            NSMutableDictionary *set = currentSetting[[currentStep intValue]];
            
            //入力の場合
            if ([set[@"entryType"]isEqualToString:@"0"]) {
                
                if ([set[@"rightEnable"]isEqualToString:@"0"]&&
                    ((self.lb_counter.text.length>max && max>0)
                     ||self.lb_counter.text.length<min)) {
                        NSString *_str = nil;
                        if (min==max) {
                            _str = [NSString stringWithFormat:[String figure],max];
                        }
                        else{
                            _str = [NSString stringWithFormat:[String To_figure],min,max];
                        }
                        //2014-01-31 ueda
                        //Alert([String Order_Station], _str);
                        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                      //alert.title=[String Order_Station];
                        alert.message=[NSString stringWithFormat:@"　\n%@\n　",_str];
                        alert.messageLabel.font=[UIFont systemFontOfSize:18];
                        alert.delegate=nil;
                        [alert addButtonWithTitle:@"OK"];
                        alert.cancelButtonIndex=0;
                        [alert show];
                        return;
                }
                else if ([set[@"rightEnable"]isEqualToString:@"1"]&&
                         ((self.lb_counter.text.intValue>max && max>0)
                          ||self.lb_counter.text.intValue<min)) {
                             NSString *_str = nil;
                             if (min==max) {
                                 _str = [NSString stringWithFormat:[String Entry_to],max];
                             }
                             else{
                                 _str = [NSString stringWithFormat:[String Entry],min,max];
                             }
                             //2014-01-31 ueda
                             //Alert([String Order_Station], _str);
                             SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                           //alert.title=[String Order_Station];
                             alert.message=[NSString stringWithFormat:@"　\n%@\n　",_str];
                             alert.messageLabel.font=[UIFont systemFontOfSize:18];
                             alert.delegate=nil;
                             [alert addButtonWithTitle:@"OK"];
                             alert.cancelButtonIndex=0;
                             [alert show];
                             return;
                }
                
                    [sys setValue:self.lb_counter.text forKey:currentSetting[[currentStep intValue]][@"key"]];
                    LOG(@"save:%@:%@",self.lb_counter.text,currentSetting[[currentStep intValue]][@"key"]);
            }
            //2015-06-01 ueda
/*
            //プリント先が固定のため次は表示しない
            if ([sys.printOut1 isEqualToString:@"1"]&&
                [currentStep isEqualToString:@"0"]&&[passkey isEqualToString:@"2222"]) {
                isFinish = YES;
            }
 */
            //2015-06-01 ueda
            //else if ([sys.menuPatternEnable isEqualToString:@"1"]&&
            if ([sys.menuPatternEnable isEqualToString:@"1"]&&
                [currentStep isEqualToString:@"0"]&&[passkey isEqualToString:@"4444"]) {
                
                currentStep = [NSString stringWithFormat:@"%d",[currentStep intValue]+1];
                [self reloadDispStep];
                
                currentStep = [NSString stringWithFormat:@"%d",[currentStep intValue]+1];
                [self reloadDispStep];
                
                sys.menuPatternType = sys.menuPattern;
            }
            else{
                if ([currentSetting count]==[currentStep intValue]+1) {
                    isFinish = YES;
                }
                else{
                    currentStep = [NSString stringWithFormat:@"%d",[currentStep intValue]+1];
                    [self reloadDispStep];
                }
            }
        }
        else{
            isFinish = YES;
        }
        
        if (isFinish) {
            //終了確認の場合
            NSMutableString *_str = [[NSMutableString alloc]init];
            for (int ct = 0; ct<[currentSetting count];ct++) {
                NSMutableDictionary *_dic = currentSetting[ct];
                if ([_dic[@"confirm"]isEqualToString:@"1"]) {
                    [_str appendString:_dic[@"title"]];
                    [_str appendString:@":"];
                    [_str appendString:[sys valueForKey:_dic[@"key"]]];
                    [_str appendString:@"\n"];
                }
            }
            
            [_str appendString:[String Change_setting]];
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String The_change_of_the_setting]
                                                           message:_str
                                                          delegate:self
                                                 cancelButtonTitle:nil
                                                 otherButtonTitles:[String Yes],[String No], nil];
            */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",_str];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.messageLabel.textAlignment = NSTextAlignmentLeft;
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 2;
            [alert show];
        }
    }
    else{
        [self reloadDispStep];
    }
}

- (IBAction)iba_countUp:(id)sender{
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSMutableDictionary *set = currentSetting[[currentStep intValue]];
    if ([set[@"headZero"]isEqualToString:@"0"]) {
        if (![self.lb_counter.text isEqualToString:@"0"]) {
            [str appendString:self.lb_counter.text];
        }
    }
    else{
        [str appendString:self.lb_counter.text];
    }
    [str appendString:[NSString stringWithFormat:@"%zd",button.tag]];
    
    
    if (![currentStep isEqualToString:@"9999"]) {
        if ([set[@"rightEnable"]isEqualToString:@"0"]){
            if (str.length>max) {
                return;
            }
        }
        else{
            if (str.intValue>max) {
                return;
            }
        }
    }
    self.lb_counter.text = str;
}

- (IBAction)iba_clear:(id)sender{
    NSMutableDictionary *set = currentSetting[[currentStep intValue]];
    if (self.lb_counter.textAlignment==NSTextAlignmentLeft||
        [set[@"headZero"]isEqualToString:@"1"]){
        self.lb_counter.text = @"";
    }
    else{
        self.lb_counter.text = @"0";
    }
}

- (IBAction)iba_backspace:(id)sender{
    NSMutableString *str= [[NSMutableString alloc]init];
    [str appendString:self.lb_counter.text];
    
    if (str.length==0) {
        return;
    }
    
    [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];

    self.lb_counter.text = str;
    
    if ([self.lb_counter.text length]==0) {
        NSMutableDictionary *set = currentSetting[[currentStep intValue]];
        if (self.lb_counter.textAlignment==NSTextAlignmentLeft||
            [set[@"headZero"]isEqualToString:@"1"]){
            self.lb_counter.text = @"";
        }
        else{
            self.lb_counter.text = @"0";
        }
    }
}

- (IBAction)iba_dot:(id)sender{
    NSMutableString *str= [[NSMutableString alloc]init];
    [str appendString:self.lb_counter.text];
    //2015-06-23 ueda
/*
    if (str.length==0) {
        return;
    }
 */
    [str appendString:[NSString stringWithFormat:@"."]];
    self.lb_counter.text = str;
}

- (IBAction)iba_selectDidTap:(id)sender{
    UIButton *_bt = (UIButton*)sender;
    //2014-10-16 ueda
    /*
	for (UIView *view in self.topView.subviews) {
        view.backgroundColor = [UIColor whiteColor];
        //2014-07-11 ueda
        [view setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:view.bounds]]];
	}
    _bt.backgroundColor = BLUE;
    //2014-07-11 ueda
    [_bt setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:_bt.bounds]]];
     */
    if (YES) {
        for (UIButton *view in self.topView.subviews) {
            view.backgroundColor = [UIColor clearColor];
            UIImage *image = [System imageWithColorAndRectFullSize:WHITE_BACK bounds:view.bounds];
            [view setBackgroundImage:image forState:UIControlStateNormal];
            [view setBackgroundImage:image forState:UIControlStateHighlighted];
        }
        _bt.backgroundColor = [UIColor clearColor];
        UIImage *image = [System imageWithColorAndRectFullSize:BLUE bounds:_bt.bounds];
        [_bt setBackgroundImage:image forState:UIControlStateNormal];
        [_bt setBackgroundImage:image forState:UIControlStateHighlighted];
    }
    
    //2014-02-18 ueda
    [System tapSound];
    
    NSString *value = currentSetting[[currentStep intValue]][@"selectValue"][_bt.tag];
    [sys setValue:value forKey:currentSetting[[currentStep intValue]][@"key"]];
    
    LOG(@"save:%zd:%@",_bt.tag,currentSetting[[currentStep intValue]][@"key"]);
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
    
    self.lb_title.text = [String Setting_system];
    
    [self.bt_next setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    [self.bt_done setTitle:[String bt_finish] forState:UIControlStateNormal];
    
    setting = [[NSMutableDictionary alloc]init];
    
    //title = 文字列
    //entryType = 入力方式 0:入力 1:選択
    //rightEnable = 0:左寄せ 1:右寄せ
    //select = 選択方式の文字配列
    //key = 結果を保管するキー名
    //max = 入力可能最大桁数
    //min = 入力可能最小桁数
    //dot = 0:disable 1:enable
    //confirm = 0:disable 1:enable
    //headZero = 0:不許可 1:許可
    
    
    NSMutableArray *setting1111 = [[NSMutableArray alloc]init];
    setting1111[0] = @{@"title": [String TerminalID],
                       @"entryType": @"0",
                       @"rightEnable": @"0",
                       @"select": @"0",
                       @"key": @"tanmatsuID",
                       @"max": @"4",
                       @"min": @"4",
                       @"dot": @"0",
                       @"confirm": @"1",
                       @"headZero": @"1"
                       };
    
    setting1111[1] = @{@"title": [String HostIP],
                       @"entryType": @"0",
                       @"rightEnable": @"0",
                       @"select": @"0",
                       @"key": @"hostIP",
                       @"max": @"17",
                       @"min": @"0",
                       @"dot": @"1",
                       @"confirm": @"1",
                       @"headZero": @"1"
                       };
    //2014-08-01 ueda
    setting1111[2] = @{@"title": [String PortNoStr],
                       @"entryType": @"0",
                       @"rightEnable": @"0",
                       @"select": @"0",
                       @"key": @"port",
                       @"max": @"5",
                       @"min": @"0",
                       @"dot": @"1",
                       @"confirm": @"1",
                       @"headZero": @"1"
                       };
    
    setting1111[3] = @{@"title": [String Time_out],
                       @"entryType": @"0",
                       @"rightEnable": @"1",
                       @"select": @"0",
                       @"key": @"timeout",
                       @"max": @"99",
                       @"min": @"1",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    //2014-09-05 ueda
    setting1111[4] = @{@"title": [String Entry_Type],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[@"A",@"B",@"C"],
                       @"selectValue": @[@"0",@"1",@"2"],
                       @"key": @"entryType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting1111[5] = @{@"title": [String Slip_request_type],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Slip_No],[String Details],[String Newes]],
                       @"selectValue": @[@"0",@"1",@"2"],
                       @"key": @"voucherType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting1111[6] = @{@"title": [String Non_selection_menu],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On],[String Off]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"nonselect",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    //2015-06-23 ueda
    setting1111[7] = @{@"title": [String Sound_effect],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"sound",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    
    NSMutableArray *setting2222 = [[NSMutableArray alloc]init];
    //2015-04-14 ueda
    setting2222[0] = @{@"title": [String tableMultiSelectTitle],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String tableMultiSelectOkTitle],[String tableMultiSelectNgTitle]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"tableMultiSelect",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };

    setting2222[1] = @{@"title": [String Fixation_of_checkout],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On2],[String Off2]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"printOut1",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting2222[2] = @{@"title": [String Checkout_slip_output],
                       @"entryType": @"0",
                       @"rightEnable": @"1",
                       @"select": @"0",
                       @"key": @"printOut2",
                       @"max": @"8",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    //2015-06-01 ueda
    setting2222[3] = @{@"title": [String useOrderStatusTitle],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String useOrderStatusNotTitle],[String useOrderStatusYesTitle]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"useOrderStatus",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };

    //2015-09-17 ueda
    setting2222[4] = @{@"title": [String useOrderConfirmTitle],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String useOrderConfirmNotTitle],[String useOrderConfirmYesTitle]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"useOrderConfirm",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
   NSMutableArray *setting3333 = [[NSMutableArray alloc]init];
    setting3333[0] = @{@"title": [String Table_input_type],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Select],[String Input]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"tableType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting3333[1] = @{@"title": [String Order_code_input],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Off3],[String On3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"codeType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting3333[2] = @{@"title": [String Regular_Category],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Off3],[String On3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"regularCategory",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting3333[3] = @{@"title": [String Input_SP],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Modify],[String Off4],[String QTY]],
                       @"selectValue": @[@"0",@"1",@"2"],
                       @"key": @"kakucho1Type",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    //2015-03-24 ueda
    setting3333[4] = @{@"title": [String RegisterType],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Off4],[String SimpleRegi],[String PokeRegi],[String PokeRegiOnly]],
                       @"selectValue": @[@"0",@"1",@"2",@"3"],
                       @"key": @"RegisterType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    setting3333[5] = @{@"title": [String PaymentType],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String PayNormal],[String PayYadokake]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"PaymentType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };

    setting3333[6] = @{@"title": [String Search_key],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"searchType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    //2014-08-19 ueda
    setting3333[7] = @{@"title": [String useBarcodeMsg],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"useBarcode",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    
    
    NSMutableArray *setting4444 = [[NSMutableArray alloc]init];
    setting4444[0] = @{@"title": [String Menu_list],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On5],[String Off5]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"menuPatternEnable",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting4444[1] = @{@"title": [String Menu_list_pattern],
                       @"entryType": @"0",
                       @"rightEnable": @"1",
                       @"select": @"0",
                       @"key": @"menuPatternType",
                       @"max": @"7",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting4444[2] = @{@"title": [String SectionCD],
                       @"entryType": @"0",
                       @"rightEnable": @"1",
                       @"select": @"0",
                       @"key": @"sectionCD",
                       @"max": @"99",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"1",
                       @"headZero": @"1"
                       };
    //2014-12-12 ueda
    setting4444[3] = @{@"title": [String childInputStr],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"childInputOnOff",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    //2015-04-20 ueda
    setting4444[4] = @{@"title": [String staffCodeInputTitle],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"staffCodeInputOnOff",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    //2015-06-17 ueda
    setting4444[5] = @{@"title": [String staffCodeKetaTitle],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String staffCodeKeta6],[String staffCodeKeta2]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"staffCodeKetaKbn",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
   
    NSMutableArray *setting6666 = [[NSMutableArray alloc]init];
    setting6666[0] = @{@"title": [String Divide_type],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Divide10],[String Divide2]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"bunkatsuType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting6666[1] = @{@"title": [String Input_SP2],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String VLayer],[String Off4],[String Customer]],
                       @"selectValue": @[@"0",@"1",@"2"],
                       @"key": @"kakucho2Type",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting6666[2] = @{@"title": [String Cooking_instruction],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"choriType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    //2014-02-09 ueda
    NSMutableArray *setting7777 = [[NSMutableArray alloc]init];
    setting7777[0] = @{@"title": [String Transceiver],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"transceiver",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting7777[1] = @{@"title": [String Ftp_user],
                       @"entryType": @"X",
                       @"rightEnable": @"0",
                       @"select": @"",
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"ftp_user",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"1",
                       @"headZero": @"0"
                       };
    
    setting7777[2] = @{@"title": [String Ftp_password],
                       @"entryType": @"X",
                       @"rightEnable": @"0",
                       @"select": @"",
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"ftp_password",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"1",
                       @"headZero": @"0"
                       };
    
    NSMutableArray *setting8888 = [[NSMutableArray alloc]init];
    setting8888[0] = @{@"title": [String Training],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On6],[String Off6]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"training",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    NSMutableArray *setting9999 = [[NSMutableArray alloc]init];
    setting9999[0] = @{@"title": [String Language],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Japanese],[String English]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"lang",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting9999[1] = @{@"title": [String Currency],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String Yen],[String Dollar]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"money",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    //2014-09-05 ueda
    setting9999[2] = @{@"title": [String typeCseatCaptionType],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String typeCseatCaptionAlphabet],[String typeCseatCaptionNumber]],
                       @"selectValue": @[@"0",@"1"],
                       @"key": @"typeCseatCaptionType",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    NSMutableArray *setting0000 = [[NSMutableArray alloc]init];
    setting0000[0] = @{@"title": [String Demo],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"demo",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    //2014-10-28 ueda
    //オーダーエントリーの０リセットやアレンジの座標問題がクリアーできないので
    NSMutableArray *setting9061 = [[NSMutableArray alloc]init];
    setting9061[0] = @{@"title": [String transitionStr],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"transitionOnOff",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    setting9061[1] = @{@"title": [String scrollStr],
                       @"entryType": @"1",
                       @"rightEnable": @"0",
                       @"select": @[[String On3],[String Off3]],
                       @"selectValue": @[@"1",@"0"],
                       @"key": @"scrollOnOff",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"0",
                       @"headZero": @"0"
                       };
    
    
    setting9061[2] = @{@"title": [String home_back],
                       @"entryType": @"X",
                       @"rightEnable": @"0",
                       @"select": @"",
                       @"selectValue": @[@""],
                       @"key": @"home_back",
                       @"max": @"0",
                       @"min": @"0",
                       @"dot": @"0",
                       @"confirm": @"1",
                       @"headZero": @"0"
                       };
    
    setting[@"1111"] = setting1111;
    setting[@"2222"] = setting2222;
    setting[@"3333"] = setting3333;
    setting[@"4444"] = setting4444;
    setting[@"6666"] = setting6666;
    //2014-02-09 ueda
    setting[@"7777"] = setting7777;
    setting[@"8888"] = setting8888;
    setting[@"9999"] = setting9999;
    setting[@"0000"] = setting0000;
    //2014-10-28 ueda
    //オーダーエントリーの０リセットやアレンジの座標問題がクリアーできない
    setting[@"9061"] = setting9061;
    
    //2014-01-31 ueda
    //self.textField.borderStyle = UITextBorderStyleNone;
    self.textField.hidden = YES;
    
    currentStep = @"9999";
    sys = [System sharedInstance];
    
    [self reloadDispStep];
    
    //2014-03-06 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonTenkey.png"];
    [self.bt_Num0 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num1 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num2 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num3 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num4 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num5 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num6 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num7 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num8 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_Num9 setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_dot  setBackgroundImage:img forState:UIControlStateNormal];
    self.bt_Num0.soundFileName = @"ppush0";
    self.bt_Num1.soundFileName = @"ppush1";
    self.bt_Num2.soundFileName = @"ppush2";
    self.bt_Num3.soundFileName = @"ppush3";
    self.bt_Num4.soundFileName = @"ppush4";
    self.bt_Num5.soundFileName = @"ppush5";
    self.bt_Num6.soundFileName = @"ppush6";
    self.bt_Num7.soundFileName = @"ppush7";
    self.bt_Num8.soundFileName = @"ppush8";
    self.bt_Num9.soundFileName = @"ppush9";
    self.bt_dot.soundFileName  = @"ppushs";
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];

    [System adjustStatusBarSpace:self.view];
    
    //2014-07-17 ueda
    if ([System is568h]) {
    } else {
        self.lb_titleEntry.frame = CGRectMake(self.lb_titleEntry.frame.origin.x,
                                              self.lb_titleEntry.frame.origin.y,
                                              self.lb_titleEntry.frame.size.width,
                                              self.lb_titleEntry.frame.size.height - 20);
    }
    
    //2014-12-11 ueda
    self.entryView.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.entryView.bounds]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    //2015-06-23 ueda
    self.navigationController.navigationBarHidden = YES;
    //2015-09-17 ueda
    sys = [System sharedInstance];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    
    
    //if ([currentStep isEqualToString:@"1111"]) {
        //トランシーバの設定を更新する
        if ([[System sharedInstance].transceiver intValue]==0) {
            //ネットワークが切れた場合を想定して再接続させる
            [[NetWorkManager sharedInstance] readyForBroadCastReceive];
        }
        else{
            [[NetWorkManager sharedInstance] finishForBroadCastReceive];
        }
    //}
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
    [self setEntryView:nil];
    [self setLb_titleEntry:nil];
    [self setBt_dot:nil];
    [self setBt_return:nil];
    [self setBt_next:nil];
    [self setBt_done:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    /*
     if([[segue identifier]isEqualToString:@"VtoD"]){
     NSDictionary *_dic = (NSDictionary*)sender;
     DetailViewController *view_ = (DetailViewController *)[segue destinationViewController];
     NSString *aImagePath = [[NSBundle mainBundle] pathForResource:[_dic valueForKey:@"thumbnail"] ofType:@"jpg"];
     UIImage *image = [[UIImage alloc]initWithContentsOfFile:aImagePath];
     view_.image = image;
     [image release];
     }
     */
    //2015-06-23 ueda
    if([[segue identifier]isEqualToString:@"ToSettingsView"]) {
        UIBarButtonItem* btn = [[UIBarButtonItem alloc] initWithTitle:[String bt_return]
                                                                style:UIBarButtonItemStylePlain
                                                               target:nil
                                                               action:nil];
        self.navigationItem.backBarButtonItem = btn;
    }
}

- (void)reloadDispStep{
    if ([currentStep isEqualToString:@"9999"]) {
        [self hideSelectCell];
        max = 4;
        self.lb_titleEntry.text = [String Password];
        self.lb_counter.textAlignment = NSTextAlignmentLeft;
        
        if ([self.lb_counter.text length]>0) {
            if ([self.lb_counter.text isEqualToString:@"...."]) {
                //2015-06-23 ueda
                //2015-07-03 ueda 復活
                [self performSegueWithIdentifier:@"ToSettingsView" sender:nil];
            } else {
                if([[setting allKeys] containsObject:self.lb_counter.text]){
                    currentStep = @"0";
                    passkey = self.lb_counter.text;
                    currentSetting = setting[passkey];
                    [self reloadDispStep];
                }
                else{
                    //2014-01-31 ueda
                    //Alert([String Order_Station], [String Wrong_password]);
                    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                    //alert.title=[String Order_Station];
                    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Wrong_password]];
                    alert.messageLabel.font=[UIFont systemFontOfSize:18];
                    alert.delegate=nil;
                    [alert addButtonWithTitle:@"OK"];
                    alert.cancelButtonIndex=0;
                    [alert show];
                }
            }
        }
    }
    else{
        NSDictionary *disp = currentSetting[[currentStep intValue]];
        
        LOG(@"%@\n:%@\n:%@",currentStep,disp,[sys valueForKey:disp[@"key"]]);
        
        self.lb_titleEntry.text = disp[@"title"];
        self.textField.hidden = YES;
        self.lb_counter.hidden = NO;
        if ([disp[@"entryType"]isEqualToString:@"0"]) {
            [self hideSelectCell];
        } else if ([disp[@"entryType"]isEqualToString:@"X"]) {
            //2014-01-31 ueda
            //For FTP-User and FTP-password
            [self hideSelectCell];
            self.textField.hidden = NO;
            self.textField.text = [sys valueForKey:disp[@"key"]];
            self.textField.clearButtonMode = UITextFieldViewModeWhileEditing;
            self.lb_counter.hidden = YES;
            [self.textField becomeFirstResponder];
        }
        else{
            [self showSelectCell:disp[@"select"]
                          values:disp[@"selectValue"]
                          select:[[sys valueForKey:disp[@"key"]]intValue]];
        }
        
        if ([disp[@"rightEnable"]isEqualToString:@"0"]) {
            self.lb_counter.textAlignment = NSTextAlignmentLeft;
        }
        else{
            self.lb_counter.textAlignment = NSTextAlignmentRight;
        }
        
        
        max = [disp[@"max"]intValue];
        min = [disp[@"min"]intValue];
        
        
        //2014-01-31 ueda
        if ([disp[@"entryType"]isEqualToString:@"X"]) {
            self.bt_Num0.enabled = NO;
            self.bt_Num1.enabled = NO;
            self.bt_Num2.enabled = NO;
            self.bt_Num3.enabled = NO;
            self.bt_Num4.enabled = NO;
            self.bt_Num5.enabled = NO;
            self.bt_Num6.enabled = NO;
            self.bt_Num7.enabled = NO;
            self.bt_Num8.enabled = NO;
            self.bt_Num9.enabled = NO;
            self.bt_NumClr.enabled = NO;
            self.bt_NumBS.enabled = NO;
        } else {
            self.bt_Num0.enabled = YES;
            self.bt_Num1.enabled = YES;
            self.bt_Num2.enabled = YES;
            self.bt_Num3.enabled = YES;
            self.bt_Num4.enabled = YES;
            self.bt_Num5.enabled = YES;
            self.bt_Num6.enabled = YES;
            self.bt_Num7.enabled = YES;
            self.bt_Num8.enabled = YES;
            self.bt_Num9.enabled = YES;
            self.bt_NumClr.enabled = YES;
            self.bt_NumBS.enabled = YES;
        }
        
        if ([disp[@"dot"]isEqualToString:@"0"]) {
            self.bt_dot.enabled = NO;
        }
        else{
            self.bt_dot.enabled = YES;
        }
        
        self.lb_counter.text = [sys valueForKey:disp[@"key"]];
        
    }
}

- (void)showSelectCell:(NSArray*)_array
                values:(NSArray*)_values
                select:(int)_select{
    
    self.topView.hidden = NO;
    
    [[self.topView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    int margin = 2;
    int w = (self.topView.bounds.size.width-margin*([_array count]-1))/[_array count];
    int h = self.topView.bounds.size.height-2;
    
    for (int ct = 0; ct < [_array count]; ct++) {
        UIButton *_bt = [UIButton buttonWithType:UIButtonTypeCustom];
        _bt.frame = CGRectMake(margin/2+(w+margin)*ct, 2, w, h);
        [_bt setTitle:_array[ct] forState:UIControlStateNormal];
        
        //2015-03-24 ueda
        NSInteger resultIntWithOption = [_bt.titleLabel.text rangeOfString:@"\n" options:NSBackwardsSearch].location;
        if (resultIntWithOption == NSNotFound) {
            //見つからなかった
            _bt.titleLabel.numberOfLines = 1;
        } else {
            _bt.titleLabel.numberOfLines = 0;
        }
        
        [_bt setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        [_bt addTarget:self action:@selector(iba_selectDidTap:) forControlEvents:UIControlEventTouchUpInside];
        //2014-10-16 ueda
        /*
        if ([_values[ct]intValue]==_select) {
            _bt.backgroundColor = BLUE;
            //2014-07-11 ueda
            [_bt setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:_bt.bounds]]];
        }
        else{
            _bt.backgroundColor = [UIColor whiteColor];
            //2014-07-11 ueda
            [_bt setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:WHITE_BACK bounds:_bt.bounds]]];
        }
         */
        if (YES) {
            _bt.backgroundColor = [UIColor clearColor];
            if ([_values[ct]intValue]==_select) {
                UIImage *image = [System imageWithColorAndRectFullSize:BLUE bounds:_bt.bounds];
                [_bt setBackgroundImage:image forState:UIControlStateNormal];
                [_bt setBackgroundImage:image forState:UIControlStateHighlighted];
            }
            else{
                UIImage *image = [System imageWithColorAndRectFullSize:WHITE_BACK bounds:_bt.bounds];
                [_bt setBackgroundImage:image forState:UIControlStateNormal];
                [_bt setBackgroundImage:image forState:UIControlStateHighlighted];
            }
        }
        _bt.tag = ct;
        //2014-07-07 ueda
        _bt.titleLabel.font = [UIFont systemFontOfSize:23];
        [self.topView addSubview:_bt];
    }
}

- (void)hideSelectCell{
    self.topView.hidden = YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    if (theTextField == self.textField) {
        [theTextField resignFirstResponder];
    }
    return YES;
}

@end
