//
//  CSProductTests.m
//  CSApi
//
//  Created by Will Harris on 12/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSProduct.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"
#import <ISO8601DateFormatter/ISO8601DateFormatter.h>

@interface CSProductTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) YBHALResource *resource;
@property (strong) CSProduct *product;

@end

@implementation CSProductTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize resource;
@synthesize product;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    resource = [self resourceForFixture:@"product.json"];
    STAssertNotNil(resource, nil);
    
    URL = [resource linkForRelation:@"self"].URL;
    
    product = [[CSProduct alloc] initWithHAL:resource
                                   requester:requester
                                  credential:credential];
}

- (void)testProperties
{
    STAssertEquals(product.credential, credential, nil);
    STAssertEquals(product.requester, requester, nil);
    STAssertEqualObjects(product.name, resource[@"name"], nil);
    STAssertEqualObjects(product.description, resource[@"description"], nil);
    STAssertEqualObjects(product.views, resource[@"views"], nil);
    STAssertEqualObjects(product.author, resource[@"author"], nil);
    STAssertEqualObjects(product.softwarePlatform, resource[@"software_platform"], nil);
    STAssertEqualObjects(product.manufacuturer, resource[@"manufacturer"], nil);
    STAssertEqualObjects(product.lastUpdated,
                         [[[ISO8601DateFormatter alloc] init]
                          dateFromString:resource[@"last_updated"]],
                         nil);
}

- (void)testGetPictures
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSPictureListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getPictures:^(id<CSPictureListPage> aPage, NSError *anError) {
            error = anError;
            page = aPage;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSPictureList> pictures = page.pictureList;
    STAssertNotNil(pictures, nil);
    
    STAssertEqualObjects(@(pictures.count), @(1), nil);
    
    error = [NSError errorWithDomain:@"not called"
                                code:0
                            userInfo:nil];
    __block id<CSPicture> picture = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [pictures getPictureAtIndex:0 callback:^(id<CSPicture> aPicture, NSError *anError) {
            picture = aPicture;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(picture, nil);
    
    STAssertEqualObjects(@(picture.count), @(4), nil);
}

- (void)testGetProductSummary
{
    id productSummaryResource = [self resourceForFixture:@"productsummary.json"];
    STAssertNotNil(productSummaryResource, nil);
    NSURL *productURL = [productSummaryResource linkForRelation:@"self"].URL;
    
    [requester addGetResponse:productSummaryResource forURL:productURL];
    
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductSummary> productSummary = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getProductSummary:^(id<CSProductSummary> aProductSummary,
                                     NSError *anError) {
            error = anError;
            productSummary = aProductSummary;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(productSummary, nil);
    
    STAssertEqualObjects(productSummary.name, product.name, nil);
    STAssertEqualObjects(productSummary.description, product.description, nil);
}

- (void)testGetPrices
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSPriceListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getPrices:^(id<CSPriceListPage> aPage, NSError *anError) {
            error = anError;
            page = aPage;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSPriceList> prices = page.priceList;
    STAssertNotNil(prices, nil);
    
    STAssertEqualObjects(@(prices.count), @(13), nil);
    
    error = [NSError errorWithDomain:@"not called"
                                code:0
                            userInfo:nil];
    __block id<CSPrice> price = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [prices getPriceAtIndex:0 callback:^(id<CSPrice> aPrice, NSError *anError) {
            price = aPrice;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(price, nil);
}

@end

