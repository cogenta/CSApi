//
//  CSRandomAccessListTests.m
//  CSApi
//
//  Created by Will Harris on 01/10/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CSRandomAccessList.h"
#import <OCMock/OCMock.h>
#import "CSAPI.h"
#import "CSProximityCache.h"
#import "CSActivityPool.h"
#import "CSDoneLaterBlockOperation.h"

BOOL
wait_until_done(void (^blk)(done_later_block_t done))
{
    __block BOOL isDone = NO;
    NSOperation *op = [CSDoneLaterBlockOperation
                       operationWithBlock:^(void (^done)())
                       {
                           blk(^(void (^blkDone)()) {
                               isDone = YES;
                               done();
                           });
                       }];
    
    NSOperationQueue *q = [[NSOperationQueue alloc] init];
    q.maxConcurrentOperationCount = 5;
    [q addOperation:op];
    
    BOOL isTimedOut = NO;
    NSDate *start = [NSDate date];
    while ( ! isDone && ! isTimedOut) {
        if ([start timeIntervalSinceNow] < -1.0) {
            isTimedOut = YES;
            continue;
        }
        [NSThread sleepForTimeInterval:0.1];
    }
    
    return isTimedOut;
}

#define WAIT_FOR(x) { if(wait_until_done(x)) { STFail(@"Time out"); } }

@interface CSRandomAccessListTests : SenTestCase
@property (strong, nonatomic) id page0mock;
@property (strong, nonatomic) CSActivityPool *pool;
@property (strong, nonatomic) CSProximityCache *cache;
@property (strong, nonatomic) CSRandomAccessList *list;
@end

@implementation CSRandomAccessListTests

- (void)setUp
{
    _page0mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    _pool = [[CSActivityPool alloc] initWithCapacity:3];
    _cache = [CSProximityCache cacheWithCapacity:3];
    _list = [[CSRandomAccessList alloc] initWithFirstPage:_page0mock
                                                     pool:_pool
                                                    cache:_cache
                                           prefetchBehind:1
                                            prefetchAhead:1];
}

- (void)testInit
{
    STAssertNotNil(_list, nil);
}

- (void)testUseCache
{
    [_cache setObject:_page0mock forPlace:0];
    id page1mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    [_cache setObject:page1mock forPlace:1];
    
    __block id page = nil;
    __block id error = @"NOT CALLED";
    WAIT_FOR(^(void (^done)()) {
        [_list getPageAtIndex:1 callback:^(id<CSListPage> aPage,
                                           NSError *anError)
        {
            page = aPage;
            error = anError;
            done();
        }];
    });
    STAssertNil(error, @"%@", error);
    STAssertEquals(page, page1mock, nil);
}

- (void)testUsePage
{
    void (^nullCb)(id<CSListPage>, NSError *) = ^(id<CSListPage> l, NSError *e)
    {
    };
    __block void (^page0cb)(id<CSListPage>, NSError*) = nullCb;
    __block void (^page1cb)(id<CSListPage>, NSError*) = nullCb;
    __block void (^page2cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:1
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page1cb = obj;
        return YES;
    }]];
    [[_page0mock expect] getPage:2
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page2cb = obj;
        return YES;
    }]];
    [[_page0mock expect] getPage:0
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page0cb = obj;
        return YES;
    }]];
    
    __block id page1 = nil;
    __block id error1 = @"NOT CALLED";
    [_list getPageAtIndex:1 callback:^(id<CSListPage> page, NSError *error) {
        page1 = page;
        error1 = error;
    }];
    
    STAssertNil(page1, nil);
    STAssertNotNil(page0cb, nil);
    STAssertNotNil(page1cb, nil);
    STAssertNotNil(page2cb, nil);
    STAssertFalse(page0cb == nullCb, nil);
    STAssertFalse(page1cb == nullCb, nil);
    STAssertFalse(page2cb == nullCb, nil);
    
    STAssertNil([_cache objectForPlace:0], nil);
    STAssertNil([_cache objectForPlace:1], nil);
    STAssertNil([_cache objectForPlace:2], nil);
    
    page0cb(_page0mock, nil);
    STAssertEquals([_cache objectForPlace:0], _page0mock, nil);
    STAssertNil(page1, nil);
    STAssertNil([_cache objectForPlace:1], nil);
    STAssertNil([_cache objectForPlace:2], nil);

    id page1mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page1cb(page1mock, nil);
    STAssertEquals([_cache objectForPlace:1], page1mock, nil);
    STAssertEquals(page1, page1mock, nil);
    
    id page2mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page2cb(page2mock, nil);
    STAssertEquals([_cache objectForPlace:2], page2mock, nil);
}

- (void)testUseCapacity
{
    [_pool beginActivity:@"filler 1"];
    [_pool beginActivity:@"filler 2"];
    [_pool beginActivity:@"filler 3"];
    
    STAssertFalse(_pool.hasUnusedCapacity,
                  @"Interal test predicate: the pool should be full");
    
    __block id page1 = nil;
    __block id error1 = @"NOT CALLED";
    [_list getPageAtIndex:1 callback:^(id<CSListPage> page, NSError *error) {
        page1 = page;
        error1 = error;
    }];
    
    void (^nullCb)(id<CSListPage>, NSError *) = ^(id<CSListPage> l, NSError *e)
    {
    };
    __block void (^page1cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:1
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page1cb = obj;
        return YES;
    }]];
    
    STAssertEquals(page1cb, nullCb, nil);
    [_pool endActivity:@"filler 1"];
    STAssertTrue(page1cb != nullCb, nil);
    
    __block void (^page2cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:2
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page2cb = obj;
        return YES;
    }]];
    
    id page1mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page1cb(page1mock, nil);
    STAssertTrue(page2cb != nullCb, nil);
    
    __block void (^page0cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:0
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page0cb = obj;
        return YES;
    }]];
    
    [_pool endActivity:@"filler 2"];
    STAssertTrue(page0cb != nullCb, nil);
    
    [_pool endActivity:@"filler 3"];
    
    id page2mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page2cb(page2mock, nil);

    id page0mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page0cb(page0mock, nil);
}

- (void)testAttach
{
    void (^nullCb)(id<CSListPage>, NSError *) = ^(id<CSListPage> l, NSError *e)
    {
    };
    __block void (^page1cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:1
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page1cb = obj;
        return YES;
    }]];
    
    [[_page0mock stub] getPage:0 callback:[OCMArg any]];
    [[_page0mock stub] getPage:2 callback:[OCMArg any]];
    
    __block id page1first = nil;
    __block id error1first = @"NOT CALLED";
    [_list getPageAtIndex:1 callback:^(id<CSListPage> page, NSError *error) {
        page1first = page;
        error1first = error;
    }];

    __block id page1second = nil;
    __block id error1second = @"NOT CALLED";
    [_list getPageAtIndex:1 callback:^(id<CSListPage> page, NSError *error) {
        page1second = page;
        error1second = error;
    }];

    id page1mock = [OCMockObject mockForProtocol:@protocol(CSListPage)];
    page1cb(page1mock, nil);
    
    STAssertEquals(page1first, page1mock, nil);
    STAssertNil(error1first, @"%@", error1first);
    STAssertEquals(page1second, page1mock, nil);
    STAssertNil(error1second, @"%@", error1second);
}

- (void)testError
{
    void (^nullCb)(id<CSListPage>, NSError *) = ^(id<CSListPage> l, NSError *e)
    {
    };
    
    __block void (^page0cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:0
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page0cb = obj;
        return YES;
    }]];
    
    __block void (^page1cb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:1
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page1cb = obj;
        return YES;
    }]];
    
    __block id page0 = @"NOT CALLED";
    __block NSError *error0 = nil;
    [_list getPageAtIndex:0 callback:^(id<CSListPage> page, NSError *error) {
        page0 = page;
        error0 = error;
    }];
    
    NSError *expectedError = [NSError errorWithDomain:@"test"
                                                 code:1234
                                             userInfo:nil];
    page0cb(nil, expectedError);
    STAssertNil(page0, @"%@", page0);
    STAssertEqualObjects(error0, expectedError, nil);
    
    __block void (^page0retrycb)(id<CSListPage>, NSError*) = nullCb;
    [[_page0mock expect] getPage:0
                        callback:[OCMArg checkWithBlock:^BOOL(id obj)
    {
        page0retrycb = obj;
        return YES;
    }]];
    
    __block id page0retry = @"NOT CALLED";
    __block NSError *error0retry = nil;
    [_list getPageAtIndex:0 callback:^(id<CSListPage> page, NSError *error) {
        page0retry = page;
        error0retry = error;
    }];
    
    page0retrycb(_page0mock, nil);
    STAssertEquals(page0retry, _page0mock, nil);
    STAssertNil(error0retry, @"%@", error0retry);
}

- (void)testAbort
{
    [_pool beginActivity:@"filler 1"];
    [_pool beginActivity:@"filler 2"];
    [_pool beginActivity:@"filler 3"];
    
    STAssertFalse(_pool.hasUnusedCapacity,
                  @"Interal test predicate: the pool should be full");
    
    __block id page0 = @"NOT CALLED";
    __block NSError *error0 = nil;
    __block id page1 = @"NOT CALLED";
    __block NSError *error1 = nil;
    __block id page2 = @"NOT CALLED";
    __block NSError *error2 = nil;
    __block id page3 = @"NOT CALLED";
    __block NSError *error3 = nil;

    [_list getPageAtIndex:0 callback:^(id<CSListPage> page, NSError *error) {
        STAssertEqualObjects(page0, @"NOT CALLED",
                             @"Callback should only be invoked once");
        page0 = page;
        error0 = error;
    }];

    STAssertEqualObjects(page0, @"NOT CALLED", nil);
    STAssertNil(error0, nil);
    STAssertEqualObjects(page1, @"NOT CALLED", nil);
    STAssertNil(error1, nil);
    STAssertEqualObjects(page2, @"NOT CALLED", nil);
    STAssertNil(error2, nil);
    STAssertEqualObjects(page3, @"NOT CALLED", nil);
    STAssertNil(error3, nil);
    
    [_list getPageAtIndex:1 callback:^(id<CSListPage> page, NSError *error) {
        STAssertEqualObjects(page1, @"NOT CALLED",
                             @"Callback should only be invoked once");

        page1 = page;
        error1 = error;
    }];
    
    STAssertEqualObjects(page0, @"NOT CALLED", nil);
    STAssertNil(error0, nil);
    STAssertEqualObjects(page1, @"NOT CALLED", nil);
    STAssertNil(error1, nil);
    STAssertEqualObjects(page2, @"NOT CALLED", nil);
    STAssertNil(error2, nil);
    STAssertEqualObjects(page3, @"NOT CALLED", nil);
    STAssertNil(error3, nil);

    [_list getPageAtIndex:2 callback:^(id<CSListPage> page, NSError *error) {
        STAssertEqualObjects(page2, @"NOT CALLED",
                             @"Callback should only be invoked once");

        page2 = page;
        error2 = error;
    }];
    
    STAssertNil(page0, @"%@", page0);
    STAssertNotNil(error0, nil);
    STAssertEqualObjects(page1, @"NOT CALLED", nil);
    STAssertNil(error1, nil);
    STAssertEqualObjects(page2, @"NOT CALLED", nil);
    STAssertNil(error2, nil);
    STAssertEqualObjects(page3, @"NOT CALLED", nil);
    STAssertNil(error3, nil);

    [_list getPageAtIndex:3 callback:^(id<CSListPage> page, NSError *error) {
        STAssertEqualObjects(page3, @"NOT CALLED",
                             @"Callback should only be invoked once");

        page3 = page;
        error3 = error;
    }];

    STAssertNil(page0, @"%@", page0);
    STAssertNotNil(error0, nil);
    STAssertNil(page1, @"%@", page0);
    STAssertNotNil(error1, nil);
    STAssertEqualObjects(page2, @"NOT CALLED", nil);
    STAssertNil(error2, nil);
    STAssertEqualObjects(page3, @"NOT CALLED", nil);
    STAssertNil(error3, nil);    
}

@end
