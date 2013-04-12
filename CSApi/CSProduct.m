//
//  CSProduct.m
//  CSApi
//
//  Created by Will Harris on 12/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProduct.h"
#import "CSPictureListPage.h"
#import "CSProductSummary.h"
#import <HyperBek/HyperBek.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@interface CSProduct ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSProduct

@synthesize resource;
@synthesize name;
@synthesize description;
@synthesize views;
@synthesize author;
@synthesize softwarePlatform;
@synthesize manufacuturer;
@synthesize lastUpdated;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester
                         credential:aCredential];
    if (self) {
        resource = aResource;
        
        name = resource[@"name"];
        description = resource[@"description"];
        views = resource[@"views"];
        author = resource[@"author"];
        softwarePlatform = resource[@"software_platform"];
        manufacuturer = resource[@"manufacturer"];
        lastUpdated = [[[ISO8601DateFormatter alloc] init]
                       dateFromString:resource[@"last_updated"]];
    }
    return self;
}

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback
{
    [self getRelation:@"/rels/pictures"
          forResource:resource
             callback:^(YBHALResource *page, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSPictureListPage alloc] initWithHal:page
                                               requester:self.requester
                                              credential:self.credential],
                  nil);
     }];
}

- (void)getPrices:(void (^)(NSArray *, NSError *))callback
{
    callback(nil, [NSError errorWithDomain:@"not implemented" code:0 userInfo:nil]);
}

- (void)getProductSummary:(void (^)(id<CSProductSummary>, NSError *))callback
{
    [self getRelation:@"/rels/productsummary"
          forResource:resource
             callback:^(YBHALResource *product, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSProductSummary alloc] initWithHAL:product
                                              requester:self.requester
                                             credential:self.credential],
                  nil);
     }];
}

@end