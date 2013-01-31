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
#import "CSBasicCredentials.h"
#import "CSHALRepresentation.h"
#import <HyperBek/HyperBek.h>

@interface CSApplication : NSObject <CSApplication>

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) YBHALResource *resource;
@property (strong, nonatomic) id<CSCredentials> credentials;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
      credentials:(id<CSCredentials>)credentials;

@end


@interface CSUser : NSObject <CSUser>

@property (strong, nonatomic) NSURL *baseUrl;

- (id)initWithHal:(YBHALResource *)resource;

@end


@implementation CSApplication

@synthesize requester;
@synthesize resource;
@synthesize credentials;
@synthesize name;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
      credentials:(id<CSCredentials>)aCredentials
{
    self = [super init];
    if (self) {
        requester = aRequester;
        resource = aResource;
        credentials = aCredentials;
        
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
           credentials:credentials
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
    id<CSCredentials> credentials = [CSBasicCredentials credentialsWithApi:self];
    [requester getURL:appUrl
          credentials:credentials
             callback:^(YBHALResource *result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        CSApplication *app = [[CSApplication alloc] initWithHAL:result
                                                      requester:requester
                                                    credentials:credentials];
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


