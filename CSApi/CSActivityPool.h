//
//  CSActivityPool.h
//  CSApi
//
//  Created by Will Harris on 30/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CSActivityPool;

@protocol CSActivityPoolDelegate <NSObject>

- (void)poolHasUnusedCapacity:(CSActivityPool *)pool;

@end

@interface CSActivityPool : NSObject

@property (weak, nonatomic) id<CSActivityPoolDelegate> delegate;
@property (readonly) NSUInteger capacity;
@property (readonly) BOOL hasUnusedCapacity;

- (instancetype)initWithCapacity:(NSUInteger)capacity;
- (void)beginActivity:(id)identifier;
- (void)endActivity:(id)identifier;
- (BOOL)hasActivity:(id)identifier;

@end
