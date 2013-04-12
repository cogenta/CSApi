//
//  NSError+CSExtension.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "NSError+CSExtension.h"

@implementation NSError (CSExtension)

- (BOOL) isHttpConflict
{
    return [self.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@409];
}

- (BOOL) isHttpNotFound
{
    return [self.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@404];
}

@end

