//
//  CSActivityPool.m
//  CSApi
//
//  Created by Will Harris on 30/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSActivityPool.h"

@interface CSActivityPool ()

@property (strong, nonatomic) NSMutableSet *activities;

- (void)checkCapacity;

@end

@implementation CSActivityPool

- (instancetype)initWithCapacity:(NSUInteger)capacity
{
    self = [super init];
    if (self) {
        _capacity = capacity;
        _hasUnusedCapacity = YES;
        _activities = [NSMutableSet setWithCapacity:capacity];
    }
    return self;
}

- (void)setDelegate:(id<CSActivityPoolDelegate>)delegate
{
    [self willChangeValueForKey:@"delegate"];
    _delegate = delegate;
    [self didChangeValueForKey:@"delegate"];
    
    if (_hasUnusedCapacity) {
        [_delegate poolHasUnusedCapacity:self];
    }
}

- (void)beginActivity:(id)identifier
{
    [_activities addObject:identifier];
    [self checkCapacity];
}

- (void)endActivity:(id)identifier
{
    [_activities removeObject:identifier];
    [self checkCapacity];
}

- (void)checkCapacity
{
    self.hasUnusedCapacity = [_activities count] < _capacity;
}

- (void)setHasUnusedCapacity:(BOOL)hasUnusedCapacity
{
    if (_hasUnusedCapacity == hasUnusedCapacity) {
        return;
    }
    
    [self willChangeValueForKey:@"hasUnusedCapacty"];
    _hasUnusedCapacity = hasUnusedCapacity;
    [self didChangeValueForKey:@"hasUnusedCapacty"];
    
    if (_hasUnusedCapacity) {
        [_delegate poolHasUnusedCapacity:self];
    }
}

@end
