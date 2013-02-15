//
//  CSAPITestCase.m
//  
//
//  Created by Will Harris on 31/01/2013.
//
//

#import "CSAPITestCase.h"
#import "TestConstants.h"
#import "TestFixtures.h"

@implementation CSAPITestCase

- (void)waitForSemaphore:(dispatch_semaphore_t)semaphore
{
    NSDate *start = [NSDate date];
    long timedout;
    int maxTries = 16;
    double totalWait = 3.0;
    double delayInSeconds = totalWait / maxTries;
    dispatch_time_t wait_time = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    for (int tries = 0; tries < maxTries; tries++) {
        timedout = dispatch_semaphore_wait(semaphore, wait_time);
        if (! timedout) {
            break;
        }
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:delayInSeconds]];
    }
    
    NSDate *end = [NSDate date];
    STAssertFalse(timedout, @"Timed out waiting for callback: %0.2fs", [end timeIntervalSinceDate:start]);
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
    NSURL *URL = [NSURL URLWithString:kBookmark];
    YBHALResource *resource = [json HALResourceWithBaseURL:URL];
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

- (YBHALResource *)resourceForFixture:(NSString *)fixture
{
    return [self resourceForData:dataForFixture(fixture)];
}

@end
