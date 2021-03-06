//
//  CSHALRepresentation.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSHALRepresentation.h"
#import "CSAPI.h"
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
    if (user.URL) {
        json[@"_links"] = @{@"self": @{@"href": [user.URL absoluteString]}};
    }
    
    if (user.reference) {
        json[@"reference"] = user.reference;
    }
    
    if (user.meta) {
        json[@"meta"] = user.meta;
    }
    
    return [json HALResourceWithBaseURL:baseURL];
}

- (id)representMutableLike:(id<CSMutableLike>)like
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    NSMutableDictionary *links = [NSMutableDictionary dictionary];
    
    links[@"/rels/liked"] = @{@"href": [like.likedURL absoluteString]};
    
    json[@"_links"] = links;
    
    return [json HALResourceWithBaseURL:baseURL];
}

- (id)representMutableGroup:(id<CSMutableGroup>)group
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (group.URL) {
        json[@"_links"] = @{@"self": @{@"href": [group.URL absoluteString]}};
    }
    
    if (group.reference) {
        json[@"reference"] = group.reference;
    }
    
    if (group.meta) {
        json[@"meta"] = group.meta;
    }
    
    return [json HALResourceWithBaseURL:baseURL];
}

@end
