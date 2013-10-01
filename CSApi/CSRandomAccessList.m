//
//  CSRandomAccessList.m
//  CSApi
//
//  Created by Will Harris on 01/10/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRandomAccessList.h"
#import "CSProximityCache.h"
#import "CSActivityPool.h"
#import "CSAPI.h"

NSString * const kCSRandomAccessListErrorDomain =
@"com.cogenta.simplyshop.CSRandomAccessList";
NSString * const kCSRandomAccessListKey_Index = @"kCSRandomAccessListKey_Index";
NSInteger const kCSRandomAccessListErrorCode_Abort = 100;
NSString * const CSAbortDescription = @"The operation was aborted.";

@interface CSRandomAccessList () <CSActivityPoolDelegate>

@property (strong, nonatomic) id<CSListPage> firstPage;
@property (strong, nonatomic) CSActivityPool *pool;
@property (strong, nonatomic) CSProximityCache *cache;
@property (assign, nonatomic) NSUInteger prefetchBehind;
@property (assign, nonatomic) NSUInteger prefetchAhead;
@property (strong, nonatomic) NSNumber *currentIndex;
@property (strong, nonatomic) NSNumber *lastRequestedIndex;
@property (readonly) NSNumber *nextIndexToRequest;
@property (strong, nonatomic) NSMutableDictionary *requests;

- (void)fillCapacity;

@end

@implementation CSRandomAccessList

- (instancetype)initWithFirstPage:(id<CSListPage>)firstPage
                             pool:(CSActivityPool *)pool
                            cache:(CSProximityCache *)cache
                   prefetchBehind:(NSUInteger)prefetchBehind
                    prefetchAhead:(NSUInteger)prefetchAhead
{
    self = [super init];
    if (self) {
        _firstPage = firstPage;
        _pool = pool;
        _cache = cache;
        _prefetchBehind = prefetchBehind;
        _prefetchAhead = prefetchAhead;
        _requests = [NSMutableDictionary dictionaryWithCapacity:pool.capacity];
        _pool.delegate = self;
    }
    return self;
}

- (void)getPageAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListPage>, NSError *))callback
{
    id<CSListPage> result = [_cache objectForPlace:index];
    if (result) {
        callback(result, nil);
        return;
    }
    
    self.currentIndex = @(index);
    void (^existingCallback)(id<CSListPage>, NSError *);
    existingCallback = self.requests[self.currentIndex];
    if (existingCallback) {
        self.requests[self.currentIndex] = ^(id<CSListPage> page,
                                             NSError *error)
        {
            existingCallback(page, error);
            callback(page, error);
        };
    } else {
        self.requests[self.currentIndex] = [callback copy];
        self.lastRequestedIndex = nil;
        [self fillCapacity];
    }
    
    NSUInteger low = index > _prefetchBehind ? index - _prefetchBehind : 0;
    NSUInteger high = index + _prefetchAhead;

    NSMutableDictionary *requestsToRemove = [NSMutableDictionary dictionary];
    [self.requests enumerateKeysAndObjectsUsingBlock:^(id key,
                                                       id obj,
                                                       BOOL *stop)
    {
        NSUInteger oldIndex = [key unsignedIntegerValue];
        if (oldIndex < low || oldIndex > high) {
            requestsToRemove[key] = obj;
        }
    }];

    [requestsToRemove enumerateKeysAndObjectsUsingBlock:^(id key,
                                                          id obj,
                                                          BOOL *stop)
    {
        [self.requests removeObjectForKey:key];
        void (^cb)(id<CSListPage>, NSError *) = obj;
        NSString *msg = @"Request aborted";
        NSDictionary *userInfo = @{kCSRandomAccessListKey_Index : key,
                                   NSLocalizedDescriptionKey : msg};
        NSError *error = [NSError errorWithDomain:kCSRandomAccessListErrorDomain
                                             code:kCSRandomAccessListErrorCode_Abort
                                         userInfo:userInfo];
        cb(nil, error);
    }];
}

- (void)poolHasUnusedCapacity:(CSActivityPool *)pool
{
    [self fillCapacity];
}

- (NSNumber *)nextIndexToRequest
{
    if ( ! self.currentIndex) {
        return nil;
    }
    
    if ( ! self.lastRequestedIndex) {
        return self.currentIndex;
    }
    
    NSUInteger last = [self.lastRequestedIndex unsignedIntValue];
    NSUInteger current = [self.currentIndex unsignedIntValue];
    
    NSUInteger low = current > _prefetchBehind ? current - _prefetchBehind : 0;
    NSUInteger high = current + _prefetchAhead;
    
    if (last == current) {
        NSUInteger next = last + 1;
        if (low <= next && next <= high) {
            return @(next);
        }
    }
    
    if (last > current) {
        NSInteger next = current - (last - current);
        if (low <= next && next <= high) {
            return @(next);
        }
    }
    
    if (last < current) {
        NSInteger next = current + (current - last) + 1;
        if (low <= next && next <= high) {
            return @(next);
        }
    }

    return nil;
}

- (void)fillCapacity
{
    for (NSNumber *nextIndexObj = self.nextIndexToRequest ;
         nextIndexObj && _pool.hasUnusedCapacity ;
         nextIndexObj = self.nextIndexToRequest) {
        NSUInteger nextIndex = [nextIndexObj unsignedIntValue];
        self.lastRequestedIndex = nextIndexObj;
        if ([_cache objectForPlace:nextIndex]) {
            continue;
        }
        
        if ([_pool hasActivity:nextIndexObj]) {
            continue;
        }
        
        [_pool beginActivity:nextIndexObj];
        [_firstPage getPage:nextIndex callback:^(id<CSListPage> page,
                                                 NSError *error)
        {
            if (page) {
                [_cache setObject:page forPlace:nextIndex];
            }
            
            void (^cb)(id<CSListPage>, NSError *) = _requests[nextIndexObj];
            if (cb) {
                cb(page, error);
                [_requests removeObjectForKey:nextIndexObj];
            }
            [_pool endActivity:nextIndexObj];
        }];
    }
}

@end
