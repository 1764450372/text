//
//  NavigationController.m
//  Order
//
//  Created by koji kodama on 2013/10/01.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "NavigationController.h"

@interface NavigationController ()

@end

@implementation NavigationController

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
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

//2015-08-03 ueda
- (BOOL)shouldAutorotate {
    return YES;
}
//2015-12-10 ueda ASTERISK
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif

// ここからコピー  http://dev.classmethod.jp/smartphone/iphone/ios-navtransition/

- (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    //2014-06-26 ueda
    //if (animated) {
    //2014-10-28 ueda
    //if (NO) {
    if ([[System sharedInstance].transitionOnOff isEqualToString:@"1"]) {
        //2015-04-08 ueda
/*
        [UIView transitionWithView:self.view duration:0.5f options:UIViewAnimationOptionTransitionFlipFromLeft animations:^{
            [super pushViewController:viewController animated:NO];
        } completion:nil];
 */
        //2015-04-08 ueda
        [super pushViewController:viewController animated:YES];
    } else {
        [super pushViewController:viewController animated:NO];
    }
}

- (NSArray *)popToViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    __block NSArray *viewControllers = nil;
    
    //2014-06-26 ueda
    //if (animated) {
    //2014-10-28 ueda
    //if (NO) {
    if ([[System sharedInstance].transitionOnOff isEqualToString:@"1"]) {
        //2015-04-08 ueda
/*
        [self popWithTransitionAnimations:^{
            viewControllers = [super popToViewController:viewController animated:NO];
        }];
 */
        //2015-04-08 ueda
        viewControllers = [super popToViewController:viewController animated:YES];
    } else {
        viewControllers = [super popToViewController:viewController animated:NO];
    }
    
    return viewControllers;
}

- (UIViewController *)popViewControllerAnimated:(BOOL)animated
{
    __block UIViewController *popedViewController = nil;
    
    //2014-06-26 ueda
    //if (animated) {
    //2014-10-28 ueda
    //if (NO) {
    if ([[System sharedInstance].transitionOnOff isEqualToString:@"1"]) {
        //2015-04-08 ueda
/*
        [self popWithTransitionAnimations:^{
            popedViewController = [super popViewControllerAnimated:NO];
        }];
 */
        //2015-04-08 ueda
        popedViewController = [super popViewControllerAnimated:YES];
    } else {
        popedViewController = [super popViewControllerAnimated:NO];
    }
    
    //2015-06-24 ueda
    if (!self.navigationBarHidden) {
        [System tapSound];
    }
    
    return popedViewController;
}

- (NSArray *)popToRootViewControllerAnimated:(BOOL)animated
{
    __block NSArray *viewControllers = nil;
    
    //2014-06-26 ueda
    //if (animated) {
    //2014-10-28 ueda
    //if (NO) {
    if ([[System sharedInstance].transitionOnOff isEqualToString:@"1"]) {
        //2015-04-08 ueda
/*
        [self popWithTransitionAnimations:^{
            viewControllers = [super popToRootViewControllerAnimated:NO];
        }];
 */
        //2015-04-08 ueda
        viewControllers = [super popToRootViewControllerAnimated:YES];
    } else {
        viewControllers = [super popToRootViewControllerAnimated:NO];
    }
    
    return viewControllers;
}

//2015-04-08 ueda
/*
- (void)popWithTransitionAnimations:(void (^)(void))animations
{
    [UIView transitionWithView:self.view
                      duration:0.5f
                       options:UIViewAnimationOptionTransitionFlipFromRight
                    animations:animations
                    completion:nil];
}
 */

@end
