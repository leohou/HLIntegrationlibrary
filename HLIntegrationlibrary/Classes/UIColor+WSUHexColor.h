//
//  UIColor+WSUHexColor.h
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIColor (WSUHexColor)

+ (UIColor *) colorWithHex:(NSInteger)rgbHexValue;

+ (UIColor *) colorWithHex:(NSInteger)rgbHexValue alpha:(CGFloat)alpha;


+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha;

@end
