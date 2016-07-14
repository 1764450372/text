//
//  SSOverlayWindow.m
//
//  Created by ToKoRo on 2013-05-28.
//

#import "SSOverlayWindow.h"
//2016-04-08 ueda
#import "CustomWindow.h"

@interface SSOverlayWindow ()
@property (weak) UIWindow* previousKeyWindow;
@end 

@implementation SSOverlayWindow

- (id)init
{
  if ((self = [super init])) {
    self.frame = [[UIScreen mainScreen] bounds];
  }
  return self;
}

- (void)makeKeyAndVisible
{
  self.previousKeyWindow = [[UIApplication sharedApplication] keyWindow];
  self.windowLevel = UIWindowLevelAlert;
  [super makeKeyAndVisible];
}

- (void)resignKeyWindow
{
  [super resignKeyWindow];
  [self.previousKeyWindow makeKeyAndVisible];
}

//2016-04-08 ueda
- (void)sendEvent:(UIEvent *)event {
    NSLog(@"SSOverlayWindow sendEvent");
    
    AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    CustomWindow *cw = (CustomWindow*)appDelegate.window;
    float timerSecond;
    if (appDelegate.isDisplayAlert) {
        timerSecond = [[System sharedInstance].notOpeCheckSecAlert floatValue];
    } else {
        timerSecond = [[System sharedInstance].notOpeCheckSecNormal floatValue];
    }
    [cw setExpireTimerSecond:timerSecond];
    
    [super sendEvent:event];
}

@end
