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
#import "TestRequester.h"
#import <SBJson/SBJson.h>

@implementation CSAPITestCase

- (NSTimeInterval)waitForSemaphore:(dispatch_semaphore_t)semaphore
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
    if (timedout != 0) {
        return [end timeIntervalSinceDate:start];
    } else {
        return 0;
    }
}

- (NSTimeInterval)timeoutInterval:(void (^)(void (^done)()))blk
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^done)() = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    blk(done);
    
    return [self waitForSemaphore:semaphore];
}

- (void)callAndWait:(void (^)(void (^done)()))blk
{
    NSTimeInterval interval = [self timeoutInterval:blk];
    if (interval != 0) {
        STFail(@"Timed out waiting for callback: %0.2fs", interval);
    }
}

+ (NSDictionary *)jsonForData:(NSData *)data
{
    if ( ! data) {
        return nil;
    }
    
    id json = [[[SBJsonParser alloc] init] objectWithData:data];
    return json;
}

- (NSDictionary *)jsonForData:(NSData *)data
{
    return [[self class] jsonForData:data];
}

- (NSDictionary *)jsonForFixture:(NSString *)fixture
{
    return [self jsonForData:dataForFixture(fixture)];
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

- (void)addGetFixture:(NSString *)fixture requester:(TestRequester *)requester
{
    YBHALResource *resource = [self resourceForFixture:fixture];
    STAssertNotNil(resource,
                   [NSString stringWithFormat:@"could not load fixture %@",
                    fixture]);
    YBHALLink *selfLink = [resource linkForRelation:@"self"];
    STAssertNotNil(resource,
                   [NSString stringWithFormat:@"missing self link (%@)",
                    fixture]);
    NSURL *selfURL = selfLink.URL;
    STAssertNotNil(selfURL,
                   [NSString stringWithFormat:@"missing self URL (%@)",
                    fixture]);
    [requester addGetResponse:resource forURL:selfURL];
}

@end
