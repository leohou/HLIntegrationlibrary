//
//  NSString+WSUFormat.h
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (WSUFormat)
+ (NSString *)stringWithUnichar:(unichar)value;
+ (NSString *)timeFormattedToHHMMSS:(NSInteger)totalSeconds; //HH:MM:SS
+ (NSString *)timeFormattedToHHMM:(NSInteger)totalSeconds; //HH:MM
+ (NSString *)timeFormattedToMMSS:(NSInteger)totalSeconds; //MM:SS
+ (NSString *)timeFormattedToHHMMSSWithoutSplit:(NSInteger)totalSeconds;  //HH:MMSS
+ (NSString *)timeFormattedToHHMMWithSuccess:(NSInteger)totalSeconds;  //H:MM
+ (NSString *)timeFormattedToHHMMWithChinese:(NSTimeInterval)totalSeconds;
- (NSString *)MD5Hash;
//- (unsigned long long)unsignedLongLongValue;

+ (NSString *)stringForLikeCount:(NSInteger)likeCount;


@end
