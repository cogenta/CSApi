//
//  CSPriceTest.m
//  CSApi
//
//  Created by Will Harris on 22/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSPrice.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

#define CSAssertEqualDecimals(actual, expectedStr, description, ...) \
STAssertTrue([actual isKindOfClass:[NSDecimalNumber class]], description, ##__VA_ARGS__); \
STAssertEqualObjects(actual, [NSDecimalNumber decimalNumberWithString:expectedStr], description, ##__VA_ARGS__);

@interface CSPriceTest : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) YBHALResource *resource;
@property (strong) CSPrice *price;

@end

@implementation CSPriceTest

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize resource;
@synthesize price;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    YBHALResource *productResource = [self resourceForFixture:@"product.json"];
    resource = [[productResource resourcesForRelation:@"/rels/price"]
                objectAtIndex:4];
    STAssertNotNil(resource, nil);
    
    URL = [resource linkForRelation:@"self"].URL;
    
    price = [[CSPrice alloc] initWithHAL:resource
                               requester:requester
                              credential:credential];
}

- (void)testProperties
{
    CSAssertEqualDecimals(price.effectivePrice, @"223.00", nil);
    CSAssertEqualDecimals(price.price, @"220.00", nil);
    CSAssertEqualDecimals(price.deliveryPrice, @"3.00", nil);
    STAssertEqualObjects(price.currencySymbol, @"£", nil);
    STAssertEqualObjects(price.currencyCode, @"GBP", nil);
}

- (void)testGetProduct
{
    id productResource = [self resourceForFixture:@"product.json"];
    STAssertNotNil(productResource, nil);
    NSURL *productURL = [productResource linkForRelation:@"self"].URL;
    
    [requester addGetResponse:productResource forURL:productURL];
    
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProduct> product = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [price getProduct:^(id<CSProduct> aProduct, NSError *anError) {
            error = anError;
            product = aProduct;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(product, nil);
    
    STAssertEqualObjects(product.name, productResource[@"name"], nil);
}

- (void)testGetRetailerAndRetailerURL
{
    YBHALResource *retailerResource = [self resourceForFixture:@"retailer_81.json"];
    STAssertNotNil(retailerResource, nil);
    
    NSURL *retailerURL = [retailerResource linkForRelation:@"self"].URL;
    [requester addGetResponse:retailerResource forURL:retailerURL];
    
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSRetailer> retailer = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [price getRetailer:^(id<CSRetailer> aRetailer, NSError *anError) {
            error = anError;
            retailer = aRetailer;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(retailer, nil);
    
    STAssertEqualObjects(retailer.name, retailerResource[@"name"], nil);
    
    STAssertEqualObjects(price.retailerURL, retailer.URL, nil);
}

@end

