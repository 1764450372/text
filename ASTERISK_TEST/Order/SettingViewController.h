//
//  SettingViewController.h
//  Order
//
//  Created by koji kodama on 13/04/28.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingViewController : UIViewController<MBProgressHUDDelegate>{
    MBProgressHUD *mbProcess;
}
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_setting;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_download;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_end;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;



- (IBAction)iba_exit:(id)sender;
- (IBAction)iba_back:(id)sender;
- (IBAction)iba_getMaster:(id)sender;
- (IBAction)iba_setting:(id)sender;

@end
