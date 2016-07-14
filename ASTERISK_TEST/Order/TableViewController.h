//
//  TableViewController.h
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CountViewController.h"
#import "VouchingListViewController.h"
#import "EntryViewController.h"
//2014-07-25 ueda
//#import "CBAlertTableView.h"

//2014-07-25 ueda
//@interface TableViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,NetWorkManagerDelegate,MBProgressHUDDelegate,CBAlertTableViewDelegate>{
@interface TableViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,NetWorkManagerDelegate,MBProgressHUDDelegate>{
    
    NSMutableArray *tableArray;
    NSMutableArray *shohinArray;
    
    MBProgressHUD *mbProcess;
    
    NSMutableDictionary *editTable;
    NSInteger tapCount;
    NSInteger currentPage;
    
    BOOL isMove;
    BOOL isMoveFinish;
    
    System *sys;
    DataList *dat;
}

@property TypeOrder type;

@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;

@property (weak, nonatomic) IBOutlet UILabel *lb_title;

- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_nextPage:(id)sender;
- (IBAction)iba_prevPage:(id)sender;

@end
