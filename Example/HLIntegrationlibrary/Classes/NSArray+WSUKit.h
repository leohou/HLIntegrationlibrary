//
//  NSArray+WSUKit.h
//  Pods
//
//  Created by houli on 2017/6/20.
//
//

#import <Foundation/Foundation.h>

@interface NSArray (WSUKit)

/*
 数组取值
 
 @param index  数组索引
 @return 索引对应值
 */
- (id)objectAt:(NSUInteger)index;

/*
 数组序列化成JSON字符串
 
 
 @return JSON字符串
 */
- (NSString *)toJsonString;


@end
