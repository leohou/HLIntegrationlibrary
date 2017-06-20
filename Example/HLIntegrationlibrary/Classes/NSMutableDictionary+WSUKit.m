//
//  NSMutableDictionary+WSUKit.m
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "NSMutableDictionary+WSUKit.h"

@implementation NSMutableDictionary (WSUKit)

- (void)wp_setValue:(id)value forKey:(NSString *)key
{
    id tempValue = value;
    if (!tempValue
        || [tempValue isKindOfClass:[NSNull class]]
        || !key
        || ![key isKindOfClass:[NSString class]]
        ) {
        return;
    }
    self[key] = tempValue;
}

@end
