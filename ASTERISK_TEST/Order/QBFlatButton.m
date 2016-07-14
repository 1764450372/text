/*
 Copyright (c) 2013 Katsuma Tanaka
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 */

#import "QBFlatButton.h"
#import "System.h"

@interface QBFlatButton (){
//2014-10-09 ueda
/*
    UIColor *textColor;
    UIColor *textColorSelected;
 */
    BOOL isSound;
}

//2014-10-09 ueda
/*
@property (nonatomic, retain) UIColor *faceColorNormal;
@property (nonatomic, retain) UIColor *faceColorHighlighted;
@property (nonatomic, retain) UIColor *faceColorSelected;
@property (nonatomic, retain) UIColor *faceColorDisabled;

@property (nonatomic, retain) UIColor *sideColorNormal;
@property (nonatomic, retain) UIColor *sideColorHighlighted;
@property (nonatomic, retain) UIColor *sideColorSelected;
@property (nonatomic, retain) UIColor *sideColorDisabled;
 */

//- (void)drawRoundedRect:(CGRect)rect radius:(CGFloat)radius context:(CGContextRef)context;

@end

@implementation QBFlatButton

- (void)setFrame:(CGRect)frame
{
    [super setFrame:frame];
    [self setNeedsDisplay];
    
    isSound = YES;
}

- (void)setHighlighted:(BOOL)value
{
    [super setHighlighted:value];

    //LOG(@"value:%d",value);
    
    if (self.enabled) {
        //2014-10-09 ueda
/*
        if (self.selected) {
            self.titleLabel.textColor = textColorSelected;
            [self setTitleColor:textColorSelected forState:UIControlStateNormal];
            [self setTitleColor:textColorSelected forState:UIControlStateSelected];
        }
        else{
            self.titleLabel.textColor = textColor;
        }
 */
        self.titleLabel.textColor = [UIColor blackColor];
    }
    else{
        //2014-01-27 ueda
        //self.titleLabel.textColor = [UIColor grayColor];
        //2014-10-09 ueda
        //self.titleLabel.textColor = self.faceColorDisabled;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.42f alpha:1.0];
    }
    
    if (value) {
        if ([[System sharedInstance].sound isEqualToString:@"0"]&&isSound) {
            if ([self.soundFileName length]) {
                [System soundPlayFile:self.soundFileName];
            } else {
                [System tapSound];
            }
            isSound = NO;
        }
    }
    else{
        isSound = YES;
    }
    
    [self setNeedsDisplay];
}

- (void)setSelected:(BOOL)value
{
    [super setSelected:value];
    
    //LOG(@"value:%d",value);
    
    if (value) {
        //2014-10-09 ueda
/*
        self.titleLabel.textColor = textColorSelected;
        [self setTitleColor:textColorSelected forState:UIControlStateNormal];
        [self setTitleColor:textColorSelected forState:UIControlStateSelected];
 */
        self.titleLabel.textColor = [UIColor blackColor];
    }
    else{
        //2014-10-09 ueda
/*
        self.titleLabel.textColor = textColor;
        [self setTitleColor:textColor forState:UIControlStateNormal];
        [self setTitleColor:textColor forState:UIControlStateSelected];
 */
        self.titleLabel.textColor = [UIColor colorWithWhite:0.42f alpha:1.0];
    }
    
    [self setNeedsDisplay];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    if (enabled) {
        //2014-10-09 ueda
        //self.titleLabel.textColor = textColor;
        self.titleLabel.textColor = [UIColor blackColor];
    }
    else{
        //2014-01-27 ueda
        //self.titleLabel.textColor = [UIColor grayColor];
        //2014-10-09 ueda
        //self.titleLabel.textColor = self.faceColorDisabled;
        self.titleLabel.textColor = [UIColor colorWithWhite:0.42f alpha:1.0];
    }
    [self setNeedsDisplay];
}

- (void)setFaceColor:(UIColor *)faceColor
{
    //2014-10-09 ueda
/*
    [self setFaceColor:faceColor forState:UIControlStateNormal];
    [self setFaceColor:faceColor forState:UIControlStateHighlighted];
    [self setFaceColor:faceColor forState:UIControlStateSelected];
    [self setFaceColor:faceColor forState:UIControlStateDisabled];
 */
    
    [self setBackgroundColor:[UIColor clearColor]];
}

//2014-10-09 ueda
/*
- (UIColor *)faceColor
{
    return [self faceColorForState:self.state];
}
 */

/*
- (void)setSideColor:(UIColor *)sideColor
{
    [self setSideColor:sideColor forState:UIControlStateNormal];
    [self setSideColor:sideColor forState:UIControlStateHighlighted];
    [self setSideColor:sideColor forState:UIControlStateSelected];
    [self setSideColor:sideColor forState:UIControlStateDisabled];
}

- (UIColor *)sideColor
{
    return [self sideColorForState:self.state];
}
*/

//2014-02-18 ueda
- (void)setNumberOfLines:(int)numberOfLines
{
    self.titleLabel.numberOfLines = numberOfLines;
    //2016-02-03 ueda
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
}

- (void)useDefaultStyle
{
    //2014-03-05 ueda
    /*
    //2014-01-27 ueda
    self.faceColorNormal = [UIColor colorWithWhite:0.75f alpha:1.0];
    self.sideColorNormal = [UIColor colorWithWhite:0.55f alpha:1.0];
    self.faceColorDisabled = [UIColor colorWithWhite:0.75f alpha:1.0];
    self.sideColorDisabled = [UIColor colorWithWhite:0.55f alpha:1.0];
    self.faceColorHighlighted = [UIColor colorWithWhite:0.55f alpha:1.0];
    self.sideColorHighlighted = [UIColor colorWithWhite:0.45f alpha:1.0];
    self.faceColorSelected = BLUE;
    self.sideColorSelected = DEEPBLUE;
    self.backgroundColor = [UIColor clearColor];
    
    self.radius = 1.0;
    self.margin = 1.0;
    self.depth = 1.0;
     */
    UIImage *img = [UIImage imageNamed:@"ButtonDefault.png"];
    [self setBackgroundImage:img forState:UIControlStateNormal];
    self.backgroundColor = [UIColor clearColor];
    //self.radius = 0.0;
    self.margin = 0.0;
    self.depth = 0.0;
    //2014-10-09 ueda
/*
    //2014-03-10 ueda
    self.faceColorDisabled = [UIColor colorWithWhite:0.42f alpha:1.0];
 */
    
    //2014-10-09 ueda
/*
    textColor = [UIColor blackColor];
    textColorSelected = [UIColor blackColor];
 */
    //2014-10-09 ueda
/*
    [self setTitleColor:textColor forState:UIControlStateNormal];
    //[self setTitleColor:[UIColor blackColor] forState:UIControlStateSelected];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateDisabled];
 */
    [self setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self setTitleColor:[UIColor colorWithWhite:0.42f alpha:1.0] forState:UIControlStateDisabled];
    
    //2014-01-30 ueda
    self.titleLabel.adjustsFontSizeToFitWidth = YES;
    //2014-02-18 ueda
    //self.titleLabel.numberOfLines=0;
    
    //2015-10-28 ueda 同時押し禁止
    self.exclusiveTouch = YES;
}

- (id)initWithCoder:(NSCoder *)decoder
{
    if (self = [super initWithCoder:decoder])
    {
        [self useDefaultStyle];
        //textColor = self.titleLabel.textColor;
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    [super drawRect:rect];
    
    //2014-03-05 ueda
    /*
    CGSize size = self.bounds.size;
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGRect faceRect = CGRectMake(0, 0, size.width, size.height);
    UIGraphicsBeginImageContextWithOptions(faceRect.size, NO, 0.0);
    
    [[self faceColorForState:self.state] set];
    
    [self drawRoundedRect:faceRect radius:self.radius context:UIGraphicsGetCurrentContext()];
    UIImage *faceImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [[self sideColorForState:self.state] set];
        
    CGRect sideRect = CGRectMake(0, size.height * 1.0 / 4.0, size.width, size.height * 3.0 / 4.0);
    [self drawRoundedRect:sideRect radius:self.radius context:context];
    
    CGRect faceShrinkedRect;
    if(self.state == UIControlStateSelected || self.state == UIControlStateHighlighted) {
        faceShrinkedRect = CGRectMake(0, self.depth, size.width, size.height - self.margin);
    } else {
        faceShrinkedRect = CGRectMake(0, 0, size.width, size.height - self.margin);
    }
    [faceImage drawInRect:faceShrinkedRect];
     */
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    CGRect frame = self.titleLabel.frame;
    frame.origin.y = frame.origin.y - self.margin / 2;
    
    CGRect imageViewFrame = self.imageView.frame;
    imageViewFrame.origin.y = imageViewFrame.origin.y - self.margin / 2;
    
    if(self.state == UIControlStateSelected || self.state == UIControlStateHighlighted) {
        frame.origin.y = frame.origin.y + self.depth;        
        imageViewFrame.origin.y = imageViewFrame.origin.y + self.depth;
    }
    
    self.titleLabel.frame = frame;
    self.imageView.frame = imageViewFrame;
}


#pragma mark -
//2014-10-09 ueda
/*
- (void)setFaceColor:(UIColor *)faceColor forState:(UIControlState)state
{
    switch(state) {
        case UIControlStateNormal: default:
            self.faceColorNormal = faceColor;
            break;
        case UIControlStateHighlighted:
            self.faceColorHighlighted = faceColor;
            break;
        case UIControlStateSelected:
            self.faceColorSelected = faceColor;
            break;
        case UIControlStateDisabled:
            self.faceColorDisabled = faceColor;
            break;
    }
}
 */

/*
- (void)setSideColor:(UIColor *)sideColor forState:(UIControlState)state
{
    switch(state) {
        case UIControlStateNormal: default:
            self.sideColorNormal = sideColor;
            break;
        case UIControlStateHighlighted:
            self.sideColorHighlighted = sideColor;
            break;
        case UIControlStateSelected:
            self.sideColorSelected = sideColor;
            break;
        case UIControlStateDisabled:
            self.sideColorDisabled = sideColor;
            break;
    }
}
*/

//2014-10-09 ueda
/*
- (UIColor *)faceColorForState:(UIControlState)state
{
    UIColor *faceColor;
    
    switch(state) {
        case UIControlStateNormal: default:
            faceColor = self.faceColorNormal;
            break;
        case UIControlStateHighlighted:
            faceColor = self.faceColorHighlighted;
            break;
        case UIControlStateSelected:
            faceColor = self.faceColorSelected;
            break;
        case UIControlStateDisabled:
            faceColor = self.faceColorDisabled;
            break;
    }
    
    return faceColor;
}
 */

/*
- (UIColor *)sideColorForState:(UIControlState)state
{
    UIColor *sideColor;
    
    switch(state) {
        case UIControlStateNormal: default:
            sideColor = self.sideColorNormal;
            break;
        case UIControlStateHighlighted:
            sideColor = self.sideColorHighlighted;
            break;
        case UIControlStateSelected:
            sideColor = self.sideColorSelected;
            break;
        case UIControlStateDisabled:
            sideColor = self.sideColorDisabled;
            break;
    }
    
    return sideColor;
}

- (void)drawRoundedRect:(CGRect)rect radius:(CGFloat)radius context:(CGContextRef)context
{	
    rect.origin.x += 0.5;
    rect.origin.y += 0.5;
    rect.size.width -= 1.0;
    rect.size.height -= 1.0;
    
    CGFloat lx = CGRectGetMinX(rect);
    CGFloat cx = CGRectGetMidX(rect);
    CGFloat rx = CGRectGetMaxX(rect);
    CGFloat by = CGRectGetMinY(rect);
    CGFloat cy = CGRectGetMidY(rect);
    CGFloat ty = CGRectGetMaxY(rect);
	
    CGContextMoveToPoint(context, lx, cy);
    CGContextAddArcToPoint(context, lx, by, cx, by, radius);
    CGContextAddArcToPoint(context, rx, by, rx, cy, radius);
    CGContextAddArcToPoint(context, rx, ty, cx, ty, radius);
    CGContextAddArcToPoint(context, lx, ty, lx, cy, radius);
    CGContextClosePath(context);
    
    CGContextDrawPath(context, kCGPathFillStroke);
}
 */

//2014-09-08 ueda
#pragma mark -

-(void)setTitle:(NSString *)title forState:(UIControlState)state {
    [super setTitle:title forState:state];
    if ([title isEqualToString:[String bt_confirm]]) {
        UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
        [self setBackgroundImage:img forState:UIControlStateNormal];
        //2016-02-03 ueda ASTERISK
        [self setTitleColor:[UIColor whiteColor] forState:state];
    }
    if ([title isEqualToString:[String bt_next]]) {
        UIImage *img = [UIImage imageNamed:@"ButtonNext.png"];
        [self setBackgroundImage:img forState:UIControlStateNormal];
        //2016-02-03 ueda ASTERISK
        [self setTitleColor:[UIColor whiteColor] forState:state];
    }
    if ([title isEqualToString:[String bt_return]]) {
        UIImage *img = [UIImage imageNamed:@"ButtonReturn.png"];
        [self setBackgroundImage:img forState:UIControlStateNormal];
    }
    if ([title isEqualToString:[String bt_send]]) {
        UIImage *img = [UIImage imageNamed:@"ButtonSend.png"];
        [self setBackgroundImage:img forState:UIControlStateNormal];
        //2016-02-03 ueda ASTERISK
        [self setTitleColor:[UIColor whiteColor] forState:state];
    }
}

@end
