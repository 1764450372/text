//
//  VouchingDetailViewController.h
//  Order
//
//  Created by koji kodama on 13/03/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface VouchingDetailViewController : UIViewController<MBProgressHUDDelegate>{
    NSArray *subList;
    NSInteger currentNo;
    NSInteger currentPage;
    NSInteger defaultHeight;
    
    MBProgressHUD *mbProcess;
    
    NSInteger select1;
    NSInteger select2;
    //2016-02-02 ueda
    NSInteger currentEdaNo;
}

@property TypeOrder type;

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

//TOP
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_left;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_right;
@property (weak, nonatomic) IBOutlet UILabel *lb_voucherNo;
@property (weak, nonatomic) IBOutlet UILabel *lb_total;
@property (weak, nonatomic) IBOutlet UILabel *lb_tab;


@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_print;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done;

//2016-01-05 ueda ASTERISK
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_ninzu;


@property (strong, nonatomic) NSMutableDictionary *voucher;

- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_prev:(id)sender;
- (IBAction)iba_next:(id)sender;
- (IBAction)iba_nextPage:(id)sender;
- (IBAction)iba_prevPage:(id)sender;
- (IBAction)iba_print:(id)sender;
- (IBAction)iba_push:(id)sender;
//2016-01-05 ueda ASTERISK
- (IBAction)iba_ninzu:(id)sender;

@end
