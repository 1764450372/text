//
//  CustomFunction.m
//  Order
//
//  Created by UEDA on 2014/07/10.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//

#import "CustomFunction.h"

/*
void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGFloat locations[] = { 0.0, 1.0 };
    
    NSArray *colors = @[(__bridge id) startColor, (__bridge id) endColor];
    
    CGGradientRef gradient = CGGradientCreateWithColors(colorSpace, (__bridge CFArrayRef) colors, locations);
    
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    CGContextSaveGState(context);
    CGContextAddRect(context, rect);
    CGContextClip(context);
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGContextRestoreGState(context);
    
    CGGradientRelease(gradient);
    CGColorSpaceRelease(colorSpace);
}

void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor)
{
    drawLinearGradient(context, rect, startColor, endColor);
    
    UIColor * glossColor1 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.35];
    UIColor * glossColor2 = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:0.1];
    
    CGRect topHalf = CGRectMake(rect.origin.x, rect.origin.y, rect.size.width, rect.size.height/2);
    
    drawLinearGradient(context, topHalf, glossColor1.CGColor, glossColor2.CGColor);
}

CGRect rectFor1PxStroke(CGRect rect)
{
    return CGRectMake(rect.origin.x + 0.5, rect.origin.y + 0.5, rect.size.width - 1, rect.size.height - 1);
}


CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius)
{
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMaxX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMaxY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMaxY(rect), CGRectGetMinX(rect), CGRectGetMinY(rect), radius);
    CGPathAddArcToPoint(path, NULL, CGRectGetMinX(rect), CGRectGetMinY(rect), CGRectGetMaxX(rect), CGRectGetMinY(rect), radius);
    CGPathCloseSubpath(path);
    
    return path;
}
*/

//GMGridViewのCellが初期化時に正しくサイズがセットされないので強制的にセットする
//OrderEntryViewController用
CGRect forceRectForOrderEntry(CGRect rect) {
    if (rect.size.height == 0) {
        if ([System is568h]) {
            rect.size.width  = 117;
            rect.size.height = 85;
        } else {
            rect.size.width  = 117;
            rect.size.height = 68;
        }
    }
    return rect;
}

//2015-12-08 ueda ASTERISK_TEST
//カテゴリーコード１桁を２桁の数字に変換（DB格納用）
//０〜９ー＞００〜０９、Ａ〜Ｊー＞１０〜１９
NSString *convertCategoryCodeTwoCharacter(NSString *oneCharacter) {
    NSArray *sourceCharacter = [NSArray arrayWithObjects:@"A", @"B", @"C", @"D", @"E", @"F", @"G", @"H", @"I", @"J", nil];
    NSArray *destCharacter   = [NSArray arrayWithObjects:@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",nil];
    for (int i = 0; i < [sourceCharacter count]; i++) {
        if ([oneCharacter isEqualToString:[sourceCharacter objectAtIndex:i]]) {
            return [destCharacter objectAtIndex:i];
        }
    }
    return [NSString stringWithFormat:@"%02zd",[oneCharacter integerValue]];
}