//
//  HL_WSUSystemUtils.m
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "HL_WSUSystemUtils.h"
#import "NSString+WSUKit.h"
#import "HL_WSUKeyChainHelper.h"
#import <unistd.h>
#import <netdb.h>
#import <arpa/inet.h>
#import <sys/param.h>
#import <sys/mount.h>
#import <sys/sysctl.h>
#import <sys/stat.h>

#import <sys/socket.h>
#import <sys/sysctl.h>
#import <net/if_dl.h>
#import <net/if.h>
#import <mach/vm_statistics.h>
#import <mach/host_info.h>
#import <mach/mach_host.h>
#import <mach/mach.h>
#import <ftw.h>
#import <sys/stat.h>
#import <sys/ioctl.h>
#include <sys/xattr.h>

#import <UIKit/UIKit.h>

#import  <CoreTelephony/CTCarrier.h>
#import  <CoreTelephony/CTTelephonyNetworkInfo.h>

#import "NSString+WSUKit.h"


#if WOODPECKER
#import "Woodpecker.h"
#endif
#import <AdSupport/AdSupport.h>

#define IOS_VM_PAGE_SIZE (4 * 1024)
#include <CommonCrypto/CommonDigest.h>


typedef enum fileTypes_tag {
    MUSIC=0,
    VIDEO=1,
    PICTURE=2,
    VIDEOANDPIC=3
} FILETYPES;

FILETYPES fileType;

int musciCount;
uint64_t musciSize;

int picCount;
uint64_t picSize;

int videoCount;
uint64_t videoSize;

vm_size_t usedMemory(void) {
    struct task_basic_info info;
    mach_msg_type_number_t size = sizeof(info);
    kern_return_t kerr = task_info(mach_task_self(), TASK_BASIC_INFO, (task_info_t)&info, &size);
    return (kerr == KERN_SUCCESS) ? info.resident_size : 0; // size in bytes
}

@implementation HL_WSUSystemUtils

+(NSString*)hostname
{
    char baseHostName[256];
    memset(baseHostName, 0, sizeof(baseHostName));
    int success = gethostname(baseHostName, sizeof(baseHostName));
    if (success != 0) {
        return nil;
    }
    baseHostName[255] = '\0';
#if !TARGET_IPHONE_SIMULATOR
    return [NSString stringWithFormat:@"%s.local", baseHostName];
#else
    return [NSString stringWithFormat:@"%s", baseHostName];
#endif
}
+(NSString *)localIPAddress
{
#if TARGET_IPHONE_SIMULATOR
    return @"255.255.255.255";
#endif
    struct hostent *host = gethostbyname([[self hostname] UTF8String]);
    if(!host)
    {
        return nil;
    }
    struct in_addr **list =(struct in_addr **)host->h_addr_list;
    return [NSString stringWithCString:inet_ntoa(*list[0]) encoding: NSUTF8StringEncoding];
}
/////////////////////////
+ (NSString*)getSysInfoByName:(char *)typeSpecifier
{
    size_t size;
    sysctlbyname(typeSpecifier, NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname(typeSpecifier, answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    return results;
}
+ (NSInteger)getSysInfo:(uint) typeSpecifier
{
    size_t size = sizeof(int);
    int results;
    int mib[2] = {CTL_HW, typeSpecifier};
    sysctl(mib,2, &results, &size, NULL, 0);
    return (NSInteger)results;
}
+(NSUInteger) cpuFrequency
{
    return [self getSysInfo:HW_CPU_FREQ];
}
+(NSUInteger) totalMemory
{
    return [self getSysInfo:HW_PHYSMEM];
}
+(NSUInteger) userMemory
{
    return [self getSysInfo:HW_USERMEM];
}
+(BOOL)getAvaliSpace:(uint64_t *) fS andTotalSpace:(uint64_t *)tS {
    
    uint64_t totalSpace = 0;
    uint64_t totalFreeSpace = 0;
    NSError *error = nil;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSDictionary *dictionary = [[NSFileManager defaultManager] attributesOfFileSystemForPath:[paths lastObject] error: &error];
    
    if (dictionary) {
        NSNumber *fileSystemSizeInBytes = [dictionary objectForKey: NSFileSystemSize];
        NSNumber *freeFileSystemSizeInBytes = [dictionary objectForKey:NSFileSystemFreeSize];
        totalSpace = [fileSystemSizeInBytes unsignedLongLongValue];
        totalFreeSpace = [freeFileSystemSizeInBytes unsignedLongLongValue];
        //        //NSLog(@"Memory Capacity of %llu MiB with %llu MiB Free memory available.", ((totalSpace/1024ll)/1024ll), ((totalFreeSpace/1024ll)/1024ll));
    } else {
        //NSLog(@"Error Obtaining System Memory Info: Domain = %@, Code = %ld", [error domain], (long)[error code]);
    }
    uint64_t off = 200*1024*1024;
    
    if (totalFreeSpace <= off)
    {
        totalFreeSpace =0;
    }
    else
    {
        totalFreeSpace -= off;
    }
    if (totalFreeSpace <=0)
    {
        totalFreeSpace =0;
    }
    *fS = totalFreeSpace;
    *tS = totalSpace;
    
    //	struct statfs buf;
    //
    //	*freeSpace = 0;
    //	*totalSpace = 0;
    //	NSString *fstab = [NSString stringWithContentsOfFile:@"/etc/fstab" encoding:NSASCIIStringEncoding error:nil];
    //	if(fstab){
    //		NSArray *lines = [fstab componentsSeparatedByString:@"\n"];
    //		for (NSString *line in lines) {
    //			NSArray *items = [line componentsSeparatedByString:@" "];
    //			if([items count] > 1){
    //				if ([[items objectAtIndex:1] length] > 3) {
    //					if(statfs([[items objectAtIndex:1] UTF8String], &buf) >= 0){
    //						*freeSpace += (long long)buf.f_bsize * buf.f_bfree;
    //						*totalSpace += (long long)(buf.f_blocks * buf.f_bsize);
    //					}
    //				}
    //			}
    //		}
    //	}
    
    return YES;
}

+(uint64_t)getMemSize{
    uint64_t memsize = -1;
    void *pMem = NULL;
    size_t len = 0;
    int err = sysctlbyname("hw.memsize", pMem, &len, NULL, 0);
    if(err != 0){
        //		err = errno;
    }else{
        if(len > 0){
            pMem = malloc(len);
            sysctlbyname("hw.memsize", pMem, &len, NULL, 0);
            memsize = *(uint64_t*)pMem;
            free(pMem);
        }
    }
    return memsize;
}
+ (vm_statistics_data_t)vm_info
{
    mach_msg_type_number_t count = HOST_VM_INFO_COUNT;
    vm_statistics_data_t vmstat;
    vmstat.wire_count = 0;
    if (host_statistics(mach_host_self(), HOST_VM_INFO, (host_info_t)&vmstat, &count) != KERN_SUCCESS)
    {
        // failed
    }
    
    return vmstat;
}

+(BOOL)getAvaliMem:(uint64_t *) availMem andTotalMem:(uint64_t *)totalMem
{
    uint64_t memsize = [self getMemSize];
    vm_statistics_data_t vm_stat = [self vm_info];
    
    *totalMem =  memsize;
    uint64_t used = memsize-(vm_stat.free_count/*+vm_stat.inactive_count*/)*IOS_VM_PAGE_SIZE;
    *availMem = *totalMem - used;
    return YES;
}

+(BOOL)totalMem:(uint64_t *)totalMem availMem:(uint64_t *)availMem wiredMem:(uint64_t *)wiredMem activeMem:(uint64_t *)activeMem
{
    uint64_t memsize = [self getMemSize];
    vm_statistics_data_t vm_stat = [self vm_info];
    
    *totalMem =  memsize;
    uint64_t used = memsize-(vm_stat.free_count/*+vm_stat.inactive_count*/)*IOS_VM_PAGE_SIZE;
    *availMem = *totalMem - used;
    *wiredMem = vm_stat.wire_count * IOS_VM_PAGE_SIZE;
    *activeMem = vm_stat.active_count * IOS_VM_PAGE_SIZE;
    
    return YES;
}

+ (NSString *)readableSize:(uint64_t)size {
    
    int i = 0;
    double realsize = size;
    while (true) {
        
        if (realsize < 1024) {
            break;
        }
        
        realsize = (realsize/1024);
        
        ++i;
        
        // 最多显示GB
        if (i == 3) {
            break;
        }
    }
    
    NSMutableString *strReadable = [[NSMutableString alloc] init];
    if (i >= 3) {
        // GB
        [strReadable appendFormat:@"%.2f", realsize];
    }
    else {
        // MB and lower
        [strReadable appendFormat:@"%llu", (uint64_t)(realsize)];
    }
    
    switch (i) {
        case 0:
            [strReadable appendString:@"B"];
            break;
            
        case 1:
            [strReadable appendString:@"K"];
            break;
            
        case 2:
            [strReadable appendString:@"M"];
            break;
            
        case 3:
            [strReadable appendString:@"G"];
            break;
            
        default:
            [strReadable appendString:@"G"];
            break;
    }
    
    return strReadable;
}

+(NSString *) localMacAddress
{
    int mib[6];
    size_t len;
    char  *buf;
    unsigned char  *ptr;
    struct if_msghdr *ifm;
    struct sockaddr_dl *sdl;
    
    mib[0] = CTL_NET;
    mib[1] = AF_ROUTE;
    mib[2] = 0;
    mib[3] = AF_LINK;
    mib[4] = NET_RT_IFLIST;
    
    if ((mib[5] = if_nametoindex("en0")) == 0) {
        return nil;
    }
    
    if (sysctl(mib, 6, NULL, &len, NULL, 0) < 0) {
        return nil;
    }
    
    if ((buf = malloc(len)) == NULL) {
        return nil;
    }
    
    if (sysctl(mib, 6, buf, &len, NULL, 0) < 0) {
        free(buf);
        return nil;
    }
    
    ifm = (struct if_msghdr *)buf;
    sdl = (struct sockaddr_dl *)(ifm + 1);
    ptr = (unsigned char *)LLADDR(sdl);
    NSString *outstring = [NSString stringWithFormat:@"%02x:%02x:%02x:%02x:%02x:%02x", *ptr, *(ptr+1), *(ptr+2), *(ptr+3), *(ptr+4), *(ptr+5)];
    free(buf);
    return [outstring uppercaseString];
}

+(NSString *)getBootTime
{
    struct timeval tv;
    struct tm  *bootime;
    size_t tvlen = sizeof(tv);
    int mib[2];
    
    mib[0] = CTL_KERN;
    mib[1] = KERN_BOOTTIME;
    
    if(sysctl(mib, 2, &tv, &tvlen, NULL, 0))
    {
        return nil;
    }
    NSTimeZone* timeZone = [NSTimeZone systemTimeZone];
    tv.tv_sec+= [timeZone secondsFromGMT];
    bootime = gmtime(&(tv.tv_sec));
    return [NSString stringWithFormat:@"%d-%d-%d %02d:%02d:%02d", bootime->tm_year+1900,bootime->tm_mon+1,bootime->tm_mday,bootime->tm_hour,bootime->tm_min,bootime->tm_sec];
}

+(NSString*)getIpAddress
{
    int inet_sock;
    struct ifreq ifr;
    inet_sock = socket(AF_INET, SOCK_DGRAM, 0);
    strcpy(ifr.ifr_name, "en0");
    if (ioctl(inet_sock, SIOCGIFADDR, &ifr) >= 0)
    {
        return [NSString stringWithFormat:@"%s",inet_ntoa(((struct sockaddr_in*)&(ifr.ifr_addr))->sin_addr)];
    }
    
    return @"N/A";
}

+ (NSString *)platform {
    size_t size;
    sysctlbyname("hw.machine", NULL, &size, NULL, 0);
    char *answer = malloc(size);
    sysctlbyname("hw.machine", answer, &size, NULL, 0);
    NSString *results = [NSString stringWithCString:answer encoding:NSUTF8StringEncoding];
    free(answer);
    return results;
}

+ (BOOL)addSkipBackupAttribute:(NSString *)fileName {
    
    if ([self getIOSVersion] >= __IPHONE_5_1) { // iOS5.1.0
        NSURL * url = [NSURL fileURLWithPath:fileName];
        
        NSError *error = nil;
        BOOL success = [url setResourceValue: [NSNumber numberWithBool: YES]
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            //NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        return success;
    }
    else if ([self getIOSVersion] >= 50001) { // iOS 5.0.1
        
        
        const char* filePath = [fileName UTF8String];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 1;
        
        int result = setxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return result == 0;
    }
    else {
        // other ios is not supported
        return FALSE;
    }
}

// 获取SkipBackup属性
+ (BOOL)getSkipBackupAttribute:(NSString *)fileName
{
    if (![[NSFileManager defaultManager] fileExistsAtPath:fileName]) {
        return FALSE;
    }
    
    if ([self getIOSVersion] >= __IPHONE_5_1) { // iOS5.1.0
        NSURL * url = [NSURL fileURLWithPath:fileName];
        
        NSError *error = nil;
        NSNumber * value = nil;
        BOOL success = [url getResourceValue: &value
                                      forKey: NSURLIsExcludedFromBackupKey error: &error];
        if(!success){
            //NSLog(@"Error excluding %@ from backup %@", [url lastPathComponent], error);
        }
        return value == nil ? NO : [value boolValue];
    }
    else if ([self getIOSVersion] >= 50001) { // iOS 5.0.1
        
        
        const char* filePath = [fileName UTF8String];
        
        const char* attrName = "com.apple.MobileBackup";
        u_int8_t attrValue = 0;
        
        getxattr(filePath, attrName, &attrValue, sizeof(attrValue), 0, 0);
        return attrValue ? YES : NO;
    }
    else {
        // other ios is not supported
        return FALSE;
    }
}

+ (NSString *) getDeviceId
{
    if ([HL_WSUSystemUtils getIOSVersion] >= 70000) {
        NSUUID * aid = [[UIDevice currentDevice] identifierForVendor];
        NSString *uniqueIdentifier = [[aid UUIDString] md5String];
        return uniqueIdentifier;
    }
    else {
        NSString *macaddress = [self localMacAddress];
        NSString *uniqueIdentifier = [macaddress md5String];
        return uniqueIdentifier;
    }
}

// 获取唯一设备ID
+ (NSString *)uniqueIdentifier:(NSString *)serviceIdentifier{
    static NSString * deviceId = nil;
    
    @synchronized(self) {
        if (deviceId == nil) {
            // 先通过keychain获取
           HL_WSUKeyChainHelper  * keyChain = [HL_WSUKeyChainHelper keyChainHelperForService:serviceIdentifier];
            NSString * errorMsg = nil;
            NSData * data = [keyChain queryItem:&errorMsg];
            
            if (data != nil) {
                // keychain中已经存在
                deviceId = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            }
            else {
                // keychain中不存在
                // 计算deviceId
                deviceId = [self getDeviceId];
                // 保存到keychain中
                if ([keyChain addItem:[deviceId dataUsingEncoding:NSUTF8StringEncoding] errorMsg:&errorMsg protection:NULL] == errSecDuplicateItem) {
                    // 已经存在，先删除
                    [keyChain deleteItemAndReturnErrorMsg:&errorMsg];
                    
                    [keyChain addItem:[deviceId dataUsingEncoding:NSUTF8StringEncoding] errorMsg:&errorMsg protection:NULL];
                }
                
            }
        }
        return deviceId;
    }
}

+ (NSString *)getSize:(uint64_t)size {
    if (size > (1024 *1024 * 1024)) {
        double realsize = size;
        while (realsize > 1024) {
            realsize = (double)((double)realsize/1024);
        }
        return [NSString stringWithFormat:@"%.2f", realsize];
    }else {
        uint64_t realsize = size;
        while (realsize > 1024) {
            realsize = (realsize/1024);
        }
        return [NSString stringWithFormat:@"%llu", realsize];
    }
}

+ (NSString*)getUint:(uint64_t) size {
    int i = 0;
    uint64_t realsize = size;
    while (realsize > 1024) {
        realsize = (realsize/1024);
        i++;
    }
    if (i == 1) {
        return @"KB";
    }else if (i == 2) {
        return @"MB";
    }
    else if (i == 3) {
        return @"GB";
    }
    else {
        return @"MB";
    }
    return @"";
}

// 获取当前ios的版本号
+ (int)getIOSVersion
{
    static int version = -1;
    
    if (version == -1) {
        int ver1 = 0;
        int ver2 = 0;
        int ver3 = 0;
        
        NSString* iosVersion = [[UIDevice currentDevice] systemVersion];
        NSArray* versions = [iosVersion componentsSeparatedByString:@"."];
        
        ver1 = [[versions objectAtIndex:0] intValue];
        ver2 = [[versions objectAtIndex:1] intValue];
        if ([versions count] == 3) {
            ver3 = [[versions objectAtIndex:2] intValue];
        }
        version = ver1*10000 + ver2*100 + ver3;
    }
    
    return version;
}

// 是否为iOS7或更高版本
+ (BOOL)isIOS7orLater
{
    return [self getIOSVersion] >= 70000;
}

+ (BOOL)isRetina
{
    return [UIScreen mainScreen].scale > 1.5;
}

+ (NSString *)fixStringForDate:(NSDate *)date
{
    NSDateFormatter* dateFormatter = [[NSDateFormatter alloc] init];
    //[dateFormatter setDateStyle:NSDateFormatterFullStyle];
    //[dateFormatter setTimeZone: [NSTimeZone timeZoneWithAbbreviation:@"UTC"]];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *fixString = [dateFormatter stringFromDate:date];
    
    return fixString;
}

/*
 * it return the screen type of iPhone. Default is SysUtilsScreenSize35Inch for iPhone 3GS,
 * iPhone 4S and iPad2, New iPad. SysUtilsScreenSize40Inch for iPhone 5.
 */
+ (WSUSysUtilsScreenSize)screenSize {
    WSUSysUtilsScreenSize size;
    
    size = WSUSysUtilsScreenSize35Inch;
    
    if(UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
    {
        CGSize screensize = [[UIScreen mainScreen] bounds].size;
        if(screensize.height == 480) {
            // iPhone Classic
            size = WSUSysUtilsScreenSize35Inch;
        }
        if(screensize.height == 568) {
            // iPhone 5
            size = WSUSysUtilsScreenSize40Inch;
        }
    }
    
    return size;
}

// 是否越狱
+ (BOOL)isBreaked
{
    static BOOL first = YES;
    static BOOL breaked = NO;
    
    @synchronized(self) {
        if (first) {
            
#if !TARGET_IPHONE_SIMULATOR
            NSArray *paths = @[[NSString stringWithFormat:@"/Applications/%@.app", @"Cydia"],
                               // 越狱过的设备，升级后，变为未越狱，此文件依然存在，所以不能以此来判断越狱
                               //                               [NSString stringWithFormat:@"/%@/%@/%@/%@/", @"private", @"var", @"lib", @"apt"],
                               [NSString stringWithFormat:@"/%@/%@", @"bin", @"bash"]];
            
            for (NSString *path in paths) {
                if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
                    breaked = YES;
                    break;
                }
            }
#endif
            
            first = NO;
        }
        
        return breaked;
    }
}

+ (NSString *)GetAppVer
{
    static NSString *ret = nil;
    if (ret == nil) {
        ret = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    }
    return ret;
}

+ (NSString *)GetAppFullVer
{
    static NSString *ret = nil;
    if (ret == nil) {
        ret = [NSString stringWithFormat:@"%@.%@",
               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"],
               [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
    }
    return ret;
}

// 获取数据网络类型
+ (WSUMobileGeneration)GetMobileGenerationNumber
{
    if ([HL_WSUSystemUtils getIOSVersion] < __IPHONE_7_0) {
        return WSUMobileUnknown;
    }
    
    CTTelephonyNetworkInfo * telNetworkInfo = [[CTTelephonyNetworkInfo alloc] init];
    NSString * radioAccessTechnology = telNetworkInfo.currentRadioAccessTechnology;
    
    if (radioAccessTechnology == nil) {
        return WSUMobileUnknown;
    }
    
    return [self GetMobileGenerationNumber:radioAccessTechnology];
}

+ (WSUMobileGeneration)GetMobileGenerationNumber:(NSString *)radioAccessTechnology
{
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyGPRS] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyEdge] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMA1x]) {
        return WSUMobile2G;
    }
    
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSDPA] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyHSUPA] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyWCDMA] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORev0] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevA] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyCDMAEVDORevB] ||
        [radioAccessTechnology isEqualToString:CTRadioAccessTechnologyeHRPD]) {
        return WSUMobile3G;
    }
    
    if ([radioAccessTechnology isEqualToString:CTRadioAccessTechnologyLTE]) {
        return WSUMobile4G;
    }
    
    return WSUMobileUnknown;
}
CFStringRef hl_WSUFileMD5HashCreateWithPath(CFStringRef filePath) {
    
    // Declare needed variables
    CFStringRef result = NULL;
    CFReadStreamRef readStream = NULL;
    
    // Get the file URL
    CFURLRef fileURL =
    CFURLCreateWithFileSystemPath(kCFAllocatorDefault,
                                  (CFStringRef)filePath,
                                  kCFURLPOSIXPathStyle,
                                  (Boolean)false);
    if (!fileURL) goto done;
    
    // Create and open the read stream
    readStream = CFReadStreamCreateWithFile(kCFAllocatorDefault,
                                            (CFURLRef)fileURL);
    if (!readStream) goto done;
    bool didSucceed = (bool)CFReadStreamOpen(readStream);
    if (!didSucceed) goto done;
    
    // Initialize the hash object
    CC_MD5_CTX hashObject;
    CC_MD5_Init(&hashObject);
    
    
    // Feed the data to the hash object
    bool hasMoreData = true;
    while (hasMoreData) {
        uint8_t buffer[4096];
        CFIndex readBytesCount = CFReadStreamRead(readStream,
                                                  (UInt8 *)buffer,
                                                  (CFIndex)sizeof(buffer));
        if (readBytesCount == -1) break;
        if (readBytesCount == 0) {
            hasMoreData = false;
            continue;
        }
        CC_MD5_Update(&hashObject,
                      (const void *)buffer,
                      (CC_LONG)readBytesCount);
    }
    
    // Check if the read operation succeeded
    didSucceed = !hasMoreData;
    
    // Compute the hash digest
    unsigned char digest[CC_MD5_DIGEST_LENGTH];
    CC_MD5_Final(digest, &hashObject);
    
    // Abort if the read operation failed
    if (!didSucceed) goto done;
    
    // Compute the string result
    char hash[2 * sizeof(digest) + 1];
    for (size_t i = 0; i < sizeof(digest); ++i) {
        snprintf(hash + (2 * i), 3, "%02x", (int)(digest[i]));
    }
    result = CFStringCreateWithCString(kCFAllocatorDefault,
                                       (const char *)hash,
                                       kCFStringEncodingUTF8);
    
done:
    
    if (readStream) {
        CFReadStreamClose(readStream);
        CFRelease(readStream);
    }
    if (fileURL) {
        CFRelease(fileURL);
    }
    
    NSLog(@"MD5// %@",result);
    
    return result;
}

@end
