//
//  PrintViewController.h
//  Order
//
//  Created by koji kodama on 13/05/15.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PrintViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,MBProgressHUDDelegate>{
    
    NSMutableArray *tableArray;
    
    MBProgressHUD *mbProcess;
    
    NSString *editTable;
    int currentPage;
    
    //2014-07-28 ueda
    //System *sys;
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