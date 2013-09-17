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
#import "CSAuthor.h"
#import <HyperBek/HyperBek.h>
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@interface CSProduct ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSProduct

@synthesize resource;
@synthesize name;
@synthesize description_;
@synthesize views;
@synthesize softwarePlatform;
@synthesize manufacturer;
@synthesize coverType;
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
        description_ = resource[@"description"];
        views = resource[@"views"];
        softwarePlatform = resource[@"software_platform"];
        manufacturer = resource[@"manufacturer"];
        coverType = resource[@"cover_type"];
    }
    return self;
}

- (NSDate *)lastUpdated
{
    if (lastUpdated) {
        return lastUpdated;
    }
    
    lastUpdated = [[[ISO8601DateFormatter alloc] init]
                   dateFromString:resource[@"last_updated"]];
    return lastUpdated;
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

- (void)getPrices:(void (^)(id<CSPriceListPage>, NSError *))callback
{
    callback([[CSPriceListPage alloc] initWithHal:self.resource
                                        requester:self.requester
                                       credential:self.credential],
             nil);
}

- (void)getAuthor:(void (^)(id<CSAuthor>, NSError *))callback
{
    [self getRelation:@"/rels/author"
          forResource:resource
             callback:^(YBHALResource *author, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        
        callback([[CSAuthor alloc] initWithResource:author
                                          requester:self.requester
                                         credential:self.credential],
                 nil);
    }];
}

@end
