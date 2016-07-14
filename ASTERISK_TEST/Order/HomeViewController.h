//
//  HomeViewController.h
//  Order
//
//  Created by koji kodama on 13/03/07.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TableViewController.h"
#import "POVoiceHUD.h"

//2015-04-20 ueda
@protocol EntryViewDelegate <NSObject>
- (void)finishStaffCode:(NSString *)returnValue;
@end

@interface HomeViewController : UIViewController<MBProgressHUDDelegate,POVoiceHUDDelegate,AVAudioPlayerDelegate,UIGestureRecognizerDelegate,UIApplicationDelegate>{
    MBProgressHUD *mbProcess;
    BOOL isReadMaster;
    BOOL isConnectionFtp;
    
    System *sys;
    
    POVoiceHUD *voiceHud;
    
    NetWorkManager *net;
    
    QBFlatButton *currentBt;
    BOOL isPlayVoice;
    //2015-04-20 ueda
    id<EntryViewDelegate> _delegate;
}

//2015-04-20 ueda
@property (nonatomic) id<EntryViewDelegate> delegate;

- (IBAction)iba_getMaster:(id)sender;
- (IBAction)iba_pushTanto:(id)sender;
- (IBAction)iba_changeSwitch:(id)sender;
- (IBAction)iba_deleteMessage:(id)sender;
- (IBAction)btnRecordTapped:(id)sender;
- (IBAction)iba_recieveTest:(id)sender;

 
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *deleteMessage;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_tanto;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prev2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prev;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_divide;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_move;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_check;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_cancel;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_add;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_original;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_2;

@property (weak, nonatomic) IBOutlet UIButton *bt_rec;
@property (weak, nonatomic) IBOutlet UIButton *bt_control;

@property (weak, nonatomic) IBOutlet UILabel *lb_msg;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (weak, nonatomic) IBOutlet UILabel *lb_demo;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

//2014-10-30 ueda
@property (weak, nonatomic) IBOutlet UIImageView *iv_background;

- (void)removeLocalFiles;
-(void) download:(NSString*)path;

@end
