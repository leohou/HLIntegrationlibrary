//
//  NSString+WSUFormat.m
//  WSUserSDK
//
//  Created by houli on 2017/6/17.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "NSString+WSUFormat.h"
#import <CommonCrypto/CommonCrypto.h>

#define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD5_BLOCK_BYTES      64          /* block size in bytes */

@implementation NSString (WSUFormat)
+ (NSString*)stringWithUnichar:(unichar)value
{
    NSString* string = [NSString stringWithFormat:@"%C",value];
    return string;
}

+ (NSString *)timeFormattedToHHMMSS:(NSInteger)totalSeconds
{
    
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02ld:%02ld:%02ld",(long)hours, (long)minutes, (long)seconds];
}

+ (NSString *)timeFormattedToHHMM:(NSInteger)totalSeconds
{
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02ld:%02ld",(long)hours, (long)minutes];
}

+ (NSString *)timeFormattedToMMSS:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    
    return [NSString stringWithFormat:@"%02ld:%02ld", (long)minutes, (long)seconds];
}

+ (NSString*)timeFormattedToHHMMSSWithoutSplit:(NSInteger)totalSeconds
{
    NSInteger seconds = totalSeconds % 60;
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%02ld:%02ld%02ld",(long)hours, (long)minutes, (long)seconds];
}

+ (NSString*)timeFormattedToHHMMWithSuccess:(NSInteger)totalSeconds
{
    NSInteger minutes = (totalSeconds / 60) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%ld:%02ld",(long)hours, (long)minutes];
}

+ (NSString *)timeFormattedToHHMMWithChinese:(NSTimeInterval)totalSeconds
{
    NSInteger minutes = ((int)(totalSeconds / 60)) % 60;
    NSInteger hours = totalSeconds / 3600;
    
    return [NSString stringWithFormat:@"%ld小时%ld分钟", (long)hours, (long)minutes];
}

- (NSString *) MD5Hash {
    const char *cStr = [self UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, (CC_LONG)(strlen(cStr)), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02X", digest[i]];
    
    return  output;
    
}

- (unsigned long long)unsignedLongLongValue
{
    return self.longLongValue;
}

+ (NSString *)stringForLikeCount:(NSInteger)likeCount
{
    return likeCount > 9999?[NSString stringWithFormat:@"%.1f万", (CGFloat)likeCount / 10000]:[NSString stringWithFormat:@"%@", @(likeCount)];
}


@end
