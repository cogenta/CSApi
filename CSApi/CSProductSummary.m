//
//  CSProductSummary.m
//  CSApi
//
//  Created by Will Harris on 11/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummary.h"
#import <HyperBek/HyperBek.h>
#import "CSPictureListPage.h"
#import "CSListItem.h"
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"
#import "CSProduct.h"

@interface CSProductSummary ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSProductSummary

@synthesize resource;
@synthesize name;
@synthesize description;

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

- (void)getProduct:(void (^)(id<CSProduct>, NSError *))callback
{
    [self getRelation:@"/rels/product"
          forResource:resource
             callback:^(YBHALResource *product, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSProduct alloc] initWithHAL:product
                                       requester:self.requester
                                      credential:self.credential],
                  nil);
     }];
}

@end
