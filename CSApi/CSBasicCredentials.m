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

@synthesize username;
@synthesize password;

- (id)initWithApi:(CSApi *)api
{
    self = [super init];
    if (self) {
        username = api.username;
        password = api.password;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)credentials
{
    self = [super init];
    if (self) {
        username = credentials[@"username"];
        password = credentials[@"password"];
    }
    return self;
}

+ (instancetype)credentialsWithApi:(CSApi *)api
{
    return [[CSBasicCredentials alloc] initWithApi:api];
}

+ (instancetype)credentialsWithDictionary:(NSDictionary *)credentials
{
    return [[CSBasicCredentials alloc] initWithDictionary:credentials];
}

- (void)applyWith:(id<CSAuthenticator>)authenticator
{
    [authenticator applyBasicAuthWithUsername:username
                                     password:password];
}

@end