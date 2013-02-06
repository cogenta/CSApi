//
//  CSUserDefaultsAPIStore.m
//  CSApi
//
//  Created by Will Harris on 06/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSUserDefaultsAPIStore.h"
#import "CSBasicCredential.h"
#import "CSAPI.h"
#import "CSAuthenticator.h"

@interface CSUserDefaultsAPIStore () <CSAuthenticator>

@end

@implementation CSUserDefaultsAPIStore

- (NSUserDefaults *)userDefaults
{
    return [NSUserDefaults alloc];
}

- (NSString *)userUrlKey
{
    return @"CSAPI_userURL";
}

- (NSString *)userCredentialKey
{
    return @"CSAPI_userCredential";
}

- (void)didCreateUser:(id<CSUser>)user
{
    NSUserDefaults *userDefaults = [self userDefaults];
    [userDefaults setURL:[user url] forKey:[self userUrlKey]];
    [[user credential] applyWith:self];
    [userDefaults synchronize];
}

- (NSURL *)userUrl
{
    return [[self userDefaults] URLForKey:[self userUrlKey]];
}

- (id<CSCredential>)userCredential
{
    NSDictionary *credentialDict = [[self userDefaults]
                                    objectForKey:[self userCredentialKey]];
    
    return [[CSBasicCredential alloc] initWithDictionary:credentialDict];
}

- (void)applyBasicAuthWithUsername:(NSString *)username
                          password:(NSString *)password
{
    NSDictionary *credentialDict = @{@"type": @"basic",
                                     @"username": username,
                                     @"password": password};
    [[self userDefaults] setObject:credentialDict
                            forKey:[self userCredentialKey]];
}

@end
