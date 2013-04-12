//
//  NSError+CSExtension.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSError (CSExtension)

- (BOOL) isHttpConflict;
- (BOOL) isHttpNotFound;

@end
