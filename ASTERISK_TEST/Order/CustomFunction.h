//
//  CustomFunction.h
//  Order
//
//  Created by UEDA on 2014/07/10.
//  Copyright (C) 2014 SPer Co.,Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

void drawLinearGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
void drawGlossAndGradient(CGContextRef context, CGRect rect, CGColorRef startColor, CGColorRef endColor);
CGRect rectFor1PxStroke(CGRect rect);
CGMutablePathRef createRoundedRectForRect(CGRect rect, CGFloat radius);
CGRect forceRectForOrderEntry(CGRect rect);
//2015-12-08 ueda ASTERISK_TEST
NSString *convertCategoryCodeTwoCharacter(NSString *oneCharacter);
