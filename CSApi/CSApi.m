//
//  CSApi.m
//  CSApi
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
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
#import "CSUserDefaultsAPIStore.h"
#import <NSArray+Functional.h>

@interface NSError (CSExtension)

- (BOOL) isHttpConflict;

@end

@implementation NSError (CSExtension)

- (BOOL) isHttpConflict
{
    return [self.userInfo[@"NSHTTPPropertyStatusCodeKey"] isEqual:@409];
}

@end

@interface CSCredentialEntity : NSObject

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) id<CSCredential> credential;

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential;

- (void)postURL:(NSURL *)url
           body:(id)body
       callback:(requester_callback_t)callback;

- (void)getURL:(NSURL *)url callback:(requester_callback_t)callback;

- (void)putURL:(NSURL *)url
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback;

@end

@interface CSApplication : CSCredentialEntity <CSApplication>

@property (strong, nonatomic) YBHALResource *resource;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end

@interface CSMutableUser : NSObject <CSMutableUser, CSRepresentable>

- (id)init;
- (id)initWithUser:(id<CSUser>)user;

@end

@interface CSUser : CSCredentialEntity <CSUser>

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

@interface CSLinkListItem : NSObject <CSListItem>

- (id)initWithLink:(YBHALLink *)link;

@end

@interface CSResourceListItem : NSObject <CSListItem>

- (id)initWithResource:(YBHALResource *)resource;

@end

@interface CSListPage : CSCredentialEntity <CSListPage>

@property (readonly) NSURL *next;
@property (readonly) NSURL *prev;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end

@implementation CSCredentialEntity

@synthesize requester;
@synthesize credential;

- (id)initWithRequester:(id<CSRequester>)aRequester
             credential:(id<CSCredential>)aCredential
{
    self = [super init];
    if (self) {
        requester = aRequester;
        credential = aCredential;
    }
    return self;
}

- (void)postURL:(NSURL *)url
           body:(id)body
       callback:(requester_callback_t)callback
{
    [requester postURL:url credential:credential body:body callback:callback];
}

- (void)getURL:(NSURL *)url callback:(requester_callback_t)callback
{
    [requester getURL:url credential:credential callback:callback];
}

- (void)putURL:(NSURL *)url
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    [requester putURL:url
           credential:credential
                 body:body
                 etag:etag
             callback:callback];
}

@end

@implementation CSApplication

@synthesize resource;
@synthesize name;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester
                         credential:aCredential];
    if (self) {
        resource = aResource;
        
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
    if (change) {
        change(user);
    }
    
    [self postURL:url
             body:[user representWithRepresentation:representation]
         callback:^(id result, id etag, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        CSUser *user = [[CSUser alloc] initWithHal:result
                                         requester:self.requester
                                              etag:etag];
        callback(user, nil);
    }];
}

- (void)getRetailers:(void (^)(id<CSListPage> page, NSError *error))callback
{
    NSURL *url = [resource linkForRelation:@"/rels/retailers"].URL;
    [self getURL:url callback:^(YBHALResource *result, id etag, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([[CSListPage alloc] initWithHal:result
                                       requester:self.requester
                                      credential:self.credential],
                 nil);
    }];
}

@end


@implementation CSUser

@synthesize url;
@synthesize reference;
@synthesize meta;
@synthesize etag;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
             etag:(id)anEtag
{
    id<CSCredential> aCredential = nil;
    if (resource[@"credential"]) {
        aCredential = [CSBasicCredential
                       credentialWithDictionary:resource[@"credential"]];
    }
    
    return [self initWithHal:resource
                   requester:aRequester
                  credential:aCredential
                        etag:anEtag];
}

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
             etag:(id)anEtag
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        [self loadFromResource:resource];
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
        
        id representedUser = [mutableUser
                              representWithRepresentation:representation];
        
        [self putURL:self.url
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
        [self getURL:self.url
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

@interface CSAPI ()

- (id<CSRequester>) requester;

@end

@implementation CSAPI

@synthesize bookmark;
@synthesize credential;

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword
{
    self = [super init];
    if (self) {
        bookmark = aBookmark;
        credential = [CSBasicCredential credentialWithUsername:aUsername
                                                      password:aPassword];
    }
    return self;
}

+ (instancetype)apiWithBookmark:(NSString *)bookmark
                       username:(NSString *)username
                       password:(NSString *)password
{
    return [[CSAPI alloc] initWithBookmark:bookmark
                                  username:username
                                  password:password];
}

- (void)getApplication:(void (^)(id<CSApplication> app, NSError *error))callback
{
    id<CSRequester> requester = [self requester];
    [requester getURL:[NSURL URLWithString:bookmark]
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
    return [[CSUserDefaultsAPIStore alloc] initWithBookmark:bookmark];
}

- (void)getUser:(NSURL *)url
     credential:(id<CSCredential>)aCredential
       callback:(void (^)(id<CSUser>, NSError *))callback
{
    id requester = [self requester];
    [requester getURL:url
           credential:aCredential
             callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         CSUser *user = [[CSUser alloc] initWithHal:result
                                          requester:requester
                                         credential:aCredential
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
    
    [self getApplication:^(id<CSApplication> app, NSError *error)
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

@implementation CSLinkListItem

@synthesize URL;

- (id)initWithLink:(YBHALLink *)link
{
    self = [super init];
    if (self) {
        URL = link.URL;
    }
    return self;
}

@end

@implementation CSResourceListItem

@synthesize URL;

- (id)initWithResource:(YBHALResource *)resource
{
    self = [super init];
    if (self) {
        URL = [resource linkForRelation:@"self"].URL;
    }
    return self;
}

@end

@implementation CSListPage

@synthesize count;
@synthesize items;
@synthesize next;
@synthesize prev;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        count = [resource[@"count"] unsignedIntegerValue];
        next = [resource linkForRelation:@"next"].URL;
        prev = [resource linkForRelation:@"prev"].URL;
        NSArray *resources = [resource resourcesForRelation:@"/rels/retailer"];
        if (resources) {
            items = [resources mapUsingBlock:^id(id obj) {
                return [[CSResourceListItem alloc] initWithResource:obj];
            }];
        } else {
            NSArray *links = [resource linksForRelation:@"/rels/retailer"];
            items = [links mapUsingBlock:^id(id obj) {
                return [[CSLinkListItem alloc] initWithLink:obj];
            }];
        }
    }
    return self;
}

- (BOOL)hasNext
{
    return next != nil;
}

- (BOOL)hasPrev
{
    return prev != nil;
}

- (void)getListURL:(NSURL *)url
          callback:(void (^)(id<CSListPage>, NSError *))callback
{
    if ( ! url) {
        callback(nil, nil);
        return;
    }
    
    [self getURL:url callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSListPage alloc] initWithHal:result
                                        requester:self.requester
                                       credential:self.credential],
                  nil);
     }];
}

- (void)getNext:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getListURL:next callback:callback];
}

- (void)getPrev:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getListURL:prev callback:callback];
}

@end




