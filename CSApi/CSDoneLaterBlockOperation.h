//
//  CSDoneLaterBlockOperation.h
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef void (^done_later_block_t)(void (^done)());

@interface CSDoneLaterBlockOperation : NSOperation

+ (CSDoneLaterBlockOperation *)operationWithBlock:(done_later_block_t)blk;

@end
