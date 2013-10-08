//
//  CSPrice.m
//  CSApi
//
//  Created by Will Harris on 22/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPrice.h"
#import "CSProduct.h"
#import "CSRetailer.h"
#import <HyperBek/HyperBek.h>

@implementation CSPrice

@synthesize effectivePrice;
@synthesize price;
@synthesize stock;
@synthesize deliveryPrice;
@synthesize currencySymbol;
@synthesize currencyCode;

- (void)loadExtraProperties
{
    effectivePrice = self.resource[@"effective_price"];
    price = self.resource[@"price"];
    deliveryPrice = self.resource[@"delivery_price"];
    currencySymbol = self.resource[@"currency_symbol"];
    currencyCode = self.resource[@"currency_code"];
    stock = self.resource[@"stock"];
}

- (void)getProduct:(void (^)(id<CSProduct>, NSError *))callback
{
    [self getRelation:@"/rels/product"
          forResource:self.resource
             callback:^(YBHALResource *product, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSProduct alloc] initWithResource:product
                                            requester:self.requester
                                           credential:self.credential],
                  nil);
     }];
}

- (void)getRetailer:(void (^)(id<CSRetailer>, NSError *))callback
{
    [self getRelation:@"/rels/retailer"
          forResource:self.resource
             callback:^(YBHALResource *retailer, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSRetailer alloc] initWithResource:retailer
                                             requester:self.requester
                                            credential:self.credential],
                  nil);
     }];
}

- (NSURL *)retailerURL
{
    YBHALLink *link = [self.resource linkForRelation:@"/rels/retailer"];
    return link.URL;
}

- (NSURL *)purchaseURL
{
    YBHALLink *link = [self.resource linkForRelation:@"/rels/purchase"];
    return link.URL;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<CSPrice: %@ [%@ %@ from %@]>",
            [self.resource linkForRelation:@"self"].URL,
            self.effectivePrice, self.currencyCode, self.retailerURL];
}

@end
