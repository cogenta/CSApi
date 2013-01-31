//
//  CSApi.m
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSApi.h"
#import "CSCredentials.h"
#import "CSAuthenticator.h"
#import "CSRequester.h"
#import "CSRepresentation.h"
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

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) YBHALResource *resource;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester;

@end


@interface CSUser : NSObject <CSUser>

@property (strong, nonatomic) NSURL *baseUrl;

- (id)initWithHal:(YBHALResource *)resource;

@end

@interface CSHALRepresentation : NSObject <CSRepresentation>

@property (nonatomic, strong) NSURL *baseURL;
+ (instancetype) representationWithBaseURL:(NSURL *)baseURL;

@end

@implementation CSApplication

@synthesize requester;
@synthesize resource;
@synthesize name;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
{
    self = [super init];
    if (self) {
        requester = aRequester;
        resource = aResource;
        
        name = resource[@"name"];
    }
    return self;
}

- (void)createUser:(id<CSUser>)user
          callback:(void (^)(id<CSUser>, NSError *))callback
{
    NSURL *url = [resource linkForRelation:@"/rels/users"].URL;
    NSURL *baseURL = [resource linkForRelation:@"self"].URL;
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:baseURL];
    
    [requester postURL:url
           credentials:nil
                  body:[user representWithRepresentation:representation]
              callback:^(id result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        CSUser *user = [[CSUser alloc] initWithHal:result];
        callback(user, nil);
    }];
}

@end


@implementation CSUser

@synthesize url;
@synthesize reference;
@synthesize meta;

- (id)initWithHal:(YBHALResource *)resource
{
    self = [super init];
    if (self) {
        url = [resource linkForRelation:@"self"].URL;
        reference = resource[@"reference"];
        meta = resource[@"meta"];
    }
    return self;
}

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    id result = [representation representUser:self];
    return result;
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
        CSApplication *app = [[CSApplication alloc] initWithHAL:result
                                                      requester:requester];
        callback(app, nil);
    }];
}

- (id<CSUser>)newUser
{
    return [[CSUser alloc] init];
}

- (id)requester
{
    return nil;
}


@end


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

- (id)representUser:(id<CSUser>)user
{
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (user.url) {
        json[@"_links"] = @{@"self": [user.url absoluteString]};
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

