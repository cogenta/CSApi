//
//  CSList.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSList.h"
#import "CSListItem.h"
#import <objc/runtime.h>
#import "CSDoneLaterBlockOperation.h"
#import "CSRandomAccessList.h"
#import "CSActivityPool.h"
#import "CSProximityCache.h"

@interface CSList ()

@property (strong, nonatomic) NSOperationQueue *synchronizer;
@property (strong, nonatomic) NSOperationQueue *pageBackgrounder;
@property (strong, nonatomic) NSOperationQueue *backgrounder;
@property (readonly, strong) id<CSListPage> firstPage;
@property (readonly, strong) id<CSListPage> lastPage;
@property (readonly, strong) NSMutableDictionary *pages;
@property (readonly, strong) NSMutableArray *items;
@property (readonly) BOOL isLoading;
@property (strong, nonatomic) CSRandomAccessList *randomAccessList;

- (void)loadSequencialPage:(id<CSListPage>)page;

- (void)getSequencialItemAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSListItem>, NSError *))callback;
- (void)getRandomAccessItemAtIndex:(NSUInteger)index
                          callback:(void (^)(id<CSListItem>,
                                             NSError *))callback;

@end

@implementation CSList

@synthesize firstPage;
@synthesize lastPage;
@synthesize items;
@synthesize isLoading;

- (id)initWithPage:(CSListPage *)page
         requester:(id<CSRequester>)aRequester
        credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        firstPage = page;
        items = [NSMutableArray array];
        NSUInteger pages = [firstPage.pages unsignedIntegerValue];
        _pages = [NSMutableDictionary dictionaryWithCapacity:pages];
        _synchronizer = [[NSOperationQueue alloc] init];
        _synchronizer.maxConcurrentOperationCount = 1;
        
        _pageBackgrounder = [[NSOperationQueue alloc] init];
        _backgrounder.maxConcurrentOperationCount = 5;
        
        _backgrounder = [[NSOperationQueue alloc] init];
        _backgrounder.maxConcurrentOperationCount = 10;
        [self loadSequencialPage:firstPage];
    }
    return self;
}

- (NSUInteger)count
{
    return [firstPage count];
}

- (void)loadMoreForIndex:(NSUInteger)index
                callback:(void (^)(BOOL success, NSError *error))cb
{
    if ( ! lastPage.hasNext) {
        NSDictionary *userInfo = @{@"index": @(index),
                                   @"items": @([items count]),
                                   @"count": @([firstPage count]),
                                   @"page": lastPage.URL,
                                   NSLocalizedDescriptionKey: @"no next page"};
        NSError *outOfRange = [NSError errorWithDomain:@"CSAPI"
                                                  code:0
                                              userInfo:userInfo];
        cb(NO, outOfRange);
        return;
    }
    
    isLoading = YES;
    [lastPage getNext:^(id<CSListPage> nextPage, NSError *error) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            isLoading = NO;
            if (error) {
                cb(NO, error);
                return;
            }
            
            [self loadSequencialPage:nextPage];
            
            [self maybeLoadMoreForIndex:index callback:cb];
        }];
        [self.synchronizer addOperation:op];
    }];
}

- (void)maybeLoadMoreForIndex:(NSUInteger)index
                     callback:(void (^)(BOOL success, NSError *error))cb
{
    if (isLoading) {
        NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            [self maybeLoadMoreForIndex:index callback:cb];
        }];
        [self.synchronizer addOperation:op];
        return;
    }
    
    if ([items count] > index) {
        cb(YES, nil);
        return;
    }
    
    [self loadMoreForIndex:index callback:cb];
}

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(CSListItem *, NSError *))callback
{
    if (self.firstPage.supportsRandomAccess) {
        [self getRandomAccessItemAtIndex:index callback:callback];
    } else {
        [self getSequencialItemAtIndex:index callback:callback];
    }
}

- (CSRandomAccessList *)randomAccessList
{
    if (_randomAccessList) {
        return _randomAccessList;
    }
    
    CSProximityCache *cache = [CSProximityCache cacheWithCapacity:11];
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:2];
    _randomAccessList = [[CSRandomAccessList alloc]
                         initWithFirstPage:self.firstPage
                         pool:pool
                         cache:cache
                         prefetchBehind:2
                         prefetchAhead:2];
    return _randomAccessList;
}

- (void)getRandomAccessItemAtIndex:(NSUInteger)index
                          callback:(void (^)(id<CSListItem>,
                                             NSError *))callback
{
    
    NSUInteger size = [self.firstPage.size unsignedIntegerValue];
    NSUInteger indexInPage = index % size;
    NSUInteger pageIndex = index / size;

    [self.randomAccessList getPageAtIndex:pageIndex
                                 callback:^(id<CSListPage> page,
                                            NSError *error)
    {
        if ( ! page) {
            callback(nil, error);
            return;
        }
        
        callback(page.items[indexInPage], nil);
    }];
}

- (void)getSequencialItemAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSListItem>, NSError *))callback
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self maybeLoadMoreForIndex:index callback:^(BOOL success,
                                                     NSError *error)
        {
            if ( ! success) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    callback(nil, error);
                });
                return;
            }
            
            CSListItem *item = [items objectAtIndex:index];
            dispatch_async(dispatch_get_main_queue(), ^{
                callback(item, nil);
            });
        }];
    }];
    [self.synchronizer addOperation:op];
}

- (void)loadSequencialPage:(id<CSListPage>)page
{
    [items addObjectsFromArray:page.items];
    lastPage = page;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s firstPage.URL=%@ lastPage.URL=%@>",
            class_getName([self class]), firstPage.URL, lastPage.URL];
}

@end

