//
//  AppDelegate.h
//  Order
//
//  Created by koji kodama on 13/03/07.
//  Copyright (c) 2013年 koji kodama. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "GMGridView.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioToolbox.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate,AVAudioPlayerDelegate>{
    UIBackgroundTaskIdentifier bgTask;
}

@property BOOL isConnection;
@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AVAudioPlayer *player;

//2014-07-25 ueda
@property (nonatomic) BOOL typeCeditModeFg;//入力タイプＣの修正モードかどうか
//2014-09-25 ueda
@property (nonatomic) BOOL typeCeditModeFirstFg;//入力タイプＣの修正モードで最初にオーダーエントリ画面表示を行う
//2014-07-28 ueda
@property (nonatomic) NSInteger printerNumberOfCheckoutSlip; //チェックアウト伝票の印刷先のプリンタ番号
//2014-08-07 ueda
@property (nonatomic) NSInteger tableViewCurrentPageNo;   //テーブル選択画面の現在ページ番号
//2014-08-18 ueda
@property (nonatomic) NSInteger barcodeUseCount;   //バーコードリーダー使用カウント for DEBUG
//2014-09-05 ueda
@property (nonatomic) NSInteger typeCorderIndex;      //入力タイプＣの入力順序番号
@property (nonatomic) BOOL typeCorderResetFg;   //入力タイプＣのオーダーエントリー画面へ戻った場合に数量をリセットする
//2014-09-08 ueda
@property (nonatomic) NSInteger typeCorderCount;      //入力タイプＣの入力オーダー数
//2014-09-11 ueda
@property TypeOrder type;                       //処理タイプ 新規、追加、取消、...
//2014-09-12 ueda
@property (nonatomic) BOOL typeCcancelStartFg;  //入力タイプＣの取消直後かどうか
//2014-09-16 ueda
@property (nonatomic) NSInteger typeCarrangeCount;    //入力タイプＣのアレンジの入力数
//2014-09-18 ueda
@property (nonatomic) NSInteger getMasterSetFg;       //ＤＢ変更等で起動時にマスターダウンロードするためのフラグ
//2014-09-22 ueda
@property (nonatomic) NSInteger typeCpreOrderTypeNo;  //入力タイプＣの直前の選択したオーダー種類番号
//2014-12-04 ueda
typedef enum : NSInteger {
    communication_Step_NotConnect = 0,  //通信前
    communication_Step_Connected  = 1,  //接続した
    communication_Step_Sended     = 2,  //送信した
    communication_Step_Recieved   = 3   //受信した
} communication_Step;
@property (nonatomic) NSInteger communication_Step_Status;      //通信ステップ 0:通信前,1:接続した,2:送信した,3:受信した
typedef enum : NSInteger {
    communication_Return_OK = 0,
    communication_Return_NG = 1,
    communication_Return_2  = 2,
    communication_Return_3  = 3,
    communication_Return_4  = 4,
    communication_Return_5  = 5,
    communication_Return_6  = 6,
    communication_Return_7  = 7,
    communication_Return_8  = 8,
    communication_Return_MasterDownload = 9
} communication_Return;
@property (nonatomic) NSInteger communication_Return_Status;    //通信のリターンステータス
//2014-12-25 ueda
@property (nonatomic) BOOL OrderRequestN31retryFlag;        //N31のリトライフラグ（電文のヘッダーを直前のままで送信する）
@property (nonatomic) BOOL OrderRequestN31forceFlag;        //N31の（相席確認で）相席でも登録する

//2014-07-25 ueda
/*
- (void)buttonSetColorGray:(float)_face
                     face2:(float)_face2
                     side1:(float)_side1
                     side2:(float)_side2;

- (void)buttonSetColorWithButton:(QBFlatButton*)_button
                           face1:(UIColor*)_face1
                           face2:(UIColor*)_face2
                           side1:(UIColor*)_side1
                           side2:(UIColor*)_side2;
 */

//2016-04-08 ueda
@property (nonatomic) BOOL isDisplayExpire;
@property (nonatomic) BOOL isDisplayAlert;

- (void)lockScreen;

@end
