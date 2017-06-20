//
//  HL_WSUSystemUtils.h
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef enum {
    WSUSysUtilsScreenSize35Inch,
    WSUSysUtilsScreenSize40Inch,
} WSUSysUtilsScreenSize;

typedef NS_ENUM(int, WSUMobileGeneration){
    WSUMobileUnknown,
    WSUMobile2G,
    WSUMobile3G,
    WSUMobile4G,
};


#define IPHONE5 (SysUtilsScreenSize40Inch == [SysUtils screenSize])

@interface HL_WSUSystemUtils : NSObject

+ (NSString *)getBootTime;
+ (NSString *)localIPAddress;
+ (NSString *)getIpAddress;
+ (NSString *)localMacAddress;

+ (BOOL)getAvaliMem:(uint64_t *) freeSpace andTotalMem:(uint64_t *)totalSpace;
+ (BOOL)totalMem:(uint64_t *)totalMem availMem:(uint64_t *)availMem wiredMem:(uint64_t *)wiredMem activeMem:(uint64_t *)activeMem;
+ (BOOL)getAvaliSpace:(uint64_t *) freeSpace andTotalSpace:(uint64_t *)totalSpace;
+ (NSString *)readableSize:(uint64_t)size;

+ (NSString *)platform;

// 给文件添加SkipBackup属性，避免文件被备份到iCloud，同时避免被系统删除
+ (BOOL)addSkipBackupAttribute:(NSString *)path;
// 获取SkipBackup属性
+ (BOOL)getSkipBackupAttribute:(NSString *)fileName;

//根据先通过keychain 获取唯一设备ID service 存到keychain里的的唯一标识
+ (NSString *)uniqueIdentifier:(NSString *)serviceIdentifier;

+ (NSString *)getSize:(uint64_t)size;
+ (NSString*)getUint:(uint64_t) size;

// 获取当前ios的版本号
+ (int)getIOSVersion;

// 是否为iOS7或更高版本
+ (BOOL)isIOS7orLater;

+ (BOOL)isRetina;

+ (NSString *)fixStringForDate:(NSDate *)date;

/*
 * it return the screen type of iPhone. Default is SysUtilsScreenSize35Inch for iPhone 3GS,
 * iPhone 4S and iPad2, New iPad. SysUtilsScreenSize40Inch for iPhone 5.
 */
+ (WSUSysUtilsScreenSize)screenSize;

// 是否越狱
+ (BOOL)isBreaked;

// 获取应用版本(不含BuildNumber)
+ (NSString *)GetAppVer;

// 获取应用版本(含BuildNumber)
+ (NSString *)GetAppFullVer;

// 获取数据网络类型
+ (WSUMobileGeneration)GetMobileGenerationNumber;
+ (WSUMobileGeneration)GetMobileGenerationNumber:(NSString *)radioAccessTechnology;
CFStringRef hl_WSUFileMD5HashCreateWithPath(CFStringRef filePath);
@end
