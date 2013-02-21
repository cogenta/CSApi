//
//  CSBasicCredential.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSBasicCredential.h"
#import "CSAuthenticator.h"
#import "CSAPI.h"
#import <objc/runtime.h>

@implementation CSBasicCredential

@synthesize username;
@synthesize password;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword
{
    self = [super init];
    if (self) {
        username = aUsername;
        password = aPassword;
    }
    return self;
}

- (id)initWithDictionary:(NSDictionary *)credential
{
    return [self initWithUsername:credential[@"username"]
                         password:credential[@"password"]];
}

+ (instancetype)credentialWithUsername:(NSString *)username
                              password:(NSString *)password
{
    return [[CSBasicCredential alloc] initWithUsername:username
                                              password:password];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s %@:%@>",
            class_getName([self class]),
            username, password];
}

@end