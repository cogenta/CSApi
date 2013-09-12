//
//  CSSliceTests.m
//  CSApi
//
//  Created by Will Harris on 13/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSSlice.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSSliceTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;

@property (strong) YBHALResource *resource;
@property (strong) CSSlice *slice;

@property (strong) YBHALResource *productResource;

@property (strong) YBHALResource *productsResource;

@property (strong) YBHALResource *productSearchResource;

@end

@implementation CSSliceTests

@synthesize requester;
@synthesize credential;
@synthesize resource;
@synthesize slice;
@synthesize productResource;
@synthesize productsResource;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    //
    
    resource = [self resourceForFixture:@"slice.json"];
    slice = [[CSSlice alloc] initWithHAL:resource
                               requester:requester
                              credential:credential];
    
    //

    productResource = [self resourceForFixture:@"slice_product_59t1CW.json"];
    STAssertNotNil(productResource, nil);
    
    productsResource = [self resourceForFixture:@"slice_products.json"];
    STAssertNotNil(productsResource, nil);
    
    [requester addGetResponse:productResource
                       forURL:[productResource linkForRelation:@"self"].URL];
    [requester addGetResponse:productsResource
                       forURL:[productsResource linkForRelation:@"self"].URL];
    
    //
    
    self.productSearchResource = [self resourceForFixture:@"slice_product_search.json"];
    NSURL *searchURL = [self.productSearchResource linkForRelation:@"self"].URL;
    [requester addGetResponse:self.productSearchResource
                       forURL:searchURL];
    
    YBHALResource *searchProductResource = [self resourceForFixture:@"slice_product_5WY4WK.json"];
    [requester addGetResponse:searchProductResource
                       forURL:[searchProductResource linkForRelation:@"self"].URL];
    
    //
    
    YBHALResource *retailerNarrowsResource = [self resourceForFixture:@"slice_retailernarrows.json"];
    [requester addGetResponse:retailerNarrowsResource
                       forURL:[retailerNarrowsResource linkForRelation:@"self"].URL];
    
    //
    
    YBHALResource *categoryNarrowsResource = [self resourceForFixture:@"slice_categorynarrows.json"];
    [requester addGetResponse:categoryNarrowsResource
                       forURL:[categoryNarrowsResource linkForRelation:@"self"].URL];
    
    //
    
    YBHALResource *authorNarrowsResource = [self resourceForFixture:@"slice_authornarrows.json"];
    [requester addGetResponse:authorNarrowsResource
                       forURL:[authorNarrowsResource linkForRelation:@"self"].URL];
}

- (void)testGetProducts
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [self.slice getProducts:^(id<CSProductListPage> aPage, NSError *anError)
         {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSProductList> list = page.productList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @260235, nil);
    
    __block id<CSProduct> product = nil;
    error = [NSError errorWithDomain:@"not called" code:0 userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [list getProductAtIndex:0
                       callback:^(id<CSProduct> aProduct, NSError *anError)
         {
             product = aProduct;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(product, nil);
    
    STAssertEqualObjects(product.name, self.productResource[@"name"], nil);
}

- (void)testProductSearch
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [slice getProductsWithQuery:@"Apple iPod classic 160GB"
                              callback:^(id<CSProductListPage> aPage,
                                         NSError *anError)
         {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSProductList> list = page.productList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @5, nil);
    
    __block id<CSProduct> product = nil;
    error = [NSError errorWithDomain:@"not called" code:0 userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [list getProductAtIndex:0 callback:^(id<CSProduct> aProduct,
                                             NSError *anError) {
            product = aProduct;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(product, nil);
    
    STAssertEqualObjects(product.name,
                         @"Apple iPod classic Silver - 160GB",
                         nil);
}

- (void)testCancelProductSearch
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [[slice getProductsWithQuery:@"Apple iPod classic 160GB"
                            callback:^(id<CSProductListPage> aPage,
                                       NSError *anError)
          {
              page = aPage;
              error = anError;
              done();
          }] cancel];
    });
    
    STAssertNotNil(error, nil);
    STAssertNil(page, @"%@", page);
}

- (void)testGetRetailerNarrows
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSNarrowListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [self.slice getRetailerNarrows:^(id<CSNarrowListPage> aPage,
                                         NSError *anError)
        {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSNarrowList> list = page.narrowList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @10, nil);
}

- (void)testGetCategoryNarrows
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSNarrowListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [self.slice getCategoryNarrows:^(id<CSNarrowListPage> aPage,
                                         NSError *anError)
         {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSNarrowList> list = page.narrowList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @12, nil);
}

- (void)testGetAuthorNarrows
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSNarrowListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [self.slice getAuthorNarrows:^(id<CSNarrowListPage> aPage,
                                       NSError *anError)
         {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSNarrowList> list = page.narrowList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @100, nil);
}

@end
