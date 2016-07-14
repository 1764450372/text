//
//  ExpireViewController.m
//  Order
//
//  Created by mac-sper on 2016-04-08.
//  Copyright © 2016年 SPer. All rights reserved.
//

//  https://codeiq.jp/magazine/2014/05/9493/

#import "ExpireViewController.h"
#import "ErrorSound.h"

#import <objc/runtime.h>

static const char kAssocKey_Window;

@interface ExpireViewController () {
    ErrorSound *errorSound;
}

@property (weak, nonatomic) IBOutlet UIButton *btClose;
- (IBAction)iba_close:(UIButton *)sender;

@end

@interface CRSWindow : UIWindow

@end

@implementation CRSWindow

-(void)dealloc
{
    NSLog(@"%@ dealloc", NSStringFromClass([self class]));
}

@end

@implementation ExpireViewController
+(void)show {
    UIWindow *window = [[CRSWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    window.alpha = 0.;
//    window.transform = CGAffineTransformMakeScale(1.1, 1.1);
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"ExpireView" bundle:nil];
    window.rootViewController = [storyboard instantiateInitialViewController];
    window.backgroundColor = [UIColor colorWithWhite:0 alpha:.6];
    window.windowLevel = UIWindowLevelAlert + 5; // テキトーにちょっと高い
    
    [window makeKeyAndVisible];
    
    // ウィンドウのオーナーとしてアプリ自身に括りつけとく
    objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, window, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [UIView transitionWithView:window duration:.2 options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut animations:^{
        window.alpha = 1.;
        window.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    void (^roundCorner)(UIView*) = ^void(UIView *v) {
        CALayer *layer = v.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 5.;
    };
    
    roundCorner(self.btClose);
    self.view.backgroundColor = [UIColor colorWithWhite:1.0f alpha:0.5f];
    
    if ([[System sharedInstance].lang isEqualToString:@"1"]) {
        [self.btClose setTitle:@"Cancel no operation warning" forState:UIControlStateNormal];
        [self.btClose.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    } else {
        [self.btClose setTitle:@"無操作警告　解除" forState:UIControlStateNormal];
    }
    
    errorSound = [[ErrorSound alloc] init];
    [errorSound soundSetup];
    [errorSound soundOn];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    [errorSound soundOff];
    [errorSound soundTerminate];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

-(void)doClose
{
    UIWindow *window = objc_getAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window);
    
    [UIView transitionWithView:window
                      duration:.3
                       options:UIViewAnimationOptionTransitionCrossDissolve|UIViewAnimationOptionCurveEaseInOut
                    animations:^{
                        UIView *view = window.rootViewController.view;
                        
                        for (UIView *v in view.subviews) {
                            v.transform = CGAffineTransformMakeScale(.8, .8);
                        }
                        
                        window.alpha = 0;
                    }
                    completion:^(BOOL finished) {
                        
                        [window.rootViewController.view removeFromSuperview];
                        window.rootViewController = nil;
                        
                        // 上乗せしたウィンドウを破棄
                        objc_setAssociatedObject([UIApplication sharedApplication], &kAssocKey_Window, nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
                        
                        // メインウィンドウをキーウィンドウにする
                        UIWindow *nextWindow = [[UIApplication sharedApplication].delegate window];
                        [nextWindow makeKeyAndVisible];
                        //
                        AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
                        appDelegate.isDisplayExpire = NO;
                    }];
}

- (IBAction)iba_close:(UIButton *)sender {
    [self doClose];
}

#if __IPHONE_OS_VERSION_MAX_ALLOWED < 90000
- (NSUInteger)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#else
- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    return UIInterfaceOrientationMaskAll;
}
#endif


@end
