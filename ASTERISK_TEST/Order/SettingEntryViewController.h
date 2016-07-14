//
//  SettingEntryViewController.h
//  Order
//
//  Created by koji kodama on 13/04/28.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingEntryViewController : UIViewController{
    NSMutableDictionary *setting;
    NSArray *currentSetting; 
    NSString *currentStep; //9999=パスワード入力
    NSString *passkey;
    int max;
    int min;
    System *sys;
}

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_titleEntry;

@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *entryView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_dot;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done;


@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num0;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num3;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num4;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num5;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num6;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num7;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num8;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_Num9;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_NumClr;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_NumBS;


@property (weak, nonatomic) IBOutlet UILabel *lb_counter;
@property int count;
@property (weak, nonatomic) IBOutlet UITextField *textField;


- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_countUp:(id)sender;
- (IBAction)iba_clear:(id)sender;
- (IBAction)iba_backspace:(id)sender;
- (IBAction)iba_dot:(id)sender;

@end
