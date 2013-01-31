//
//  CSAPITestCase.m
//  
//
//  Created by Will Harris on 31/01/2013.
//
//

#import "CSAPITestCase.h"
#import "TestConstants.h"

@implementation CSAPITestCase

- (void)waitForSemaphore:(dispatch_semaphore_t)semaphore
{
    long timedout;
    for (int tries = 0; tries < 1; tries++) {
        timedout = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    STAssertFalse(timedout, @"Timed out waiting for callback");
}

- (void)callAndWait:(void (^)(void (^done)()))blk
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^done)() = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    blk(done);
    [self waitForSemaphore:semaphore];
}

+ (NSDictionary *)jsonForData:(NSData *)data
{
    __block NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:0
                                                error:&error];
    
    return json;
}

- (NSDictionary *)jsonForData:(NSData *)data
{
    return [[self class] jsonForData:data];
}

+ (YBHALResource *)resourceForJson:(NSDictionary *)json
{
    NSURL *url = [NSURL URLWithString:kBookmark];
    YBHALResource *resource = [json HALResourceWithBaseURL:url];
    return resource;
}

- (YBHALResource *)resourceForJson:(NSDictionary *)json
{
    return [[self class] resourceForJson:json];
}

- (YBHALResource *)resourceForData:(NSData *)data
{
    NSDictionary *json = [self jsonForData:data];
    return [self resourceForJson:json];
}

@end
