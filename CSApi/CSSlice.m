//
//  CSSlice.m
//  CSApi
//
//  Created by Will Harris on 08/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSSlice.h"
#import "CSProductListPage.h"
#import "CSRetailer.h"
#import "CSRetailerListPage.h"
#import "CSCategory.h"
#import "CSNominal.h"
#import "CSNarrowListPage.h"
#import <HyperBek/HyperBek.h>

@implementation CSSlice

- (NSURL *)productsURL
{
    return [self URLForRelation:@"/rels/products"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)retailerNarrowsURL
{
    return [self URLForRelation:@"/rels/retailernarrows"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)categoryNarrowsURL
{
    return [self URLForRelation:@"/rels/categorynarrows"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)authorNarrowsURL
{
    return [self URLForRelation:@"/rels/authornarrows"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)coverTypeNarrowsURL
{
    return [self URLForRelation:@"/rels/covertypenarrows"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)manufacturerNarrowsURL
{
    return [self URLForRelation:@"/rels/manufacturernarrows"
                      arguments:nil
                       resource:self.resource];
}

- (NSURL *)softwarePlatformNarrowsURL
{
    return [self URLForRelation:@"/rels/softwareplatformnarrows"
                      arguments:nil
                       resource:self.resource];
}

- (id<CSAPIRequest>)getProducts:(void (^)(id<CSProductListPage>,
                                          NSError *))callback
{
    return [self getRelation:@"/rels/products"
                 forResource:self.resource
                    callback:^(YBHALResource *result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([[CSProductListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                 nil);
    }];
}

- (id<CSAPIRequest>)getProductsWithQuery:(NSString *)query
                                callback:(void (^)(id<CSProductListPage>,
                                                   NSError *))callback
{
    return [self getRelation:@"/rels/searchproducts"
               withArguments:@{@"q": query}
                 forResource:self.resource
                    callback:^(YBHALResource *result, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([[CSProductListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                 nil);
    }];
}

- (void)getRetailerNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/retailernarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getCategoryNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/categorynarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getAuthorNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/authornarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getCoverTypeNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/covertypenarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getManufacturerNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/manufacturernarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getSoftwarePlatformNarrows:(void (^)(id<CSNarrowListPage>, NSError *))callback
{
    [self getRelation:@"/rels/softwareplatformnarrows"
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSNarrowListPage alloc] initWithResource:result
                                                   requester:self.requester
                                                  credential:self.credential],
                  nil);
     }];
}

- (void)getFiltersByRetailer:(void (^)(id<CSRetailer>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbyretailer"
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

- (void)getFiltersByRetailerList:(void (^)(id<CSRetailerListPage>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbyretailerlist"
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
         
         callback([[CSRetailerListPage alloc] initWithResource:result
                                                     requester:self.requester
                                                    credential:self.credential],
                  nil);
     }];
}

- (void)getFiltersByCategory:(void (^)(id<CSCategory>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbycategory"
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
         
         callback([[CSCategory alloc] initWithResource:result
                                             requester:self.requester
                                            credential:self.credential],
                  nil);
     }];
}

- (void)getFiltersByAuthor:(void (^)(id<CSAuthor>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbyauthor"
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

- (void)getFiltersByCoverType:(void (^)(id<CSCoverType>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbycovertype"
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

- (void)getFiltersByManufacturer:(void (^)(id<CSManufacturer>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbymanufacturer"
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

- (void)getFiltersBySoftwarePlatform:(void (^)(id<CSSoftwarePlatform>, NSError *))callback
{
    [self getRelation:@"/rels/filtersbysoftwareplatform"
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

- (void)getSliceWithoutAuthorFilter:(void (^)(id<CSSlice>, NSError *))callback
{
    [self getRelation:@"/rels/slicewithoutauthorfilter"
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

- (void)getSliceWithoutCoverTypeFilter:(void (^)(id<CSSlice>, NSError *))callback
{
    [self getRelation:@"/rels/slicewithoutcovertypefilter"
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

- (void)getSliceWithoutManufacturerFilter:(void (^)(id<CSSlice>, NSError *))callback
{
    [self getRelation:@"/rels/slicewithoutmanufacturerfilter"
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

- (void)getSliceWithoutSoftwarePlatformFilter:(void (^)(id<CSSlice>, NSError *))callback
{
    [self getRelation:@"/rels/slicewithoutsoftwareplatformfilter"
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
