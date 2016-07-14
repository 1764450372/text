/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import <UIKit/UIKit.h>

@interface QBFlatButton : UIButton

//2014-10-09 ueda
//@property (nonatomic, retain) UIColor *faceColor;
//@property (nonatomic, retain) UIColor *sideColor;

//@property (nonatomic, assign) CGFloat radius;
@property (nonatomic, assign) CGFloat margin;
@property (nonatomic, assign) CGFloat depth;

//2014-10-09 ueda
//- (void)setFaceColor:(UIColor *)faceColor forState:(UIControlState)state;
//- (void)setSideColor:(UIColor *)sideColor forState:(UIControlState)state;

//2014-10-09 ueda
//- (UIColor *)faceColorForState:(UIControlState)state;
//- (UIColor *)sideColorForState:(UIControlState)state;

//2014-02-18 ueda
- (void)setNumberOfLines:(int)numberOfLines;

@property (nonatomic, copy) NSString *soundFileName;

//2014-09-08 ueda
-(void)setTitle:(NSString *)title forState:(UIControlState)state;

@end
