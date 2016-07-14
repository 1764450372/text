//
//  AppDelegate.m
//  Order
//
//  Created by koji kodama on 13/03/07.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import "AppDelegate.h"
#import "HomeViewController.h"
//2016-04-08 ueda
#import "CustomWindow.h"
#import "ExpireViewController.h"
#import "NavigationController.h"

@implementation AppDelegate{
        char                _networkOperationCountDummy;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch

     if ([[System sharedInstance].transceiver intValue]==0) {
         [[NetWorkManager sharedInstance] readyForBroadCastReceive];
     }
    
    [[NetWorkManager sharedInstance] addObserver:self forKeyPath:@"networkOperationCount" options:NSKeyValueObservingOptionInitial context:&self->_networkOperationCountDummy];
    
    //2014-10-29 ueda エラー追跡用の機能を追加する。
    //http://www.yoheim.net/blog.php?q=20130113
    NSSetUncaughtExceptionHandler(&exceptionHandler);

    return YES;
}

//2014-10-29 ueda 異常終了を検知した場合に呼び出されるメソッド
//http://www.yoheim.net/blog.php?q=20130113
void exceptionHandler(NSException *exception) {
    // ここで、例外発生時の情報を出力します。
    // NSLog関数でcallStackSymbolsを出力することで、
    // XCODE上で開発している際にも、役立つスタックトレースを取得できるようになります。
    NSLog(@"%@", exception.name);
    NSLog(@"%@", exception.reason);
    NSLog(@"%@", exception.callStackSymbols);
    
    // ログをUserDefaultsに保存しておく。
    // 次の起動の際に存在チェックすれば、前の起動時に異常終了したことを検知できます。
    NSString *log = [NSString stringWithFormat:@"%@, %@, %@", exception.name, exception.reason, exception.callStackSymbols];
    [[NSUserDefaults standardUserDefaults] setValue:log forKey:@"failLog"];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == &self->_networkOperationCountDummy) {
        //[UIApplication sharedApplication].networkActivityIndicatorVisible = ([NetWorkManager sharedInstance].networkOperationCount != 0);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    if ([[System sharedInstance].transceiver intValue]==0) {
        __block UIBackgroundTaskIdentifier task = [application beginBackgroundTaskWithExpirationHandler:^{
            
        
            //音声のバックグラウンド再生用にプロパティを設定する
            NSString *path = [[NSBundle mainBundle] pathForResource:@"15sec" ofType:@"mp3"];
            NSURL* url = [NSURL fileURLWithPath:path];
            self.player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
            NSError *error = nil;
            AVAudioSession* audioSession = [AVAudioSession sharedInstance];
            [audioSession setCategory:AVAudioSessionCategoryPlayback error:&error];
            [audioSession setActive:YES error:&error];
            [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
            if ( error != nil ){
                LOG(@"Error %@", [error localizedDescription]);
            }
            [self.player setDelegate:self];
            [self.player play];
        }];
    }
    else{
        [[NetWorkManager sharedInstance] finishForBroadCastReceive];
    }
    //2016-04-08 ueda
    if (YES) {
        //ロック/スリープの禁止の解除
        [[UIApplication sharedApplication] setIdleTimerDisabled:NO];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    if ([[System sharedInstance].transceiver intValue]==0) {
        //ブロードキャスト受信を開始する
        [[NetWorkManager sharedInstance] readyForBroadCastReceive];
    }
    else{
        [[NetWorkManager sharedInstance] finishForBroadCastReceive];
    }
    //2016-04-08 ueda
    if (YES) {
        if ([[System sharedInstance].notSleepOnOff isEqualToString:@"1"]) {
            //ロック/スリープの禁止
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
        }
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    UINavigationController *nav = (UINavigationController*)self.window.rootViewController;
    HomeViewController *hv = nav.viewControllers[0];
    [hv removeLocalFiles];
}

//2014-07-25 ueda
/*
- (void)buttonSetColorGray:(float)_face1
                     face2:(float)_face2
                     side1:(float)_side1
                     side2:(float)_side2{
    
    [[QBFlatButton appearance] setFaceColor:[UIColor colorWithWhite:_face1 alpha:1.0] forState:UIControlStateNormal];
    [[QBFlatButton appearance] setSideColor:[UIColor colorWithWhite:_side1 alpha:1.0] forState:UIControlStateNormal];
    
    [[QBFlatButton appearance] setFaceColor:[UIColor colorWithWhite:_face1 alpha:1.0] forState:UIControlStateDisabled];
    [[QBFlatButton appearance] setSideColor:[UIColor colorWithWhite:_side1 alpha:1.0] forState:UIControlStateDisabled];
    
    [[QBFlatButton appearance] setFaceColor:[UIColor colorWithWhite:_face2 alpha:1.0] forState:UIControlStateHighlighted];
    [[QBFlatButton appearance] setSideColor:[UIColor colorWithWhite:_side2 alpha:1.0] forState:UIControlStateHighlighted];
    
    [[QBFlatButton appearance] setFaceColor:BLUE forState:UIControlStateSelected];
    [[QBFlatButton appearance] setSideColor:DEEPBLUE forState:UIControlStateSelected];
    
    [[QBFlatButton appearance] setRadius:2.0f];
    [[QBFlatButton appearance] setMargin:4.0f];
    [[QBFlatButton appearance] setDepth:3.0f];
}
 */

//2014-07-25 ueda
/*
- (void)buttonSetColorWithButton:(QBFlatButton*)_button
                           face1:(UIColor*)_face1
                           face2:(UIColor*)_face2
                           side1:(UIColor*)_side1
                           side2:(UIColor*)_side2{
    
    [_button setFaceColor:_face1 forState:UIControlStateNormal];
    [_button setSideColor:_side1 forState:UIControlStateNormal];
    
    [_button setFaceColor:_face1 forState:UIControlStateDisabled];
    [_button setSideColor:_side1 forState:UIControlStateDisabled];
    
    [_button setFaceColor:_face2 forState:UIControlStateHighlighted];
    [_button setSideColor:_side2 forState:UIControlStateHighlighted];
    
    [_button setFaceColor:BLUE forState:UIControlStateSelected];
    [_button setSideColor:DEEPBLUE forState:UIControlStateSelected];

    [_button setRadius:2.0f];
    [_button setMargin:4.0f];
    [_button setDepth:3.0f];
    
    [_button setNeedsDisplay];
}
 */

//2016-04-08 ueda
#pragma mark -

//http://qiita.com/sasanao/items/b3b8907acadd0c5bc62c
- (CustomWindow *)window
{
    static CustomWindow *customWindow = nil;
    if (!customWindow) customWindow = [[CustomWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    return customWindow;
}

//http://d.hatena.ne.jp/h_mori/20120213/1329088354
- (void)lockScreen {
    if (![[System sharedInstance].notOpeCheckOnOff isEqualToString:@"1"]) {
        return;
    }
    if (self.isDisplayExpire) {
        return;
    }
    
    NSInteger wc = [UIApplication sharedApplication].windows.count;
    if (self.isDisplayAlert) {
        //アラート表示中
    } else {
        //最前面のViewController
        UIViewController *topController = [UIApplication sharedApplication].keyWindow.rootViewController;
        while (topController.presentedViewController) {
            topController = topController.presentedViewController;
        }
        if ([topController isKindOfClass:[NavigationController class]]) {
            UINavigationController *nvc = (UINavigationController*)topController;
            //メインメニューの場合は＝１
            NSInteger count = nvc.viewControllers.count;
            if (count == 1) {
                return;
            }
        }
    }
    
    self.isDisplayExpire = YES;
    [ExpireViewController show];
}

@end
