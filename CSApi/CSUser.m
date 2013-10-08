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
#import "CSLike.h"
#import "CSLikeListPage.h"
#import "CSMutableGroup.h"
#import "CSGroup.h"
#import "CSGroupListPage.h"
#import "CSSlice.h"

@interface CSUser ()

- (void)loadFromResource:(YBHALResource *)aResource;

@end

@implementation CSUser

@synthesize reference;
@synthesize meta;

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
                  etag:(id)anEtag
{
    id<CSCredential> aCredential = nil;
    if (aResource[@"credential"]) {
        aCredential = [CSBasicCredential
                       credentialWithDictionary:aResource[@"credential"]];
    }
    
    return [self initWithResource:aResource
                        requester:aRequester
                       credential:aCredential
                             etag:anEtag];
}

- (void)loadExtraProperties
{
    reference = self.resource[@"reference"];
    meta = self.resource[@"meta"];
}

- (void)loadFromResource:(YBHALResource *)aResource
{
    self.resource = aResource;
    [self loadExtraProperties];
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
                 self.etag = etagFromPut;
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
             self.etag = etagFromGet;
             
             dispatch_async(dispatch_get_main_queue(), doPut);
         }];
    };
    
    
    if (self.etag) {
        doPut();
    } else {
        doGet();
    }
    
}

- (void)getLikes:(void (^)(id<CSLikeListPage>, NSError *))callback
{
    NSURL *likesURL = [self.resource linkForRelation:@"/rels/likes"].URL;
    [self.requester getURL:likesURL
                credential:self.credential
                  callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSLikeListPage alloc] initWithResource:result
                                                 requester:self.requester
                                                credential:self.credential],
                  nil);
     }];
}

- (void)getGroupsWithReference:(NSString *)aReference callback:(void (^)(id<CSGroupListPage>, NSError *))callback
{
    YBHALLink *groupsByReferenceLink = [self.resource linkForRelation:@"/rels/groupsbyreference"];
    NSURL *groupsURL = [groupsByReferenceLink URLWithVariables:@{@"reference": aReference}];
    groupsURL = [[NSURL URLWithString:[groupsURL absoluteString]
                       relativeToURL:self.URL] absoluteURL];
    [self.requester getURL:groupsURL
                credential:self.credential
                  callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSGroupListPage alloc] initWithResource:result
                                                  requester:self.requester
                                                 credential:self.credential],
                  nil);
     }];
}

- (void)getGroups:(void (^)(id<CSGroupListPage>, NSError *))callback
{
    NSURL *groupsURL = [self.resource linkForRelation:@"/rels/groups"].URL;
    [self.requester getURL:groupsURL
                credential:self.credential
                  callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSGroupListPage alloc] initWithResource:result
                                                  requester:self.requester
                                                 credential:self.credential],
                  nil);
     }];
}

- (void)createGroupWithChange:(void (^)(id<CSMutableGroup>))change
                     callback:(void (^)(id<CSGroup>, NSError *))callback
{
    CSMutableGroup *group = [[CSMutableGroup alloc] init];
    change(group);
    
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:self.URL];
    
    if ( ! representation) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                       @"representation is nil"};
        callback(NO, [NSError errorWithDomain:@"CSAPI"
                                         code:3
                                     userInfo:userInfo]);
        return;
    }
    
    NSURL *groupsURL = [self.resource linkForRelation:@"/rels/groups"].URL;
    id body = [group representWithRepresentation:representation];
    [self.requester postURL:groupsURL
                 credential:self.credential
                       body:body
                   callback:^(id result, id newEtag, NSError *error)
     {
         if ( ! result) {
             callback(nil, error);
             return;
         }
         
         CSGroup *group = [[CSGroup alloc] initWithResource:result
                                                  requester:self.requester
                                                 credential:self.credential];
         callback(group, nil);
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
         
         callback([[CSSlice alloc] initWithResource:result
                                          requester:self.requester
                                         credential:self.credential],
                  nil);
     }];
}

@end


