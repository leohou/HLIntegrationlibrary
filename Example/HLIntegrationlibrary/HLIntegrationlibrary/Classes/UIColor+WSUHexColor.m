//
//  UIColor+WSUHexColor.m
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "UIColor+WSUHexColor.h"

@implementation UIColor (WSUHexColor)

+ (UIColor *) colorWithHex:(NSInteger)rgbHexValue {
    return [UIColor colorWithHex:rgbHexValue alpha:1.0];
}

+ (UIColor *)colorWithHex:(NSInteger)rgbHexValue
                    alpha:(CGFloat)alpha {
    return [UIColor colorWithRed:((float)((rgbHexValue & 0xFF0000) >> 16))/255.0
                           green:((float)((rgbHexValue & 0xFF00) >> 8))/255.0
                            blue:((float)(rgbHexValue & 0xFF))/255.0
                           alpha:alpha];
}




+ (UIColor *)colorWithHexString:(NSString *)hexString alpha:(CGFloat)alpha
{
    //删除字符串中的空格
    NSString *cString = [[hexString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] uppercaseString];
    // String should be 6 or 8 characters
    if ([cString length] < 6)
    {
        return [UIColor clearColor];
    }
    // strip 0X if it appears
    if ([cString hasPrefix:@"0X"])
    {
        cString = [cString substringFromIndex:2];
    }
    if ([cString hasPrefix:@"#"])
    {
        cString = [cString substringFromIndex:1];
    }
    if ([cString length] != 6)
    {
        return [UIColor clearColor];
    }
    
    // Separate into r, g, b substrings
    NSRange range;
    range.location = 0;
    range.length = 2;
    //r
    NSString *rString = [cString substringWithRange:range];
    //g
    range.location = 2;
    NSString *gString = [cString substringWithRange:range];
    //b
    range.location = 4;
    NSString *bString = [cString substringWithRange:range];
    
    // Scan values
    unsigned int r, g, b;
    [[NSScanner scannerWithString:rString] scanHexInt:&r];
    [[NSScanner scannerWithString:gString] scanHexInt:&g];
    [[NSScanner scannerWithString:bString] scanHexInt:&b];
    return [UIColor colorWithRed:((float)r / 255.0f) green:((float)g / 255.0f) blue:((float)b / 255.0f) alpha:alpha];
}

@end
