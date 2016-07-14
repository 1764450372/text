//
//  ImageViewController.m
//  Order
//
//  Created by koji kodama on 13/06/20.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "ImageViewController.h"

@interface ImageViewController ()

@end

@implementation ImageViewController


- (IBAction)iba_back:(id)sender{
    [self dismissViewControllerAnimated:YES completion:nil];
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
    
    [self.bt_return setTitle:[String bt_return] forState:UIControlStateNormal];
    self.imageView.image = self.image;
    
    
    [System adjustStatusBarSpace:self.view];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidUnload {
    [self setImageView:nil];
    [self setBt_return:nil];
    [super viewDidUnload];
}
@end
