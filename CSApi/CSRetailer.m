//
//  CSRetailer.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailer.h"
#import <HyperBek/HyperBek.h>
#import <objc/runtime.h>

@implementation CSRetailer

@synthesize URL;
@synthesize name;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        URL = [resource linkForRelation:@"self"].URL;
        name = resource[@"name"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end

