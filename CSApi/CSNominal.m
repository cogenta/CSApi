//
//  CSNominal.m
//  CSApi
//
//  Created by Will Harris on 12/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNominal.h"
#import <HyperBek/HyperBek.h>

@interface CSNominal ()

@property (readonly) YBHALResource *resource;

@end

@implementation CSNominal

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        _resource = aResource;
    }
    return self;
}

- (NSString *)name
{
    return _resource[@"name"];
}

@end