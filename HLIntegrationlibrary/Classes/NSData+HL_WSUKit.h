//
//  NSData+HL_WSUKit.h
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CommonCrypto/CommonDigest.h>
@interface NSData (HL_WSUKit)
// NOTE: For 64bit, none of these apis handle input sizes >32bits, they will
// return nil when given such data.  To handle data of that size you really
// should be streaming it rather then doing it all in memory.

#pragma mark Gzip Compression

/// Return an autoreleased NSData w/ the result of gzipping the bytes.
//
//  Uses the default compression level.
+ (NSData *)dataByGzippingBytes:(const void *)bytes
                         length:(NSUInteger)length;

/// Return an autoreleased NSData w/ the result of gzipping the payload of |data|.
//
//  Uses the default compression level.
+ (NSData *)dataByGzippingData:(NSData *)data;
- (NSData *)dataByGzippingData;

/// Return an autoreleased NSData w/ the result of gzipping the bytes using |level| compression level.
//
// |level| can be 1-9, any other values will be clipped to that range.
+ (NSData *)dataByGzippingBytes:(const void *)bytes
                         length:(NSUInteger)length
               compressionLevel:(int)level;

/// Return an autoreleased NSData w/ the result of gzipping the payload of |data| using |level| compression level.
+ (NSData *)dataByGzippingData:(NSData *)data
              compressionLevel:(int)level;
- (NSData *)dataByGzippingData:(int)level;

#pragma mark Zlib "Stream" Compression

// NOTE: deflate is *NOT* gzip.  deflate is a "zlib" stream.  pick which one
// you really want to create.  (the inflate api will handle either)

/// Return an autoreleased NSData w/ the result of deflating the bytes.
//
//  Uses the default compression level.
+ (NSData *)dataByDeflatingBytes:(const void *)bytes
                          length:(NSUInteger)length;

/// Return an autoreleased NSData w/ the result of deflating the payload of |data|.
//
//  Uses the default compression level.
+ (NSData *)dataByDeflatingData:(NSData *)data;
- (NSData *)dataByDeflatingData;

/// Return an autoreleased NSData w/ the result of deflating the bytes using |level| compression level.
//
// |level| can be 1-9, any other values will be clipped to that range.
+ (NSData *)dataByDeflatingBytes:(const void *)bytes
                          length:(NSUInteger)length
                compressionLevel:(int)level;

/// Return an autoreleased NSData w/ the result of deflating the payload of |data| using |level| compression level.
+ (NSData *)dataByDeflatingData:(NSData *)data
               compressionLevel:(int)level;
- (NSData *)dataByDeflatingData:(int)level;

#pragma mark Uncompress of Gzip or Zlib

/// Return an autoreleased NSData w/ the result of decompressing the bytes.
//
// The bytes to decompress can be zlib or gzip payloads.
+ (NSData *)dataByInflatingBytes:(const void *)bytes
                          length:(NSUInteger)length;

/// Return an autoreleased NSData w/ the result of decompressing the payload of |data|.
//
// The data to decompress can be zlib or gzip payloads.
+ (NSData *)dataByInflatingData:(NSData *)data;
- (NSData *)dataByInflatingData;


#pragma mark "Raw" Compression Support

// NOTE: raw deflate is *NOT* gzip or deflate.  it does not include a header
// of any form and should only be used within streams here an external crc/etc.
// is done to validate the data.  The RawInflate apis can be used on data
// processed like this.

/// Return an autoreleased NSData w/ the result of *raw* deflating the bytes.
//
//  Uses the default compression level.
//  *No* header is added to the resulting data.
+ (NSData *)dataByRawDeflatingBytes:(const void *)bytes
                             length:(NSUInteger)length;

/// Return an autoreleased NSData w/ the result of *raw* deflating the payload of |data|.
//
//  Uses the default compression level.
//  *No* header is added to the resulting data.
+ (NSData *)dataByRawDeflatingData:(NSData *)data;
- (NSData *)dataByRawDeflatingData;

/// Return an autoreleased NSData w/ the result of *raw* deflating the bytes using |level| compression level.
//
// |level| can be 1-9, any other values will be clipped to that range.
//  *No* header is added to the resulting data.
+ (NSData *)dataByRawDeflatingBytes:(const void *)bytes
                             length:(NSUInteger)length
                   compressionLevel:(int)level;

/// Return an autoreleased NSData w/ the result of *raw* deflating the payload of |data| using |level| compression level.
//  *No* header is added to the resulting data.
+ (NSData *)dataByRawDeflatingData:(NSData *)data
                  compressionLevel:(int)level;
- (NSData *)dataByRawDeflatingData:(int)level;

/// Return an autoreleased NSData w/ the result of *raw* decompressing the bytes.
//
// The data to decompress, it should *not* have any header (zlib nor gzip).
+ (NSData *)dataByRawInflatingBytes:(const void *)bytes
                             length:(NSUInteger)length;

/// Return an autoreleased NSData w/ the result of *raw* decompressing the payload of |data|.
//
// The data to decompress, it should *not* have any header (zlib nor gzip).
+ (NSData *)dataByRawInflatingData:(NSData *)data;
- (NSData *)dataByRawInflatingData;

//data + md5
- (NSString*)md5;
@end
