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

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    return self;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(nil, nil);
}

- (NSURL *)URL
{
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), self.URL];
}

@end

