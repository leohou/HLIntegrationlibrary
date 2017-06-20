//
//  NSData+HL_WSUKit.m
//  HLIntegrationlibrary
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 leohou. All rights reserved.
//

#import "NSData+HL_WSUKit.h"
#import <zlib.h>
#define kChunkSize 1024

typedef enum {
    WSUCompressionModeZlib,
    WSUCompressionModeGzip,
    WSUCompressionModeRaw,
} WSUCompressionMode;

@interface NSData (zlib_private)
+ (NSData *)dataByCompressingBytes:(const void *)bytes
                            length:(NSUInteger)length
                  compressionLevel:(int)level
                              mode:(WSUCompressionMode)mode;
+ (NSData *)dataByInflatingBytes:(const void *)bytes
                          length:(NSUInteger)length
                       isRawData:(BOOL)isRawData;
@end

@implementation NSData (zlib_private)

+ (NSData *)dataByCompressingBytes:(const void *)bytes
                            length:(NSUInteger)length
                  compressionLevel:(int)level
                              mode:(WSUCompressionMode)mode {
    if (!bytes || !length) {
        return nil;
    }
    
#if defined(__LP64__) && __LP64__
    // Don't support > 32bit length for 64 bit, see note in header.
    if (length > UINT_MAX) {
        return nil;
    }
#endif
    
    if (level == Z_DEFAULT_COMPRESSION) {
        // the default value is actually outside the range, so we have to let it
        // through specifically.
    } else if (level < Z_BEST_SPEED) {
        level = Z_BEST_SPEED;
    } else if (level > Z_BEST_COMPRESSION) {
        level = Z_BEST_COMPRESSION;
    }
    
    z_stream strm;
    bzero(&strm, sizeof(z_stream));
    
    int memLevel = 8; // the default
    int windowBits = 15; // the default
    switch (mode) {
        case WSUCompressionModeZlib:
            // nothing to do
            break;
            
        case WSUCompressionModeGzip:
            windowBits += 16; // enable gzip header instead of zlib header
            break;
            
        case WSUCompressionModeRaw:
            windowBits *= -1; // Negative to mean no header.
            break;
    }
    int retCode;
    if ((retCode = deflateInit2(&strm, level, Z_DEFLATED, windowBits,
                                memLevel, Z_DEFAULT_STRATEGY)) != Z_OK) {
        // COV_NF_START - no real way to force this in a unittest (we guard all args)
        NSLog(@"Failed to init for deflate w/ level %d, error %d",level, retCode);
        return nil;
        // COV_NF_END
    }
    
    // hint the size at 1/4 the input size
    NSMutableData *result = [NSMutableData dataWithCapacity:(length/4)];
    unsigned char output[kChunkSize];
    
    // setup the input
    strm.avail_in = (unsigned int)length;
    strm.next_in = (unsigned char*)bytes;
    
    // loop to collect the data
    do {
        // update what we're passing in
        strm.avail_out = kChunkSize;
        strm.next_out = output;
        retCode = deflate(&strm, Z_FINISH);
        if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
            // COV_NF_START - no real way to force this in a unittest
            // (in inflate, we can feed bogus/truncated data to test, but an error
            // here would be some internal issue w/in zlib, and there isn't any real
            // way to test it)
            NSLog(@"Error trying to deflate some of the payload, error %d",
                  retCode);
            deflateEnd(&strm);
            return nil;
            // COV_NF_END
        }
        // collect what we got
        unsigned gotBack = kChunkSize - strm.avail_out;
        if (gotBack > 0) {
            [result appendBytes:output length:gotBack];
        }
        
    } while (retCode == Z_OK);
    
    // if the loop exits, we used all input and the stream ended
    NSAssert(strm.avail_in == 0,
             @"thought we finished deflate w/o using all input, %u bytes left",
             strm.avail_in);
    NSAssert(retCode == Z_STREAM_END,
             @"thought we finished deflate w/o getting a result of stream end, code %d",
             retCode);
    
    // clean up
    deflateEnd(&strm);
    
    return result;
} // dataByCompressingBytes:length:compressionLevel:useGzip:

+ (NSData *)dataByInflatingBytes:(const void *)bytes
                          length:(NSUInteger)length
                       isRawData:(BOOL)isRawData {
    if (!bytes || !length) {
        return nil;
    }
    
#if defined(__LP64__) && __LP64__
    // Don't support > 32bit length for 64 bit, see note in header.
    if (length > UINT_MAX) {
        return nil;
    }
#endif
    
    z_stream strm;
    bzero(&strm, sizeof(z_stream));
    
    // setup the input
    strm.avail_in = (unsigned int)length;
    strm.next_in = (unsigned char*)bytes;
    
    int windowBits = 15; // 15 to enable any window size
    if (isRawData) {
        windowBits *= -1; // make it negative to signal no header.
    } else {
        windowBits += 32; // and +32 to enable zlib or gzip header detection.
    }
    
    int retCode;
    if ((retCode = inflateInit2(&strm, windowBits)) != Z_OK) {
        // COV_NF_START - no real way to force this in a unittest (we guard all args)
        NSLog(@"Failed to init for inflate, error %d", retCode);
        return nil;
        // COV_NF_END
    }
    
    // hint the size at 4x the input size
    NSMutableData *result = [NSMutableData dataWithCapacity:(length*4)];
    unsigned char output[kChunkSize];
    
    // loop to collect the data
    do {
        // update what we're passing in
        strm.avail_out = kChunkSize;
        strm.next_out = output;
        retCode = inflate(&strm, Z_NO_FLUSH);
        if ((retCode != Z_OK) && (retCode != Z_STREAM_END)) {
            NSLog(@"Error trying to inflate some of the payload, error %d: %s",
                  retCode, strm.msg);
            inflateEnd(&strm);
            return nil;
        }
        // collect what we got
        unsigned gotBack = kChunkSize - strm.avail_out;
        if (gotBack > 0) {
            [result appendBytes:output length:gotBack];
        }
        
    } while (retCode == Z_OK);
    
    // make sure there wasn't more data tacked onto the end of a valid compressed
    // stream.
    if (strm.avail_in != 0) {
        NSLog(@"thought we finished inflate w/o using all input, %u bytes left",
              strm.avail_in);
        result = nil;
    }
    // the only way out of the loop was by hitting the end of the stream
    NSAssert(retCode == Z_STREAM_END,
             @"thought we finished inflate w/o getting a result of stream end, code %d",
             retCode);
    
    // clean up
    inflateEnd(&strm);
    
    return result;
} // dataByInflatingBytes:length:windowBits:

@end

@implementation NSData (HL_WSUKit)

+ (NSData *)dataByGzippingBytes:(const void *)bytes
                         length:(NSUInteger)length {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeGzip];
} // dataByGzippingBytes:length:

+ (NSData *)dataByGzippingData:(NSData *)data {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeGzip];
} // dataByGzippingData:

- (NSData *)dataByGzippingData {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                     mode:WSUCompressionModeGzip];
} // dataByGzippingData

+ (NSData *)dataByGzippingBytes:(const void *)bytes
                         length:(NSUInteger)length
               compressionLevel:(int)level {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:level
                                   mode:WSUCompressionModeGzip];
} // dataByGzippingBytes:length:level:

+ (NSData *)dataByGzippingData:(NSData *)data
              compressionLevel:(int)level {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:level
                                   mode:WSUCompressionModeGzip];
} // dataByGzippingData:level:

- (NSData *)dataByGzippingData:(int)level {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:level
                                     mode:WSUCompressionModeGzip];
}

#pragma mark -

+ (NSData *)dataByDeflatingBytes:(const void *)bytes
                          length:(NSUInteger)length {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeZlib];
} // dataByDeflatingBytes:length:

+ (NSData *)dataByDeflatingData:(NSData *)data {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeZlib];
} // dataByDeflatingData:

- (NSData *)dataByDeflatingData {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                     mode:WSUCompressionModeZlib];
} // dataByDeflatingData

+ (NSData *)dataByDeflatingBytes:(const void *)bytes
                          length:(NSUInteger)length
                compressionLevel:(int)level {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:level
                                   mode:WSUCompressionModeZlib];
} // dataByDeflatingBytes:length:level:

+ (NSData *)dataByDeflatingData:(NSData *)data
               compressionLevel:(int)level {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:level
                                   mode:WSUCompressionModeZlib];
} // dataByDeflatingData:level:

- (NSData *)dataByDeflatingData:(int)level {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                     mode:WSUCompressionModeZlib];
} // dataByDeflatingData:

#pragma mark -

+ (NSData *)dataByInflatingBytes:(const void *)bytes
                          length:(NSUInteger)length {
    return [self dataByInflatingBytes:bytes
                               length:length
                            isRawData:NO];
} // dataByInflatingBytes:length:

+ (NSData *)dataByInflatingData:(NSData *)data {
    return [self dataByInflatingBytes:[data bytes]
                               length:[data length]
                            isRawData:NO];
} // dataByInflatingData:

- (NSData *)dataByInflatingData {
    return [NSData dataByInflatingBytes:[self bytes]
                                 length:[self length]
                              isRawData:NO];
} // dataByInflatingData

#pragma mark -

+ (NSData *)dataByRawDeflatingBytes:(const void *)bytes
                             length:(NSUInteger)length {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeRaw];
} // dataByRawDeflatingBytes:length:

+ (NSData *)dataByRawDeflatingData:(NSData *)data {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:Z_DEFAULT_COMPRESSION
                                   mode:WSUCompressionModeRaw];
} // dataByRawDeflatingData:

- (NSData *)dataByRawDeflatingData {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:Z_DEFAULT_COMPRESSION
                                     mode:WSUCompressionModeRaw];
} // dataByRawDeflatingData

+ (NSData *)dataByRawDeflatingBytes:(const void *)bytes
                             length:(NSUInteger)length
                   compressionLevel:(int)level {
    return [self dataByCompressingBytes:bytes
                                 length:length
                       compressionLevel:level
                                   mode:WSUCompressionModeRaw];
} // dataByRawDeflatingBytes:length:compressionLevel:

+ (NSData *)dataByRawDeflatingData:(NSData *)data
                  compressionLevel:(int)level {
    return [self dataByCompressingBytes:[data bytes]
                                 length:[data length]
                       compressionLevel:level
                                   mode:WSUCompressionModeRaw];
} // dataByRawDeflatingData:compressionLevel:

- (NSData *)dataByRawDeflatingData:(int)level {
    return [NSData dataByCompressingBytes:[self bytes]
                                   length:[self length]
                         compressionLevel:level
                                     mode:WSUCompressionModeRaw];
} // dataByRawDeflatingData:compressionLevel

+ (NSData *)dataByRawInflatingBytes:(const void *)bytes
                             length:(NSUInteger)length {
    return [self dataByInflatingBytes:bytes
                               length:length
                            isRawData:YES];
} // dataByRawInflatingBytes:length:

+ (NSData *)dataByRawInflatingData:(NSData *)data {
    return [self dataByInflatingBytes:[data bytes]
                               length:[data length]
                            isRawData:YES];
} // dataByRawInflatingData:

- (NSData *)dataByRawInflatingData {
    return [NSData dataByInflatingBytes:[self bytes]
                                 length:[self length]
                              isRawData:YES];
} // dataByRawInflatingData

//data MD5
- (NSString*)md5
{
    unsigned char result[16];
    CC_MD5( self.bytes, (CC_LONG)self.length, result ); // This is the md5 call
    return [NSString stringWithFormat:
            @"%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x%02x",
            result[0], result[1], result[2], result[3],
            result[4], result[5], result[6], result[7],
            result[8], result[9], result[10], result[11],
            result[12], result[13], result[14], result[15]
            ];  
}

@end
