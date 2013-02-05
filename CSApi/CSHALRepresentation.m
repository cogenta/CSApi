//
//  CSHALRepresentation.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSHALRepresentation.h"
#import "CSApi.h"
#import <HyperBek/HyperBek.h>

@implementation CSHALRepresentation

@synthesize baseURL;

- (id)initWithBaserURL:(NSURL *)aBaseURL
{
    self = [super init];
    if (self) {
        baseURL = aBaseURL;
    }
    return self;
}

+ (instancetype)representationWithBaseURL:(NSURL *)baseURL
{
    return [[CSHALRepresentation alloc] initWithBaserURL:baseURL];
}

- (id)representMutableUser:(id<CSMutableUser>)user
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (user.url) {
        json[@"_links"] = @{@"self": @{@"href": [user.url absoluteString]}};
    }
    
    if (user.reference) {
        json[@"reference"] = user.reference;
    }
    
    if (user.meta) {
        json[@"meta"] = user.meta;
    }
    
    return [json HALResourceWithBaseURL:baseURL];
}

@end
