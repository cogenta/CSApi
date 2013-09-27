//
//  CSProximityCache.h
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^response_cb)(id result);
typedef void (^request_cb)(response_cb response);

@interface CSProximityCache : NSObject

+ (instancetype)cacheWithCapacity:(NSUInteger)capacity;
- (void)setObject:(id)obj forPlace:(NSInteger)place;
- (id)objectForPlace:(NSInteger)place;
- (void)removeObjectForPlace:(NSInteger)place;

@end
