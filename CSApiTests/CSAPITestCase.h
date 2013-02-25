//
//  CSAPITestCase.h
//  
//
//  Created by Will Harris on 31/01/2013.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <HyperBek/HyperBek.h>

#define CALL_AND_WAIT(blk) \
{ \
    if ([self timeoutInterval:(blk)] > 0.0) { \
        STFail(@"timed out"); \
    } \
}

@interface CSAPITestCase : SenTestCase

- (NSTimeInterval)waitForSemaphore:(dispatch_semaphore_t)semaphore;

- (void)callAndWait:(void (^)(void (^)()))blk;
- (NSTimeInterval)timeoutInterval:(void (^)(void (^)()))blk;

+ (NSDictionary*)jsonForData:(NSData*)data;
- (NSDictionary*)jsonForData:(NSData*)data;

- (NSDictionary *)jsonForFixture:(NSString *)fixture;

+ (YBHALResource*)resourceForJson:(NSDictionary*)json;
- (YBHALResource*)resourceForJson:(NSDictionary*)json;

- (YBHALResource*)resourceForData:(NSData*)data;

- (YBHALResource *)resourceForFixture:(NSString *)fixture;

@end
