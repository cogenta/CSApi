//
//  CSApi.m
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSApi.h"
#import <HyperBek/HyperBek.h>

@interface BasicCredentials : NSObject <CSCredentials>

@property (nonatomic, weak) CSApi *api;
- (id)initWithApi:(CSApi *)api;

+ (instancetype) credentialsWithApi:(CSApi *)api;

@end

@implementation BasicCredentials

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
    return [[BasicCredentials alloc] initWithApi:api];
}

- (void)applyWith:(id<CSAuthenticator>)authenticator
{
    [authenticator applyBasicAuthWithUsername:api.username
                                     password:api.password];
}

@end


@interface CSApplication : NSObject <CSApplication>

- (id)initWithHAL:(YBHALResource *)resource;

@end

@implementation CSApplication

@synthesize name;

- (id)initWithHAL:(YBHALResource *)resource
{
    self = [super init];
    if (self) {
        name = resource[@"name"];
    }
    return self;
}

@end

@interface CSApi ()

- (id<CSRequester>) requester;

@end

@implementation CSApi

@synthesize bookmark;
@synthesize username;
@synthesize password;

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword
{
    self = [super init];
    if (self) {
        bookmark = aBookmark;
        username = aUsername;
        password = aPassword;
    }
    return self;
}

- (void)getApplication:(NSURL *)appUrl
              callback:(void (^)(id<CSApplication> app, NSError *error))callback
{
    id<CSRequester> requester = [self requester];
    [requester getURL:appUrl
          credentials:[BasicCredentials credentialsWithApi:self]
             callback:^(YBHALResource *result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        CSApplication *app = [[CSApplication alloc] initWithHAL:result];
        callback(app, nil);
    }];
}

- (id)requester
{
    return nil;
}


@end

