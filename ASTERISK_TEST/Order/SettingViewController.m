//
//  SettingViewController.m
//  Order
//
//  Created by koji kodama on 13/04/28.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "SettingViewController.h"
#import "SSGentleAlertView.h"
//2015-04-30 ueda
#import "OrderStatusViewController.h"
#import "ReserveListViewController.h"

@interface SettingViewController ()

@end

@implementation SettingViewController

//==============================================================================


- (IBAction)iba_exit:(id)sender{
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                   message:[String System_will_finish]
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:[String Yes],[String No], nil];
    */
	//2014-01-30 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String System_will_finish]];
    alert.messageLabel.font=[UIFont systemFontOfSize:18];
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 3;
    [alert show];
}

- (IBAction)iba_back:(id)sender{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)iba_getMaster:(id)sender{
    
    LOG(@"%@",[System sharedInstance].masterVer);
    
    NSString *_str = [NSString stringWithFormat:[String Load_Master_with_num],[System sharedInstance].masterVer];
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
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
	//alert.messageLabel.textAlignment = NSTextAlignmentLeft;
    alert.delegate=self;
    [alert addButtonWithTitle:[String Yes]];
    [alert addButtonWithTitle:[String No]];
    alert.cancelButtonIndex=0;
    alert.tag = 2;
    [alert show];
    

}

- (IBAction)iba_setting:(id)sender{
    //2014-01-30 ueda
    /*
    UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[String Order_Station]
                                                   message:[String Set_up]
                                                  delegate:self
                                         cancelButtonTitle:nil
                                         otherButtonTitles:[String Yes],[String No], nil];
    */
	//2014-01-30 ueda
    SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
  //alert.title=[String Order_Station];
    alert.message=[NSString stringWithFormat:@"　\n%@\n　",[String Set_up]];
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
                //2015-06-24 ueda
                //2015-07-03 ueda 復活
                [self performSegueWithIdentifier:@"ToSettingEntryView" sender:nil];
                //[self performSegueWithIdentifier:@"ToSettingsView" sender:nil];
                break;
                
            case 1:
                break;
        }
    }
    else if (alertView.tag==2) {
            switch (buttonIndex) {
                case 0:{
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
                    
                    //マスターデータの取得
                    
                    NetWorkManager *_net = [NetWorkManager sharedInstance];
                    [_net deleteAllData];
                    [_net getMasterData:self
                                  count:1];
                    break;
                }
                case 1:
                    break;
            }
        }
    else if (alertView.tag==3) {
        switch (buttonIndex) {
            case 0:{
                //[[UIApplication sharedApplication] performSelector:@selector(terminate)];
                break;
            }
            case 1:
                break;
        }
    }
}


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
    
    //2014-07-11 ueda
    self.lb_title.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_title.bounds]];
    
    [System adjustStatusBarSpace:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    self.lb_title.text = [String Sub_menu];
    
    [self.bt_setting setTitle:[String Setting] forState:UIControlStateNormal];
    [self.bt_download setTitle:[String Download] forState:UIControlStateNormal];
    [self.bt_end setTitle:[String Program_end] forState:UIControlStateNormal];
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    
    //2014-09-08 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonSetting.png"];
    [self.bt_setting setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_end setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_download setBackgroundImage:img forState:UIControlStateNormal];
    [self.bt_return setBackgroundImage:img forState:UIControlStateNormal];

    //2015-06-24 ueda
    self.navigationController.navigationBarHidden = YES;
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
    [self setBt_setting:nil];
    [self setBt_download:nil];
    [self setBt_end:nil];
    [self setBt_return:nil];
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
        else{
            LOG(@"_dataList:%@",_dataList);
            DataList *_data = [DataList sharedInstance];
            [_data reloadTantoList];
        }
        [mbProcess hide:YES];
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
        
        if ([System existCacheAccount]) {
            System *sys = [System sharedInstance];
            sys.getMaster = @"0";
            [sys saveChacheAccount];
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

@end
