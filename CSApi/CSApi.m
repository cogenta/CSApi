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

@interface CSMutableUser : NSObject <CSMutableUser>

- (id)init;
- (id)initWithUser:(id<CSUser>)user;

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

- (void)createUserWithChange:(void (^)(id<CSMutableUser>))change
                    callback:(void (^)(id<CSUser>, NSError *))callback
{
    NSURL *url = [resource linkForRelation:@"/rels/users"].URL;
    NSURL *baseURL = [resource linkForRelation:@"self"].URL;
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:baseURL];
    id<CSMutableUser> user = [[CSMutableUser alloc] init];
    change(user);
    
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

- (void)createUser:(void (^)(id<CSUser>, NSError *))callback
{
    [self createUserWithChange:^(id<CSMutableUser> user) {
        // Do nothing
    } callback:callback];
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

- (CSMutableUser *)mutableUser
{
    return [[CSMutableUser alloc] initWithUser:self];
}

- (void)loadFromMutableUser:(CSMutableUser *)mutableUser
{
    reference = mutableUser.reference;
    meta = mutableUser.meta;
}

- (void)change:(void (^)(id<CSMutableUser>))change
      callback:(void (^)(BOOL, NSError *))callback
{
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:self.url];
    CSMutableUser *mutableUser = [self mutableUser];
    change(mutableUser);

    [requester putURL:url
           credential:self.credential
                 body:[mutableUser representWithRepresentation:representation]
                 etag:self.etag
             callback:^(id result, id newEtag, NSError *error)
    {
        if ( ! result) {
            callback(NO, error);
            return;
        }
        
        [self loadFromMutableUser:mutableUser];
        etag = newEtag;
        callback(YES, nil);
    }];
}

@end

@implementation CSMutableUser

@synthesize url;
@synthesize reference;
@synthesize meta;

- (id)init
{
    return [self initWithUser:nil];
}

- (id)initWithUser:(id<CSUser>)user
{
    self = [super init];
    if (self) {
        url = user.url;
        self.reference = user.reference;
        self.meta = user.meta;
    }
    return self;
}

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    id result = [representation representMutableUser:self];
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
        
        [app createUserWithChange:^(id<CSMutableUser> user) {
            // Do nothing
        } callback:^(id<CSUser> user, NSError *error)
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


