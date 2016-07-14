//
//  CountJikaViewController.m
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "CountJikaViewController.h"
#import "SSGentleAlertView.h"

@interface CountJikaViewController (){

}
@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

@end

@implementation CountJikaViewController

#pragma mark -
#pragma mark - Control object action
- (IBAction)iba_back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                   message:[String Cancel1]
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:[String Yes],[String No], nil];
    */
	//2014-01-30 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Cancel1]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 1;
    [alert show];
}

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag==1) {
        switch (buttonIndex) {
            case 0:
                //[self.delegate orderCancel1];
                [self.delegate returnEntryCount:entryJika
                                      menuCount:@"0"];
                //2015-12-03 ueda オリジナルと同じ対応
                if (YES) {
                    //セットメニューの場合はサブメニューを表示する
                    if([self.editMenu[@"SG1FLG"] isEqualToString:@"1"]){
                        [self.delegate setDispSub1Menu:self.editMenu
                                                   sub:nil];
                    }
                }
                [self dismissViewControllerAnimated:NO completion:nil];
                
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==2) {
        switch (buttonIndex) {
            case 0:
                [self.delegate returnEntryCount:entryJika
                                      menuCount:self.lb_menuCount.text];
                [self dismissViewControllerAnimated:NO completion:nil];
                
                break;
                
            case 1:
                break;
        }
    }
}

- (IBAction)iba_showNext:(id)sender{
    //2015-09-08 ueda
    //if ([entryJika intValue]==0) {
    if ((self.typeCount==EntryTypeCountJika) && ([entryJika intValue]==0)) {
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                       message:[String No_amount]
                                                      delegate:self
                                             cancelButtonTitle:nil
                                             otherButtonTitles:[String Yes],[String No], nil];
        */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String No_amount]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 2;
        [alert show];
    }
    else{
        if (self.typeCount == EntryTypeCountQTY) {
            [self.delegate returnEntryCount:@""
                                  menuCount:self.lb_menuCount.text];
        }
        else{
            [self.delegate returnEntryCount:entryJika
                                  menuCount:self.lb_menuCount.text];
        }

        
        //セットメニューの場合はサブメニューを表示する
        if([self.editMenu[@"SG1FLG"] isEqualToString:@"1"]){
            [self.delegate setDispSub1Menu:self.editMenu
                                       sub:nil];
        }
        
        [self dismissViewControllerAnimated:NO completion:nil];
    }
}


- (IBAction)iba_countUp:(id)sender{    
    
    if (isEntry) {
        editingLabel.text = @"";
        
        if (editingLabel == self.lb_price) {
            entryJika = [[NSMutableString alloc]initWithString:@""];
        }
    }
    isEntry = NO;
    

    NSString *text = @"";
    if (editingLabel==self.lb_price) {
        text = entryJika;
    }
    else{
        text = editingLabel.text;
    }
    
    
    UIButton *button = (UIButton*)sender;
    NSMutableString *str= [[NSMutableString alloc]init];
    NSMutableDictionary *set = currentSetting[[currentStep intValue]];
    if ([set[@"headZero"]isEqualToString:@"0"]) {
        if (![text isEqualToString:@"0"]) {
            [str appendString:text];
        }
    }
    else{
        [str appendString:text];
    }
    [str appendString:[NSString stringWithFormat:@"%zd",button.tag]];
    
    
    if ([set[@"rightEnable"]isEqualToString:@"0"]||[set[@"headZero"]isEqualToString:@"1"]){
        if (str.length>max) {
            return;
        }
    }
    else{
        if (str.intValue>max) {
            return;
        }
    }
    
    editingLabel.text = str;
    
    if (editingLabel==self.lb_price) {
        entryJika = [[NSMutableString alloc]initWithString:str];
        [self outputPrice];
    }
}

- (IBAction)iba_clear:(id)sender{
    
    isEntry = NO;
    
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    
    if ([disp[@"headZero"]isEqualToString:@"1"]) {
        editingLabel.text = @"";
    }
    else{
        editingLabel.text = @"0";
    }
    
    if (editingLabel==self.lb_price) {
        entryJika = [[NSMutableString alloc]initWithString:@"0"];
        [self outputPrice];
    }
}

- (IBAction)iba_backspace:(id)sender{
    
    
    isEntry = NO;
    
    NSString *text = @"";
    if (editingLabel==self.lb_price) {
        text = entryJika;
    }
    else{
        text = editingLabel.text;
    }
    
    
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    
    NSMutableString *str= [[NSMutableString alloc]init];
    [str appendString:text];
    
    if (str.length==0) {
        return;
    }
    
    [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    
    editingLabel.text = str;
    
    if ([editingLabel.text length]==0) {
        if ([disp[@"headZero"]isEqualToString:@"1"]) {
            editingLabel.text = @"";
        }
        else{
            editingLabel.text = @"0";
        }
    }
    
    if (editingLabel==self.lb_price) {
        entryJika = [[NSMutableString alloc]initWithString:str];
        [self outputPrice];
    }
    
    /*
    isEntry = NO;
    
    NSMutableString *str= [[NSMutableString alloc]init];
    [str appendString:editingLabel.text];
    
    if (str.length==0) {
        return;
    }
    
    [str deleteCharactersInRange:NSMakeRange(str.length-1, 1)];
    
    editingLabel.text = str;
    
    if ([editingLabel.text length]==0) {
        if (editingLabel.textAlignment==NSTextAlignmentLeft) {
            editingLabel.text = @"";
        }
        else{
            editingLabel.text = @"0";
        }
    }
     */
}

- (IBAction)iba_dot:(id)sender{
    
    if (isEntry) {
        editingLabel.text = @"";
        
        if (editingLabel == self.lb_price) {
            entryJika = [[NSMutableString alloc]initWithString:@""];
        }
    }
    isEntry = NO;
    
    
    if (editingLabel==self.lb_price) {
        
        UIButton *button = (UIButton*)sender;
        button.tag = 0;
        [self iba_countUp:button];
        [self iba_countUp:button];
        
        /*
        if ([[System sharedInstance].money isEqualToString:@"0"]) {

        }
        else{
            NSRange range = [editingLabel.text rangeOfString:@"."];
            if (range.location != NSNotFound) {
                return;
            }
            
            
            NSMutableString *str= [[NSMutableString alloc]init];
            [str appendString:editingLabel.text];
            if (str.length==0) {
                return;
            }
            [str appendString:[NSString stringWithFormat:@"."]];
            
            NSMutableDictionary *set = currentSetting[[currentStep intValue]];
            if ([set[@"rightEnable"]isEqualToString:@"0"]||[set[@"dot"]isEqualToString:@"1"]){
                if (str.length>max) {
                    return;
                }
            }
            else{
                if (str.intValue>max) {
                    return;
                }
            }
            
            editingLabel.text = str;
        }
         */
    }
}


-(NSString*)appendSpace:(NSString*)str
            totalLength:(int)length{
    NSMutableString *mutable = [[NSMutableString alloc]init];
    [mutable appendString:str];
    if ([mutable length]<length) {
        for (int ct1 = 0; ct1<length-[str length]; ct1++) {
            [mutable appendString:@" "];
        }
    }
    return [NSString stringWithFormat:@"%@",mutable];
}



- (IBAction)iba_countUpMenu:(id)sender{
    
    //2015-07-03 ueda
    [System tapSound];
    
    if([self.editMenu[@"SG1FLG"] isEqualToString:@"1"]){
        return;
    }
    
    //2015-06-26 ueda
    int count = [self.lb_menuCount.text intValue];
    count++;
    if (count<100) {
        
        isEntry = YES;
        
        NSString *countStr = self.lb_menuCount.text;
        self.editMenu[@"count"] = [NSString stringWithFormat:@"%d",[countStr intValue]+1];
        
        editingLabel = self.lb_menuCount;
        currentStep = @"1";
        [self reloadDisp];
        [self reloadDispStep];

    }
}

- (IBAction)iba_countDownMenu:(id)sender{
    
    //2015-07-03 ueda
    [System tapSound];

    if([self.editMenu[@"SG1FLG"] isEqualToString:@"1"]){
        return;
    }
    
    isEntry = YES;
    
    self.editMenu[@"count"] = @"0";
    self.lb_menuCount.text = @"0";
    editingLabel = self.lb_menuCount;
    currentStep = @"1";
     [self reloadDisp];
    [self reloadDispStep];
}


- (IBAction)iba_selectArea:(id)sender{
    
    isEntry = YES;

    editingLabel = self.lb_price;
    currentStep = @"0";
    [self reloadDispStep];
}

//==============================================================================


//==============================================================================


#pragma mark -
#pragma mark - Lifecycle delegate
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        //self.count = 0;
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
    
    [self.bt_next setTitle:[String bt_ok] forState:UIControlStateNormal];
    //2014-09-19 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_next setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_next setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    
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
    
    
    NSString *jika = [self.editMenu[@"Jika"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    entryJika = [[NSMutableString alloc]initWithString:jika];
    
    currentSetting = [[NSMutableArray alloc]init];
    currentSetting[0] = @{@"title":@"",
                          @"rightEnable": @"1",
                          @"select": @"0",
                          @"max": @"999999",
                          @"min": @"0",
                          @"dot": @"1",
                          @"headZero": @"0"
                          };
    
    currentSetting[1] = @{@"title":@"",
                          @"rightEnable": @"1",
                          @"select": @"0",
                          @"max": @"99",
                          @"min": @"0",
                          @"dot": @"0",
                          @"headZero": @"0"
                          };
    
    //currentStep = @"0";
    sys = [System sharedInstance];
    
    /*
    if ([[System sharedInstance].money isEqualToString:@"0"]) {
        [self.bt_dot setTitle:@"00" forState:UIControlStateNormal];
    }
    else{
        [self.bt_dot setTitle:@"." forState:UIControlStateNormal];
    }
     */

    LOG(@"%@",self.editMenu);
    
    DataList *dat = [DataList sharedInstance];
    
    if (dat.currentTable) {
        NSString *_no = [dat.currentTable[@"TableNo"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //2014-11-17 ueda
/*
        //2014-10-23 ueda
        if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
            //入力タイプＣの場合
            NSString *_str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount];
            self.lb_title.text = _str;
        } else {
            //2014-09-22 ueda
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                //英語
                NSString *_str = [NSString stringWithFormat:@"　%@%@　Ad%d Ch%d",[String Str_t],_no,dat.manCount,dat.womanCount];
                self.lb_title.text = _str;
            } else {
                //日本語
                NSString *_str = [NSString stringWithFormat:@"　%@%@　M%d F%d",[String Str_t],_no,dat.manCount,dat.womanCount];
                self.lb_title.text = _str;
            }
        }
 */
        NSString *_str;
        //2014-11-18 ueda
        if ([[System sharedInstance].ninzu isEqualToString:@"0"]) {
            _str = [NSString stringWithFormat:@"　%@%@",[String Str_t],_no];
        } else {
            //2014-12-12 ueda
            if (([[System sharedInstance].entryType isEqualToString:@"2"]) || ([[System sharedInstance].childInputOnOff isEqualToString:@"1"])) {
                //入力タイプＣ or 小人入力する
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd C%zd",[String Str_t],_no,dat.manCount,dat.womanCount,dat.childCount];
            } else {
                //小人入力しない
                _str = [NSString stringWithFormat:@"　%@%@　M%zd F%zd",[String Str_t],_no,dat.manCount,dat.womanCount];
            }
        }
        self.lb_title.text = _str;
    }
    else{
        self.lb_title.text = [String bt_order];
    }
    
    if (self.typeCount==EntryTypeCountJika) {
        editingLabel = self.lb_price;
        currentStep = @"0";
    }
    else{
        self.secondView.hidden = YES;
        editingLabel = self.lb_menuCount;
        currentStep = @"1";
    }
    [self reloadDispStep];
    [self reloadDisp];
    [self outputPrice];
    
    isEntry = YES;
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
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

- (void)viewDidUnload {
    [self setLb_title:nil];
    [self setBt_select:nil];
    [self setLb_menuCount:nil];
    [self setLb_price:nil];
    [self setTopView:nil];
    [self setSecondView:nil];
    [self setBt_return:nil];
    [self setBt_next:nil];
    [super viewDidUnload];
}

- (void)reloadDispStep{
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    //self.lb_titleEntry.text = disp[@"title"];
    
    if ([disp[@"rightEnable"]isEqualToString:@"0"]) {
        editingLabel.textAlignment = NSTextAlignmentLeft;
    }
    else{
        editingLabel.textAlignment = NSTextAlignmentRight;
    }
    
    
    max = [disp[@"max"]intValue];
    min = [disp[@"min"]intValue];
    
    
    if ([disp[@"dot"]isEqualToString:@"0"]) {
        self.bt_dot.enabled = NO;
    }
    else{
        self.bt_dot.enabled = YES;
    }
    LOG(@"%d",max);

    
    self.topView.backgroundColor = [UIColor whiteColor];
    self.secondView.backgroundColor = [UIColor whiteColor];
    //2014-08-08 ueda
    [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.topView.bounds]]];
    [self.secondView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.secondView.bounds]]];
    
    if (editingLabel==self.lb_price) {
        self.secondView.backgroundColor = BLUE;
        //2014-08-08 ueda
        [self.secondView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.secondView.bounds]]];
    }
    else{
        self.topView.backgroundColor = BLUE;
        //2014-08-08 ueda
        [self.topView setBackgroundColor:[UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.topView.bounds]]];
    }
}

- (void)reloadDisp{
    //OrderManager *orderManager = [OrderManager sharedInstance];
    //self.editMenu = [orderManager reloadMenu:self.editMenu];
    
    
    NSString *str1 = [self.editMenu[@"HTDispNMU"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *str2 = [self.editMenu[@"HTDispNMM"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    NSString *str3 = [self.editMenu[@"HTDispNML"] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    self.lb_titleEntry.text = [NSString stringWithFormat:@"%@%@%@",str1,str2,str3];
    self.lb_menuCount.text = self.editMenu[@"count"];
}


- (void)outputPrice{
    LOG(@"%@",entryJika);
    self.lb_price.text = [DataList appendComma:entryJika];
}

@end
