//
//  CountJikaViewController.h
//  Order
//
//  Created by koji kodama on 13/04/16.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol JikaViewControllerDelegate;

enum {
    EntryTypeCountJika,
    EntryTypeCountQTY
};
typedef int EntryTypeCount;

@interface CountJikaViewController : UIViewController{
    //Common
    NSMutableArray *currentSetting;
    NSString *currentStep;
    int max;
    int min;
    System *sys;
    MBProgressHUD *mbProcess;
    
    UILabel *editingLabel;
    
    NSMutableString *entryJika;
    
    BOOL isEntry;
}

@property (nonatomic, strong) id <JikaViewControllerDelegate>delegate;
@property EntryTypeCount typeCount;

//Common
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_titleEntry;
@property (weak, nonatomic) IBOutlet UILabel *lb_price;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_select;
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UIView *secondView;
@property (weak, nonatomic) IBOutlet UILabel *lb_menuCount;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_dot;
@property (strong, nonatomic) NSMutableDictionary *editMenu;
@property int count;

@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_next;


- (IBAction)iba_back:(id)sender;
- (IBAction)iba_showNext:(id)sender;
- (IBAction)iba_countUp:(id)sender;
- (IBAction)iba_clear:(id)sender;
- (IBAction)iba_backspace:(id)sender;
- (IBAction)iba_dot:(id)sender;

- (IBAction)iba_countUpMenu:(id)sender;
- (IBAction)iba_countDownMenu:(id)sender;

- (IBAction)iba_selectArea:(id)sender;

@end


@protocol JikaViewControllerDelegate <NSObject>
@optional
- (void)returnEntryCount:(NSString*)jika
               menuCount:(NSString*)count;
- (void)countUp:(int)type;
- (void)countDown:(int)type;
- (void)orderCancel1;
- (void)setDispSub1Menu:(NSMutableDictionary*)_menu
                    sub:(NSMutableDictionary*)_subMenu;
@end
