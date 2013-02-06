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
#import "CSRepresentable.h"
#import "CSBasicCredential.h"
#import "CSHALRepresentation.h"
#import "CSAPIStore.h"
#import <HyperBek/HyperBek.h>
#import "CSAPIRequester.h"

@interface NSError (CSExtension)

- (BOOL) isHttpConflict;

@end

@implementation NSError (CSExtension)

- (BOOL) isHttpConflict
{
    return [self.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@409];
}

@end

@interface CSApplication : NSObject <CSApplication>

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) YBHALResource *resource;
@property (strong, nonatomic) id<CSCredential> credential;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end

@interface CSMutableUser : NSObject <CSMutableUser, CSRepresentable>

- (id)init;
- (id)initWithUser:(id<CSUser>)user;

@end

@interface CSUser : NSObject <CSUser>

@property (readonly) id<CSCredential> credential;
@property (strong, nonatomic) NSURL *baseUrl;
@property (strong, nonatomic) id<CSRequester> requester;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
             etag:(id)etag;
- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
             etag:(id)etag;

- (void)loadFromResource:(YBHALResource *)resource;

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
    CSMutableUser *user = [[CSMutableUser alloc] init];
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
        
        CSUser *user = [[CSUser alloc] initWithHal:result
                                         requester:requester
                                              etag:etag];
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
        requester:(id<CSRequester>)aRequester
             etag:(id)anEtag
{
    self = [super init];
    if (self) {
        [self loadFromResource:resource];
        
        requester = aRequester;
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
        [self loadFromResource:resource];
        requester = aRequester;
        credential = aCredential;
        etag = anEtag;
    }
    return self;
}

- (void)loadFromResource:(YBHALResource *)resource
{
    url = [resource linkForRelation:@"self"].URL;
    reference = resource[@"reference"];
    meta = resource[@"meta"];
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
    
    if ( ! representation) {
        callback(NO, [NSError errorWithDomain:@"CSAPI" code:3 userInfo:@{NSLocalizedDescriptionKey: @"representation is nil"}]);
        return;
    }

    __block void (^doGet)() = ^{
        callback(NO, [NSError errorWithDomain:@"CSApi" code:0 userInfo:@{NSLocalizedDescriptionKey: @"wrong doGet called"}]);
    };
    
    void (^doPut)() = ^{
        CSMutableUser *mutableUser = [self mutableUser];
        change(mutableUser);
        
        id representedUser = [mutableUser representWithRepresentation:representation];
        
        [requester putURL:self.url
               credential:self.credential
                     body:representedUser
                     etag:self.etag
                 callback:^(id result, id etagFromPut, NSError *error)
         {
             if ( ! error) {
                 [self loadFromResource:result];
                 etag = etagFromPut;
                 callback(YES, nil);
                 return;
             }
             
             if ([error isHttpConflict]) {
                 dispatch_async(dispatch_get_main_queue(), doGet);
                 return;
             }
             
             callback(NO, error);
         }];
    };

    doGet = ^{
        [requester getURL:self.url
               credential:self.credential
                 callback:^(id result, id etagFromGet, NSError *getError)
         {
             if ( ! result) {
                 callback(false, getError);
                 return;
             }
             
             [self loadFromResource:result];
             etag = etagFromGet;
             
             dispatch_async(dispatch_get_main_queue(), doPut);
         }];
    };
    

    if (etag) {
        doPut();
    } else {
        doGet();
    }
    
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
        self.meta = [user.meta mutableCopy];
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
    return [[CSAPIRequester alloc] init];
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


