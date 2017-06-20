//
//  UIImage+HL_Compress.m
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "UIImage+HL_Compress.h"
#import <QuartzCore/QuartzCore.h>

#define MAX_IMAGEPIX 1600.0          // max pix 200.0px
#define MAX_IMAGEDATA_LEN 200.0   // max data length 5K

@implementation UIImage (HL_Compress)

+ (CGFloat)screenScale {
    CGFloat scale = [UIScreen mainScreen].scale;
    if ([UIDevice currentDevice].systemVersion.floatValue >= 8.0) {
        scale = ceil([UIScreen mainScreen].nativeScale);
    }
    return scale;
}

//截取部分图像
//- (UIImage *)getSubImage:(CGRect)rect
//{
//    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.CGImage, rect);
//    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef];
//    CFRelease(subImageRef);
//    return smallImage;
//}

- (UIImage*)scaledImage:(CGSize)targetSize {
    
    if (targetSize.width <= 0.0 ||
        targetSize.height <= 0.0 ||
        self.size.width <= 0.0 ||
        self.size.height <= 0.0) {
        return nil;
    }
    
    CGFloat scale = [UIImage screenScale];
    
    if (self.size.width * self.scale <= targetSize.width * scale &&
        self.size.height * self.scale <= targetSize.height * scale) {
        // zfs_2013.8.13_01
        return self;
    } else {
        CGFloat width = ceil((self.size.width / self.size.height) * targetSize.height);
        CGFloat height = ceil((self.size.height / self.size.width) * targetSize.width);
        targetSize.width = MIN(targetSize.width, width);
        targetSize.height = MIN(targetSize.height, height);
        
        // zfs_2013.8.13_01
        if (scale > 1.0) {
            targetSize.width  *= scale;
            targetSize.height *= scale;
        }
    }
    
    UIImageOrientation orientation = self.imageOrientation;
    switch (orientation) {
            // zfs_2013.8.13_02
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGFloat swapValue = targetSize.width;
            targetSize.width  = targetSize.height;
            targetSize.height = swapValue;
            break;
        }
            
        default:
            break;
    }
    
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap;
    bitmap = CGBitmapContextCreate(NULL,
                                   targetSize.width,
                                   targetSize.height,
                                   8,
                                   targetSize.width * 4,
                                   colorSpaceInfo,
                                   kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpaceInfo);
    colorSpaceInfo = nil;
    CGContextDrawImage(bitmap,
                       CGRectMake(0.0, 0.0, targetSize.width, targetSize.height),
                       self.CGImage);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    bitmap = nil;
    // zfs_2013.8.13_01
    UIImage * newImage = [UIImage imageWithCGImage:ref
                                             scale:scale
                                       orientation:orientation];
    CGImageRelease(ref);
    ref = nil;
    return newImage;
}

- (CGRect)frameToClip:(CGSize)viewSize {
    CGSize imageSize = self.size;
    if (viewSize.width / viewSize.height > imageSize.width / imageSize.height) {
        // wider
        CGFloat newImageHeight = viewSize.height * imageSize.width / viewSize.width;
        return CGRectMake(0, (imageSize.height - newImageHeight)/2, imageSize.width, newImageHeight);
    } else {
        CGFloat newImageWidth = viewSize.width * imageSize.height / viewSize.height;
        return CGRectMake((imageSize.width - newImageWidth)/2, 0, newImageWidth, imageSize.height);
    }
}

#if 0
- (UIImage *)faceImageConstrainedToSize:(CGSize)viewSize {
    if ([[[UIDevice currentDevice]systemVersion]floatValue] < 5.0) {
        return [self thumbnailWithoutTransform:viewSize];
    }
    
    CIImage * ciImage = [CIImage imageWithCGImage:self.CGImage];
    CIDetector* detector = [CIDetector detectorOfType:CIDetectorTypeFace
                                              context:nil options:[NSDictionary dictionaryWithObject:CIDetectorAccuracyLow forKey:CIDetectorAccuracy]];
    NSArray * features = [detector featuresInImage:ciImage];
    CGFloat maxSize = 0;
    CGRect faceBounds;
    for (CIFaceFeature * feature in features) {
        CGRect bounds = feature.bounds;
        if (maxSize < bounds.size.width * bounds.size.height) {
            maxSize = bounds.size.width * bounds.size.height;
            faceBounds = CGRectMake(bounds.origin.x, self.size.height - bounds.origin.y - bounds.size.height, bounds.size.width, bounds.size.height);
        }
    }
    if (maxSize <= 0) {
        return [self thumbnailWithoutTransform:viewSize];
    }
    CGPoint faceCenter = CGPointMake((faceBounds.origin.x + faceBounds.size.width)/2,
                                     (faceBounds.origin.y + faceBounds.size.height)/2);
    CGPoint startCenter = CGPointMake(self.size.width/2, self.size.height/2);
    
    CGFloat scale = [UIImage screenScale];
    if (scale > 1.0) {
        viewSize.width  *= scale;
        viewSize.height *= scale;
    }
    
    UIImageOrientation orientation = self.imageOrientation;
    switch (orientation) {
            // zfs_2013.8.13_02
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGFloat swapValue = viewSize.width;
            viewSize.width  = viewSize.height;
            viewSize.height = swapValue;
            break;
        }
            
        default:
            break;
    }
    
    CGRect clipedFrame = [self frameToClip:viewSize];
    CGPoint origin = clipedFrame.origin;
    CGSize clipedRange = CGSizeMake(abs(origin.x), abs(origin.y));
    CGPoint vector = CGPointMake(faceCenter.x - startCenter.x, faceCenter.y - startCenter.y);
    CGPoint offset = CGPointMake(MIN(MAX(-clipedRange.width, vector.x), clipedRange.width),
                                 MIN(MAX(-clipedRange.height, vector.y), clipedRange.height));
    if (-clipedRange.width < vector.x) {
        offset.x = -offset.x;
    }
    //NSLog(@"origin=%@;vector=%@;offset=%@",NSStringFromCGPoint(origin),NSStringFromCGPoint(vector),NSStringFromCGPoint(offset));
    clipedFrame = CGRectMake(clipedFrame.origin.x + offset.x, clipedFrame.origin.y + offset.y, clipedFrame.size.width, clipedFrame.size.height);
    //NSLog(@"clipedFrame=%@",NSStringFromCGRect(clipedFrame));
    CGImageRef imageRef = CGImageCreateWithImageInRect([self CGImage], clipedFrame);
    UIImage * tImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:orientation];
    CGImageRelease(imageRef);
    return tImage;
}
#endif
// zfs_2013.8.12_02
- (UIImage *)thumbnailWithoutTransform:(CGSize)targetSize {
    
    if (targetSize.width <= 0.0 ||
        targetSize.height <= 0.0 ||
        self.size.width <= 0.0 ||
        self.size.height <= 0.0) {
        return nil;
    }
    
    // zfs_2013.8.13_01
    CGFloat scale = [UIImage screenScale];
    if (scale > 1.0) {
        targetSize.width  *= scale;
        targetSize.height *= scale;
    }
    
    // zfs_2013.8.13_01
    CGRect rect;
    CGFloat width = ceil((self.size.width / self.size.height) * targetSize.height);
    CGFloat height = ceil((self.size.height / self.size.width) * targetSize.width);
    rect.size.width = MAX(targetSize.width, width);
    rect.size.height = MAX(targetSize.height, height);
    rect.origin.x = ceil(((targetSize.width - rect.size.width) / 2.0));
    rect.origin.y = ceil(((targetSize.height - rect.size.height) / 2.0));
    
    UIImageOrientation orientation = self.imageOrientation;
    switch (orientation) {
            // zfs_2013.8.13_02
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGPoint swapPoint = rect.origin;
            CGSize  swapSize  = rect.size;
            rect.origin = CGPointMake(swapPoint.y, swapPoint.x);
            rect.size   = CGSizeMake(swapSize.height, swapSize.width);
            break;
        }
            
        default:
            break;
    }
    
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap;
    bitmap = CGBitmapContextCreate(NULL,
                                   targetSize.width,
                                   targetSize.height,
                                   8,
                                   targetSize.width * 4,
                                   colorSpaceInfo,
                                   kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpaceInfo);
    colorSpaceInfo = nil;
    CGContextDrawImage(bitmap,
                       rect,
                       self.CGImage);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    bitmap = nil;
    // zfs_2013.8.13_01
    UIImage * newImage = [UIImage imageWithCGImage:ref
                                             scale:scale
                                       orientation:orientation];
    
    CGImageRelease(ref);
    ref = nil;
    return newImage;
}

/**
 拍照时旋转90度，保存时调整回来
 */
+ (UIImage *)fixOrientation:(UIImage *)aImage {
    
    // No-op if the orientation is already correct
    if (aImage.imageOrientation == UIImageOrientationUp)
        return aImage;
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, aImage.size.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, aImage.size.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
        default:
            break;
    }
    
    switch (aImage.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, aImage.size.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             aImage.size.width,
                                             aImage.size.height,
                                             CGImageGetBitsPerComponent(aImage.CGImage), 0,
                                             CGImageGetColorSpace(aImage.CGImage),
                                             CGImageGetBitmapInfo(aImage.CGImage));
    CGContextConcatCTM(ctx, transform);
    switch (aImage.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.height, aImage.size.width), aImage.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, aImage.size.width, aImage.size.height), aImage.CGImage);
            break;
    }
    
    // And now we just create a new UIImage from the drawing context
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)scaledImageWithTransform:(CGSize)targetSize {
    
    if (targetSize.width <= 0.0 ||
        targetSize.height <= 0.0 ||
        self.size.width <= 0.0 ||
        self.size.height <= 0.0) {
        return nil;
    }
    
    if (self.size.width <= targetSize.width &&
        self.size.height <= targetSize.height) {
        if (self.imageOrientation == UIImageOrientationUp) {
            return self;
        } else {
            targetSize = self.size;
        }
    } else {
        CGFloat width = ceil((self.size.width / self.size.height) * targetSize.height);
        CGFloat height = ceil((self.size.height / self.size.width) * targetSize.width);
        targetSize.width = MIN(targetSize.width, width);
        targetSize.height = MIN(targetSize.height, height);
    }
    
    CGImageRef imageRef = self.CGImage;
    CGBitmapInfo bitmapInfo = CGImageGetBitmapInfo(imageRef);
    if (bitmapInfo == kCGImageAlphaNone) {
        bitmapInfo = kCGBitmapAlphaInfoMask & kCGImageAlphaNoneSkipLast;
    }
    
    // We need to calculate the proper transformation to make the image upright.
    // We do it in 2 steps: Rotate if Left/Right/Down, and then flip if Mirrored.
    CGAffineTransform transform = CGAffineTransformIdentity;
    
    switch (self.imageOrientation) {
        case UIImageOrientationDown:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, targetSize.width, targetSize.height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
            transform = CGAffineTransformTranslate(transform, targetSize.width, 0);
            transform = CGAffineTransformRotate(transform, M_PI_2);
            break;
            
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, 0, targetSize.height);
            transform = CGAffineTransformRotate(transform, -M_PI_2);
            break;
            
        default:
            break;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
            transform = CGAffineTransformTranslate(transform, targetSize.width, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
            transform = CGAffineTransformTranslate(transform, targetSize.height, 0);
            transform = CGAffineTransformScale(transform, -1, 1);
            break;
            
        default:
            break;
    }
    
    // Now we draw the underlying CGImage into a new context, applying the transform
    // calculated above.
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             targetSize.width,
                                             targetSize.height,
                                             CGImageGetBitsPerComponent(self.CGImage),
                                             0,
                                             CGImageGetColorSpace(self.CGImage),
                                             bitmapInfo);
    CGContextConcatCTM(ctx, transform);
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
            // Grr...
            CGContextDrawImage(ctx, CGRectMake(0, 0, targetSize.height, targetSize.width), self.CGImage);
            break;
            
        default:
            CGContextDrawImage(ctx, CGRectMake(0, 0, targetSize.width, targetSize.height), self.CGImage);
            break;
    }
    
    CGImageRef ref = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return newImage;
}

// zfs_2013.8.13_03
- (UIImage *)clippedImageInRect:(CGRect)rect {
    
    if (self.scale > 1.0) {
        rect.origin.x *= self.scale;
        rect.origin.y *= self.scale;
        rect.size.width *= self.scale;
        rect.size.height *= self.scale;
    }
    
    switch (self.imageOrientation) {
        case UIImageOrientationLeft:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRight:
        case UIImageOrientationRightMirrored:
        {
            CGRect buff = rect;
            rect.origin.x = buff.origin.y;
            rect.origin.y = buff.origin.x;
            rect.size.width = buff.size.height;
            rect.size.height = buff.size.width;
        }
            break;
            
        default:
            break;
    }
    
    CGImageRef cgImage = CGImageCreateWithImageInRect(self.CGImage, rect);
    UIImage * uiImage = [UIImage imageWithCGImage:cgImage scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(cgImage);
    return uiImage;
}

+ (UIImage *)CGThumbnail:(CGFloat)dimension fromImage:(NSString *)path {
    
    NSURL * url = [[NSURL alloc] initFileURLWithPath:path];
    CGImageSourceRef imageSource = CGImageSourceCreateWithURL((__bridge CFURLRef)url, NULL);
    if (imageSource == NULL) {
        return nil;
    }
    
    NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                      [NSNumber numberWithFloat:dimension], kCGImageSourceThumbnailMaxPixelSize,
                                      nil];
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
    CFRelease(imageSource);
    
    if (thumbnail != NULL) {
        UIImage *image = [UIImage imageWithCGImage:thumbnail];
        CFRelease(thumbnail);
        return image;
    }
    
    return nil;
}

// zfs_2013.11.07_01
+ (UIImage *)CGThumbnail:(CGFloat)dimension fromData:(NSData *)data {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)data, NULL);
    if (imageSource == NULL) {
        return nil;
    }
    
    NSDictionary *thumbnailOptions = [NSDictionary dictionaryWithObjectsAndKeys:
                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailWithTransform,
                                      (id)kCFBooleanTrue, kCGImageSourceCreateThumbnailFromImageAlways,
                                      [NSNumber numberWithFloat:dimension], kCGImageSourceThumbnailMaxPixelSize,
                                      nil];
    CGImageRef thumbnail = CGImageSourceCreateThumbnailAtIndex(imageSource, 0, (__bridge CFDictionaryRef)thumbnailOptions);
    CFRelease(imageSource);
    
    if (thumbnail != NULL) {
        UIImage *image = [UIImage imageWithCGImage:thumbnail];
        CFRelease(thumbnail);
        return image;
    }
    
    return nil;
}

- (BOOL)writeToDestination:(CGImageDestinationRef)destination
                  withType:(CFStringRef)imageType
                   quality:(CGFloat)quality
                andOptions:(NSDictionary *)options {
    NSMutableDictionary * dict = (options ?
                                  [NSMutableDictionary dictionaryWithDictionary:options] :
                                  [NSMutableDictionary dictionary]);
    [dict setValue:@(quality) forKey:(NSString*)kCGImageDestinationLossyCompressionQuality];
    
    CGImageDestinationAddImage(destination,
                               self.CGImage,
                               (__bridge CFDictionaryRef)(dict));
    return CGImageDestinationFinalize(destination);
}

- (BOOL)writeToData:(NSMutableData *)data
           withType:(CFStringRef)imageType
            quality:(CGFloat)quality
         andOptions:(NSDictionary *)options {
    CGImageDestinationRef destination = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)data,
                                                                         imageType,
                                                                         1,
                                                                         NULL);
    if (destination == NULL) {
        return NO;
    }
    BOOL success = [self writeToDestination:destination
                                   withType:imageType
                                    quality:quality
                                 andOptions:options];
    CFRelease(destination);
    destination = nil;
    return success;
}

- (BOOL)writeToFile:(NSString *)file
           withType:(CFStringRef)imageType
            quality:(CGFloat)quality
         andOptions:(NSDictionary *)options {
    //    CFURLRef urlRef = (__bridge CFURLRef)([NSURL fileURLWithPath:file]);
    
    CGImageDestinationRef destination = CGImageDestinationCreateWithURL((__bridge CFURLRef)([NSURL fileURLWithPath:file]),
                                                                        imageType,
                                                                        1,
                                                                        NULL);
    if (destination == NULL) {
        return NO;
    }
    BOOL success = [self writeToDestination:destination
                                   withType:imageType
                                    quality:quality
                                 andOptions:options];
    CFRelease(destination);
    destination = nil;
    return success;
}

- (NSData *)JPEGRepresentation:(CGFloat)quality
          saveImageOrientation:(BOOL)saveImageOrientation {
    if (!saveImageOrientation ||
        self.imageOrientation == UIImageOrientationUp) {
        return UIImageJPEGRepresentation(self, 1.0);
    }
    
    NSInteger CGImageOrientation = [UIImage CGImageOrientationFrom:self.imageOrientation];
    NSString * key = (NSString *)kCGImagePropertyOrientation;
    NSDictionary * meta = @{key : @(CGImageOrientation)};
    NSMutableData * data = [NSMutableData data];
    if ([self writeToData:data
                 withType:kUTTypeJPEG
                  quality:quality
               andOptions:meta]) {
        return data;
    } else {
        return nil;
    }
}

+ (NSInteger)CGImageOrientationFrom:(UIImageOrientation)imageOrientation {
    
    int CGImageOrientation = 1;
    switch (imageOrientation) {
        case UIImageOrientationUp:
            CGImageOrientation = 1;
            break;
        case UIImageOrientationDown:
            CGImageOrientation = 3;
            break;
        case UIImageOrientationLeft:
            CGImageOrientation = 8;
            break;
        case UIImageOrientationRight:
            CGImageOrientation = 6;
            break;
        case UIImageOrientationUpMirrored:
            CGImageOrientation = 2;
            break;
        case UIImageOrientationDownMirrored:
            CGImageOrientation = 4;
            break;
        case UIImageOrientationLeftMirrored:
            CGImageOrientation = 5;
            break;
        case UIImageOrientationRightMirrored:
            CGImageOrientation = 7;
            break;
        default:
            break;
    }
    return CGImageOrientation;
}

+ (UIImageOrientation)UIImageOrientationFrom:(NSInteger)CGImageOrientation {
    
    UIImageOrientation imageOrientation = UIImageOrientationUp;
    switch (CGImageOrientation) {
        case 1:
            imageOrientation = UIImageOrientationUp;
            break;
        case 3:
            imageOrientation = UIImageOrientationDown;
            break;
        case 8:
            imageOrientation = UIImageOrientationLeft;
            break;
        case 6:
            imageOrientation = UIImageOrientationRight;
            break;
        case 2:
            imageOrientation = UIImageOrientationUpMirrored;
            break;
        case 4:
            imageOrientation = UIImageOrientationDownMirrored;
            break;
        case 5:
            imageOrientation = UIImageOrientationLeftMirrored;
            break;
        case 7:
            imageOrientation = UIImageOrientationRightMirrored;
            break;
        default:
            break;
    }
    return imageOrientation;
}

+ (UIImage *)getOverlappedImage:(NSArray *)images {
    int randomAngel1 = (rand() % 4) + 4;
    int randomAngel2 = (rand() % 3) + 3;
    if (rand() % 2 == 0) {
        randomAngel1 = ABS(randomAngel1);
        randomAngel2 = -ABS(randomAngel2);
    } else {
        randomAngel1 = -ABS(randomAngel1);
        randomAngel2 = ABS(randomAngel2);
    }
    
    CGAffineTransform transform1 = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * (float)randomAngel1 / 180.0);
    CGAffineTransform transform2 = CGAffineTransformRotate(CGAffineTransformIdentity, M_PI * (float)randomAngel2 / 180.0);
    
    CGRect thumbnailRect = CGRectMake(0, 0, 100, 100);
    CGRect rect1 = CGRectApplyAffineTransform(thumbnailRect, transform1);
    CGRect rect2 = CGRectApplyAffineTransform(thumbnailRect, transform2);
    CGRect unionRect = CGRectUnion(rect1, rect2);
    unionRect.size.width = ceil(unionRect.size.width);
    unionRect.size.height = ceil(unionRect.size.height);
    thumbnailRect.origin = CGPointMake(-50, -50);
    
    //
    // render
    //
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             unionRect.size.width,
                                             unionRect.size.height,
                                             8,
                                             unionRect.size.width * 4,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    CGContextSetAllowsAntialiasing(ctx, true);
    CGContextTranslateCTM(ctx, unionRect.size.width / 2, unionRect.size.height / 2);
    CGContextSaveGState(ctx);
    for (NSInteger index = 0; index < images.count; index++) {
        CGAffineTransform transform = CGAffineTransformIdentity;
        if (index != images.count - 1) {
            if (index % 2 == 0) {
                transform = transform1;
            } else {
                transform = transform2;
            }
        }
        CGContextRestoreGState(ctx);
        CGContextSaveGState(ctx);
        CGContextConcatCTM(ctx, transform);
        CGContextDrawImage(ctx, thumbnailRect, [[images objectAtIndex:index] CGImage]);
    }
    CGContextRestoreGState(ctx);
    
    //
    // get render image
    //
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

+ (UIImage *)getOverlappedImage:(UIImage *)topImage withImage:(UIImage *)bottomImage {
    
    // zfs_2013.11.05_03
    topImage = [self fixOrientation:topImage];
    bottomImage = [self fixOrientation:bottomImage];
    
    CGRect rect1 = CGRectMake(0, 8, 100, 100);
    CGRect rect2 = CGRectOffset(rect1, 8, -8);
    CGRect unionRect = CGRectUnion(rect1, rect2);
    unionRect.size.width = ceil(unionRect.size.width);
    unionRect.size.height = ceil(unionRect.size.height);
    
    //
    // render
    //
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             unionRect.size.width,
                                             unionRect.size.height,
                                             8,
                                             unionRect.size.width * 4,
                                             colorSpace,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpace);
    CGContextSetFillColorWithColor(ctx, [UIColor whiteColor].CGColor);
    CGContextFillRect(ctx, rect2);
    rect2.origin.x += 2.0;
    rect2.origin.y += 2.0;
    rect2.size.width -= 4.0;
    rect2.size.height -= 4.0;
    CGContextDrawImage(ctx, rect2, bottomImage.CGImage);
    CGContextFillRect(ctx, rect1);
    rect1.origin.x += 2.0;
    rect1.origin.y += 2.0;
    rect1.size.width -= 4.0;
    rect1.size.height -= 4.0;
    CGContextDrawImage(ctx, rect1, topImage.CGImage);
    
    //
    // get render image
    //
    CGImageRef cgimg = CGBitmapContextCreateImage(ctx);
    UIImage *img = [UIImage imageWithCGImage:cgimg];
    CGContextRelease(ctx);
    CGImageRelease(cgimg);
    return img;
}

- (UIImage *)tiltSlightly:(CGFloat)angle {
    CGRect rect = CGRectMake(0.0, 0.0, self.size.width, self.size.height);
    CGAffineTransform transform = CGAffineTransformMakeRotation(angle);
    CGRect rotatedRect = CGRectApplyAffineTransform(rect, transform);
    
    CGColorSpaceRef space = CGColorSpaceCreateDeviceRGB();
    CGContextRef ctx = CGBitmapContextCreate(NULL,
                                             ceil(rotatedRect.size.width),
                                             ceil(rotatedRect.size.height),
                                             8,
                                             ceil(rotatedRect.size.width) * 4,
                                             space,
                                             kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(space);
    CGContextSetAllowsAntialiasing(ctx, YES);
    CGContextSetShouldAntialias(ctx, YES);
    CGContextSetInterpolationQuality(ctx, kCGInterpolationHigh);
    CGContextTranslateCTM(ctx,
                          +(rotatedRect.size.width * 0.5f),
                          +(rotatedRect.size.height * 0.5f));
    CGContextConcatCTM(ctx, transform);
    CGContextDrawImage(ctx,
                       CGRectMake(-self.size.width / 2.0,
                                  -self.size.height / 2.0,
                                  self.size.width,
                                  self.size.height),
                       self.CGImage);
    
    CGImageRef ref = CGBitmapContextCreateImage(ctx);
    CGContextRelease(ctx);
    
    UIImage* newImage = [UIImage imageWithCGImage:ref];
    CGImageRelease(ref);
    
    return newImage;
}

// zfs_2013.9.9_02
- (UIImage *)imageResizeTo:(CGSize)size
          withCornerRadius:(CGFloat)cornerRadius {
    
    CGFloat scale = [UIImage screenScale];
    CGSize targetSize = CGSizeMake(ceil(size.width * scale),
                                   ceil(size.height * scale));
    CGFloat targetCornerRadius = cornerRadius * scale;
    CGRect targetRect = CGRectMake(0.0,
                                   0.0,
                                   targetSize.width,
                                   targetSize.height);
    
    CGColorSpaceRef colorSpaceInfo = CGColorSpaceCreateDeviceRGB();
    CGContextRef bitmap;
    bitmap = CGBitmapContextCreate(NULL,
                                   targetSize.width,
                                   targetSize.height,
                                   8,
                                   targetSize.width * 4,
                                   colorSpaceInfo,
                                   kCGImageAlphaPremultipliedFirst | kCGBitmapByteOrder32Little);
    CGColorSpaceRelease(colorSpaceInfo);
    colorSpaceInfo = nil;
    UIBezierPath * path = [UIBezierPath bezierPathWithRoundedRect:targetRect
                                                     cornerRadius:targetCornerRadius];
    CGContextAddPath(bitmap, path.CGPath);
    CGContextClip(bitmap);
    CGContextDrawImage(bitmap,
                       targetRect,
                       self.CGImage);
    CGImageRef ref = CGBitmapContextCreateImage(bitmap);
    CGContextRelease(bitmap);
    bitmap = nil;
    
    UIImage * newImage = [UIImage imageWithCGImage:ref
                                             scale:scale
                                       orientation:UIImageOrientationUp];
    
    CGImageRelease(ref);
    ref = nil;
    return newImage;
}

// zfs_2013.11.11_03
- (UIImage *)portraitImage {
    return [UIImage fixOrientation:self];
}

+ (BOOL)CGSetQuality:(CGFloat)quality
            fromData:(NSData *)sourceData
              toData:(NSMutableData *)destData
         toImageType:(CFStringRef)imageType
         withOptions:(NSDictionary *)options {
    
    CGImageSourceRef imageSource = CGImageSourceCreateWithData((__bridge CFDataRef)sourceData, NULL);
    if (imageSource == NULL) {
        return NO;
    }
    
    CGImageDestinationRef imageDest = CGImageDestinationCreateWithData((__bridge CFMutableDataRef)destData, imageType, 1, NULL);
    if (imageDest == NULL) {
        CFRelease(imageSource);
        return NO;
    }
    
    NSMutableDictionary * dict = (options ?
                                  [NSMutableDictionary dictionaryWithDictionary:options] :
                                  [NSMutableDictionary dictionary]);
    [dict setValue:@(quality) forKey:(NSString*)kCGImageDestinationLossyCompressionQuality];
    
    CGImageDestinationAddImageFromSource(imageDest,
                                         imageSource,
                                         0,
                                         (__bridge CFDictionaryRef)(dict));
    BOOL success = CGImageDestinationFinalize(imageDest);
    
    CFRelease(imageSource);
    CFRelease(imageDest);
    
    return success;
}

- (void)blur:(CGFloat)inputRadius completion:(void (^)(UIImage *))completion {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *blurImage = nil;
        if ([UIDevice currentDevice].systemVersion.floatValue >= 7.0) {
            CIContext *cicxt = [CIContext contextWithOptions:nil];
            CIImage *inputImage = [CIImage imageWithCGImage:self.CGImage];
            CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
            if (filter) {
                [filter setValue:inputImage forKey:kCIInputImageKey];
                [filter setValue:@(inputRadius) forKey:@"inputRadius"];
                CIImage *result = [filter valueForKey:kCIOutputImageKey];
                CGFloat diff = -result.extent.origin.x;
                CGRect imageInset = CGRectInset(result.extent,
                                                diff,
                                                diff);
                CGImageRef cgImage = [cicxt createCGImage:result fromRect:imageInset];
                if (cgImage) {
                    blurImage = [UIImage imageWithCGImage:cgImage];
                    CGImageRelease(cgImage);
                }
            }
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completion) {
                completion(blurImage ?: self);
            }
        });
    });
}

@end
