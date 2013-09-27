//
//  CSProximityCacheTests.m
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "CSProximityCache.h"

#define CSAssertNil(v) \
{ id _v=(v);if (_v != nil) { STFail(@"" #v " should be nil, not %@", _v); } }

@interface CSProximityCacheTests : SenTestCase

@end

@implementation CSProximityCacheTests

- (void)testAssignment
{
    CSProximityCache *cache = [CSProximityCache cacheWithCapacity:3];
    CSAssertNil([cache objectForPlace:1]);
    CSAssertNil([cache objectForPlace:2]);
    CSAssertNil([cache objectForPlace:3]);

    [cache setObject:@"one" forPlace:1];
    
    STAssertEqualObjects([cache objectForPlace:1], @"one", nil);
    CSAssertNil([cache objectForPlace:2]);
    CSAssertNil([cache objectForPlace:3]);

    [cache setObject:@"two" forPlace:2];
    STAssertEqualObjects([cache objectForPlace:1], @"one", nil);
    STAssertEqualObjects([cache objectForPlace:2], @"two", nil);
    CSAssertNil([cache objectForPlace:3]);
}

- (void)testRemoval
{
    CSProximityCache *cache = [CSProximityCache cacheWithCapacity:3];
    [cache setObject:@"one" forPlace:1];
    [cache setObject:@"two" forPlace:2];
    [cache removeObjectForPlace:1];
    
    CSAssertNil([cache objectForPlace:1]);
    STAssertEqualObjects([cache objectForPlace:2], @"two", nil);
    CSAssertNil([cache objectForPlace:3]);
}

- (void)testReplacement
{
    CSProximityCache *cache = [CSProximityCache cacheWithCapacity:3];
    [cache setObject:@"one" forPlace:1];
    [cache setObject:@"two" forPlace:2];
    [cache setObject:@"three" forPlace:3];
    [cache setObject:@"TWO" forPlace:2];
    
    STAssertEqualObjects([cache objectForPlace:1], @"one", nil);
    STAssertEqualObjects([cache objectForPlace:2], @"TWO", nil);
    STAssertEqualObjects([cache objectForPlace:3], @"three", nil);
}

- (void)testOverflow
{
    CSProximityCache *cache = [CSProximityCache cacheWithCapacity:3];
    [cache setObject:@"ten" forPlace:10];
    [cache setObject:@"twenty" forPlace:20];
    [cache setObject:@"thirty" forPlace:30];

    STAssertEqualObjects([cache objectForPlace:10], @"ten", nil);
    CSAssertNil([cache objectForPlace:15]);
    STAssertEqualObjects([cache objectForPlace:20], @"twenty", nil);
    STAssertEqualObjects([cache objectForPlace:30], @"thirty", nil);
    
    [cache setObject:@"fifteen" forPlace:15];

    STAssertEqualObjects([cache objectForPlace:10], @"ten", nil);
    STAssertEqualObjects([cache objectForPlace:15], @"fifteen", nil);
    STAssertEqualObjects([cache objectForPlace:20], @"twenty", nil);
    CSAssertNil([cache objectForPlace:30]);
    
    [cache setObject:@"twenty-one" forPlace:21];

    CSAssertNil([cache objectForPlace:10]);
    STAssertEqualObjects([cache objectForPlace:15], @"fifteen", nil);
    STAssertEqualObjects([cache objectForPlace:20], @"twenty", nil);
    STAssertEqualObjects([cache objectForPlace:21], @"twenty-one", nil);
    CSAssertNil([cache objectForPlace:30]);
}

@end
