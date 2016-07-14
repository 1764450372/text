//
//  VouchingListViewController.h
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountViewController.h"
#import "OrderEntryViewController.h"
#import "OrderConfirmViewController.h"
#import "VouchingDetailViewController.h"

@interface VouchingListViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,MBProgressHUDDelegate>{
    NSDictionary *editVoucher;
    MBProgressHUD *mbProcess;
    BOOL isAutoSend;
}

@property TypeOrder type;

@property (strong, nonatomic) NSMutableArray *voucherList;

@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_check;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_count;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_print;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;

- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_slip:(id)sender;
- (void)setVoucher:(NSDictionary*)dic;

@end
