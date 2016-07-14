//
//  BarcodeReaderViewController.m
//  Order
//
//  Created by UEDA on 2014/08/19.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//
//  iOS 7 用の標準ＳＤＫによるバーコード読み取り機能
//

#import <AVFoundation/AVFoundation.h>
#import "BarcodeReaderViewController.h"
#import "SSGentleAlertView.h"

@interface BarcodeReaderViewController () <AVCaptureMetadataOutputObjectsDelegate> {
    AVCaptureSession *captureSession;
    AVCaptureDeviceInput *inputDevice;
    AVCaptureVideoPreviewLayer *videoPreviewLayer;
    NSString *cameraError;
}
@end

@implementation BarcodeReaderViewController

@synthesize delegate = _delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

//2015-08-27 ueda Upsidownを有効にする
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

//2014-10-01 ueda
-(void)alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (alertView.tag == 101) {
        [self dismissViewControllerAnimated:YES completion:NULL];
    }
}

//2015-09-28 ueda
// デバイスが回転した際に、呼び出されるメソッド
- (void) didRotate:(NSNotification *)notification {
    [self setCameraViewRotation];
}
//2015-09-28 ueda
- (void) setCameraViewRotation {
    UIInterfaceOrientation o = [[UIApplication sharedApplication] statusBarOrientation];
    if (o == UIDeviceOrientationPortraitUpsideDown) {
        videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortraitUpsideDown;
    } else {
        videoPreviewLayer.connection.videoOrientation = AVCaptureVideoOrientationPortrait;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UILabel *waitingMessage = [[UILabel alloc] initWithFrame:self.view.bounds];
    [waitingMessage setTextAlignment:NSTextAlignmentCenter];
    if ([[System sharedInstance].lang isEqualToString:@"0"]) {
        waitingMessage.text = @"カメラを起動中...";
    } else {
        waitingMessage.text = @"Waiting for CAMERA";
    }
    waitingMessage.font = [UIFont systemFontOfSize:25.0f];
    waitingMessage.textColor = [UIColor whiteColor];
    waitingMessage.backgroundColor = [UIColor blackColor];
    [self.view addSubview:waitingMessage];
    
    UILabel *labelTop    = [[UILabel alloc] initWithFrame:CGRectMake(0,0,320,20)];
    labelTop.backgroundColor = [UIColor blackColor];
    [self.view addSubview:labelTop];
    UILabel *labelTitle  = [[UILabel alloc] initWithFrame:CGRectMake(0,20,320,23)];
    [labelTitle setTextAlignment:NSTextAlignmentCenter];
    UILabel *labelBottom = nil;
    if ([System is568h]) {
        labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0,518,320,50)];
    } else {
        labelBottom = [[UILabel alloc] initWithFrame:CGRectMake(0,430,320,50)];
    }
    labelTitle.text = [String scanBarcodeMsg];//バーコードにピントを合わせて下さい
    labelTitle.textColor = [UIColor whiteColor];
    float osVersion = [[[UIDevice currentDevice] systemVersion] floatValue];
    if(osVersion >= 8.0f)  {
        //2014-11-21 ueda なぜか不明だが iOS Ver 8 はオフセットが必要！？
        labelTitle.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:CGRectMake(0,4,320,27)]];
    } else {
        labelTitle.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:TITLE_BLUE bounds:labelTitle.bounds]];
    }
    [self.view addSubview:labelTitle];
    labelBottom.backgroundColor = [UIColor darkGrayColor];
    [self.view addSubview:labelBottom];
    
    UIButton *buttonCancel = [UIButton buttonWithType:UIButtonTypeCustom];
    if ([System is568h]) {
        buttonCancel.frame = CGRectMake(100, 518, 120, 50);
    } else {
        buttonCancel.frame = CGRectMake(100, 430, 120, 50);
    }
    [buttonCancel setTitle:[String Cancel3] forState:UIControlStateNormal];//キャンセル
    [buttonCancel.titleLabel setFont:[UIFont boldSystemFontOfSize:17]];
    buttonCancel.titleLabel.textColor = [UIColor whiteColor];
    //2014-10-16 ueda
    //buttonCancel.backgroundColor = [UIColor colorWithPatternImage:[System imageWithColorAndRect:[UIColor redColor] bounds:buttonCancel.bounds]];
    buttonCancel.backgroundColor = [UIColor clearColor];
    UIImage *image = [System imageWithColorAndRectFullSize:[UIColor redColor] bounds:buttonCancel.bounds];
    [buttonCancel setBackgroundImage:image forState:UIControlStateNormal];
    [buttonCancel setBackgroundImage:image forState:UIControlStateHighlighted];

    [buttonCancel addTarget:self action:@selector(scanCancelProc) forControlEvents:UIControlEventTouchDown];
    CALayer *btnLayer = [buttonCancel layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:5.0f];
    [self.view addSubview:buttonCancel];
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_async(queue, ^{
        
        NSError *error = nil;
        AVCaptureDevice *captureDevice = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        inputDevice = [AVCaptureDeviceInput deviceInputWithDevice:captureDevice error:&error];
        if (!inputDevice) {
            NSLog(@"%@", [error localizedDescription]);
            //2014-10-01 ueda
            cameraError = [error localizedDescription];
        } else {
            //2014-10-01 ueda
            
            captureSession = [[AVCaptureSession alloc] init];
            [captureSession addInput:inputDevice];
            
            AVCaptureMetadataOutput *output = [AVCaptureMetadataOutput new];
            [output setMetadataObjectsDelegate:self queue:dispatch_get_main_queue()];
            [captureSession addOutput:output];
            
            //output.metadataObjectTypes = output.availableMetadataObjectTypes;
            output.metadataObjectTypes = @[AVMetadataObjectTypeAztecCode,
                                           AVMetadataObjectTypeCode128Code,
                                           AVMetadataObjectTypeCode39Code,
                                           AVMetadataObjectTypeCode39Mod43Code,
                                           AVMetadataObjectTypeCode93Code,
                                           AVMetadataObjectTypeEAN13Code,
                                           AVMetadataObjectTypeEAN8Code,
                                           AVMetadataObjectTypePDF417Code,
                                           AVMetadataObjectTypeQRCode,
                                           AVMetadataObjectTypeUPCECode];
            
            //NSLog(@"%@", output.availableMetadataObjectTypes);
            //NSLog(@"%@", output.metadataObjectTypes);
            
            [captureSession startRunning];
            
        }

        //http://d.hatena.ne.jp/shu223/20121203/1356509154
        dispatch_async(dispatch_get_main_queue(), ^{
            // メインスレッドでの処理（UIまわり）
            UILabel *labelCount = nil;
            if ([System is568h]) {
                labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0,498,320,20)];
            } else {
                labelCount = [[UILabel alloc] initWithFrame:CGRectMake(0,410,320,20)];
            }
            AppDelegate* appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            appDelegate.barcodeUseCount++;
            labelCount.textAlignment = NSTextAlignmentRight;
            labelCount.text = [NSString stringWithFormat:@"Count : %zd", appDelegate.barcodeUseCount];
            labelCount.font = [UIFont systemFontOfSize:15.0f];
            labelCount.textColor = [UIColor blackColor];
            labelCount.backgroundColor = [UIColor clearColor];
            [self.view addSubview:labelCount];
            
            [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationNone];
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleBlackOpaque];

            videoPreviewLayer = [AVCaptureVideoPreviewLayer layerWithSession:captureSession];
            //videoPreviewLayer.frame = self.view.bounds;
            if ([System is568h]) {
                videoPreviewLayer.frame = CGRectMake(0,43,320,475);
            } else {
                videoPreviewLayer.frame = CGRectMake(0,43,320,387);
            }
            videoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
            //[self.view.layer addSublayer:videoPreviewLayer];
            [self.view.layer insertSublayer:videoPreviewLayer atIndex:1];
            
            //2015-09-28 ueda
            if (YES) {
                // デバイスの回転を開始する
                [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
                // デバイスが回転した際に、呼び出してほしいメソッドを設定する。
                // 今回は、selfのdidRotate:というメソッドを呼び出し対象に設定してみました。
                [[NSNotificationCenter defaultCenter] addObserver:self
                                                         selector:@selector(didRotate:)
                                                             name:UIDeviceOrientationDidChangeNotification
                                                           object:nil];
                [self setCameraViewRotation];
            }
        });
    });
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //2014-10-01 ueda
    if (!inputDevice) {
        SSGentleAlertView *alert = [[SSGentleAlertView alloc] initWithStyle:SSGentleAlertViewStyleBlack ];
      //alert.title=[String Order_Station];
        alert.message=[NSString stringWithFormat:@"　\n%@\n　",cameraError];
        alert.messageLabel.font=[UIFont systemFontOfSize:18];
        alert.delegate=self;
        [alert addButtonWithTitle:@"OK"];
        alert.cancelButtonIndex=0;
        alert.tag = 101;
        [alert show];
    }
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    [captureSession stopRunning];
    for (AVCaptureOutput *output in captureSession.outputs) {
        [captureSession removeOutput:output];
    }
    for (AVCaptureInput *input in captureSession.inputs) {
        [captureSession removeInput:input];
    }
    videoPreviewLayer = nil;
    inputDevice = nil;
    captureSession = nil;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputMetadataObjects:(NSArray *)metadataObjects fromConnection:(AVCaptureConnection *)connection {
    [captureSession stopRunning];

    for (AVMetadataObject *metadata in metadataObjects) {
        if ([metadata.type isEqualToString:AVMetadataObjectTypeAztecCode] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeCode128Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeCode39Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeCode39Mod43Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeCode93Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeEAN13Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeEAN8Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypePDF417Code] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeQRCode] ||
            [metadata.type isEqualToString:AVMetadataObjectTypeUPCECode]) {
            NSString *readText  = [(AVMetadataMachineReadableCodeObject *)metadata stringValue];
            [System barcodeScanSound];
            if ([_delegate respondsToSelector:@selector(finishView:)]){
                [_delegate finishView:readText];
            }
        }
        break;
    }
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)scanCancelProc{
    [captureSession stopRunning];

    [System tapSound];
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
