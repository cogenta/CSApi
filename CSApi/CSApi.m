//
//  CSApi.m
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSApi.h"
#import "CSCredential.h"
#import "CSAuthenticator.h"
#import "CSRequester.h"
#import "CSRepresentation.h"
#import "CSBasicCredential.h"
#import "CSHALRepresentation.h"
#import "CSAPIStore.h"
#import <HyperBek/HyperBek.h>

@interface CSApplication : NSObject <CSApplication>

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) YBHALResource *resource;
@property (strong, nonatomic) id<CSCredential> credential;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end


@interface CSUser : NSObject <CSUser>

@property (strong, nonatomic) NSURL *baseUrl;
@property (strong, nonatomic) id<CSRequester> requester;

- (id)initWithHal:(YBHALResource *)resource;
- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
             etag:(id)etag;

@end


@implementation CSApplication

@synthesize requester;
@synthesize resource;
@synthesize credential;
@synthesize name;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super init];
    if (self) {
        requester = aRequester;
        resource = aResource;
        credential = aCredential;
        
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
           credential:credential
                  body:[user representWithRepresentation:representation]
              callback:^(id result, id etag, NSError *error)
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
@synthesize requester;
@synthesize credential;
@synthesize etag;

- (id)initWithHal:(YBHALResource *)resource
{
    self = [super init];
    if (self) {
        url = [resource linkForRelation:@"self"].URL;
        reference = resource[@"reference"];
        meta = resource[@"meta"];
        
        if (resource[@"credential"]) {
            credential = [CSBasicCredential
                          credentialWithDictionary:resource[@"credential"]];
        }
    }
    return self;
}

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
             etag:(id)anEtag
{
    self = [super init];
    if (self) {
        url = [resource linkForRelation:@"self"].URL;
        reference = resource[@"reference"];
        meta = resource[@"meta"];
        requester = aRequester;
        credential = aCredential;
        etag = anEtag;
    }
    return self;
}

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    id result = [representation representUser:self];
    return result;
}

- (void)save:(void (^)(BOOL, NSError *))callback
{
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:self.url];
    [requester putURL:url
           credential:self.credential
                 body:[self representWithRepresentation:representation]
                 etag:self.etag
             callback:^(id result, id newEtag, NSError *error)
    {
        if ( ! result) {
            callback(NO, error);
            return;
        }
        
        etag = newEtag;
        callback(YES, nil);
    }];
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
    id<CSCredential> credential = [CSBasicCredential credentialWithApi:self];
    [requester getURL:appUrl
           credential:credential
             callback:^(YBHALResource *result, id etag, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        CSApplication *app = [[CSApplication alloc] initWithHAL:result
                                                      requester:requester
                                                     credential:credential];
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

- (id<CSAPIStore>)store
{
    return nil;
}

- (void)getUser:(NSURL *)url
     credential:(id<CSCredential>)credential
       callback:(void (^)(id<CSUser>, NSError *))callback
{
    [[self requester] getURL:url
                  credential:credential
                    callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         CSUser *user = [[CSUser alloc] initWithHal:result
                                          requester:[self requester]
                                         credential:credential
                                               etag:etag];
         callback(user, nil);
     }];
}

- (void)login:(void (^)(id<CSUser>, NSError *))callback
{
    NSURL *storedUserURL = [[self store] userUrl];
    id<CSCredential> storedCredential = [[self store] userCredential];
    
    if (storedUserURL) {
        [self getUser:storedUserURL
           credential:storedCredential
             callback:callback];
        return;
    }
    
    [self getApplication:[NSURL URLWithString:bookmark]
                callback:^(id<CSApplication> app, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        [app createUser:[self newUser]
               callback:^(id<CSUser> user, NSError *error)
        {
            if (error) {
                callback(nil, error);
                return;
            }
            
            [[self store] didCreateUser:user];
            callback(user, nil);
        }];
    }];
}


@end


