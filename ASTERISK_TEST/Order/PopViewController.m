//
//  PopViewController.m
//  Order
//
//  Created by koji kodama on 13/06/21.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "PopViewController.h"

@interface PopViewController ()
//2014-08-08 ueda
@property (weak, nonatomic) IBOutlet UIView *popGamen;

@end

@implementation PopViewController


- (IBAction)iba_countUp:(id)sender{
    
    //2015-07-09 ueda
    [System tapSound];
    
}
- (IBAction)iba_countDwon:(id)sender{
    
    //2015-07-09 ueda
    [System tapSound];
    
}



- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    //2014-07-17 ueda
    self.lb_label.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:self.lb_label.bounds]];
    self.view.backgroundColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.3];
    //2014-08-08 ueda
    self.popGamen.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor whiteColor] bounds:self.popGamen.bounds]];
    //2014-09-19 ueda
    UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
    [self.bt_done setBackgroundImage:img forState:UIControlStateNormal];
    //2016-02-03 ueda ASTERISK
    [self.bt_done setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setLb_label:nil];
    [self setLb_title:nil];
    [self setLb_count:nil];
    [self setBt_return:nil];
    [self setBt_done:nil];
    [self setBt_countUp:nil];
    [self setBt_countDown:nil];
    [super viewDidUnload];
}
@end
