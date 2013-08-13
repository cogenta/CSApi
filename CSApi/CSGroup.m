//
//  CSGroup.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSGroup.h"
#import "CSHALRepresentation.h"
#import "CSMutableLike.h"
#import "CSLike.h"
#import "CSProductListPage.h"
#import "CSCategoryListPage.h"
#import <HyperBek/HyperBek.h>
#import "CSLikeListPage.h"
#import "CSMutableGroup.h"
#import "CSSlice.h"
#import <objc/runtime.h>
#import "NSError+CSExtension.h"

@implementation CSGroup

@synthesize resource;
@synthesize URL;
@synthesize etag;

@synthesize reference;
@synthesize meta;

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

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    return [self initWithHal:aResource
                   requester:aRequester
                  credential:aCredential
                        etag:nil];
}


- (void)loadFromResource:(YBHALResource *)aResource
{
    resource = aResource;
    URL = [resource linkForRelation:@"self"].URL;
    reference = resource[@"reference"];
    meta = resource[@"meta"];
}


- (CSMutableGroup *)mutableGroup
{
    return [[CSMutableGroup alloc] initWithGroup:self];
}

- (void)loadFromMutableGroup:(CSMutableGroup *)mutableGroup
{
    reference = mutableGroup.reference;
    meta = mutableGroup.meta;
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

- (void)change:(void (^)(id<CSMutableGroup>))change
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
        CSMutableGroup *mutableGroup = [self mutableGroup];
        change(mutableGroup);
        
        id representedGroup = [mutableGroup
                               representWithRepresentation:representation];
        
        [self putURL:self.URL
                body:representedGroup
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

- (void)remove:(void (^)(BOOL, NSError *))callback
{
    [self.requester deleteURL:URL
                   credential:self.credential
                     callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(NO, error);
             return;
         }
         
         callback(YES, nil);
     }];
}


- (void)getSlice:(void (^)(id<CSSlice>, NSError *))callback
{
    [self getRelation:@"/rels/slice"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         if ( ! result) {
             callback(nil, nil);
             return;
         }
         
         callback([[CSSlice alloc] initWithHAL:result
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
