//
//  ExtensionViewController.m
//  Order
//
//  Created by koji kodama on 13/07/17.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "ExtensionViewController.h"
#import "SSGentleAlertView.h"

@interface ExtensionViewController ()

@end

@implementation ExtensionViewController

- (IBAction)iba_addTime:(id)sender{
    UIButton *bt = (UIButton*)sender;
    
    if (isMidTfActive) {
        extensionInt = 0;
    }
    
    switch (bt.tag) {
        case 1:
            extensionInt = extensionInt + 60;
            break;
            
        case 2:
            extensionInt = extensionInt + 30;
            break;
            
        case 3:
            extensionInt = extensionInt + 10;
            break;
            
        case 4:
            extensionInt = 0;
            break;
            
        default:
            break;
    }
    
    self.tf_extensionTime.text = [self timeFromInt];
    [self reloadUpdateTime];
    isMidTfActive = NO;
}

- (IBAction)iba_regist:(id)sender{
    NSString *_no = [[DataList sharedInstance].currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *mess = [NSString stringWithFormat:[String It_changes],[_no intValue]];
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:mess delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
    */
	//2014-01-30 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",mess];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 1;
    [alert show];
}

- (IBAction)iba_return:(id)sender{
    if (self.bt_regist.enabled) {
        NSString *_no = [[DataList sharedInstance].currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSString *mess = [NSString stringWithFormat:[String The_content],[_no intValue]];
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:mess delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
        */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",mess];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 2;
        [alert show];
    }
    else{
        [self.navigationController popViewControllerAnimated:NO];
    }
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (alertView.tag==1) {
                [self showIndicator];
                [[NetWorkManager sharedInstance] sendTableExtension:self.tf_updateTime.text
                                                              KeyID:self.KeyID
                                                           delegate:self];
            }
            else if (alertView.tag==2) {
                [self.navigationController popViewControllerAnimated:NO];
            }
            break;
            
        case 1:
            break;
    }
}

- (int)timeFromString{
    
    int hour = 0;
    int min = 0;
    if (self.tf_extensionTime.text.length>2) {
        hour = [[self.tf_extensionTime.text substringToIndex:2]intValue];
    }
    
    if (self.tf_extensionTime.text.length==5) {
        min = [[self.tf_extensionTime.text substringFromIndex:3]intValue];
    }
    
    return hour*60+min;
}

- (NSString*)timeFromInt{
    NSString *time = @"";
    
    int hour = extensionInt/60;
    int min = extensionInt - hour*60;
    
    time = [NSString stringWithFormat:@"%02d %02d",hour,min];
    
    return time;
}

- (void)reloadUpdateTime{
    LOG(@"%d",extensionInt);
    NSDate *updateTime = [currentTime initWithTimeInterval:extensionInt*60 sinceDate:currentTime];
    self.tf_updateTime.text = [inputDateFormatter stringFromDate:updateTime];
    
    if ([self.tf_updateTime.text isEqualToString:self.tf_currentTime.text]) {
        self.bt_regist.enabled = NO;
    }
    else{
        self.bt_regist.enabled = YES;
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

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    isMidTfActive = NO;
    
    //2015-03-19 ueda
    //currentTime = [NSDate date];
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm"];
    [formatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    currentTime = [formatter dateFromString:self.defaultTime];

    
    inputDateFormatter = [[NSDateFormatter alloc] init];
	[inputDateFormatter setDateFormat:@"yyyy/MM/dd HH:mm"];
    [inputDateFormatter setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"JST"]];
    self.tf_currentTime.text = [inputDateFormatter stringFromDate:currentTime];
    
    [self reloadUpdateTime];
    
    
    [self.bt_regist setTitle:[String SUBMIT] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String CANCEL2] forState:UIControlStateNormal];
    [self.bt1 setTitle:[String HOUR] forState:UIControlStateNormal];
    [self.bt2 setTitle:[String MINITES1] forState:UIControlStateNormal];
    [self.bt3 setTitle:[String MINITES2] forState:UIControlStateNormal];
    [self.bt4 setTitle:[String RESET] forState:UIControlStateNormal];
    
    NSString *_no = [[DataList sharedInstance].currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    self.lb_title.text = [NSString stringWithFormat:[String EXTRA_TIME_OF_TABLE],[_no intValue]];

    
    self.lb1.text = [String SCHEDULE_TIME];
    self.lb2.text = [String EXTRA_TIME];
    self.lb3.text = [String NEW_TIME];
    //2014-02-07 ueda
    self.lb1.adjustsFontSizeToFitWidth = YES;
    self.lb2.adjustsFontSizeToFitWidth = YES;
    self.lb3.adjustsFontSizeToFitWidth = YES;
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    [System adjustStatusBarSpace:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [mbProcess hide:YES];
        [self.navigationController popViewControllerAnimated:YES];
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

#pragma mark -
#pragma mark MBProgressHUDDelegate methods
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

#pragma mark UITextField Delegate
- (BOOL)textField:(UITextField *)textField
shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    // すでに入力されているテキストを取得
    NSMutableString *text = [textField.text mutableCopy];
    
    //バックスペース時
    if ([string isEqualToString:@""]) {
        if (text.length==3) {
            textField.text = [text substringToIndex:2];
        }
    }
    else{
        if (text.length==2) {
            [text appendString:@" "];
            textField.text = text;
        }
        
        [text replaceCharactersInRange:range withString:string];
        
        if (text.length==5) {
            [self performSelector:@selector(textDidChange) withObject:nil afterDelay:0.2f];
        }
        
        if (text.length>5) {
            return NO;
        }
    }
    
    isMidTfActive = YES;
    
    return YES;
}

- (void)textDidChange{
    extensionInt = [self timeFromString];
    [self reloadUpdateTime];
}

@end
