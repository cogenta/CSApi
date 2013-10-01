//
//  CSActivityPoolTests.m
//  CSApi
//
//  Created by Will Harris on 30/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CSActivityPool.h"

@interface CSActivityPoolTests : SenTestCase

@end

@implementation CSActivityPoolTests

- (void)testInit
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock expect] poolHasUnusedCapacity:pool];
    pool.delegate = delegateMock;
    
    STAssertNotNil(pool, nil);
    STAssertEqualObjects(@(pool.capacity), @(3), nil);
    STAssertEqualObjects(@(pool.hasUnusedCapacity), @(YES), nil);
    STAssertEquals(pool.delegate, delegateMock, nil);

    [delegateMock verify];
}

- (void)testFill
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    for (NSUInteger i = pool.capacity; i; --i) {
        STAssertTrue(pool.hasUnusedCapacity, nil);
        [pool beginActivity:@(i)];
        STAssertEqualObjects(@(pool.capacity), @(3), nil);
    }
    
    STAssertFalse(pool.hasUnusedCapacity, nil);
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];

    pool.delegate = delegateMock;
    STAssertFalse(wasInvoked, nil);
}

- (void)testEndRequestWhenFull
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    for (NSUInteger i = pool.capacity; i; --i) {
        [pool beginActivity:@(i)];
    }
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];
    
    pool.delegate = delegateMock;
    [pool endActivity:@(1)];
    STAssertTrue(wasInvoked, nil);
}


- (void)testEndRequest
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    for (NSUInteger i = pool.capacity; i; --i) {
        [pool beginActivity:@(i)];
    }

    for (NSUInteger i = pool.capacity; i; --i) {
        [pool endActivity:@(i)];
        STAssertTrue(pool.hasUnusedCapacity, nil);
    }
}

- (void)testTriggerDelegateOnUnusedCapacityChange
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];
    pool.delegate = delegateMock;
    wasInvoked = NO;
    
    for (NSUInteger i = pool.capacity; i; --i) {
        [pool beginActivity:@(i)];
    }
    
    STAssertFalse(wasInvoked, nil);
    STAssertFalse(pool.hasUnusedCapacity, nil);
    
    [pool endActivity:@(1)];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertTrue(wasInvoked, nil);
    wasInvoked = NO;
    
    [pool endActivity:@(2)];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool beginActivity:@(4)];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool beginActivity:@(5)];
    STAssertFalse(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool endActivity:@(4)];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertTrue(wasInvoked, nil);
    wasInvoked = NO;
}

- (void)testEndUnknownRequest
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:1];
    [pool beginActivity:@"known request"];
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];
    pool.delegate = delegateMock;
    
    STAssertFalse(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool endActivity:@"unknown request"];
    
    STAssertFalse(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool endActivity:@"known request"];
    
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertTrue(wasInvoked, nil);
}

- (void)testBeginAlreadyBegunRequest
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:2];
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];
    pool.delegate = delegateMock;
    wasInvoked = NO;
    
    [pool beginActivity:@"known request"];
    [pool beginActivity:@"known request"];

    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool beginActivity:@"another request"];
    STAssertFalse(pool.hasUnusedCapacity, nil);
    STAssertFalse(wasInvoked, nil);
    
    [pool endActivity:@"known request"];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertTrue(wasInvoked, nil);
}

- (void)testOverCapacity
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    
    __block BOOL wasInvoked = NO;
    id delegateMock = [OCMockObject
                       mockForProtocol:@protocol(CSActivityPoolDelegate)];
    [[delegateMock stub]
     poolHasUnusedCapacity:[OCMArg checkWithBlock:^BOOL(id obj) {
        wasInvoked = YES;
        return obj == pool;
    }]];
    pool.delegate = delegateMock;
    wasInvoked = NO;
    
    NSUInteger capacity = pool.capacity;
    for (NSUInteger i = 0; i < capacity; ++i) {
        STAssertTrue(pool.hasUnusedCapacity, nil);
        [pool beginActivity:@(i)];
    }
    
    for (NSUInteger i = capacity; i < capacity * 2 ; ++i) {
        STAssertFalse(pool.hasUnusedCapacity, nil);
        [pool beginActivity:@(i)];
    }
    
    for (NSUInteger i = 0; i < capacity; ++i) {
        [pool endActivity:@(i)];
        STAssertFalse(pool.hasUnusedCapacity, nil);
    }

    STAssertFalse(wasInvoked, nil);

    [pool endActivity:@(capacity)];
    STAssertTrue(pool.hasUnusedCapacity, nil);
    STAssertTrue(wasInvoked, nil);
    wasInvoked = NO;
    
    for (NSUInteger i = capacity + 1; i < capacity * 2 ; ++i) {
        STAssertTrue(pool.hasUnusedCapacity, nil);
        [pool endActivity:@(i)];
        STAssertFalse(wasInvoked, nil);
    }
}

- (void)testHasActivity
{
    CSActivityPool *pool = [[CSActivityPool alloc] initWithCapacity:3];
    STAssertFalse([pool hasActivity:@(1)], nil);
    STAssertFalse([pool hasActivity:@(2)], nil);
    [pool beginActivity:@(1)];
    STAssertTrue([pool hasActivity:@(1)], nil);
    STAssertFalse([pool hasActivity:@(2)], nil);
    [pool endActivity:@(1)];
    STAssertFalse([pool hasActivity:@(1)], nil);
    STAssertFalse([pool hasActivity:@(2)], nil);
}

@end
