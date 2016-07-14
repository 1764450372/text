//
//  OrderEntryViewController.h
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CategoryCell.h"
#import "OrderConfirmViewController.h"
#import "CountJikaViewController.h"
#import "EntryViewController.h"
#import "GMGridView.h"
#import "PopViewController.h"
//2015-09-17 ueda
#import "OrderTypeViewController.h"

@interface OrderEntryViewController : UIViewController<GMGridViewDataSource, GMGridViewActionDelegate,JikaViewControllerDelegate, MBProgressHUDDelegate>{

    OrderManager *orderManager;
    DataList *dat;
    
    NSArray *menuList;
    NSArray *categoryList;

    NSMutableDictionary *editMenu;
    NSMutableDictionary *editSub1Menu;
    NSMutableDictionary *editSub2Menu;
    NSMutableDictionary *editFolder1Menu;
    NSMutableDictionary *editFolder2Menu;
    NSMutableDictionary *editArrangeMenu;
    
    NSMutableDictionary *editCategory;
    NSMutableDictionary *editSub1Category;
    NSMutableDictionary *editSub2Category;
    NSMutableDictionary *editFolder1Category;
    NSMutableDictionary *editFolder2Category;
    NSMutableDictionary *editArrangeCategory;
    
    
    NSInteger currentPositon;
    NSInteger pastPosition;

    
    MBProgressHUD *mbProcess;
    
    BOOL isShowSub1;
    BOOL isShowSub2;
    //BOOL isShowJika;
    BOOL isShowGroup1;
    BOOL isShowGroup2;
    BOOL isShowArrange;
    BOOL isArrangeMenuEnable;
    BOOL isShowConfirm;//確認画面の表示可否
    
    //2014-09-19 ueda
    //2014-10-01 ueda 再度使用
    BOOL isTap;
    
    NSInteger tempCategoryIndex;//第二階層グループフォルダ対応
    NSArray *tempCategoryArray;
    
    PopViewController *popView;
}

@property TypeOrder type;

@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down1_1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down1_2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down1_3;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_down1_4;


@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up1_1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up1_2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up1_3;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_up1_4;


@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done1_1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done1_2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return1_1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return1_2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_arrange;


@property (weak, nonatomic) IBOutlet UITableView *categoryTable;
@property (weak, nonatomic) IBOutlet GMGridView *gmGridView;


//ForSubGroup
@property (weak, nonatomic) IBOutlet UIView *subView;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet GMGridView *subGridView;
@property (weak, nonatomic) IBOutlet UILabel *lb_dispName;
@property (weak, nonatomic) IBOutlet UILabel *lb_dispCount;
@property (weak, nonatomic) IBOutlet UILabel *lb_dispCountSub;
@property (weak, nonatomic) IBOutlet UILabel *lb_dispJika;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_downArrange;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_upArrange;
//2015-12-15 ueda ASTERISK
@property (weak, nonatomic) IBOutlet UILabel *lb_dispSingleTrayCountAll;


//For Arrange
@property (weak, nonatomic) IBOutlet UIView *normal1Bottom;
@property (weak, nonatomic) IBOutlet UIView *normal2Bottom;
@property (weak, nonatomic) IBOutlet UIView *arrangeBottom;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevArrange;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextArrange;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done2;

//For Single
@property (weak, nonatomic) IBOutlet UIView *single1Bottom;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevSingle1;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextSingle1;


@property (weak, nonatomic) IBOutlet UIView *single2Bottom;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done3;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_prevSingle2;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_nextSingle2;


- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_nextPage:(id)sender;
- (IBAction)iba_prevPage:(id)sender;

- (IBAction)iba_nextPageNo:(id)sender;
- (IBAction)iba_prevPageNo:(id)sender;

/*
// 0 = メニュー　1 = 第1階層 2 = 第2階層
- (void)countUp:(int)type
           plus:(int)plus;
*/
- (void)countDown:(NSInteger)type;

- (IBAction)iba_countUpTop:(id)sender;
- (IBAction)iba_countDownTop:(id)sender;
- (IBAction)iba_countDownTopSub:(id)sender;

- (IBAction)iba_hideArrangetable:(id)sender;
- (IBAction)iba_showArrange:(id)sender;

- (void)setCategory:(NSMutableDictionary*)_category;
- (void)setConfirm;

@end
