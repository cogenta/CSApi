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
#import <objc/runtime.h>

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

- (void)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback;

- (void)getURL:(NSURL *)URL callback:(requester_callback_t)callback;

- (void)putURL:(NSURL *)URL
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
@property (strong, nonatomic) YBHALResource *resource;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
             etag:(id)etag;
- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
             etag:(id)etag;

- (void)loadFromResource:(YBHALResource *)resource;

@end

@interface CSListItem : CSCredentialEntity <CSListItem>

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential;

- (void)getSelf:(void (^)(YBHALResource *resource, NSError *error))callback;

@end

@interface CSLinkListItem : CSListItem

- (id)initWithLink:(YBHALLink *)link
         requester:(id<CSRequester>)requester
        credential:(id<CSCredential>)credential;

@end

@interface CSResourceListItem : CSListItem

@property (readonly) YBHALResource *resource;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential;

@end

@interface CSListPage : CSCredentialEntity <CSListPage>

@property (readonly) NSURL *URL;
@property (readonly) NSURL *next;
@property (readonly) NSURL *prev;
@property (readonly) NSString *rel;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end

@interface CSRetailerListPage : CSListPage <CSRetailerListPage>

@property (readonly) id<CSRetailerList> retailerList;

@end

@interface CSLikeListPage : CSListPage <CSLikeListPage>

@property (readonly) id<CSLikeList> likeList;

@end

@interface CSList : CSCredentialEntity <CSList>

@property (readonly) id<CSListPage> firstPage;
@property (readonly) id<CSListPage> lastPage;
@property (readonly) NSMutableArray *items;
@property (readonly) BOOL isLoading;

- (id)initWithPage:(CSListPage *)page
         requester:(id<CSRequester>)requester
        credential:(id<CSCredential>)credential;

- (void)loadPage:(id<CSListPage>)page;

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListItem> item, NSError *))callback;

@end

@interface CSRetailerList : CSList <CSRetailerList>

@end

@interface CSLikeList : CSList <CSLikeList>

@end

@interface CSRetailer : CSCredentialEntity <CSRetailer, CSListItem>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential;

@end

@interface CSLike : NSObject <CSLike>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential;

@end

@interface CSMutableLike : NSObject <CSMutableLike, CSRepresentable>

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

- (void)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback
{
    [requester postURL:URL credential:credential body:body callback:callback];
}

- (void)getURL:(NSURL *)URL callback:(requester_callback_t)callback
{
    [requester getURL:URL credential:credential callback:callback];
}

- (void)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    [requester putURL:URL
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
    NSURL *URL = [resource linkForRelation:@"/rels/users"].URL;
    NSURL *baseURL = [resource linkForRelation:@"self"].URL;
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:baseURL];
    CSMutableUser *user = [[CSMutableUser alloc] init];
    if (change) {
        change(user);
    }
    
    [self postURL:URL
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

- (void)getRetailers:(void (^)(id<CSRetailerListPage> page, NSError *error))callback
{
    NSURL *URL = [resource linkForRelation:@"/rels/retailers"].URL;
    [self getURL:URL callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSRetailerListPage alloc] initWithHal:result
                                                requester:self.requester
                                               credential:self.credential],
                  nil);
     }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]),
            [resource linkForRelation:@"self"].URL];
}

@end


@implementation CSUser

@synthesize URL;
@synthesize reference;
@synthesize meta;
@synthesize etag;
@synthesize resource;

- (id)initWithHal:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
             etag:(id)anEtag
{
    id<CSCredential> aCredential = nil;
    if (aResource[@"credential"]) {
        aCredential = [CSBasicCredential
                       credentialWithDictionary:aResource[@"credential"]];
    }
    
    return [self initWithHal:aResource
                   requester:aRequester
                  credential:aCredential
                        etag:anEtag];
}

- (id)initWithHal:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
             etag:(id)anEtag
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        [self loadFromResource:aResource];
        etag = anEtag;
    }
    return self;
}

- (void)loadFromResource:(YBHALResource *)aResource
{
    resource = aResource;
    URL = [resource linkForRelation:@"self"].URL;
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
                                           representationWithBaseURL:self.URL];
    
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
        
        [self putURL:self.URL
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
        [self getURL:self.URL
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

- (void)createLikeWithChange:(void (^)(id<CSMutableLike>))change
                    callback:(void (^)(id<CSLike>, NSError *))callback
{
    CSMutableLike *like = [[CSMutableLike alloc] init];
    change(like);
    
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:self.URL];
    
    if ( ! representation) {
        callback(NO, [NSError errorWithDomain:@"CSAPI" code:3 userInfo:@{NSLocalizedDescriptionKey: @"representation is nil"}]);
        return;
    }
    
    NSURL *likesURL = [resource linkForRelation:@"/rels/likes"].URL;
    id body = [like representWithRepresentation:representation];
    [self.requester postURL:likesURL
                 credential:self.credential
                       body:body
                   callback:^(id result, id newEtag, NSError *error)
     {
         if ( ! result) {
             callback(nil, error);
             return;
         }
         
         CSLike *like = [[CSLike alloc] initWithResource:result
                                               requester:self.requester
                                              credential:self.credential];
         callback(like, nil);
     }];
}

- (void)getLikes:(void (^)(id<CSLikeListPage>, NSError *))callback
{
    NSURL *likesURL = [resource linkForRelation:@"/rels/likes"].URL;
    [self.requester getURL:likesURL
                credential:self.credential
                  callback:^(id result, id etag, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([[CSLikeListPage alloc] initWithHal:result
                                           requester:self.requester
                                          credential:self.credential],
                 nil);
    }];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end

@implementation CSMutableUser

@synthesize URL;
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
        URL = user.URL;
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
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

- (void)getUser:(NSURL *)URL
     credential:(id<CSCredential>)aCredential
       callback:(void (^)(id<CSUser>, NSError *))callback
{
    id requester = [self requester];
    [requester getURL:URL
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s bookmark=%@>",
            class_getName([self class]), bookmark];
}

@end

@implementation CSListItem

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    return self;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(nil, nil);
}

- (NSURL *)URL
{
    return nil;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), self.URL];
}

@end


@implementation CSLinkListItem

@synthesize URL;

- (id)initWithLink:(YBHALLink *)link
         requester:(id<CSRequester>)aRequester
        credential:(id<CSCredential>)aCredential;
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        URL = link.URL;
    }
    return self;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    [self getURL:URL callback:^(id result, id etag, NSError *error) {
        callback(result, error);
    }];
}

@end

@implementation CSResourceListItem

@synthesize resource;

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        resource = aResource;
    }
    return self;
}

- (NSURL *)URL
{
    return [resource linkForRelation:@"self"].URL;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(resource, nil);
}

@end

@implementation CSListPage

@synthesize count;
@synthesize items;
@synthesize URL;
@synthesize next;
@synthesize prev;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        count = [resource[@"count"] unsignedIntegerValue];
        URL = [resource linkForRelation:@"self"].URL;
        next = [resource linkForRelation:@"next"].URL;
        prev = [resource linkForRelation:@"prev"].URL;
        NSArray *resources = [resource resourcesForRelation:self.rel];
        if (resources) {
            items = [resources mapUsingBlock:^id(id obj) {
                return [[CSResourceListItem alloc] initWithResource:obj
                                                          requester:aRequester
                                                         credential:aCredential];
            }];
        } else {
            NSArray *links = [resource linksForRelation:self.rel];
            items = [links mapUsingBlock:^id(id obj) {
                return [[CSLinkListItem alloc] initWithLink:obj
                                                  requester:aRequester
                                                 credential:aCredential];
            }];
        }
    }
    return self;
}

- (NSString *)rel
{
    return @"item";
}

- (BOOL)hasNext
{
    return next != nil;
}

- (BOOL)hasPrev
{
    return prev != nil;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSListPage alloc] initWithHal:resource
                                 requester:self.requester
                                credential:self.credential];
}

- (void)getListURL:(NSURL *)aURL
          callback:(void (^)(id<CSListPage>, NSError *))callback
{
    if ( ! aURL) {
        callback(nil, nil);
        return;
    }
    
    [self getURL:aURL callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([self pageWithHal:result
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end

@implementation CSRetailerListPage

@synthesize retailerList;

- (id<CSRetailerList>)retailerList
{
    if (  ! retailerList) {
        retailerList = [[CSRetailerList alloc] initWithPage:self
                                                  requester:self.requester
                                                 credential:self.credential];
    }
    
    return retailerList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSRetailerListPage alloc] initWithHal:resource
                                         requester:self.requester
                                        credential:self.credential];
}

- (NSString *)rel
{
    return @"/rels/retailer";
}

@end

@implementation CSLikeListPage

@synthesize likeList;

- (id<CSLikeList>)likeList
{
    if (  ! likeList) {
        likeList = [[CSLikeList alloc] initWithPage:self
                                          requester:self.requester
                                         credential:self.credential];
    }
    
    return likeList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSLikeListPage alloc] initWithHal:resource
                                     requester:self.requester
                                    credential:self.credential];
}

- (NSString *)rel
{
    return @"/rels/like";
}

@end

@implementation CSList

@synthesize firstPage;
@synthesize lastPage;
@synthesize items;
@synthesize isLoading;

- (id)initWithPage:(CSListPage *)page
         requester:(id<CSRequester>)aRequester
        credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        firstPage = page;
        items = [NSMutableArray array];
        [self loadPage:firstPage];
    }
    return self;
}

- (NSUInteger)count
{
    return [firstPage count];
}

- (void)loadMoreForIndex:(NSUInteger)index
                callback:(void (^)(BOOL success, NSError *error))cb
{
    if ( ! lastPage.hasNext) {
        NSDictionary *userInfo = @{@"index": @(index),
                                   @"items": @([items count]),
                                   @"count": @([firstPage count]),
                                   @"page": lastPage.URL,
                                   NSLocalizedDescriptionKey: @"no next page"};
        NSError *outOfRange = [NSError errorWithDomain:@"CSAPI"
                                                  code:0
                                              userInfo:userInfo];
        cb(NO, outOfRange);
        return;
    }
    
    isLoading = YES;
    [lastPage getNext:^(id<CSListPage> nextPage, NSError *error) {
        if (error) {
            cb(NO, error);
            return;
        }
        
        [self loadPage:nextPage];
        
        [self maybeLoadMoreForIndex:index callback:cb];
    }];
}

- (void)maybeLoadMoreForIndex:(NSUInteger)index
                     callback:(void (^)(BOOL success, NSError *error))cb
{
    if (isLoading) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self maybeLoadMoreForIndex:index callback:cb];
        });
        return;
    }
    
    if ([items count] > index) {
        cb(YES, nil);
        return;
    }
    
    [self loadMoreForIndex:index callback:cb];
}

- (void)getItemAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSListItem>, NSError *))callback
{
    dispatch_async(dispatch_get_main_queue(), ^{
        [self maybeLoadMoreForIndex:index callback:^(BOOL success, NSError *error) {
            if ( ! success) {
                callback(nil, error);
                return;
            }
            
            CSListItem *item = [items objectAtIndex:index];
            callback(item, nil);
        }];
    });
}


- (void)loadPage:(id<CSListPage>)page
{
    [items addObjectsFromArray:page.items];
    lastPage = page;
    isLoading = NO;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s firstPage.URL=%@ lastPage.URL=%@>",
            class_getName([self class]), firstPage.URL, lastPage.URL];
}

@end

@implementation CSRetailerList

- (void)getRetailerAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSRetailer>, NSError *))callback
{
    [self getItemAtIndex:index callback:^(CSListItem *item, NSError *error) {
        if ( ! item) {
            callback(nil, error);
            return;
        }
        
        [item getSelf:^(YBHALResource *resource, NSError *error) {
            if (error) {
                callback(nil, error);
                return;
            }
            
            CSRetailer *retailer = [[CSRetailer alloc]
                                    initWithResource:resource
                                    requester:self.requester
                                    credential:self.credential];
            callback(retailer, nil);
        }];
    }];
}

@end

@implementation CSLikeList

- (void)getLikeAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSLike>, NSError *))callback
{
    [self getItemAtIndex:index callback:^(CSListItem *item, NSError *error) {
        if ( ! item) {
            callback(nil, error);
            return;
        }
        
        [item getSelf:^(YBHALResource *resource, NSError *error) {
            if (error) {
                callback(nil, error);
                return;
            }
            
            CSLike *like = [[CSLike alloc] initWithResource:resource
                                                  requester:self.requester
                                                 credential:self.credential];
            callback(like, nil);
        }];
    }];
}

@end

@implementation CSRetailer

@synthesize URL;
@synthesize name;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        URL = [resource linkForRelation:@"self"].URL;
        name = resource[@"name"];
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end


@implementation CSLike

@synthesize retailerURL;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential
{
    self = [super init];
    if (self) {
        retailerURL = [resource linkForRelation:@"/rels/retailer"].URL;
    }
    return self;
}

@end

@implementation CSMutableLike

@synthesize retailer;

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    return [representation representMutableLike:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s retailer=%@>",
            class_getName([self class]),
            self.retailer];
}

@end