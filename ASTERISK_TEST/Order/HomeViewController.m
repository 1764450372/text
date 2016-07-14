//
//  HomeViewController.m
//  Order
//
//  Created by koji kodama on 13/03/07.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "HomeViewController.h"
#import "CustomerViewController.h"
#import <AudioToolbox/AudioToolbox.h>

#import "GetController.h"
#import "PutController.h"
#import "SSGentleAlertView.h"
#import "TypeCCountViewController.h"
//2015-04-20 ueda
#import "EntryViewController.h"

@interface HomeViewController ()<PutControllerDelegate,GetControllerDelegate,EntryViewDelegate>{
    UILabel *kakutei;
    NSArray *controls1;
    NSArray *controls2;
    NSArray *controls3;
    
    
    BOOL isSend;
    BOOL isShowMenuPattern;//メニューパターンを表示するか否か
    NSString *patternStr;
    NSString *filePath;
    
    PutController *put;
    GetController *get;
}

@end

@implementation HomeViewController

#pragma mark -
#pragma mark - Control object action

static void onSoundFinished(SystemSoundID sndId, void *info) {
    AudioServicesDisposeSystemSoundID(sndId);
    
    NSString* mySelf = (__bridge_transfer NSString*)info;
    LOG(@"%@",mySelf);
    
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    if (![fileManager removeItemAtPath:mySelf error:NULL]) {
        //2014-01-31 ueda
        //Alert([String Order_Station], @"Error.Did not remove local file.");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"Error.Did not remove local file."];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
}

- (IBAction)iba_getMaster:(id)sender{
    
    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
        //2014-10-30 ueda
        [self showIndicator];
        
        //マスターデータの取得
        isReadMaster = YES;
        [net deleteAllData];
        [net getMasterData:self
                     count:1];
    }
}

- (IBAction)iba_changeSwitch:(id)sender{
    UISwitch *_switch = (UISwitch*)sender;
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.isConnection = _switch.isOn;
}

- (IBAction)iba_deleteMessage:(id)sender{
    
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Clear_Message] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
     */
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Clear_Message]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 2;
    [alert show];
}

- (IBAction)iba_showNext:(id)sender{
    
    currentBt = sender;
    
    
    if ([[System sharedInstance].demo isEqualToString:@"1"]) {
        if (sender!=self.bt_original&&sender!=self.bt_2) {
            return;
        }
    }
    
    //担当者が選択されているかの判定
    if (!sys.currentTanto) {
        //2014-01-31 ueda
        //Alert([String Order_Station], [String Choice_staff]);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Choice_staff]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        return;
    }
    
    //マスタダウンロードが完了しているかの判定
    if (![sys.getMaster isEqualToString:@"1"]) {
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Load_Master] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
         */
        //2014-01-30 ueda
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Load_Master]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 1;
        [alert show];
        return;
    }
    
    //担当者が選択されているかの判定
    if (!sys.currentTanto) {
        //2014-01-31 ueda
        //Alert([String Order_Station], [String Choice_staff]);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Choice_staff]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        return;
    }
    
    //2014-12-25 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.OrderRequestN31retryFlag = NO;
    appDelegate.OrderRequestN31forceFlag = NO;

    //入力タイプBの判定(新規のみ、追加の場合は後フェーズで変更)
    if ([sys.entryType isEqualToString:@"1"]&&
        sender==self.bt_original) {
        
        /*
        mbProcess = [[MBProgressHUD alloc] initWithView:self.view];
        mbProcess.labelText = @"Loading Data";
        [self.view addSubview:mbProcess];
        [mbProcess setDelegate:self];
        [mbProcess show:YES];
        [[NetWorkManager sharedInstance] getTableStatus:self];//欠品(品切れ)情報取得のため
         */
        [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
        return;
    }
    
    //検索機能使用の判定（新規は選択不可）
    if (sender==self.bt_add||sender==self.bt_cancel||sender==self.bt_check) {
        if ([sys.searchType isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"SearchView" sender:@"typeSearch"];
            return;
        }
    }
    
    //2014-09-09 ueda
    if ([sys.entryType isEqualToString:@"2"]) {
        //入力タイプＣの場合
        appDelegate.typeCeditModeFg   = NO;
        appDelegate.typeCorderIndex   = 1;
        appDelegate.typeCorderResetFg = YES;
        appDelegate.typeCorderCount   = 0;
        appDelegate.typeCarrangeCount = 0;
        //2014-09-22 ueda
        appDelegate.typeCpreOrderTypeNo = 0;
        [[OrderManager sharedInstance] zeroReset];
        [[OrderManager sharedInstance] typeCclearDB];
        [DataList sharedInstance].typeCseatSelect = [[NSMutableArray alloc]init];
    }
    
    //新規の場合
    if (sender==self.bt_original) {
        //拡張2　0 = 客層 1 = 無し　2 = 顧客
        if ([sys.kakucho2Type isEqualToString:@"0"]) {
            [self performSegueWithIdentifier:@"ToCustomerView" sender:sender];
        }
        else if([sys.kakucho2Type isEqualToString:@"1"]){
            [self goToSelectTableView:sender];
        }
        else{
            [self performSegueWithIdentifier:@"SearchView" sender:@"typeKokyaku"];
        }
    }
    else{
        [self goToSelectTableView:sender];
    }
}

- (void)goToSelectTableView:(id)sender{
    
    currentBt = sender;
    
    //2015-06-01 ueda
    if (sender==self.bt_check) {
        if ([[System sharedInstance].useOrderStatus isEqualToString:@"1"]) {
            [self showIndicator];
            [[NetWorkManager sharedInstance] getOrderStat:self count:1];
            return;
        }
    }
    
    //テーブル入力の判定
    if ([sys.tableType isEqualToString:@"0"]) {
        [self performSegueWithIdentifier:@"ToTableView" sender:sender];
    }
    else{
        //2015-12-08 ueda ASTERISK
        //調理指示もテーブル入力
/*
        if (sender==self.bt_1) {//指示画面のみテーブルタッチ入力に限定
            [self performSegueWithIdentifier:@"ToTableView" sender:sender];
        }
 */
        //2015-12-08 ueda ASTERISK
        if (NO) {
            //NOP
        }
        else{
            //2014-10-22 ueda
            if ([[System sharedInstance].entryType isEqualToString:@"2"]) {
                //入力タイプＣの場合
                if (sender==self.bt_original) {
                    //新規の場合
                    if ([sys.ninzu isEqualToString:@"1"]) {
                        //人数入力する
                        [self performSegueWithIdentifier:@"ToTypeCCountView" sender:sender];
                    } else {
                        [self performSegueWithIdentifier:@"ToCountView" sender:sender];
                    }
                } else {
                    [self performSegueWithIdentifier:@"ToCountView" sender:sender];
                }
            } else {
                [self performSegueWithIdentifier:@"ToCountView" sender:sender];
            }
        }
    }
}

- (IBAction)iba_pushTanto:(id)sender{
    
    if (![sys.getMaster isEqualToString:@"1"]) {
        //2014-01-30 ueda
        /*
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Load_Master] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
         */
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Load_Master]];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:[String Yes]];
        [alert addButtonWithTitle:[String No]];
        alert.cancelButtonIndex=0;
        alert.tag = 1;
        [alert show];
        return;
    }
    
    UIButton *_bt = (UIButton*)sender;
    if (_bt.selected) {
        [self hideControl:YES];
        _bt.selected = NO;
        //2014-02-07 ueda
        _bt.backgroundColor = BLUE;
        //2014-03-05 ueda
        if ([sys.training isEqualToString:@"1"]){
            UIImage *img = [UIImage imageNamed:@"Tanto3.png"];
            [_bt setBackgroundImage:img forState:UIControlStateNormal];
        } else {
            UIImage *img = [UIImage imageNamed:@"Tanto1.png"];
            [_bt setBackgroundImage:img forState:UIControlStateNormal];
        }
        //2014-01-29 ueda
        [System tapSound];
        
        if (kakutei) {
            [kakutei removeFromSuperview];
        }
        
        [self changeEnableFunction];
    
        //2014-01-27 ueda
        //[self.bt_tanto setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];

        if ([System existCacheAccount]) {
            [sys saveChacheAccount];
        }
    }
    else{
        //2015-04-20 ueda
        if ([[System sharedInstance].staffCodeInputOnOff isEqualToString:@"1"]) {
            //担当者コード入力
            [System tapSound];
            EntryViewController *entryViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"STAFFCODEINPUT"];
            entryViewController.entryType = EntryTypeStaffCode;
            entryViewController.delegate = self;
            entryViewController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
            [self presentViewController:entryViewController animated:YES completion:nil];
        } else {
            DataList *_data = [DataList sharedInstance];
            [_data reloadTantoList];
            
            [self showControl:YES];
            _bt.selected = YES;
            //2014-01-27 ueda
            _bt.backgroundColor= [UIColor redColor];
            //2014-03-05 ueda
            UIImage *img = [UIImage imageNamed:@"Tanto2.png"];
            [_bt setBackgroundImage:img forState:UIControlStateNormal];
            //2014-01-29 ueda
            [System tapSound];
            
            kakutei = [[UILabel alloc]initWithFrame:CGRectMake(0, 5, _bt.bounds.size.width, 20)];
            kakutei.text = [String Select_staff];
            kakutei.textAlignment = NSTextAlignmentCenter;
            kakutei.font = [UIFont systemFontOfSize:15];
            kakutei.textColor = [UIColor blackColor];
            [kakutei setBackgroundColor:[UIColor clearColor]];
            kakutei.hidden = YES;
            [_bt addSubview:kakutei];
            
            [self performSelector:@selector(showMes) withObject:nil afterDelay:0.2];
        }
    }
}

- (void)changeEnableFunction{
    if ([sys.currentTanto[@"CancelFLG"]isEqualToString:@"0"]) {
        self.bt_cancel.enabled = NO;
    }
    else{
        self.bt_cancel.enabled = YES;
    }
    
    if ([sys.currentTanto[@"OriginalFLG"]isEqualToString:@"0"]) {
        self.bt_original.enabled = NO;
    }
    else{
        self.bt_original.enabled = YES;
    }
    
    if ([sys.currentTanto[@"AddFLG"]isEqualToString:@"0"]) {
        self.bt_add.enabled = NO;
    }
    else{
        self.bt_add.enabled = YES;
    }
    
    if ([sys.currentTanto[@"DivideFLG"]isEqualToString:@"0"]) {
        self.bt_divide.enabled = NO;
    }
    else{
        self.bt_divide.enabled = YES;
    }
    
    if ([sys.currentTanto[@"MoveFLG"]isEqualToString:@"0"]) {
        self.bt_move.enabled = NO;
    }
    else{
        self.bt_move.enabled = YES;
    }
}

- (void)showMes{
    if (kakutei) {
        kakutei.hidden = NO;
    }
}

- (void)showControl:(BOOL)_anim{
    
    float duration = 0.0;
    if (_anim) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         for (int ct = 0; ct < [controls1 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls1 objectAtIndex:ct];
                             _bt.alpha = 1.0;
                         }
                         
                         for (int ct = 0; ct < [controls2 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls2 objectAtIndex:ct];
                             _bt.alpha = 0.0;
                         }
                         for (int ct = 0; ct < [controls3 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls3 objectAtIndex:ct];
                             _bt.alpha = 0.0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (void)hideControl:(BOOL)_anim{
    
    float duration = 0.0;
    if (_anim) {
        duration = 0.2f;
    }
    
    [UIView animateWithDuration:duration
                          delay:0.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         for (int ct = 0; ct < [controls1 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls1 objectAtIndex:ct];
                             _bt.alpha = 0.0;
                         }
                         
                         for (int ct = 0; ct < [controls2 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls2 objectAtIndex:ct];
                             _bt.alpha = 1.0;
                         }
                         for (int ct = 0; ct < [controls3 count]; ct++) {
                             UIButton *_bt = (UIButton*)[controls3 objectAtIndex:ct];
                             _bt.alpha = 1.0;
                         }
                     }
                     completion:^(BOOL finished){
                         
                     }];
}

- (IBAction)iba_prev2:(id)sender{
    [self moveTantoName:NO name:[self tanto:0]];
}

- (IBAction)iba_prev:(id)sender{
    [self moveTantoName:NO name:[self tanto:1]];
}

- (IBAction)iba_next:(id)sender{
    [self moveTantoName:YES name:[self tanto:2]];
}

- (IBAction)iba_next2:(id)sender{
    [self moveTantoName:YES name:[self tanto:3]];
}

- (NSString*)tanto:(int)_type{

    NSString *_name = nil;
    NSInteger row = 0;
    DataList *_data = [DataList sharedInstance];
    if (sys.currentTanto) {
        row = [_data.tantoList indexOfObject:sys.currentTanto];
    }
    
    switch (_type) {
        case 0:
            row = 0;
            break;
            
        case 1:
            row--;
            if (row<0) {
                row = [_data.tantoList count]-1;
            }
            break;
            
        case 2:
            if (sys.currentTanto) {
                row++;
            }
            else{
                row = 0;
            }
            
            if (row>[_data.tantoList count]-1) {
                row = 0;
            }
            break;
            
        case 3:
            row = [_data.tantoList count]-1;
            break;
            
        default:
            break;
    }
    

    if (!self.bt_prev2.enabled) {
        self.bt_prev.enabled = YES;
        self.bt_prev2.enabled = YES;
    }
    if (!self.bt_next2.enabled) {
        self.bt_next.enabled = YES;
        self.bt_next2.enabled = YES;
    }
    
    if (row==0) {
        self.bt_prev.enabled = NO;
        self.bt_prev2.enabled = NO;
    }
    else if(row==[_data.tantoList count]-1){
        self.bt_next.enabled = NO;
        self.bt_next2.enabled = NO;
    }
    
    
    NSDictionary *tanto = [_data.tantoList objectAtIndex:row];
    if ([tanto[@"MstTantoCD"]intValue]!=[sys.currentTanto[@"MstTantoCD"]intValue]) {
        sys.currentTanto = [_data.tantoList objectAtIndex:row];
        _name = sys.currentTanto[@"TantoNM"];
        return _name;
    }
    return nil;
}

- (void)moveTantoName:(BOOL)_next
                 name:(NSString*)_name{
    
    if (!_name) {
        return;
    }
    
    int point1;
    int point2;
    if (_next) {
        point1 = -1.5;
        point2 =  2.5;
    }
    else{
        point1 =  2.5;
        point2 = -1.5;
    }
    
    [UIView animateWithDuration:0.15f
                          delay:0.0f
                        options:UIViewAnimationOptionAllowAnimatedContent
                     animations:^{
                         CGPoint point = CGPointMake(self.bt_tanto.bounds.size.width*point1,self.bt_tanto.bounds.size.height/2);
                         self.bt_tanto.titleLabel.center = point;
                     }
                     completion:^(BOOL finished){
                         //2014-01-28
                         //[self.bt_tanto setTitle:_name forState:UIControlStateNormal];
                         //[self.bt_tanto setTitle:_name forState:UIControlStateSelected];
                         //[self.bt_tanto setTitle:_name forState:UIControlStateHighlighted];
                         NSString *titleText =[NSString stringWithFormat:@"%@   %@",sys.currentTanto[@"MstTantoCD"],sys.currentTanto[@"TantoNM"]];
                         [self.bt_tanto setTitle:titleText forState:UIControlStateNormal];
                         [self.bt_tanto setTitle:titleText forState:UIControlStateSelected];
                         [self.bt_tanto setTitle:titleText forState:UIControlStateHighlighted];

                         CGPoint point = CGPointMake(self.bt_tanto.bounds.size.width*point2,self.bt_tanto.bounds.size.height/2);
                         self.bt_tanto.titleLabel.center = point;

                         [UIView animateWithDuration:0.15f
                                               delay:0.0f
                                             options:UIViewAnimationOptionAllowAnimatedContent
                                          animations:^{
                                              CGPoint point = CGPointMake(self.bt_tanto.bounds.size.width*0.5,self.bt_tanto.bounds.size.height/2);
                                              self.bt_tanto.titleLabel.center = point;
                                          }
                                          completion:^(BOOL finished){
                                              
                                          }];
                     }];
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

/*
- (void) viewDidLayoutSubviews {

    CGRect viewBounds = self.view.bounds;
    
    LOG(@"%f",viewBounds.size.height);
    
    CGFloat topBarOffset = self.topLayoutGuide.length;
    viewBounds.origin.y = topBarOffset * -1;
    //viewBounds.size.height = viewBounds.size.height -10;
    self.view.bounds = viewBounds;
    
    
    LOG(@"%f",viewBounds.size.height);
}
*/
- (void)viewDidLoad
{
    [super viewDidLoad];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    delegate.isConnection = YES;
    isReadMaster = NO;
    isConnectionFtp = NO;
    
    
    controls1 = [[NSArray alloc]initWithObjects:self.bt_prev,self.bt_prev2,self.bt_next,self.bt_next2, nil];
    controls2 = [[NSArray alloc]initWithObjects:self.bt_divide,self.bt_move,self.bt_1,self.bt_2, nil];
    controls3 = [[NSArray alloc]initWithObjects:self.bt_check,self.bt_cancel,self.bt_add,self.bt_original, nil];
    
    
    [self hideControl:NO];
    
    sys = [System sharedInstance];
    //2015-09-17 ueda
    if ([sys.useOrderConfirm length] == 0) {
        sys.useOrderConfirm = @"1";
        [sys saveChacheAccount];
        sys = [System sharedInstance];
    }
    isShowMenuPattern = NO;
    isPlayVoice = NO;
    
    //2014-02-05 ueda Start
    NSString *copyFlag =@"0";
    //ＤＢファイル名
    NSString* database_filename;
    database_filename = @"orderdb.db";
    //"/Library/Application Support"フォルダ
    NSString *applicationSupportDirectory = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) lastObject];
    NSError *error0 = nil;
    if ( ![[NSFileManager defaultManager] fileExistsAtPath:applicationSupportDirectory isDirectory:NULL] ) {
        //存在しない場合は作成する
        if (![[NSFileManager defaultManager]
              createDirectoryAtPath:applicationSupportDirectory
              withIntermediateDirectories:NO
              attributes:nil
              error:&error0]) {
            // エラー（無視）
        }
    }
    NSString* work_path;
    work_path = [NSSearchPathForDirectoriesInDomains(NSApplicationSupportDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* database_path;
    //ターゲットパス(/Library/Application Support/orderdb.db)
    database_path = [NSString stringWithFormat:@"%@/%@", work_path, database_filename];
    NSFileManager* manager = [NSFileManager defaultManager];
    if (![manager fileExistsAtPath:database_path])
    {
        copyFlag = @"1";
        //ターゲットパスに存在しない場合
        NSError* error = nil;
        NSString* template_path;
        template_path = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:database_filename];
        //データベースをバンドルからコピー
        if (![manager copyItemAtPath:template_path toPath:database_path error:&error])
        {
            //コピーに失敗した場合（無視）
        }
        //2014-09-22 ueda
        //サンプル画像をコピー
        NSString *jpgFile = @"101.jpg";
        NSString *copyJpgFile = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:jpgFile];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *docPath = [NSString stringWithFormat:@"%@/%@", [paths objectAtIndex:0], jpgFile];
        if (![manager copyItemAtPath:copyJpgFile toPath:docPath error:&error]) {
            //コピーに失敗した場合（無視）
        }
        sys.getMaster=@"1";
        sys.demo=@"1";
        sys.menuPatternType=@"0";
        sys.orderType=@"1";
        [sys saveChacheAccount];
    }
    //2014-02-05 ueda End
    
    //データベースの初期化
    net = [NetWorkManager sharedInstance];
    net.voiceDelegate = self;
    [net createDateBase];
    
    if (![sys.getMaster isEqualToString:@"1"]) {
        [self iba_getMaster:nil];
    }
    
    //2014-02-05 ueda
    if ([copyFlag  isEqualToString:@"1"]) {
        DataList *_data = [DataList sharedInstance];
        sys.currentTanto = [_data.tantoList objectAtIndex:0];
        [sys saveChacheAccount];
    }
    //if (sys.currentTanto) {
    //    [self.bt_tanto setTitle:sys.currentTanto[@"TantoNM"] forState:UIControlStateNormal];
    //}
    
    [self showDeviceVer:0];
    
    //音声のバックグラウンド再生用にプロパティを設定する
    NSString *path = [[NSBundle mainBundle] pathForResource:@"15sec" ofType:@"mp3"];
    NSURL* url = [NSURL fileURLWithPath:path];
    self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    
    NSError *error = nil;
    AVAudioSession* audioSession = [AVAudioSession sharedInstance];
    [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
    [audioSession setActive:YES error:&error];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ( error != nil ){
        LOG(@"Error %@", [error localizedDescription]);
    }
    self.player.delegate = self;
    [self.player play];
    
    
    
    //ディレクトリ内に存在する音声ファイルキャッシュを削除する
    NSString *docDir = [NSString stringWithFormat:@"%@/Documents", NSHomeDirectory()];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    error = nil;
    NSArray *list = [fileManager contentsOfDirectoryAtPath:docDir
                                                     error:&error];
    for (NSString *path in list) {
        //2014-02-03 ueda
        if ([path hasSuffix:@".jpg"]) {
            //JPGは対象外
        } else {
            [self removeFilePath:[NSString stringWithFormat:@"%@/%@",docDir,path]];
        }
    }
    
    NSString *tmpDir = [NSString stringWithFormat:@"%@/tmp", NSHomeDirectory()];
    error = nil;
    list = [fileManager contentsOfDirectoryAtPath:tmpDir
                                                     error:&error];
    for (NSString *path in list) {
        [self removeFilePath:[NSString stringWithFormat:@"%@/%@",tmpDir,path]];
    }
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    [System adjustStatusBarSpace:self.view];
    
    //2015-06-17 ueda
/*
    //2014-09-18 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.getMasterSetFg) {
        appDelegate.getMasterSetFg = 0;
        sys.masterVer = @"ZZ";
        [sys saveChacheAccount];
    }
 */
    
    //2015-06-29 ueda
    if ([[[[UIDevice currentDevice] systemVersion] componentsSeparatedByString:@"."][0] intValue] >= 7) {
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }

}

//type 0 = 初回表示　1 = メッセージ表示
- (void)showDeviceVer:(int)type{
    if (type==0) {
        if ([sys.menuPatternEnable isEqualToString:@"0"]){
            self.lb_msg.text = [NSString stringWithFormat:@"%@\n(%@:%@)",[String Ver],[String Menu_pattern],sys.menuPatternType];
        }
        else{
            self.lb_msg.text = [NSString stringWithFormat:@"%@",[String Ver]];
        }
        self.lb_msg.textAlignment = NSTextAlignmentCenter;
    }
    else{
        if ([sys.menuPatternEnable isEqualToString:@"0"]) {
            self.lb_msg.text = [NSString stringWithFormat:@"(%@:%@)",[String Menu_pattern],sys.menuPatternType];
            self.lb_msg.textAlignment = NSTextAlignmentCenter;
        }
        else{
            if ([net.orderResultMsg length]>0) {
                self.lb_msg.text = net.orderResultMsg;
                self.lb_msg.textAlignment = NSTextAlignmentLeft;
            }
            else{
                self.lb_msg.text = @"";
            }
        }
    }
}


#pragma mark NetWorkManagerDelegate
-(void)didFinishRead:(id)_dataList
            readList:(NSArray*)_readList
                type:(int)type{
    dispatch_async(dispatch_get_main_queue(), ^{
        if (type==RequestTypeSystem) {
            if ([(NSString*)_dataList isEqualToString:@"1"]) {
                //2014-01-30 ueda
                /*
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[String Load_Master] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
                 */
                //2014-01-30 ueda
                SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
              //alert.title=[String Order_Station];
                alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Load_Master]];
                alert.messageLabel.font=[UIFont systemFontOfSize:18];
                alert.delegate=self;
                [alert addButtonWithTitle:[String Yes]];
                [alert addButtonWithTitle:[String No]];
                alert.cancelButtonIndex=0;
                alert.tag = 1;
                [alert show];
            }
        }
        else if (type==RequestTypeTableStatus) {
            [self performSegueWithIdentifier:@"ToOrderEntryView" sender:nil];
        }
        //2015-05-12 ueda
        else if (type==RequestTypeClearMessage) {
            net.orderResultMsg = @"";
            [self showDeviceVer:1];
        }
        //2015-06-01 ueda
        else if (type==RequestTypeOrderStat) {
            [self performSegueWithIdentifier:@"ToOrderStatusView" sender:nil];
        }
        else{
            LOG(@"_dataList:%@",_dataList);
            DataList *_data = [DataList sharedInstance];
            [_data reloadTantoList];
            
            isReadMaster = NO;
            
            sys = [System sharedInstance];
            //2015-11-04 ueda
            if (YES) {
                if (sys.currentTanto) {
                    if ([_data.tantoList containsObject:sys.currentTanto]) {
                    } else {
                        [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateNormal];
                        [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateSelected];
                        [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateHighlighted];
                        sys.currentTanto = nil;
                        self.bt_prev.enabled = NO;
                        self.bt_prev2.enabled = NO;
                        [sys saveChacheAccount];
                    }
                }
                [self viewWillAppear:NO];
            }
        }
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

-(void)didFinishReadWithError:(NSError*)_error
                          msg:(NSString*)_msg
                         type:(int)type{
    dispatch_async(dispatch_get_main_queue(), ^{
         

        if (isReadMaster) {
            LOG(@"1:%d",type);
            isReadMaster = NO;
            
            
            
            if ([System existCacheAccount]) {
                sys = [System sharedInstance];
                sys.getMaster = @"0";
                [sys saveChacheAccount];
            }
            //2014-01-30 ueda
            /*
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[String Order_Station] message:[NSString stringWithFormat:@"%@\n%@",_msg,[String Load_Master]] delegate:self cancelButtonTitle:nil otherButtonTitles:[String Yes],[String No], nil];
             */
            SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
          //alert.title=[String Order_Station];
            alert.message=[NSString stringWithFormat:@"%@\n%@",_msg,[String Load_Master]];
            alert.messageLabel.font=[UIFont systemFontOfSize:18];
            alert.delegate=self;
            [alert addButtonWithTitle:[String Yes]];
            [alert addButtonWithTitle:[String No]];
            alert.cancelButtonIndex=0;
            alert.tag = 1;
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
            //2015-06-10 ueda
            if (type==RequestTypeOrderStat) {
                AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                if (appDelegate.communication_Return_Status == communication_Return_MasterDownload) {
                    alert.delegate=self;
                    alert.tag=3;
                }
            }
            [alert addButtonWithTitle:@"OK"];
            alert.cancelButtonIndex=0;
            [alert show];
        }
        
        if (mbProcess) {
            [mbProcess hide:YES];
        }
    });
}

-(void)setStatusText:(NSString*)text stepCount:(int)_count{
    //2014-07-10 ueda
    //mbProcess.labelText = text;
    mbProcess.detailsLabelText = text;
    mbProcess.mode = MBProgressHUDModeDeterminate;
    //2015-03-24 ueda
    float progVal = (float)(_count / 20.f);
    if (progVal <= 1.0f) {
        mbProcess.progress = progVal;
    }
}


-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    
    if (alertView.tag==1) {
        switch (buttonIndex) {
            case 0:
                [self iba_getMaster:nil];
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==2) {
        switch (buttonIndex) {
            case 0:{
                //2015-05-12 ueda
                if ([[System sharedInstance].demo isEqualToString:@"1"]) {
                    net.orderResultMsg = @"";
                    [self showDeviceVer:1];
                } else {
                    [self showIndicator];
                    [[NetWorkManager sharedInstance] clearMessage:self];
                }
                break;
            }
            case 1:
                break;
        }
    }
    //2015-06-10 ueda
    else if (alertView.tag==3) {
        switch (buttonIndex) {
            case 0:{
                if (!isReadMaster) {
                    if ([[System sharedInstance].demo isEqualToString:@"0"]) {
                        if ([sys.getMaster isEqualToString:@"1"]) {
                            [self showIndicator];
                            [net getSystemSetting:self
                                            count:0];
                        }
                    }
                }
                break;
            }
            case 1:
                break;
        }
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    //2014-01-27 ueda
    /*
    AppDelegate *delegate = [[UIApplication sharedApplication]delegate];
    [delegate buttonSetColorGray:0.55f face2:0.35f side1:0.35f side2:0.25f];
     */
    
    DataList *dat = [DataList sharedInstance];
    [dat clearData];
    
    OrderManager *_order = [OrderManager sharedInstance];
    [_order zeroReset];
    //2016-02-02 ueda
    [_order typeCclearDB];
    
    sys = [System sharedInstance];
    
    dat.typeOrder = TypeOrderNone;
    
    //ボタンの初期設定
    [self.bt_original setTitle:[String bt_new] forState:UIControlStateNormal];
    [self.bt_divide setTitle:[String bt_divide] forState:UIControlStateNormal];
    [self.bt_move setTitle:[String bt_move] forState:UIControlStateNormal];
    [self.bt_add setTitle:[String bt_add] forState:UIControlStateNormal];
    [self.bt_cancel setTitle:[String bt_cancel] forState:UIControlStateNormal];
    [self.bt_check setTitle:[String bt_check] forState:UIControlStateNormal];
    [self.bt_1 setTitle:[String bt_cook] forState:UIControlStateNormal];
    [self.bt_2 setTitle:[String bt_setting] forState:UIControlStateNormal];
    
    self.bt_original.enabled = YES;
    self.bt_divide.enabled = YES;
    self.bt_move.enabled = YES;
    self.bt_add.enabled = YES;
    self.bt_1.enabled = NO;
    

    if ([sys.transceiver isEqualToString:@"0"]) {
        self.bt_control.hidden = NO;
        self.bt_rec.hidden = NO;
    }
    else{
        self.bt_control.hidden = YES;
        self.bt_rec.hidden = YES;
    }
    
    //担当者による設定
    if (sys.currentTanto) {
        if ([dat.tantoList containsObject:sys.currentTanto]) {
            //2014-01-28 ueda
            //[self.bt_tanto setTitle:sys.currentTanto[@"TantoNM"] forState:UIControlStateNormal];
            //2015-11-04 ueda
            //[self.bt_tanto setTitle:[NSString stringWithFormat:@"%@   %@",sys.currentTanto[@"MstTantoCD"],sys.currentTanto[@"TantoNM"]] forState:UIControlStateNormal];
            NSString *titleText =[NSString stringWithFormat:@"%@   %@",sys.currentTanto[@"MstTantoCD"],sys.currentTanto[@"TantoNM"]];
            [self.bt_tanto setTitle:titleText forState:UIControlStateNormal];
            [self.bt_tanto setTitle:titleText forState:UIControlStateSelected];
            [self.bt_tanto setTitle:titleText forState:UIControlStateHighlighted];
        }
        else{
            //2015-11-04 ueda
            //[self.bt_tanto setTitle:@"担当者を選択" forState:UIControlStateNormal];
            [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateNormal];
            [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateSelected];
            [self.bt_tanto setTitle:[String No_Staff] forState:UIControlStateHighlighted];            sys.currentTanto = nil;
            self.bt_prev.enabled = NO;
            self.bt_prev2.enabled = NO;
        }
    }
    
    [self changeEnableFunction];
    
    //2014-07-07 ueda
    if (([sys.entryType isEqualToString:@"0"]) || ([sys.entryType isEqualToString:@"2"])){//オーダータイプA
        [self.bt_original setTitle:[String bt_new] forState:UIControlStateNormal];
        
        if ([sys.searchType isEqualToString:@"0"]) {//検索機能を使用する
            [self.bt_original setTitle:@"" forState:UIControlStateNormal];
             [self.bt_divide setTitle:@"" forState:UIControlStateNormal];
             [self.bt_move setTitle:@"" forState:UIControlStateNormal];
            self.bt_original.enabled = NO;
            self.bt_divide.enabled = NO;
            self.bt_move.enabled = NO;
        }
    }
    else{//オーダータイプB
        [self.bt_original setTitle:[String bt_order] forState:UIControlStateNormal];
        [self.bt_add setTitle:@"" forState:UIControlStateNormal];
        self.bt_add.enabled = NO;
    }
    
    if ([sys.choriType isEqualToString:@"1"]) {
        [self.bt_1 setTitle:@"" forState:UIControlStateNormal];
        self.bt_1.enabled = NO;
    }
    else{
        [self.bt_1 setTitle:[String bt_cook] forState:UIControlStateNormal];
        self.bt_1.enabled = YES;
    }
    
    if ([sys.demo isEqualToString:@"1"]) {
        self.lb_demo.text = [NSString stringWithFormat:@"///  %@  ///",[String Demo_mode]];
        self.lb_msg.text = [NSString stringWithFormat:@"\n%@",self.lb_msg.text];
    }
    else if ([sys.training isEqualToString:@"1"]){
        self.lb_demo.text = [NSString stringWithFormat:@"///  %@  ///",[String Training_mode]];
        self.lb_msg.text = [NSString stringWithFormat:@"\n%@",self.lb_msg.text];
    }
    else{
        self.lb_demo.text = @"";
    }
    
    self.lb_title.text = [NSString stringWithFormat:@"  %@:%@",[String DeviceID],sys.tanmatsuID];
    
    if (isShowMenuPattern) {
        [self showDeviceVer:1];
    }
    else{
        isShowMenuPattern = YES;
    }
    
    //2014-02-07 ueda
    _bt_tanto.backgroundColor = BLUE;
    //2014-03-05 ueda
    if ([sys.training isEqualToString:@"1"]){
        UIImage *img = [UIImage imageNamed:@"Tanto3.png"];
        [_bt_tanto setBackgroundImage:img forState:UIControlStateNormal];
    } else {
        UIImage *img = [UIImage imageNamed:@"Tanto1.png"];
        [_bt_tanto setBackgroundImage:img forState:UIControlStateNormal];
    }
    
    //2014-10-30 ueda
    self.iv_background.image = [UIImage imageNamed:@"home_background.png"];
    //2016-02-18 ueda ASSTERISK
/*
    if ([sys.home_back isEqualToString:@"fs"]) {
        self.iv_background.image = [UIImage imageNamed:@"fs_logo.png"];
    }
    //2014-11-12 ueda
    if ([sys.home_back isEqualToString:@"fj"]) {
        self.iv_background.image = [UIImage imageNamed:@"fj_logo.png"];
    }
 */
    //2016-02-18 ueda ASSTERISK
    if ([sys.home_back isEqualToString:@"kzt"]) {
        self.iv_background.image = [UIImage imageNamed:@"kzt_logo.png"];
    }
    if ([sys.home_back isEqualToString:@"else"]) {
        NSString *documents = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
        NSString *fileName = @"else_logo.jpg";
        NSString *fileFullPath = [documents stringByAppendingPathComponent:fileName];
        UIImage *elseLogoImage = [UIImage imageWithContentsOfFile:fileFullPath];
        if (elseLogoImage) {
            self.iv_background.image = elseLogoImage;
        }
    }
    
    //2015-04-10 ueda
/*
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
 */
    
    //2015-06-17 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    if (appDelegate.getMasterSetFg) {
        appDelegate.getMasterSetFg = 0;
        sys.masterVer = @"ZZ";
        [sys saveChacheAccount];
    }
    
    //マスタ更新の確認
    if (!isReadMaster) {
        if ([[System sharedInstance].demo isEqualToString:@"0"]) {
            if ([sys.getMaster isEqualToString:@"1"]) {
                [self showIndicator];
                [net getSystemSetting:self
                                count:0];
            }
        }
    }
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
    LOG(@"shouldAutorotate");
    //[[UIApplication sharedApplication] setStatusBarHidden:YES];
    return YES;
}

// For ios5
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation{
    LOG(@"shouldAutorotateToInterfaceOrientation");
    
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
    [self setBt_tanto:nil];
    [self setBt_prev:nil];
    [self setBt_prev2:nil];
    [self setBt_prev:nil];
    [self setBt_next:nil];
    [self setBt_next2:nil];
    [self setBt_divide:nil];
    [self setBt_move:nil];
    [self setBt_check:nil];
    [self setBt_cancel:nil];
    [self setBt_add:nil];
    [self setBt_original:nil];
    [self setBt_1:nil];
    [self setBt_2:nil];
    [self setLb_msg:nil];
    [self setBt_control:nil];
    [self setBt_rec:nil];
    [self setDeleteMessage:nil];
    [self setLb_demo:nil];
    [super viewDidUnload];
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    UIButton *button = currentBt;
    
    int type = 0;
    if(button==self.bt_original){
        
        type = TypeOrderOriginal;
    }
    else if(button==self.bt_add){
        
        type = TypeOrderAdd;
    }
    else if(button==self.bt_cancel){
        
        type = TypeOrderCancel;
    }
    else if(button==self.bt_check){
        
        type = TypeOrderCheck;
    }
    else if(button==self.bt_divide){
        type = TypeOrderDivide;
    }
    else if(button==self.bt_move){
        type = TypeOrderMove;
    }
    else if(button==self.bt_1){
        type = TypeOrderDirection;
    }
    
    //2014-09-11 ueda
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    appDelegate.type = type;
    
     if([[segue identifier]isEqualToString:@"ToTableView"]){
         TableViewController *view_ = (TableViewController *)[segue destinationViewController];
         view_.type = type;
     }
     else if([[segue identifier]isEqualToString:@"ToCountView"]){
         CountViewController *view_ = (CountViewController *)[segue destinationViewController];
         view_.type = type;
         
         //人数入力可否の判定(人数入力不可の場合か、新規以外の場合)
         if ([sys.ninzu isEqualToString:@"0"]||
             type!=TypeOrderOriginal) {
             view_.entryType = EntryTypeTableOnly;
         }
         else{
             view_.entryType = EntryTypeTableAndNinzu;
         }
     }
     else if([[segue identifier]isEqualToString:@"ToEntryView"]){
             OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
              view_.type = TypeOrderOriginal;
     }
     else if([[segue identifier]isEqualToString:@"ToOrderEntryView"]){
         OrderEntryViewController *view_ = (OrderEntryViewController *)[segue destinationViewController];
         view_.type = TypeOrderOriginal;
     }
     else if([[segue identifier]isEqualToString:@"SearchView"]){
         EntryViewController *view_ = (EntryViewController *)[segue destinationViewController];
         view_.type = type;
         
         if ([(NSString*)sender isEqualToString:@"typeKokyaku"]) {
             view_.entryType = EntryTypeKokyaku;
         }
         else if ([(NSString*)sender isEqualToString:@"typeSearch"]) {
             view_.entryType = EntryTypeSearch;
         }
     }
     else if([[segue identifier]isEqualToString:@"ToCustomerView"]){
         CustomerViewController *view_ = (CustomerViewController *)[segue destinationViewController];
         view_.type = type;
     }
    //2014-10-23 ueda
    else if([[segue identifier]isEqualToString:@"ToTypeCCountView"]){
         TypeCCountViewController *view_ = (TypeCCountViewController *)[segue destinationViewController];
         view_.type = type;

     }
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
    //2014-07-10 ueda
    mbProcess.mode = MBProgressHUDModeIndeterminate;
    mbProcess.detailsLabelText = nil;
    [mbProcess show:YES];
}

- (void)hudWasHidden {
    // Remove HUD from screen when the HUD was hidded
    [mbProcess removeFromSuperview];
}


#pragma mark - Actions

- (IBAction)btnRecordTapped:(id)sender {
    
   if (isPlayVoice) {
        //2014-01-31 ueda
        //Alert(@"オーダーステーション", @"音声ファイルを再生中です。");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"音声ファイルを再生中です。"];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        return;
    }
    
    
    if (isConnectionFtp) {
        //2014-01-31 ueda
        //Alert(@"オーダーステーション", @"ファイルの送受信中です。");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"ファイルの送受信中です。"];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
        return;
    }
    
    isPlayVoice = YES;
    isConnectionFtp = YES;
    
    
    if (!voiceHud) {
        voiceHud = [[POVoiceHUD alloc] initWithParentView:self.view];
        voiceHud.title = [String Speak_now];
        [voiceHud setDelegate:self];
        [self.view addSubview:voiceHud];
    }
    
    NSDateFormatter *_outputFormatter = [[NSDateFormatter alloc] init];
    [_outputFormatter setDateFormat:@"yyMMddHHmmss"];
    NSString* _date = [_outputFormatter stringFromDate:[NSDate date]];
    
    //2014-02-14 ueda
    //NSString *fileName = [NSString stringWithFormat:@"voice_%04d%@.mp4",[sys.tanmatsuID intValue],_date];
    NSString *fileName = [NSString stringWithFormat:@"voice_%@_%04d.mp4",_date,[sys.tanmatsuID intValue]];
    [voiceHud startForFilePath:[NSString stringWithFormat:@"%@/Documents/%@", NSHomeDirectory(),fileName]];
    
    [self performSelector:@selector(commitRecorded) withObject:nil afterDelay:20.0f];
}

- (void)commitRecorded{
    if (voiceHud) {
        [voiceHud commitRecording];
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commitRecorded) object:nil];
    }
}


#pragma mark - POVoiceHUD Delegate
- (void)POVoiceHUD:(POVoiceHUD *)voiceHUD voiceRecorded:(NSString *)recordPath length:(float)recordLength {
    
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(commitRecorded) object:nil];
    
    NSLog(@"Sound recorded with file %@ for %.2f seconds", [recordPath lastPathComponent], recordLength);
    
    LOG(@"recordPath:%@",recordPath);
    
    [self showIndicator];
    isConnectionFtp = YES;
    [self upload:recordPath];
    mbProcess.labelText = @"Connecting server";
}

- (void)voiceRecordCancelledByUser:(POVoiceHUD *)voiceHUD {
    NSLog(@"Voice recording cancelled for HUD: %@", voiceHUD);

    voiceHud.delegate = nil;
    voiceHud = nil;
    
    isPlayVoice = NO;
    isConnectionFtp = NO;
    
    [self nextSoundPlay];
}




#pragma mark * Status management

// These methods are used by the core transfer code to update the UI.


- (IBAction)iba_recieveTest:(id)sender{
    if (isPlayVoice) {
        //2014-01-31 ueda
        //Alert(@"オーダーステーション", @"音声ファイルを再生中です。");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"音声ファイルを再生中です。"];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
    else if(!filePath){
        //2014-01-31 ueda
        //Alert(@"オーダーステーション", @"再生できる音声がありません。");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"再生できる音声がありません。"];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
    else{
        isPlayVoice = YES;
        [self receiveDidStopWithStatus:nil];
    }
}


- (void)sendDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        //statusString = @"Put succeeded";
    }
    else{
        //2014-01-31 ueda
        //Alert([String Order_Station], statusString);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",statusString];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
    

    isPlayVoice = NO;
    isConnectionFtp = NO;
    
    //[[NetWorkManager sharedInstance] didStopNetworkOperation];
    
    [mbProcess hide:YES];
    
    NSString *ftpPath =[NSString stringWithFormat:@"%@",put.urlPath];
    [[NetWorkManager sharedInstance] sendVoice:self urlStr:ftpPath];
    
    
    //前回録音分のファイルをを削除する
    if (![self removeFilePath:put.filePath]) {
        //2014-01-31 ueda
        //Alert([String Order_Station], @"Error.Did not remove local file.");
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",@"Error.Did not remove local file."];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
}

- (void)receiveDidStopWithStatus:(NSString *)statusString
{
    if (statusString == nil) {
        
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        
        NSError *error = nil;
        
        NSString *path = nil;
        if (get&&get.filePath.length>0) {
            path = get.filePath;
            filePath = get.filePath;
        }
        else{
            path = filePath;
        }
        
        LOG(@"filePath:%@",path);
        
        NSURL *url = [[NSURL alloc] initFileURLWithPath:path];
        self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:&error];
        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
        [audioSession setActive:YES error:&error];
        [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

        if ( error != nil )
        {
            LOG(@"Error %@", [error localizedDescription]);
        }
        
        [self.player play];
        [self.player setDelegate:self];
    }
    else{
        //2014-01-31 ueda
        //Alert([String Order_Station], statusString);
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",statusString];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=nil;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        [alert show];
    }
    LOG(@"%@",statusString);

}

//RemoteControlDelegate
- (void)remoteControlReceivedWithEvent:(UIEvent *)event
{
    NSLog(@"receive remote control events");
}

#pragma mark - AVAudioPlayerDelegate
-(void)audioPlayerDidFinishPlaying:(AVAudioPlayer *)player successfully:(BOOL)flag
{
    if (flag){
        
        isPlayVoice = NO;

        LOG(@"Done:%@",net.voiceList);
        // Can start next audio?
        
        
        if (net.voiceList&&net.voiceList.count>0) {
            LOG(@"Play next sound");
            [net.voiceList removeObjectAtIndex:0];
        }
        [self nextSoundPlay];
    }
}

- (void)nextSoundPlay{
    //次の音声の取得を開始する
    if (net.voiceList&&net.voiceList.count>0) {
        LOG(@"Play next sound");
        //[net.voiceList removeObjectAtIndex:0];
        [self download:[net.voiceList[0] substringFromIndex:6]];
    }
    
    //音声再生を終了する
    else if (net.voiceList&&net.voiceList.count==1){
        LOG(@"Sound list is finish");
        [net.voiceList removeObjectAtIndex:0];
    }
}


- (void)removeLocalFiles
{
    LOG(@"1");
    
    //当該ファイルを削除する
    if (filePath) {
        if (![self removeFilePath:filePath]) {
            LOG( @"Error.Did not remove local file.");
        }
        filePath = nil;
    }
}

- (BOOL)removeFilePath:(NSString*)path
{
    NSFileManager *fileManager = [[NSFileManager alloc] init];
    return [fileManager removeItemAtPath:path error:NULL];
}


#pragma mark * Core transfer code
-(void) download:(NSString*)path
{
    
    if (isPlayVoice) {
        return;
    }
    isPlayVoice = YES;
    
    if (isConnectionFtp) {
        return;
    }
    isConnectionFtp = YES;
    

    //前回受信分のファイルを削除する
    if (![self removeFilePath:filePath]) {
        LOG(@"Error.Did not remove local file.");
    }
    
    LOG(@"%@",path);
    
    if (!get) {
        get = [[GetController alloc]init];
        get.delegate = self;
    }
    [get startReceive:path];
}

-(void) upload:(NSString*)path
{
    if (!put) {
        put = [[PutController alloc]init];
        put.delegate = self;
    }
    [put startSend:path];
}

- (void)stopSendWithStatus:(NSString *)statusString
{
    LOG(@"%@",statusString);
    [self sendDidStopWithStatus:statusString];
    
    isPlayVoice = NO;
    isConnectionFtp = NO;
    
    put.delegate = nil;
    put = nil;
    
    //取得失敗時には、失敗したURLを破棄して次の音声取得を開始する
    if (statusString.length>0) {
        if (net.voiceList&&net.voiceList.count>0) {
            [net.voiceList removeObjectAtIndex:0];
        }
    }
    
    [self nextSoundPlay];
}

- (void)stopReceiveWithStatus:(NSString *)statusString
{
    [self receiveDidStopWithStatus:statusString];

    isConnectionFtp = NO;
    
    if (statusString&&statusString.length>0) {
        LOG(@"remove paths");
        
        //取得失敗時には、失敗したURLを破棄して次の音声取得を開始する
        if (net.voiceList&&net.voiceList.count>0) {
            [net.voiceList removeObjectAtIndex:0];
        }
        
        isPlayVoice = NO;
        
        [self nextSoundPlay];
    }
    
    get.delegate = nil;
    get = nil;
}


//2015-04-20 ueda
- (void)finishStaffCode:(NSString*)returnValue{
    NetWorkManager *_net = [NetWorkManager sharedInstance];
    [_net openDb];
    //2015-06-17 ueda 担当者コードを６桁に
    NSString *code = [_net appendSpace:returnValue totalLength:[System sharedInstance].staffCodeKetaStr.intValue];
    FMResultSet *rs  = [_net.db executeQuery:@"select * from Tanto_MT where MstTantoCD = ?",code];
    if ([rs next]) {
        NSMutableDictionary *_dic = [[NSMutableDictionary alloc]init];
        for (int ct = 0; ct < [rs columnCount]; ct++) {
            NSString *column = [rs columnNameForIndex:ct];
            
            if ([column isEqualToString:@"MstTantoCD"]) {
                int num = [[rs stringForColumn:column]intValue];
                [_dic setValue:[NSNumber numberWithInt:num] forKey:column];
            }
            else{
                [_dic setValue:[rs stringForColumn:column] forKey:column];
            }
        }
        sys.currentTanto = _dic;
        [sys saveChacheAccount];
    }
    [rs close];
    [_net closeDb];
}

@end
