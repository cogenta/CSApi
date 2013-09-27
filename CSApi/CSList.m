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

@interface CSList ()

@property (strong, nonatomic) NSOperationQueue *synchronizer;
@property (strong, nonatomic) NSOperationQueue *pageBackgrounder;
@property (strong, nonatomic) NSOperationQueue *backgrounder;
@property (readonly, strong) id<CSListPage> firstPage;
@property (readonly, strong) id<CSListPage> lastPage;
@property (readonly, strong) NSMutableDictionary *pages;
@property (readonly, strong) NSMutableArray *items;
@property (readonly) BOOL isLoading;

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

- (void)getRandomAccessItemAtIndex:(NSUInteger)index
                          callback:(void (^)(id<CSListItem>, NSError *))callback
{
    NSUInteger size = [self.firstPage.size unsignedIntegerValue];
    NSUInteger indexInPage = index % size;
    NSUInteger pageIndex = index / size;

    NSOperation *getPage = [CSDoneLaterBlockOperation operationWithBlock:^(void (^done)()) {
        [self.synchronizer addOperation:[NSBlockOperation blockOperationWithBlock:^{
            id<CSListPage> page = self.pages[@(pageIndex)];
            if ([page isKindOfClass:[NSOperation class]]) {
                NSOperation *duplicateOp = [NSBlockOperation blockOperationWithBlock:done];
                [duplicateOp addDependency:page];
                [_backgrounder addOperation:duplicateOp];
                return;
            }
            
            if ([page conformsToProtocol:@protocol(CSListPage)]) {
                done();
                return;
            }
            
            NSOperation *loadOp = [CSDoneLaterBlockOperation operationWithBlock:^(void (^doneLoad)()) {
                [self.firstPage getPage:pageIndex callback:^(id<CSListPage> aPage, NSError *anError) {
                    [self.synchronizer addOperation:[NSBlockOperation blockOperationWithBlock:^{
                        if (aPage) {
                            self.pages[@(pageIndex)] = aPage;
                        } else if (anError) {
                            self.pages[@(pageIndex)] = anError;
                        } else {
                            [self.pages removeObjectForKey:@(pageIndex)];
                        }
                        
                        doneLoad();
                    }]];
                }];
            }];
            
            [self.synchronizer addOperation:[NSBlockOperation blockOperationWithBlock:^{
                if ( ! [self.pages[@(pageIndex)] isKindOfClass:[NSOperation class]]) {
                    int kMaxPageCacheSize = 3;
                    if ([self.pages count] >= kMaxPageCacheSize) {
                        NSArray *keysByDistance = [[self.pages allKeys] sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
                            if ( ! [obj1 respondsToSelector:@selector(integerValue)]
                                || ! [obj2 respondsToSelector:@selector(integerValue)]) {
                                // Should never happen.
                                return [obj1 compare:obj2];
                            }
                            
                            NSInteger difference1 = [obj1 integerValue] - pageIndex;
                            NSInteger distance1 = ABS(difference1);
                            NSInteger difference2 = [obj2 integerValue] - pageIndex;
                            NSInteger distance2 = ABS(difference2);
                            
                            if (distance1 < distance2) {
                                return NSOrderedAscending;
                            } else if (distance1 > distance2) {
                                return NSOrderedDescending;
                            } else {
                                return NSOrderedSame;
                            }
                        }];
                        id furthestKey = [keysByDistance lastObject];
                        id furthestItem = self.pages[furthestKey];
                        if ([furthestItem respondsToSelector:@selector(cancel)]) {
                            [furthestItem cancel];
                        }
                        [self.pages removeObjectForKey:furthestKey];
                    }
                    self.pages[@(pageIndex)] = loadOp;
                }
                [_pageBackgrounder addOperation:loadOp];
                
                NSBlockOperation *doneOp = [NSBlockOperation blockOperationWithBlock:done];
                [doneOp addDependency:loadOp];
                [_pageBackgrounder addOperation:doneOp];

            }]];

        }]];
    }];
    
    NSOperation *getItem = [NSBlockOperation blockOperationWithBlock:^{
        __block int opId = -1;
        NSOperation *op = [NSBlockOperation blockOperationWithBlock:^{
            id page = self.pages[@(pageIndex)];
            [_backgrounder addOperation:[NSBlockOperation blockOperationWithBlock:^{
                if ([page conformsToProtocol:@protocol(CSListPage)]) {
                    callback([page items][indexInPage], nil);
                } else if ([page isKindOfClass:[NSError class]]) {
                    callback(nil, page);
                } else {
                    callback(nil, nil);
                }
            }]];
        }];
        opId = (int) op;
        [self.synchronizer addOperation:op];

    }];
    [getItem addDependency:getPage];
    
    [_backgrounder addOperation:getPage];
    [_backgrounder addOperation:getItem];
}

- (void)getSequencialItemAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSListItem>, NSError *))callback
{
    NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
        [self maybeLoadMoreForIndex:index callback:^(BOOL success, NSError *error) {
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

