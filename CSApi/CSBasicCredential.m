//
//  CSBasicCredential.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSBasicCredential.h"
#import "CSAuthenticator.h"
#import "CSApi.h"

@implementation CSBasicCredential

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

- (id)initWithDictionary:(NSDictionary *)credential
{
    self = [super init];
    if (self) {
        username = credential[@"username"];
        password = credential[@"password"];
    }
    return self;
}

+ (instancetype)credentialWithApi:(CSApi *)api
{
    return [[CSBasicCredential alloc] initWithApi:api];
}

+ (instancetype)credentialWithDictionary:(NSDictionary *)credential
{
    return [[CSBasicCredential alloc] initWithDictionary:credential];
}

- (void)applyWith:(id<CSAuthenticator>)authenticator
{
    [authenticator applyBasicAuthWithUsername:username
                                     password:password];
}

@end