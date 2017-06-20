//
//  NSArray+WSUKit.m
//  Pods
//
//  Created by houli on 2017/6/20.
//
//

#import "NSArray+WSUKit.h"

@implementation NSArray (WSUKit)

- (id)objectAt:(NSUInteger)index
{
    @synchronized (self) {
        NSUInteger count =[self count];
        if (index < count) {
            return [self objectAtIndex:index];
        }
        
        return nil;
    }
}

- (NSString *)toJsonString
{

    return [[NSString alloc] initWithData:[self toJSONData:self]
                                 encoding:NSUTF8StringEncoding];


}

- (NSData *)toJSONData:(id)theData{
    
    NSError *error = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:theData
                                                       options:NSJSONWritingPrettyPrinted
                                                         error:&error];
    
    if ([jsonData length] > 0 && error == nil){
        return jsonData;
    }else{
        return nil;
    }
    
}


@end
