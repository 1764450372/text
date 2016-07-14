//
//  OrderTypeViewController.h
//  Order
//
//  Created by koji kodama on 13/06/04.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderTypeViewController : UIViewController<MBProgressHUDDelegate>{
    NSMutableDictionary *editTable;
    int currentPage;
     MBProgressHUD *mbProcess;
    NSMutableArray *noteList;
    
    OrderManager *orderManager;
    DataList *dat;
    
    BOOL isTouch;
}


@property TypeOrder type;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_push;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_back;


- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;

@end
