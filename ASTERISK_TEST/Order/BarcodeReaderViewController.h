//
//  BarcodeReaderViewController.h
//  Order
//
//  Created by UEDA on 2014/08/19.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol BarcodeReaderViewDelegate <NSObject>
- (void)finishView:(NSString *)returnValue;
@end

@interface BarcodeReaderViewController : UIViewController{
    id<BarcodeReaderViewDelegate> _delegate;
}
@property (nonatomic) id<BarcodeReaderViewDelegate> delegate;

@end
