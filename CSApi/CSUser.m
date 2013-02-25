//
//  CSUser.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSUser.h"
#import "CSRequester.h"
#import <HyperBek/HyperBek.h>
#import "CSBasicCredential.h"
#import "CSMutableUser.h"
#import "CSHALRepresentation.h"
#import "NSError+CSExtension.h"
#import "CSMutableLike.h"
#import "CSLike.h"
#import "CSLikeListPage.h"
#import <objc/runtime.h>

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

- (void)getGroupsWithReference:(NSString *)reference callback:(void (^)(id<CSGroupListPage>, NSError *))callback
{
    NSError *notImplemented = [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:nil];
    callback(nil, notImplemented);
}

- (void)getGroups:(void (^)(id<CSGroupListPage>, NSError *))callback
{
    NSError *notImplemented = [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:nil];
    callback(nil, notImplemented);
}

- (void)createGroupWithChange:(void (^)(id<CSMutableGroup>))change callback:(void (^)(id<CSGroup>, NSError *))callback
{
    NSError *notImplemented = [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:nil];
    callback(nil, notImplemented);
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end


