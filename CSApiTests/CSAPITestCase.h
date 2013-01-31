//
//  CSAPITestCase.h
//  
//
//  Created by Will Harris on 31/01/2013.
//
//

#import <SenTestingKit/SenTestingKit.h>

@interface CSAPITestCase : SenTestCase

- (void)waitForSemaphore: (dispatch_semaphore_t)semaphore;

- (void)callAndWait: (void (^)(void (^)()))blk;

@end
