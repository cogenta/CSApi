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

@interface NSDecimalNumber (CSNumberAdditions)

+ (NSDecimalNumber *)decimalNumberWithNumber:(NSNumber *)number;

@end

@implementation NSDecimalNumber (CSNumberAdditions)

+ (NSDecimalNumber *)decimalNumberWithNumber:(NSNumber *)number
{
    if ( ! [number respondsToSelector:@selector(decimalValue)]) {
        return (NSDecimalNumber *) [NSNull null];
    }
    
    return [NSDecimalNumber decimalNumberWithDecimal:[number decimalValue]];
}

@end

@interface CSPrice ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSPrice

@synthesize resource;
@synthesize effectivePrice;
@synthesize price;
@synthesize deliveryPrice;
@synthesize currencySymbol;
@synthesize currencyCode;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        resource = aResource;
        effectivePrice = [NSDecimalNumber decimalNumberWithNumber:resource[@"effective_price"]];
        price = [NSDecimalNumber decimalNumberWithNumber:resource[@"price"]];
        deliveryPrice = [NSDecimalNumber decimalNumberWithNumber:resource[@"delivery_price"]];
        currencySymbol = resource[@"currency_symbol"];
        currencyCode = resource[@"currency_code"];
    }
    
    return self;
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

- (void)getRetailer:(void (^)(id<CSRetailer>, NSError *))callback
{
    [self getRelation:@"/rels/retailer"
          forResource:resource
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

@end
