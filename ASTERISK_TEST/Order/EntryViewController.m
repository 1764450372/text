//
//  EntryViewController.m
//  Order
//
//  Created by koji kodama on 13/05/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "EntryViewController.h"
//#import "TableViewController.h"
#import "OrderEntryViewController.h"
#import "SSGentleAlertView.h"
//#import "ZBarSDK.h"
#import "BarcodeReaderViewController.h"
#import "TypeCCountViewController.h"

@interface EntryViewController () <BarcodeReaderViewDelegate> {
    //2014-08-04 ueda
    BOOL _useBarcodeReader;
    NSInteger  _maxInputLength;
    //ZBarReaderViewController *readerZBar;
    //2014-08-22 ueda
    bool _canUseBarcodeReader;
}

@property (weak, nonatomic) IBOutlet UIButton *bt_clear;

@end

@implementation EntryViewController

#pragma mark -
#pragma mark - Control object action

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
    
    if (self.entryType == EntryTypeKokyaku||self.entryType == EntryTypeSearch) {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else if (self.entryType == EntryTypeOrder) {
        NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
        if ([[System sharedInstance].entryType isEqualToString:@"1"]&&[orderList count]>0) {
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_this_slip] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
            */
            //2014-01-30 ueda
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_this_slip]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 3;
            [alert show];
        }
        else{
            [[(OrderEntryViewController*)self.delegate navigationController] popViewControllerAnimated:YES];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
    }
    //2015-04-20 ueda
    else if (self.entryType == EntryTypeStaffCode) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}


- (IBAction)iba_showNext:(id)sender{
    
    if (self.entryType == EntryTypeKokyaku) {
        if ([sys.tableType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToTableView" sender:sender];
        }
        else{
            //2014-10-23 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                [self performSegueWithIdentifier:@"ToTypeCCountView" sender:sender];
            } else {
                [self performSegueWithIdentifier:@"ToCountView" sender:sender];
            }
        }
    }
    else if (self.entryType == EntryTypeOrder) {
        //[self.delegate bt_back];
        
        if (editMenu) {
            editMenu[@"count"] = self.lb_count.text;
            editMenu[@"Jika"] = entryJika;
            [[OrderManager sharedInstance] addTopMenu:editMenu];
            
            /*
            if ([editMenu[@"SG1FLG"] isEqualToString:@"1"]) {
                [self.delegate setDispSub1Menu:editMenu
                                           sub:nil];
                [self dismissViewControllerAnimated:NO completion:nil];
            }
            else{
             */
                [self iba_clearTap:nil];
                [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
            //}
        }
        else if(!editMenu&&[self.lb_syohinCD.text length]==0){
            //NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
            //if ([orderList count]>0) {
                //[self.delegate iba_showNext:sender];
            
            OrderEntryViewController *oevc = (OrderEntryViewController*)self.delegate;
            [oevc setConfirm];
            [self dismissViewControllerAnimated:NO completion:nil];
            //}
            //else{
            //    Alert([String Order_Station], [String No_order1]);
            //}
        }
        else{
            //YES = 商品が見つかった　NO = 商品が見つからない
            if (![self outputOrder]) {
                [self iba_clearTap:nil];
                //[self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
            }
        }
    }
    else if (self.entryType == EntryTypeSearch) {
        
        LOG(@"");
        
        //2014-12-16 ueda
/*
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        //2014-10-30 ueda
        //mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
        [mbProcess show:YES];
 */
        [self showIndicator];
        [[NetWorkManager sharedInstance] getVoucherSearch:self
                                                     word:editingLabel.text];
    }
    //2015-04-20 ueda
    else if (self.entryType == EntryTypeStaffCode) {
        NSString *txt = self.lb_syohinCD.text;
        if (txt == nil || [txt isEqualToString:@""]) {
            //未入力
            [self dismissViewControllerAnimated:YES completion:NULL];
        } else {
            NetWorkManager *_net = [NetWorkManager sharedInstance];
            [_net openDb];
            //2015-06-17 ueda 担当者コードを６桁に
            NSString *code = [_net appendSpace:self.lb_syohinCD.text totalLength:[System sharedInstance].staffCodeKetaStr.intValue];
            FMResultSet *rs  = [_net.db executeQuery:@"select * from Tanto_MT where MstTantoCD = ?",code];
            if ([rs next]) {
                self.bt_result.enabled = YES;
                self.lb_titleEntry.text = [NSString stringWithFormat:@"%@　%@",[String Search],[rs stringForColumn:@"TantoNM"]];
                [self.delegate finishStaffCode:txt];
                [self dismissViewControllerAnimated:YES completion:NULL];
            } else {
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
                //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String staffCodeNotFound]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
            }
            [rs close];
            [_net closeDb];
        }
    }
}

- (IBAction)iba_search:(id)sender{
    
    LOG(@"");
    
    //2014-12-16 ueda
/*
    mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
    //2014-10-30 ueda
    //mbProcess.labelText = @"Loading Data";
    [self.view addSubview:mbProcess];
    [mbProcess setDelegate:self];
    [mbProcess show:YES];
 */

    [self showIndicator];
    
    [DataList sharedInstance].currentKokyakuCD = self.lb_syohinCD.text;
    [[NetWorkManager sharedInstance] getKokyaku:self count:1];
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
    
    if (self.entryType == EntryTypeOrder) {
        if (editingLabel==self.lb_count||editingLabel==self.lb_price) {
            
            if (editingLabel==self.lb_price) {
                entryJika = [[NSMutableString alloc]initWithString:str];
            }
            
            [self outputPrice];
        }
        else if (editingLabel==self.lb_syohinCD){
            [self.bt_result setTitle:[String bt_search] forState:UIControlStateNormal];
        }
    }
    
    if (self.entryType == EntryTypeKokyaku) {
        self.bt_result.enabled = NO;
        //2014-04-18 ueda
        [DataList sharedInstance].currentKokyakuCD = nil;
        self.lb_titleEntry.text = [String Search];
    }
    //2015-04-20 ueda
    if (self.entryType == EntryTypeStaffCode) {
        self.lb_titleEntry.text = [String Search];
    }
}

- (IBAction)iba_clear:(id)sender{
    LOG(@"%@",editMenu);
    
     isEntry = NO;
    
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    
    if ([disp[@"headZero"]isEqualToString:@"1"]) {
        editingLabel.text = @"";
    }
    else{
        editingLabel.text = @"0";
    }
    
    
    if (self.entryType == EntryTypeOrder) {
        if (editingLabel==self.lb_count||editingLabel==self.lb_price) {
            
            if (editingLabel==self.lb_price) {
                entryJika = [[NSMutableString alloc]initWithString:@"0"];
            }
            
            [self outputPrice];
        }
        else if (editingLabel==self.lb_syohinCD){
            [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
        }
    }
    
    if (self.entryType == EntryTypeKokyaku) {
        self.bt_result.enabled = YES;
        //2014-04-18 ueda
        [DataList sharedInstance].currentKokyakuCD = nil;
        self.lb_titleEntry.text = [String Search];
    }
    //2015-04-20 ueda
    if (self.entryType == EntryTypeStaffCode) {
        self.lb_titleEntry.text = [String Search];
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
    
    if (self.entryType == EntryTypeOrder) {
        if (editingLabel==self.lb_count||editingLabel==self.lb_price) {
            
            if (editingLabel==self.lb_price) {
                entryJika = [[NSMutableString alloc]initWithString:str];
            }
            
            [self outputPrice];
        }
        else if (editingLabel==self.lb_syohinCD&&self.lb_syohinCD.text.length==0){
            [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
        }
    }
    
    //2014-04-18 ueda
    if (self.entryType == EntryTypeKokyaku) {
        if (str.length==0) {
            self.bt_result.enabled = YES;
        } else {
            self.bt_result.enabled = NO;
        }
        [DataList sharedInstance].currentKokyakuCD = nil;
        self.lb_titleEntry.text = [String Search];
    }
    //2015-04-20 ueda
    if (self.entryType == EntryTypeStaffCode) {
        self.lb_titleEntry.text = [String Search];
    }
}

- (IBAction)iba_dot:(id)sender{
    
    //2014-10-16 ueda
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    if ([disp[@"dot"]isEqualToString:@"0"]) {
        //2014-08-22 ueda
        if (_canUseBarcodeReader) {
            [self cameraViewStart];
            return;
        }
    }
    
    if (isEntry) {
        editingLabel.text = @"";
        
        if (editingLabel == self.lb_price) {
            entryJika = [[NSMutableString alloc]initWithString:@""];
        }
    }
    isEntry = NO;

    
    if (self.entryType == EntryTypeKokyaku) {
        NSMutableString *str= [[NSMutableString alloc]init];
        [str appendString:editingLabel.text];
        if (str.length==0) {
            return;
        }
        [str appendString:[NSString stringWithFormat:@"."]];
        editingLabel.text = str;
    }
    else if (self.entryType == EntryTypeOrder) {
        UIButton *button = (UIButton*)sender;
        button.tag = 0;
        [self iba_countUp:button];
        [self iba_countUp:button];
        [self iba_countUp:button];
    }
}


//For EntryTypeOrder
- (IBAction)iba_clearTap:(id)sender{
    
    isEntry = NO;
    
    self.lb_syohinCD.text = @"";
    self.lb_count.text = @"";
    self.lb_totalPrice.text = @"";
    self.lb_price.text = @"";
    self.lb_titleEntry.text = @"";
    
    editMenu = nil;
    
    editingLabel = self.lb_syohinCD;
    currentStep = @"0";
    [self reloadDispStep];
    
    [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
}

- (IBAction)iba_countUpMenu:(id)sender{
    
    if (!editMenu) {
        return;
    }
    
    isEntry = YES;
    
    self.lb_count.text = [NSString stringWithFormat:@"%d",[self.lb_count.text intValue]+1];
    
    [self outputPrice];

    editingLabel = self.lb_count;
    
    currentStep = @"1";
    [self reloadDispStep];
}

- (IBAction)iba_jikaEntry:(id)sender{
    
    if (!editMenu) {
        return;
    }
    
    if ([editMenu[@"JikaFLG"] isEqualToString:@"0"]) {
        return;
    }
    
    if (editingLabel != self.lb_price) {
        isEntry = YES;
        editingLabel = self.lb_price;
    }

    
    currentStep = @"2";
    [self reloadDispStep];
}

- (void)outputPrice{

    int count = [self.lb_count.text intValue];
    self.lb_count.text = [NSString stringWithFormat:@"%d",count];
    
    LOG(@"%@",entryJika);
    
    self.lb_totalPrice.text = [DataList appendComma:[NSString stringWithFormat:@"%d",[DataList intValue:entryJika]*count]];
    self.lb_price.text = [DataList appendComma:entryJika];
}

- (BOOL)outputOrder{
    NSString *str = [self appendSpace:self.lb_syohinCD.text totalLength:13];
    NSMutableDictionary *_menu = [[OrderManager sharedInstance] getMenuForCancel:str];
    
    LOG(@"%@",_menu);
    
    //フォルダ商品の場合は選択不可
    if ([_menu[@"BFLG"] isEqualToString:@"1"]) {
        return NO;
    }
    
    /*
    //メニューパターンが異なる場合は選択不可
    if ([_menu[@"PatternCD"] isEqualToString:sys.menuPatternType]) {
        return NO;
    }
    */
    
    if ([[_menu allKeys]containsObject:@"SyohinCD"]) {
        editingLabel = self.lb_count;
        editMenu = _menu;
        currentStep = @"1";
        [self reloadDispStep];
    
        [self iba_countUpMenu:nil];
        
        self.lb_titleEntry.text = [NSString stringWithFormat:@"%@\n%@\n%@",_menu[@"HTDispNMU"],_menu[@"HTDispNMM"],_menu[@"HTDispNML"]];
        
        
        //数値カンマ区切り成形用
        self.lb_totalPrice.text = [DataList appendComma:_menu[@"Tanka"]];
        self.lb_price.text = [DataList appendComma:_menu[@"Tanka"]];
        entryJika = [[NSMutableString alloc]initWithString:_menu[@"Tanka"]];
        
        
        [self.bt_result setTitle:[String bt_add] forState:UIControlStateNormal];
        
        
        if ([editMenu[@"SG1FLG"] isEqualToString:@"1"]) {
            editMenu[@"count"] = @"1";
            
            //シングルトレイの場合はトレイNoを01に指定する
            if ([editMenu[@"TrayStyle"]isEqualToString:@"1"]) {
                [DataList sharedInstance].TrayNo = @"01";
                editMenu[@"trayNo"] = @"01";
            }
            else{
                [DataList sharedInstance].TrayNo = @"00";
            }
            
            [[OrderManager sharedInstance] addTopMenu:editMenu];
            [self.delegate setDispSub1Menu:editMenu
                                       sub:nil];
            [self dismissViewControllerAnimated:NO completion:nil];
        }
        
        return YES;
    }
    return NO;
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
    

    isEntry = NO;
    
    [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
    [self.bt_search setTitle:[String bt_search] forState:UIControlStateNormal];
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
    
    //2014-08-04 ueda
    _useBarcodeReader = NO;
    //2014-08-22 ueda
    _canUseBarcodeReader = NO;
    NSString *useBar = [System sharedInstance].useBarcode;
    //後から追加したので値が入っていない場合に設定画面で「オン」状態になるため、つじつまを合わせておく
    if ((useBar.length == 0) || ([useBar isEqualToString:@"0"])) {
        if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
            _canUseBarcodeReader = YES;
        }
    }

    
    if (self.entryType == EntryTypeKokyaku) {

        currentSetting = [[NSMutableArray alloc]init];
        currentSetting[0] = @{@"title": [String search],
                           @"rightEnable": @"1",
                           @"select": @"0",
                           @"max": @"10",
                           @"min": @"1",
                           @"dot": @"0",
                           @"headZero": @"1"
                           };

        editingLabel = self.lb_syohinCD;
        
        //2014-10-02 ueda
        _useBarcodeReader = YES;
        _maxInputLength = 10;
    }
    //2015-04-20 ueda
    else if (self.entryType == EntryTypeStaffCode) {
        
        currentSetting = [[NSMutableArray alloc]init];
        //2015-06-17 ueda 担当者コードを６桁に
        currentSetting[0] = @{@"title": [String search],
                              @"rightEnable": @"1",
                              @"select": @"0",
                              @"max": [System sharedInstance].staffCodeKetaStr,
                              @"min": @"1",
                              @"dot": @"0",
                              @"headZero": @"1"
                              };
        
        editingLabel = self.lb_syohinCD;
        self.bt_search.hidden = YES;
    }
    else if (self.entryType == EntryTypeOrder) {
        currentSetting = [[NSMutableArray alloc]init];
        currentSetting[0] = @{@"title": @"",
                          @"rightEnable": @"0",
                          @"select": @"0",
                          @"max": @"13",
                          @"min": @"1",
                          @"dot": @"1",
                          @"headZero": @"1"
                          };
        
        currentSetting[1] = @{@"title": @"カウント",
                          @"rightEnable": @"1",
                          @"select": @"0",
                          @"max": @"99",
                          @"min": @"1",
                          @"dot": @"0",
                          @"headZero": @"0"
                          };
        
        currentSetting[2] = @{@"title": @"時価",
                              @"rightEnable": @"1",
                              @"select": @"0",
                              @"max": @"999999",
                              @"min": @"1",
                              @"dot": @"1",
                              @"headZero": @"0"
                              };
        

        editingLabel = self.lb_syohinCD;
        
        /*
        NSMutableArray *orderList = [[OrderManager sharedInstance] getOrderList:0][0];
        if ([orderList count]>0) {
            [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
        }
        else{
            [self.bt_result setTitle:[String bt_search] forState:UIControlStateNormal];
        }
         */
        [self.bt_result setTitle:[String bt_next] forState:UIControlStateNormal];
    }
    else if (self.entryType == EntryTypeSearch) {
        
        NSString *length = @"";
        if ([[System sharedInstance].kakucho2Type intValue]==0) {
            length = @"6";
        }
        else if ([[System sharedInstance].kakucho2Type intValue]==1){
            length = @"7";
        }
        else if ([[System sharedInstance].kakucho2Type intValue]==2){
            length = @"8";
        }
        
        
        currentSetting = [[NSMutableArray alloc]init];
        currentSetting[0] = @{@"title": [String Search],
                              @"rightEnable": @"1",
                              @"select": @"0",
                              @"max": length,
                              @"min": @"1",
                              @"dot": @"0",
                              @"headZero": @"1"
                              };
        

        editingLabel = self.lb_syohinCD;
        self.bt_search.hidden = YES;
        
        //2014-08-04 ueda
        _useBarcodeReader = YES;
        _maxInputLength = [length integerValue];
    }


    currentStep = @"0";
    sys = [System sharedInstance];
    
    [self reloadDispStep];
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];

    [System adjustStatusBarSpace:self.view];
}

- (void)backgroundColorUpdate{
    
    //2014-08-07 ueda
    self.lb_syohinCD.backgroundColor   = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.lb_syohinCD.bounds]];
    self.lb_price.backgroundColor      = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.lb_price.bounds]];
    self.lb_count.backgroundColor      = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.lb_count.bounds]];
    self.lb_titleEntry.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.lb_titleEntry.bounds]];
    self.lb_totalPrice.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.lb_totalPrice.bounds]];
    
    editingLabel.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:BLUE bounds:self.lb_syohinCD.bounds]];
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
    
    
    NSString *txt = [self.delegate lb_title].text;
    if ([txt length]==0||!txt) {
        if (self.entryType == EntryTypeSearch) {
            if (self.type == TypeOrderAdd) {
                txt = [String searchAdd];
            }
            else if(self.type == TypeOrderCheck){
                txt = [String searchCheck];
            }
            else if(self.type == TypeOrderCancel){
                txt = [String searchCancel];
            }
        }
        else{
             txt = [String searchC];
        }
    }
    //2015-04-20 ueda
    if (self.entryType == EntryTypeStaffCode) {
        txt = [String searchStaffCode];
    }
    self.lb_title.text = txt;
    
    //2014-08-22 ueda
    if (_canUseBarcodeReader) {
        if (_useBarcodeReader) {
            _useBarcodeReader = NO;
            [self cameraViewStart];
        }
    }
}

//iOS7標準のバーコード読み取りデータ
- (void)finishView:(NSString*)returnValue{
    if (_maxInputLength) {
        if (returnValue.length > _maxInputLength) {
            self.lb_syohinCD.text = [returnValue substringToIndex:_maxInputLength];
        } else {
            self.lb_syohinCD.text = returnValue;
        }
    } else {
        self.lb_syohinCD.text = returnValue;
    }
    //2014-10-02 ueda
    if (!(self.bt_search.hidden)) {
        self.bt_result.enabled = NO;
        [self iba_search:nil];
    } else {
        [self iba_showNext:nil];
    }
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    //readerZBar = nil;
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
    //[self setEntryView:nil];
    [self setLb_titleEntry:nil];
    [self setBt_dot:nil];
    [self setLb_count:nil];
    [self setLb_price:nil];
    [self setLb_totalPrice:nil];
    [self setBt_result:nil];
    [self setBt_search:nil];
    [self setBt_return:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    if([[segue identifier]isEqualToString:@"ToTableView"]){
        TableViewController *view_ = (TableViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToCountView"]){
        CountViewController *view_ = (CountViewController *)[segue destinationViewController];
        view_.type = self.type;
        
        //人数入力可否の判定
        if ([sys.ninzu isEqualToString:@"0"]) {
            view_.entryType = EntryTypeTableOnly;
        }
        else{
            //入力タイプ AorBの判定
            //2014-07-07 ueda
            if ([sys.entryType isEqualToString:@"0"] || [sys.entryType isEqualToString:@"2"]) {
                view_.entryType = EntryTypeTableAndNinzu;
            }
            else{
                view_.entryType = EntryTypeTableOnly;
            }
        }
    }
    else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
        OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
    else if([[segue identifier]isEqualToString:@"ToVoucherDetailView"]){
        VouchingDetailViewController *view_ = (VouchingDetailViewController *)[segue destinationViewController];
        view_.type = self.type;
        view_.voucher = (NSMutableDictionary*)sender;
    }
    //2014-10-23 ueda
    else if([[segue identifier]isEqualToString:@"ToTypeCCountView"]){
        TypeCCountViewController *view_ = (TypeCCountViewController *)[segue destinationViewController];
        view_.type = self.type;
    }
}

- (void)reloadDispStep{
    NSDictionary *disp = currentSetting[[currentStep intValue]];
    
    if (self.entryType!=EntryTypeOrder) {
        self.lb_titleEntry.text = disp[@"title"];
    }
    else{
        [self backgroundColorUpdate];
    }
    
    if ([disp[@"rightEnable"]isEqualToString:@"0"]) {
        self.lb_syohinCD.textAlignment = NSTextAlignmentLeft;
    }
    else{
        if (self.entryType!=EntryTypeOrder) {
            self.lb_syohinCD.textAlignment = NSTextAlignmentRight;
        }
        else{
            self.lb_syohinCD.textAlignment = NSTextAlignmentLeft;
        }
    }
    
    //2015-04-20 ueda
    if (self.entryType == EntryTypeStaffCode) {
        self.lb_titleEntry.text = [String Search];
    }
    
    max = [disp[@"max"]intValue];
    min = [disp[@"min"]intValue];
    
    
    if ([disp[@"dot"]isEqualToString:@"0"]) {
        self.bt_dot.enabled = NO;
        //2014-08-22 ueda
        if (_canUseBarcodeReader) {
            self.bt_dot.enabled = YES;
            [self.bt_dot.titleLabel setFont:[UIFont boldSystemFontOfSize:25]];
            if ([[System sharedInstance].lang isEqualToString:@"1"]) {
                [self.bt_dot setTitle:@"Canera" forState:UIControlStateNormal];
            } else {
                [self.bt_dot setTitle:@"カメラ" forState:UIControlStateNormal];
            }
        }
    }
    else{
        self.bt_dot.enabled = YES;
    }
    
    //self.lb_syohinCD.text = @"";
    
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


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        BOOL isFinish = YES;
        if (type==RequestTypeKokyakuInfoGet) {
            NSDictionary *_dic = (NSDictionary*)_dataList;
            self.lb_titleEntry.text = [NSString stringWithFormat:@"%@　%@",[String Search],_dic[@"KokyakuName"]];
            NSString *cd = _dic[@"KokyakuCD"];
            
            //顧客CDがある場合は更新する、ない場合はユーザー入力値を活かす
            if (cd) {
                NSString *cd2 = [cd stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
                if ([cd2 length]>0) {
                    [DataList sharedInstance].currentKokyakuCD = _dic[@"KokyakuCD"];
                }
            }
            
            self.bt_result.enabled = YES;
            isFinish = YES;
        }
        else if (type==RequestTypeVoucherSearch) {
            if([[(NSString*)_dataList substringWithRange:NSMakeRange(3,1)]intValue]==0){
                NSString *EdaNo = [(NSString*)_dataList substringWithRange:NSMakeRange(4,4)];
                [DataList sharedInstance].currentVoucher = @{@"EdaNo": EdaNo};
                [DataList sharedInstance].currentTable = [[NSMutableDictionary alloc]initWithDictionary:@{@"TableNo": @"-"}];
                
                if (self.type==TypeOrderAdd) {
                    LOG(@"Add");
                    //[[NetWorkManager sharedInstance] getVoucherDetail:self];
                    //2015-04-06 ueda
                    if ([sys.tableType isEqualToString:@"0"]) {
                        [self performSegueWithIdentifier:@"ToTableView" sender:nil];
                    } else {
                        [self performSegueWithIdentifier:@"ToCountView" sender:nil];
                    }
                    isFinish = YES;
                }
                else if(self.type== TypeOrderCancel){
                    LOG(@"Cancel");
                    [[NetWorkManager sharedInstance] getVoucherDetail:self];
                    isFinish = NO;
                }
                else if(self.type== TypeOrderCheck){
                    LOG(@"Check");
                    [[NetWorkManager sharedInstance] getVoucherCheck:self];
                    isFinish = NO;
                }
            }
            else{
                //2014-01-31 ueda
                //Alert([String Order_Station], _dataList);
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",_dataList];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=nil;
                [alert addButtonWithTitle:@"OK"];
                alert.cancelButtonIndex=0;
                [alert show];
                isFinish = YES;
            }
        }
        else if (type==RequestTypeVoucherDetail) {
            //LOG(@"dat.currentVoucher:%@",[DataList sharedInstance].currentVoucher);
            [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
            isFinish = YES;
        }
        else if(type==RequestTypeVoucherCheck){
            if ([(NSMutableDictionary*)_dataList count]==0) {
                //2014-01-31 ueda
                //Alert([String Order_Station], [String not_possible_to_confirm])
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
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
            isFinish = YES;
        }
        
        
        if (mbProcess&&isFinish) {
            [mbProcess hide:YES];
        }
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        //2014-12-04 ueda
/*
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
 */
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

-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==3) {
        switch (buttonIndex) {
            case 0:
                [[(OrderEntryViewController*)self.delegate navigationController] popViewControllerAnimated:YES];
                [self dismissViewControllerAnimated:NO completion:nil];
                break;
                
            case 1:
                break;
        }
    }
}


/*

 #pragma mark For ZBar SDK

//2014-08-04 ueda
- (void)barcodeScanStart {
    @autoreleasepool {
        //ZBarReaderViewController *reader = [[ZBarReaderViewController alloc] init];
        //2014-08-18 ueda
        readerZBar = [ZBarReaderViewController new];
        readerZBar.readerDelegate = self;
        
        //標準のコントロールバーを隠す
        readerZBar.showsZBarControls = NO;
        
        ZBarImageScanner *scanner = readerZBar.scanner;
        [scanner setSymbology:ZBAR_I25
                       config:ZBAR_CFG_ENABLE
                           to:0];
        [self presentViewController:readerZBar
                           animated:YES
                         completion:nil];
        
        //重ねる UIView
        readerZBar.cameraOverlayView = [self cameraOverlay];
    }
}

-(UIView*)cameraOverlay{
    @autoreleasepool {
        UIView* view = [[UIView alloc] initWithFrame:CGRectMake(0,0,320,568)];
        UILabel *labelTop    = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,23)];
        labelTop.backgroundColor = [UIColor blackColor];
        [view addSubview:labelTop];
        UILabel *labelTitle  = [[UILabel alloc] initWithFrame:CGRectMake(0,23,320,23)];
        [labelTitle setTextAlignment:NSTextAlignmentCenter];
        UILabel *labelBottom = nil;
        if ([System is568h]) {
            labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0,518,320,50)];
        } else {
            labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0,430,320,50)];
        }
        labelTitle.text = [String scanBarcodeMsg];//バーコードにピントを合わせて下さい
        labelTitle.textColor = [UIColor whiteColor];
        labelTitle.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:labelTitle.bounds]];
        [view addSubview:labelTitle];
        labelBottom.backgroundColor = [UIColor darkGrayColor];
        [view addSubview:labelBottom];

        UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
        if ([System is568h]) {
            buttonCancel.frame = CGRectMake(100, 518, 120, 50);
        } else {
            buttonCancel.frame = CGRectMake(100, 430, 120, 50);
        }
        [buttonCancel setTitle:[String Cancel3] forState:UIControlStateNormal];//キャンセル
        [buttonCancel.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
        buttonCancel.titleLabel.textColor = [UIColor whiteColor];
        buttonCancel.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:buttonCancel.bounds]];
        [buttonCancel addTarget:self action:@selector(scanCancelProc) forControlEvents:UIControlEventTouchDown];
        CALayer *btnLayer = [buttonCancel layer];
        [btnLayer setMasksToBounds:YES];
        [btnLayer setCornerRadius:5.0f];
        [view addSubview:buttonCancel];

        if (YES) {
            //2014-08-19 ueda for DEBUG
            UILabel *labelCount = nil;
            if ([System is568h]) {
                labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0,498,320,20)];
            } else {
                labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0,410,320,20)];
            }
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.barcodeUseCount++;
            labelCount.textAlignment = NSTextAlignmentRight;
            labelCount.text = [NSString stringWithFormat:@"Count : %d", appDelegate.barcodeUseCount];
            labelCount.font = [UIFont systemFontOfSize:15.0f];
            labelCount.textColor = [UIColor blackColor];
            labelCount.backgroundColor = [UIColor clearColor];
            [view addSubview:labelCount];
        }

        //    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        //iOS7 later
        [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];
        //    }
        return view;
    }
}

- (void)scanCancelProc{
    [System tapSound];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)imagePickerController:(UIImagePickerController *)reader didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    @autoreleasepool {
        [System barcodeScanSound];
        
        id results = [info objectForKey:ZBarReaderControllerResults];
        ZBarSymbol *symbol = nil;
        
        for (symbol in results)
            break;
        
        if (_maxInputLength) {
            if (symbol.data.length > _maxInputLength) {
                self.lb_syohinCD.text = [symbol.data substringToIndex:_maxInputLength];
            } else {
                self.lb_syohinCD.text = symbol.data;
            }
        } else {
            self.lb_syohinCD.text = symbol.data;
        }
        
        //[reader dismissModalViewControllerAnimated:YES];
        [reader dismissViewControllerAnimated:YES completion:NULL];
        
        [self iba_showNext:nil];
    }
}
*/

- (void)cameraViewStart {
    if (NO) {
        // ZBar SDK
        //[self barcodeScanStart];
    } else {
        //iOS7標準機能 → 起動がZBarは１秒くらいだが、こちらは２秒くらいかかる
        //また、連続スキャンで割り込みが発生した場合にアプリが終了してしまうのでとりあえずやめておく
        if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
            BarcodeReaderViewController *barcodeReaderViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"BCDVIEW"];
            barcodeReaderViewController.delegate = self;
            barcodeReaderViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:barcodeReaderViewController animated:YES completion:nil];
        }
    }
}

@end