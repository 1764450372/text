//
//  ErrorSound.m
//  ErrorSample
//
//  Created by mac-sper on 2016-02-04.
//  Copyright © 2016年 mac-sper. All rights reserved.
//

#import <AudioToolbox/AudioToolbox.h>

#import "ErrorSound.h"

@implementation ErrorSound {
    SystemSoundID errorSoundID;
    OSStatus soundSetupError;
    BOOL isPlaying;
}

- (void)soundSetup {
    NSBundle *mainBundle = [NSBundle mainBundle];
    //2016-04-08 ueda
/*
    NSURL *beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"pinpon" ofType:@"mp3"] isDirectory:NO];
 */
    //2016-04-08 ueda
    NSURL *beepWavURL;
    if ([[System sharedInstance].notOpeCheckSound isEqualToString:@"1"]) {
        beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"pinpon" ofType:@"mp3"] isDirectory:NO];
    } else {
        beepWavURL = [NSURL fileURLWithPath:[mainBundle pathForResource:@"no_sound" ofType:@"mp3"] isDirectory:NO];
        
    }
    
    //システムサウンドIDの割り当て
    soundSetupError = AudioServicesCreateSystemSoundID((__bridge CFURLRef)beepWavURL, &errorSoundID);
    isPlaying = NO;
}

- (void)soundOn{
    if ((!soundSetupError) && (isPlaying == NO)) {
        isPlaying = YES;
        AudioServicesAddSystemSoundCompletion(errorSoundID, NULL, NULL, MyAudioServicesSystemSoundCompletionProc, (__bridge void *) self);
        AudioServicesPlaySystemSound(errorSoundID);
        //2016-04-08 ueda
        if ([[System sharedInstance].notOpeCheckVib isEqualToString:@"1"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    }
}

- (void)soundOff{
    isPlaying = NO;
}

- (void)soundTerminate{
    //サウンドIDの割り当てを解除
    AudioServicesDisposeSystemSoundID(errorSoundID);
}

#pragma mark AudioService callback function prototypes
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID ssID,
                                               void *clientData
                                               );
#pragma mark AudioService callback function implementation
void MyAudioServicesSystemSoundCompletionProc (
                                               SystemSoundID ssID,
                                               void *clientData
                                               ) {
    if (((__bridge ErrorSound *)clientData)->isPlaying) {
        NSTimeInterval elapsedTime = 1; // 1秒間隔
        [NSThread sleepForTimeInterval:(NSTimeInterval)elapsedTime];
        // バイブ
        AudioServicesPlaySystemSound(((__bridge ErrorSound *)clientData)->errorSoundID);
        //2016-04-08 ueda
        if ([[System sharedInstance].notOpeCheckVib isEqualToString:@"1"]) {
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
    } else {
        AudioServicesRemoveSystemSoundCompletion(((__bridge ErrorSound *)clientData)->errorSoundID);
    }
}

@end
