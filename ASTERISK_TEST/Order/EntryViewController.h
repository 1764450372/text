//
//  EntryViewController.h
//  Order
//
//  Created by koji kodama on 13/05/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>


enum {
    EntryTypeOrder,
    EntryTypeKokyaku,
    EntryTypeSearch,
    //2015-04-20 ueda
    EntryTypeStaffCode
};
typedef int EntryType;

@interface EntryViewController : UIViewController<MBProgressHUDDelegate>{
    
    //Common
    NSMutableArray *currentSetting;
    NSString *currentStep;
    int max;
    int min;
    System *sys;
    MBProgressHUD *mbProcess;
    UILabel *editingLabel;
    
    //NSMutableString *entryCount;
    NSMutableString *entryJika;
    
    //For EntryTypeOrder
    NSMutableDictionary *editMenu;
    
    BOOL isEntry;
}

@property TypeOrder type;
@property EntryType entryType;
@property (nonatomic, strong) id delegate;

//Common
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_titleEntry;
@property (weak, nonatomic) IBOutlet UILabel *lb_syohinCD;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_dot;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_result;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_search;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;

- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_countUp:(id)sender;
- (IBAction)iba_clear:(id)sender;
- (IBAction)iba_backspace:(id)sender;
- (IBAction)iba_dot:(id)sender;


//For EntryTypeOrder
@property (weak, nonatomic) IBOutlet UILabel *lb_count;
@property (weak, nonatomic) IBOutlet UILabel *lb_price;
@property (weak, nonatomic) IBOutlet UILabel *lb_totalPrice;
- (IBAction)iba_clearTap:(id)sender;
- (IBAction)iba_countUpMenu:(id)sender;
- (IBAction)iba_jikaEntry:(id)sender;

@end
