//
//  CSDoneLaterBlockOperation.h
//  CSApi
//
//  Created by Will Harris on 27/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CSDoneLaterBlockOperation : NSOperation

+ (CSDoneLaterBlockOperation *)operationWithBlock:(void (^)(void (^done)()))blk;

@end
