//
//  OrderConfirmViewController.h
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeViewController.h"
#import "ConfirmCell.h"
#import "DivideCell.h"

//2014-07-25 ueda
//@protocol ConfirmViewControllerDelegate;

@interface OrderConfirmViewController : UIViewController<MBProgressHUDDelegate>{
    
    MBProgressHUD *mbProcess;
    
    OrderManager *orderManager;
    DataList *dat;

    NSMutableArray *directionList; //指示確認画面の選択メニュー
    NSMutableDictionary *editingDic; //メニュー確認時の編集メニュー
    
    //NSMutableArray *cancelMenu;
    BOOL showCancel;
    BOOL showDivide;
    
    BOOL isFinish;
    BOOL isSetIsSingle;
    BOOL isSetMenuFlag;
    
    int menuPage;
    int defaultHeight;
    int currentindex;
    int setMenuCount;
    
    NSString *resultMsg;
    
    //2014-10-01 ueda
    bool divideFirstFg;
    //2014-10-30 ueda
    NSMutableString *orderDivideType;
}

//2014-07-25 ueda
//@property (nonatomic, strong) id <ConfirmViewControllerDelegate>delegate;

@property TypeOrder type;
//2014-07-25 ueda
@property (nonatomic, strong) id delegate;

@property (weak, nonatomic) IBOutlet UITableView *table;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_push;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_back;

@property (strong, nonatomic) NSMutableArray *orderList;


- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_nextPage:(id)sender;
- (IBAction)iba_prevPage:(id)sender;

@end


@protocol ConfirmViewControllerDelegate <NSObject>
@optional
- (void)setDispMenu:(NSMutableDictionary*)_menu;
- (void)setDispSub1Menu:(NSMutableDictionary*)_menu
                    sub:(NSMutableDictionary*)_subMenu;
- (void)setDispGroupMenu:(NSMutableDictionary*)_menu
                     sub:(NSMutableDictionary*)_subMenu;
@end