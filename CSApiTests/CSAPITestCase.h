//
//  CSAPITestCase.h
//  
//
//  Created by Will Harris on 31/01/2013.
//
//

#import <SenTestingKit/SenTestingKit.h>
#import <HyperBek/HyperBek.h>

@interface CSAPITestCase : SenTestCase

- (void)waitForSemaphore: (dispatch_semaphore_t)semaphore;

- (void)callAndWait: (void (^)(void (^)()))blk;

+ (NSDictionary*)jsonForData: (NSData*)data;

- (NSDictionary*)jsonForData: (NSData*)data;

+ (YBHALResource*)resourceForJson: (NSDictionary*)json;

- (YBHALResource*)resourceForJson: (NSDictionary*)json;

- (YBHALResource*)resourceForData: (NSData*)data;

@end
