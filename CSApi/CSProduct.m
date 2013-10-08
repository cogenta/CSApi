//
//  CSProduct.m
//  CSApi
//
//  Created by Will Harris on 12/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProduct.h"
#import "CSPictureListPage.h"
#import "CSPriceListPage.h"
#import "CSNominal.h"
#import <HyperBek/HyperBek.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@implementation CSProduct

@synthesize name;
@synthesize description_;
@synthesize views;
@synthesize lastUpdated;

- (void)loadExtraProperties
{
    name = self.resource[@"name"];
    description_ = self.resource[@"description"];
    views = self.resource[@"views"];
}

- (NSDate *)lastUpdated
{
    if (lastUpdated) {
        return lastUpdated;
    }
    
    lastUpdated = [[[ISO8601DateFormatter alloc] init]
                   dateFromString:self.resource[@"last_updated"]];
    return lastUpdated;
}

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback
{
    [self getRelation:@"/rels/pictures"
          forResource:self.resource
             callback:^(YBHALResource *page, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSPictureListPage alloc] initWithResource:page
                                                    requester:self.requester
                                                   credential:self.credential],
                  nil);
     }];
}

- (void)getPrices:(void (^)(id<CSPriceListPage>, NSError *))callback
{
    callback([[CSPriceListPage alloc] initWithResource:self.resource
                                             requester:self.requester
                                            credential:self.credential],
             nil);
}

- (void)getNominalForRelation:(NSString *)rel
                     callback:(void (^)(CSNominal *, NSError *))callback
{
    [self getRelation:rel
          forResource:self.resource
             callback:^(YBHALResource *author, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        
        callback([[CSNominal alloc] initWithResource:author
                                          requester:self.requester
                                         credential:self.credential],
                 nil);
    }];
}

- (void)getAuthor:(void (^)(id<CSAuthor>, NSError *))callback
{
    [self getNominalForRelation:@"/rels/author"
                       callback:^(CSNominal *result, NSError *error)
    {
        callback(result, error);
    }];
}

- (void)getCoverType:(void (^)(id<CSCoverType>, NSError *))callback
{
    [self getNominalForRelation:@"/rels/covertype"
                       callback:^(CSNominal *result, NSError *error)
     {
         callback(result, error);
     }];
}

- (void)getManufacturer:(void (^)(id<CSManufacturer>, NSError *))callback
{
    [self getNominalForRelation:@"/rels/manufacturer"
                       callback:^(CSNominal *result, NSError *error)
     {
         callback(result, error);
     }];
}

- (void)getSoftwarePlatform:(void (^)(id<CSSoftwarePlatform>,
                                      NSError *))callback
{
    [self getNominalForRelation:@"/rels/softwareplatform"
                       callback:^(CSNominal *result, NSError *error)
     {
         callback(result, error);
     }];
}


@end
