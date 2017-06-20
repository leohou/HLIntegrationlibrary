//
//  UIDevice+HL_WSUKit.h
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIDevice (HL_WSUKit)

+ (unsigned long long) totalDiskSpace;
+ (unsigned long long) freeDiskSpace;
@end

