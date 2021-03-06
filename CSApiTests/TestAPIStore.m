//
//  TestAPIStore.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestAPIStore.h"
#import "CSAPI.h"
#import "CSBasicCredential.h"

@implementation TestAPIStore

@synthesize userUrl;
@synthesize userCredential;

- (void)resetToFirstLogin
{
    userUrl = nil;
    userCredential = nil;
}

- (void)resetWithURL:(NSURL *)URL credential:(NSDictionary *)credential
{
    userUrl = URL;
    userCredential = [CSBasicCredential credentialWithDictionary:credential];
}

- (void)didCreateUser:(id<CSUser>)user
{
    userUrl = user.URL;
    userCredential = user.credential;
}

- (NSURL *)userUrl
{
    return userUrl;
}

- (id<CSCredential>)userCredential
{
    return userCredential;
}

@end
