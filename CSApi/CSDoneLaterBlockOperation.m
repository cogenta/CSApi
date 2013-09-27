//
//  CSDoneLaterBlockOperation.m
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSDoneLaterBlockOperation.h"

@interface CSDoneLaterBlockOperation ()

@property (copy, nonatomic) void (^blk)(void (^)());
@property (readonly) BOOL isExecuting;
@property (readonly) BOOL isFinished;

@end

@implementation CSDoneLaterBlockOperation

- (id)initWithBlock:(void (^)(void (^done)()))blk
{
    self = [super init];
    if (self) {
        _blk = [blk copy];
    }
    return self;
}

+ (CSDoneLaterBlockOperation *)operationWithBlock:(void (^)(void (^done)()))blk
{
    return [[CSDoneLaterBlockOperation alloc] initWithBlock:blk];
}

- (void)start
{
    [self willChangeValueForKey:@"isExecuting"];
    _isExecuting = YES;
    [self didChangeValueForKey:@"isExecuting"];
    
    _blk(^{
        [self willChangeValueForKey:@"isExecuting"];
        [self willChangeValueForKey:@"isFinished"];
        _isExecuting = NO;
        _isFinished = YES;
        [self didChangeValueForKey:@"isExecuting"];
        [self didChangeValueForKey:@"isFinished"];
    });
}

- (BOOL)isConcurrent
{
    return YES;
}

@end