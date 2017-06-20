//
//  NSString+WSUKit.h
//  Pods
//
//  Created by houli on 2017/6/20.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <CommonCrypto/CommonDigest.h>


#define MD5_LENGTH 16

@interface NSString (WSUKit)

//MD5
// 计算md5，全小写
- (NSString *)md5String;
// 计算md5，全大写
- (NSString *)md5StringInUpperCase;

- (NSData *)md5Data;

- (NSString*)md5Encrypt16;


//URL
- (NSString *)URLEncodedString;
+ (NSString *)getStringFromUrl: (NSString*)url needle:(NSString *)needle;

- (NSString *)WP_URLDecodedString;
- (NSDictionary *)WP_URLParameterDictionary;
- (BOOL)isURLString;
- (NSMutableDictionary *)getURLParameters;


//price
+ (NSString *)stringForShowPrice:(NSInteger)price;
+ (NSAttributedString *)attributeStringForShowPrice:(NSInteger)price;
+ (NSString *)stringForMoviePrice:(CGFloat)price;


//
- (BOOL)isStartWithString:(NSString*)start;
- (BOOL)isEndWithString:(NSString*)end;

- (NSInteger)numberOfLinesWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth;

- (CGFloat)heightWithFont:(UIFont*)font withLineWidth:(NSInteger)lineWidth;

- (NSString*)md5;
- (NSString*)encodeUrl;


//CompareToVersion
-(NSComparisonResult)compareToVersion:(NSString *)version;

-(BOOL)isOlderThanVersion:(NSString *)version;
-(BOOL)isNewerThanVersion:(NSString *)version;
-(BOOL)isEqualToVersion:(NSString *)version;
-(BOOL)isEqualOrOlderThanVersion:(NSString *)version;
-(BOOL)isEqualOrNewerThanVersion:(NSString *)version;


//fromat
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
