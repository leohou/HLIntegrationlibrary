//
//  NSObject+WSUNull.h
//  SportEvents
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 wesai. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSObject (WSUNull)

/**
 *@brief 是否为空
 *@return 是否为空
 *@warning nil值不能使用该方法
 */

- (BOOL)isNull;

/**
 *  去除NSNull
 *
 *  @return 返回去除了NSNull的instancetype
 */
- (instancetype)objectByRemovingNulls;

@end
