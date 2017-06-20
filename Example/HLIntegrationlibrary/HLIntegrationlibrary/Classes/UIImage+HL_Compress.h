//
//  UIImage+HL_Compress.h
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ImageIO/ImageIO.h>
#import <MobileCoreServices/MobileCoreServices.h>


@interface UIImage (HL_Compress)
+ (CGFloat)screenScale;

//- (UIImage *)getSubImage:(CGRect)rect;
- (UIImage *)scaledImage:(CGSize)targetSize;
- (UIImage *)thumbnailWithoutTransform:(CGSize)targetSize; // zfs_2013.8.12_02
#if 0
- (UIImage *)faceImageConstrainedToSize:(CGSize)viewSize;
#endif

- (UIImage *)scaledImageWithTransform:(CGSize)targetSize;
- (UIImage *)clippedImageInRect:(CGRect)rect; // zfs_2013.8.13_03

+ (UIImage *)CGThumbnail:(CGFloat)dimension
               fromImage:(NSString *)path;
+ (UIImage *)CGThumbnail:(CGFloat)dimension
                fromData:(NSData *)data;

- (BOOL)writeToData:(NSMutableData *)data
           withType:(CFStringRef)imageType
            quality:(CGFloat)quality
         andOptions:(NSDictionary *)options;

- (BOOL)writeToFile:(NSString *)file
           withType:(CFStringRef)imageType
            quality:(CGFloat)quality
         andOptions:(NSDictionary *)options;

- (NSData *)JPEGRepresentation:(CGFloat)quality
          saveImageOrientation:(BOOL)saveImageOrientation;

+ (NSInteger)CGImageOrientationFrom:(UIImageOrientation)imageOrientation;
+ (UIImageOrientation)UIImageOrientationFrom:(NSInteger)CGImageOrientation;

+ (UIImage *)getOverlappedImage:(NSArray *)images; // zfs_2013.7.30_02
+ (UIImage *)getOverlappedImage:(UIImage *)topImage withImage:(UIImage *)bottomImage;

- (UIImage *)tiltSlightly:(CGFloat)angle;

- (UIImage *)imageResizeTo:(CGSize)size
          withCornerRadius:(CGFloat)cornerRadius; // zfs_2013.9.9_02

- (UIImage *)portraitImage; // zfs_2013.11.11_03

+ (BOOL)CGSetQuality:(CGFloat)quality
            fromData:(NSData *)sourceData
              toData:(NSMutableData *)destData
         toImageType:(CFStringRef)imageType // eg. kUTTypeJPEG
         withOptions:(NSDictionary *)options;

- (void)blur:(CGFloat)inputRadius completion:(void (^)(UIImage *blurImage))completion;


@end
