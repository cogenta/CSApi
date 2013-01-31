//
//  CSBasicCredentials.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSBasicCredentials.h"
#import "CSAuthenticator.h"
#import "CSApi.h"

@implementation CSBasicCredentials

@synthesize api;

- (id)initWithApi:(CSApi *)anApi
{
    self = [super init];
    if (self) {
        api = anApi;
    }
    return self;
}

+ (instancetype)credentialsWithApi:(CSApi *)api
{
    return [[CSBasicCredentials alloc] initWithApi:api];
}

- (void)applyWith:(id<CSAuthenticator>)authenticator
{
    [authenticator applyBasicAuthWithUsername:api.username
                                     password:api.password];
}

@end