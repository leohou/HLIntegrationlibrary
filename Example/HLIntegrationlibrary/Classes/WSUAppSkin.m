//
//  WSUAppSkin.m
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "WSUAppSkin.h"

@implementation WSUAppSkin

+ (instancetype)mainSkin
{
    static WSUAppSkin *mainSkin = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        mainSkin = [[WSUAppSkin alloc] init];
    });
    return mainSkin;
}

@end
