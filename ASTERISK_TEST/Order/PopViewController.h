//
//  PopViewController.h
//  Order
//
//  Created by koji kodama on 13/06/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopViewController : UIViewController
@property (weak, nonatomic) IBOutlet UILabel *lb_label;
@property (weak, nonatomic) IBOutlet UILabel *lb_title;
@property (weak, nonatomic) IBOutlet UILabel *lb_count;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_done;
@property (weak, nonatomic) IBOutlet UIButton *bt_countUp;
@property (weak, nonatomic) IBOutlet UIButton *bt_countDown;

- (IBAction)iba_countUp:(id)sender;
- (IBAction)iba_countDwon:(id)sender;

@end
