//
//  CSNarrow.m
//  CSApi
//
//  Created by Will Harris on 08/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNarrow.h"
#import "CSSlice.h"
#import "CSRetailer.h"
#import "CSCategory.h"
#import "CSNominal.h"
#import <HyperBek/HyperBek.h>

@interface CSNarrow ()
@property (strong, nonatomic) YBHALResource *resource;
@end

@implementation CSNarrow

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        self.resource = resource;
    }
    return self;
}

- (NSString *)title
{
    return self.resource[@"title"];
}

- (NSURL *)sliceURL
{
    return [self URLForRelation:@"/rels/slice"
                      arguments:nil
                       resource:self.resource];
}

- (void)getSlice:(void (^)(id<CSSlice> result, NSError *error))callback
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

- (NSURL *)narrowsByRetailerURL
{
    return [self URLForRelation:@"/rels/narrowsbyretailer"
                      arguments:nil
                       resource:self.resource];
}

- (void)getNarrowsByRetailer:(void (^)(id<CSRetailer> result,
                                       NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbyretailer"
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
         
         callback([[CSRetailer alloc] initWithResource:result
                                             requester:self.requester
                                            credential:self.credential],
                  nil);
     }];
}

- (NSURL *)narrowsByCategoryURL
{
    return [self URLForRelation:@"/rels/narrowsbycategory"
                      arguments:nil
                       resource:self.resource];
}

- (void)getNarrowsByCategory:(void (^)(id<CSCategory> result,
                                       NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbycategory"
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
         
         callback([[CSCategory alloc] initWithHAL:result
                                        requester:self.requester
                                       credential:self.credential],
                  nil);
     }];
}

- (NSURL *)narrowsByAuthorURL
{
    return [self URLForRelation:@"/rels/narrowsbyauthor"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)narrowsByCoverTypeURL
{
    return [self URLForRelation:@"/rels/narrowsbycovertype"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)narrowsByManufacturerURL
{
    return [self URLForRelation:@"/rels/narrowsbymanufacturer"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)narrowsBySoftwarePlatformURL
{
    return [self URLForRelation:@"/rels/narrowsbysoftwareplatform"
                      arguments:nil
                       resource:self.resource];
}

- (void)getNarrowsByAuthor:(void (^)(id<CSAuthor> result,
                                     NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbyauthor"
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
         
         callback([[CSNominal alloc] initWithResource:result
                                            requester:self.requester
                                           credential:self.credential],
                  nil);
     }];
}

- (void)getNarrowsByCoverType:(void (^)(id<CSCoverType> result,
                                     NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbycovertype"
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
         
         callback([[CSNominal alloc] initWithResource:result
                                            requester:self.requester
                                           credential:self.credential],
                  nil);
     }];
}

- (void)getNarrowsByManufacturer:(void (^)(id<CSManufacturer> result,
                                     NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbymanufacturer"
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
         
         callback([[CSNominal alloc] initWithResource:result
                                            requester:self.requester
                                           credential:self.credential],
                  nil);
     }];
}

- (void)getNarrowsBySoftwarePlatform:(void (^)(id<CSSoftwarePlatform> result,
                                     NSError *error))callback
{
    [self getRelation:@"/rels/narrowsbysoftwareplatform"
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
         
         callback([[CSNominal alloc] initWithResource:result
                                            requester:self.requester
                                           credential:self.credential],
                  nil);
     }];
}

@end
