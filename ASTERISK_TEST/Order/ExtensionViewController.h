//
//  ExtensionViewController.h
//  Order
//
//  Created by koji kodama on 13/07/17.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ExtensionViewController : UIViewController<MBProgressHUDDelegate,UITextFieldDelegate>{
    int extensionInt;
    MBProgressHUD *mbProcess;
    
    BOOL isMidTfActive;
    
    NSDate *currentTime;
    NSDateFormatter *inputDateFormatter;
}

@property (weak, nonatomic) IBOutlet UITextField *tf_currentTime;
@property (weak, nonatomic) IBOutlet UITextField *tf_extensionTime;
@property (weak, nonatomic) IBOutlet UITextField *tf_updateTime;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_regist;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt3;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt4;

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet UILabel *lb1;
@property (weak, nonatomic) IBOutlet UILabel *lb2;
@property (weak, nonatomic) IBOutlet UILabel *lb3;



@property (strong, nonatomic) NSString *defaultTime;
@property (strong, nonatomic) NSString *KeyID;

- (IBAction)iba_addTime:(id)sender;
- (IBAction)iba_regist:(id)sender;
- (IBAction)iba_return:(id)sender;

@end
