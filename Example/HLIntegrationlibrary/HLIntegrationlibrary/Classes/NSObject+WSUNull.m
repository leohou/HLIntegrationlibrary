//
//  NSObject+WSUNull.m
//  SportEvents
//
//  Created by houli on 2017/6/20.
//  Copyright © 2017年 wesai. All rights reserved.
//

#import "NSObject+WSUNull.h"

@implementation NSObject (WSUNull)
- (BOOL)isNull
{
    if(!self || [[NSNull null] isEqual:self] || [self isEqual:Nil] || [self isEqual:NULL]) {
        return YES;
    }
    return NO;
}

- (instancetype)objectByRemovingNulls{
    
    id replaced = nil;
    const id nul = [NSNull null];
    if (nul==self) {
        
    }else if ([self isKindOfClass:[NSDictionary class]]){
        NSDictionary *dict = (NSDictionary *)self;
        replaced = [self dictionaryByRemovingNulls:dict];
    }else if ([self isKindOfClass:[NSArray class]]){
        NSArray *array = (NSArray *)self;
        replaced = [self arrayByRemovingNulls:array];
    }else{
        replaced = self;
    }
    return replaced;
}

- (NSArray *) arrayByRemovingNulls:(NSArray *)array{
    const NSMutableArray *replaced = [NSMutableArray new];
    const id nul = [NSNull null];
    
    for (int i=0; i<[array count]; i++) {
        const id object = [array objectAtIndex:i];
        
        if (object == nul){
            
        }else if ([object isKindOfClass:[NSDictionary class]]) {
            [replaced setObject:[object dictionaryByRemovingNulls:object] atIndexedSubscript:i];
        } else if ([object isKindOfClass:[NSArray class]]) {
            [replaced setObject:[object arrayByRemovingNulls:object] atIndexedSubscript:i];
        }   else {
            [replaced setObject:object atIndexedSubscript:i];
        }
    }
    return [NSArray arrayWithArray:(NSArray*)replaced];
}

- (NSDictionary *) dictionaryByRemovingNulls:(NSDictionary *)dict{
    
    const NSMutableDictionary *replaced = [NSMutableDictionary new];
    const id nul = [NSNull null];
    
    for(NSString *key in dict) {
        const id object = [dict objectForKey:key];
        if(object == nul) {
            
        } else if ([object isKindOfClass:[NSDictionary class]]) {
            [replaced setObject:[object dictionaryByRemovingNulls:object] forKey:key];
        } else if ([object isKindOfClass:[NSArray class]]) {
            [replaced setObject:[object arrayByRemovingNulls:object] forKey:key];
        } else {
            [replaced setObject:object forKey:key];
        }
    }
    return [NSDictionary dictionaryWithDictionary:(NSDictionary*)replaced];
}
@end
