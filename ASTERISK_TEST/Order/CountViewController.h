//
//  CountViewController.h
//  Order
//
//  Created by koji kodama on 13/03/10.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderEntryViewController.h"

@protocol CountViewControllerDelegate;

enum {
    EntryTypeTableOnly,
    EntryTypeTableNot,
    EntryTypeTableAndNinzu
};
typedef int EntryTableType;

@interface CountViewController : UIViewController<MBProgressHUDDelegate>{
    MBProgressHUD *mbProcess;

/*
    QBFlatButton *counter_man;
    QBFlatButton *counter_woman;

    UIButton *counter_man_up;
    UIButton *counter_woman_up;
    UIButton *counter_man_down;
    UIButton *counter_woman_down;
 */
    
    NSArray *tableArray;
    
    System *sys;
    DataList *dat;
}

@property (nonatomic, strong) id <CountViewControllerDelegate>delegate;
@property TypeOrder type;
@property EntryTableType entryType;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;

//2014-11-18 ueda
@property NSInteger man_count;
@property NSInteger woman_count;
@property NSInteger child_count;

- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_countUp:(id)sender;
- (IBAction)iba_countDown:(UIButton *)sender;
- (IBAction)iba_clear:(id)sender;
- (IBAction)iba_backspace:(id)sender;
@end

@protocol CountViewControllerDelegate <NSObject>
@optional
//2014-11-18 ueda
/*
- (void)returnEntryCount:(int)man
                   woman:(int)woman;
 */
@end