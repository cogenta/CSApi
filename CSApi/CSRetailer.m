//
//  CSRetailer.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailer.h"
#import <HyperBek/HyperBek.h>
#import <objc/runtime.h>
#import "CSPicture.h"
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"
#import "CSProductSummaryListPage.h"

@interface CSRetailer ()

@property (readonly) YBHALResource *resource;

@end

@implementation CSRetailer

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

- (NSString *)name
{
    return resource[@"name"];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), self.URL];
}

- (void)getLogo:(void (^)(id<CSPicture>, NSError *))callback
{
    [self getRelation:@"/rels/logo"
          forResource:resource
             callback:^(YBHALResource *logoResource, NSError *error)
     {
        if (error) {
            callback(nil, error);
        }
        
        CSPicture *result =  [[CSPicture alloc] initWithHal:logoResource
                                                  requester:self.requester
                                                 credential:self.credential];
        callback(result, nil);
    }];
}

- (void)getProductSummaries:(void (^)(id<CSProductSummaryListPage>, NSError *))callback
{
    [self getRelation:@"/rels/productsummaries"
          forResource:resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSProductSummaryListPage alloc] initWithHal:result
                                                      requester:self.requester
                                                     credential:self.credential],
                  nil);
     }];
}

@end
