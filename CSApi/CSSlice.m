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
#import "CSNarrowListPage.h"

@interface CSSlice ()
@property (strong, nonatomic) YBHALResource *resource;
@end

@implementation CSSlice

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
        
        callback([[CSProductListPage alloc] initWithHal:result
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
        
        callback([[CSProductListPage alloc] initWithHal:result
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
         
         callback([[CSNarrowListPage alloc] initWithHal:result
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
         
         callback([[CSNarrowListPage alloc] initWithHal:result
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
         
         callback([[CSRetailerListPage alloc] initWithHal:result
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
         
         callback([[CSCategory alloc] initWithHAL:result
                                        requester:self.requester
                                       credential:self.credential],
                  nil);
     }];
}

@end
