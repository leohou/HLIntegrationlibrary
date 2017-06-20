//
//  NSString+WSUKit.m
//  Pods
//
//  Created by houli on 2017/6/20.
//
//

#import "NSString+WSUKit.h"

#import <CommonCrypto/CommonCrypto.h>

#define CC_MD5_DIGEST_LENGTH    16          /* digest length in bytes */
#define CC_MD5_BLOCK_BYTES      64          /* block size in bytes */


@implementation NSString (WSUKit)
//md5
// 计算md5，全小写
- (NSString *)md5String {
    
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    return [NSString stringWithFormat:@"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

// 计算md5，全大写
- (NSString *)md5StringInUpperCase {
    
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    return [NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
            result[0], result[1], result[2], result[3], result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11], result[12], result[13], result[14], result[15]];
}

- (NSData *)md5Data {
    NSData * data = [self dataUsingEncoding:NSUTF8StringEncoding];
    
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5([data bytes], (CC_LONG)[data length], result);
    
    return [NSData dataWithBytes:result length:CC_MD5_DIGEST_LENGTH];
}

- (NSString*)md5Encrypt16 {
    return [self md5String];
}

//url
- (NSString *)URLEncodedString
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,(CFStringRef)self,(CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",NULL,kCFStringEncodingUTF8));
    return encodedString;
}

+ (NSString *)getStringFromUrl: (NSString*)url needle:(NSString *)needle
{
    NSString * str = nil;
    NSRange start = [url rangeOfString:needle];
    if (start.location != NSNotFound) {
        NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
        NSUInteger offset = start.location+start.length;
        str = (end.location == NSNotFound)? [url substringFromIndex:offset]: [url substringWithRange:NSMakeRange(offset, end.location)];
        str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    }
    
    if (!str) {
        str=@"";
    }
    return str;
}


- (NSString *)WP_URLDecodedString {
    BOOL shouldDecodePlusSymbols =  YES;
    NSString *input = shouldDecodePlusSymbols ? [self stringByReplacingOccurrencesOfString:@"+" withString:@" " options:NSLiteralSearch range:NSMakeRange(0, self.length)] : self;
    return [input stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

- (NSDictionary *)WP_URLParameterDictionary {
    NSMutableDictionary *parameters = [NSMutableDictionary dictionary];
    
    if (self.length && [self rangeOfString:@"="].location != NSNotFound) {
        NSMutableArray *keyValuePairs = [NSMutableArray array];
        if ([self rangeOfString:@"&"].location == NSNotFound) {
            [keyValuePairs addObject:self];
        } else {
            [keyValuePairs addObjectsFromArray:[self componentsSeparatedByString:@"&"]];
        }
        for (NSString *keyValuePair in keyValuePairs) {
            NSArray *pair = [keyValuePair componentsSeparatedByString:@"="];
            // don't assume we actually got a real key=value pair. start by assuming we only got @[key] before checking count
            NSString *paramValue = pair.count == 2 ? pair[1] : @"";
            // CFURLCreateStringByReplacingPercentEscapesUsingEncoding may return NULL
            parameters[pair[0]] = [paramValue WP_URLDecodedString] ?: @"";
        }
    }
    
    return parameters;
}

- (BOOL)isURLString
{
    NSString * _regexString=@"http(s)?:\\/\\/([\\w-]+\\.)+[\\w-]+(\\/[\\w- .\\/?%&=]*)?";
    NSPredicate* _urlPredicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", _regexString];
    return [_urlPredicate evaluateWithObject:self];
}

/**
 *  截取URL中的参数
 *
 *  @return NSMutableDictionary parameters
 */
- (NSMutableDictionary *)getURLParameters {
    
    // 查找参数
    NSRange range = [self rangeOfString:@"?"];
    if (range.location == NSNotFound) {
        return nil;
    }
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    
    // 截取参数
    NSString *parametersString = [self substringFromIndex:range.location + 1];
    
    // 判断参数是单个参数还是多个参数
    if ([parametersString containsString:@"&"]) {
        
        // 多个参数，分割参数
        NSArray *urlComponents = [parametersString componentsSeparatedByString:@"?"];
        
        if (urlComponents.count >= 2) {
            
            NSString *urlparame = [urlComponents objectAtIndex:1];
            urlComponents = [urlparame componentsSeparatedByString:@"&"];
        }
        
        
        for (NSString *keyValuePair in urlComponents) {
            // 生成Key/Value
            NSArray *pairComponents = [keyValuePair componentsSeparatedByString:@"="];
            NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
            NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
            
            // Key不能为nil
            if (key == nil || value == nil) {
                continue;
            }
            
            id existValue = [params valueForKey:key];
            
            if (existValue != nil) {
                
                // 已存在的值，生成数组
                if ([existValue isKindOfClass:[NSArray class]]) {
                    // 已存在的值生成数组
                    NSMutableArray *items = [NSMutableArray arrayWithArray:existValue];
                    [items addObject:value];
                    
                    [params setValue:items forKey:key];
                } else {
                    
                    // 非数组
                    [params setValue:@[existValue, value] forKey:key];
                }
                
            } else {
                
                // 设置值
                [params setValue:value forKey:key];
            }
        }
    } else {
        // 单个参数
        
        // 生成Key/Value
        NSArray *pairComponents = [parametersString componentsSeparatedByString:@"="];
        
        // 只有一个参数，没有值
        if (pairComponents.count == 1) {
            return nil;
        }
        
        // 分隔值
        NSString *key = [pairComponents.firstObject stringByRemovingPercentEncoding];
        NSString *value = [pairComponents.lastObject stringByRemovingPercentEncoding];
        
        // Key不能为nil
        if (key == nil || value == nil) {
            return nil;
        }
        
        // 设置值
        [params setValue:value forKey:key];
    }
    
    return params;
}


//price
+ (NSString *)stringForShowPrice:(NSInteger)price
{
    NSString *priceStr = @"";
    if(price% 10  > 0)  //有分
    {
        priceStr = [NSString stringWithFormat:@"%.2f元",price / 100.0];
    }
    else  if(price % 100  > 0) //有角
    {
        priceStr= [NSString stringWithFormat:@"%.1f元",price / 100.0];
    }
    else
    {
        priceStr = [NSString stringWithFormat:@"%.f元",price / 100.0];
    }
    return priceStr;
}

+ (NSAttributedString *)attributeStringForShowPrice:(NSInteger)price
{
    NSString *priceStr = @"";
    if(price% 10  > 0)  //有分
    {
        priceStr = [NSString stringWithFormat:@"%.2f 元",price / 100.0];
    }
    else  if(price % 100  > 0) //有角
    {
        priceStr= [NSString stringWithFormat:@"%.1f 元",price / 100.0];
    }
    else
    {
        priceStr = [NSString stringWithFormat:@"%.f 元",price / 100.0];
    }
    NSMutableAttributedString * _attriString=[[NSMutableAttributedString alloc] initWithString:priceStr];
    [_attriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor redColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:14],NSFontAttributeName, nil] range:NSMakeRange(0, priceStr.length-2)];
    [_attriString addAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor grayColor],NSForegroundColorAttributeName,[UIFont systemFontOfSize:14],NSFontAttributeName, nil] range:NSMakeRange(priceStr.length-2, 2)];
    return _attriString;
}

+ (NSString *)stringForMoviePrice:(CGFloat)price
{
    NSString *priceStr = [NSString stringWithFormat:@"%.2f",price];
    for (int i = 0; i < MAXFLOAT; i++) {
        if ([priceStr hasSuffix:@"0"]) {
            priceStr = [priceStr substringToIndex:priceStr.length - 1];
        } else if ([priceStr hasSuffix:@"."]) {
            priceStr = [priceStr substringToIndex:priceStr.length - 1];
            return priceStr;
        } else {
            return priceStr;
        }
    }
    return priceStr;
}



- (NSInteger)numberOfLinesWithFont:(UIFont*)font
                     withLineWidth:(NSInteger)lineWidth
{
    //    CGSize size = [self sizeWithFont:font
    //                   constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX)
    //                       lineBreakMode:NSLineBreakByTruncatingTail];
    
    CGSize size = [self boundingRectWithSize:CGSizeMake(lineWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:NULL].size;
    
    NSInteger lines = size.height / [self ittLineHeight];
    return lines;
}
- (CGFloat)ittLineHeight {
    UIFont *font = [[UIFont alloc]init];
    return (font.ascender - font.descender) + 1;
}

- (CGFloat)heightWithFont:(UIFont*)font
            withLineWidth:(NSInteger)lineWidth
{
    //    CGSize size = [self sizeWithFont:font
    //                   constrainedToSize:CGSizeMake(lineWidth, CGFLOAT_MAX)
    //                       lineBreakMode:NSLineBreakByTruncatingTail];
    //
    
    CGSize size = [self boundingRectWithSize:CGSizeMake(lineWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:NULL].size;
    return size.height;
    
}

- (NSString *)md5
{
    const char *concat_str = [self UTF8String];
    unsigned char result[CC_MD5_DIGEST_LENGTH];
    CC_MD5(concat_str, strlen(concat_str), result);
    NSMutableString *hash = [NSMutableString string];
    for (int i = 0; i < 16; i++){
        [hash appendFormat:@"%02X", result[i]];
    }
    return [hash lowercaseString];
    
}

- (NSString*)encodeUrl
{
    NSString *newString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault, (CFStringRef)self, NULL, CFSTR(":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`"), CFStringConvertNSStringEncodingToEncoding(NSUTF8StringEncoding)));
    if (newString) {
        return newString;
    }
    return @"";
}

- (BOOL)isStartWithString:(NSString*)start
{
    BOOL result = FALSE;
    NSRange found = [self rangeOfString:start options:NSCaseInsensitiveSearch];
    if (found.location == 0)
    {
        result = TRUE;
    }
    return result;
}

- (BOOL)isEndWithString:(NSString*)end
{
    NSInteger endLen = [end length];
    NSInteger len = [self length];
    BOOL result = TRUE;
    if (endLen <= len) {
        NSInteger index = len - 1;
        for (NSInteger i = endLen - 1; i >= 0; i--) {
            if ([end characterAtIndex:i] != [self characterAtIndex:index]) {
                result = FALSE;
                break;
            }
            index--;
        }
    }
    else {
        result = FALSE;
    }
    return result;
}

//compareToVersion
-(NSComparisonResult)compareToVersion:(NSString *)version{
    NSComparisonResult result;
    
    result = NSOrderedSame;
    
    if(![self isEqualToString:version]){
        NSArray *thisVersion = [self componentsSeparatedByString:@"."];
        NSArray *compareVersion = [version componentsSeparatedByString:@"."];
        
        for(NSInteger index = 0; index < MAX([thisVersion count], [compareVersion count]); index++){
            NSInteger thisSegment = (index < [thisVersion count]) ? [[thisVersion objectAtIndex:index] integerValue] : 0;
            NSInteger compareSegment = (index < [compareVersion count]) ? [[compareVersion objectAtIndex:index] integerValue] : 0;
            
            if(thisSegment < compareSegment){
                result = NSOrderedAscending;
                break;
            }
            
            if(thisSegment > compareSegment){
                result = NSOrderedDescending;
                break;
            }
        }
    }
    
    return result;
}


-(BOOL)isOlderThanVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedAscending);
}

-(BOOL)isNewerThanVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedDescending);
}

-(BOOL)isEqualToVersion:(NSString *)version{
    return ([self compareToVersion:version] == NSOrderedSame);
}

-(BOOL)isEqualOrOlderThanVersion:(NSString *)version{
    return ([self compareToVersion:version] != NSOrderedDescending);
}

-(BOOL)isEqualOrNewerThanVersion:(NSString *)version{
    return ([self compareToVersion:version] != NSOrderedAscending);
}

//format
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
