//
//  CustomWindow.m
//  Order
//
//  Created by mac-sper on 2016-04-08.
//  Copyright © 2016年 SPer. All rights reserved.
//

//  http://d.hatena.ne.jp/h_mori/20120213/1329088354

#import "CustomWindow.h"
#import "AppDelegate.h"

@interface CustomWindow () {
    NSTimer *_checkExpireTimer;
    NSTimeInterval secInterval;
}
@end

@implementation CustomWindow

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        secInterval = 120.0f;
        [self resetTimer];
    }
    return self;
}

- (void)sendEvent:(UIEvent *)event {
    [self resetTimer];
    [super sendEvent:event];
}

-(void) setExpireTimerSecond:(NSTimeInterval)second {
    secInterval = second;
    [self resetTimer];
}

- (void)resetTimer {
    NSLog(@"reset timer");
    [_checkExpireTimer invalidate];
    if (YES) {
        _checkExpireTimer = [NSTimer timerWithTimeInterval:secInterval
                                                    target:self
                                                  selector:@selector(expire)
                                                  userInfo:nil
                                                   repeats:NO];
        [[NSRunLoop mainRunLoop] addTimer:_checkExpireTimer forMode:NSDefaultRunLoopMode];
    }
}

- (void)expire {
    NSLog(@"expire");
    [self resetTimer];
    dispatch_async(dispatch_get_main_queue(), ^{
        [(AppDelegate *)[[UIApplication sharedApplication] delegate] lockScreen];
    });
}


@end
