//
//  CSResourceListItem.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSResourceListItem.h"
#import <HyperBek/HyperBek.h>

@implementation CSResourceListItem

@synthesize resource;

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        resource = aResource;
    }
    return self;
}

- (NSURL *)URL
{
    return [resource linkForRelation:@"self"].URL;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(resource, nil);
}

@end

