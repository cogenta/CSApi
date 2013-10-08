//
//  CSListItem.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListItem.h"
#import <objc/runtime.h>

@implementation CSListItem

- (id<CSAPIRequest>)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(nil, nil);
    return nil;
}

- (NSURL *)URL
{
    return nil;
}

@end

