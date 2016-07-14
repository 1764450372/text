//
//  ImageViewController.h
//  Order
//
//  Created by koji kodama on 13/06/20.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ImageViewController : UIViewController

@property (weak, nonatomic) IBOutlet UIImageView *imageView;
@property (weak, nonatomic) IBOutlet QBFlatButton *bt_return;
@property (strong, nonatomic) UIImage *image;

- (IBAction)iba_back:(id)sender;

@end
