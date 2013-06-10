//
//  CSCategoryTests.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSCategory.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSCategoryTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) YBHALResource *resource;
@property (strong) CSCategory *category;
@property (strong) YBHALResource *productsResource;
@property (strong) YBHALResource *productResource;
@property (strong) YBHALResource *subcategoryResource;


@end

@implementation CSCategoryTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize resource;
@synthesize category;
@synthesize productsResource;
@synthesize productResource;
@synthesize subcategoryResource;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    resource = [self resourceForFixture:@"category_3-all-products.json"];
    STAssertNotNil(resource, nil);
    
    URL = [resource linkForRelation:@"self"].URL;
    
    category = [[CSCategory alloc] initWithHAL:resource
                                     requester:requester
                                    credential:credential];
    
    //
    
    productResource = [self resourceForFixture:@"product.json"];
    STAssertNotNil(productResource, nil);
    
    NSString *productsHref = [resource linkForRelation:@"/rels/products"].href;
    STAssertNotNil(productsHref, nil);
    NSString *productHref = [productResource linkForRelation:@"self"].href;
    STAssertNotNil(productHref, nil);
    NSMutableDictionary *productsDict = [NSMutableDictionary dictionary];
    productsDict[@"_links"] = [NSMutableDictionary dictionary];
    productsDict[@"_links"][@"self"] = [NSMutableDictionary dictionary];
    productsDict[@"_links"][@"self"][@"href"] = productsHref;
    productsDict[@"_links"][@"/rels/product"] = [NSMutableDictionary dictionary];
    productsDict[@"_links"][@"/rels/product"][@"href"] = productHref;
    productsDict[@"count"] = @1;
    productsResource = [self resourceForJson:productsDict];
    STAssertNotNil(productsResource, nil);
    
    [requester addGetResponse:productResource
                       forURL:[productResource linkForRelation:@"self"].URL];
    [requester addGetResponse:productsResource
                       forURL:[productsResource linkForRelation:@"self"].URL];
    
    //
    
    subcategoryResource = [self resourceForFixture:@"category_1167-digital-video.json"];
    STAssertNotNil(subcategoryResource, nil);
    
    [requester addGetResponse:subcategoryResource
                       forURL:[subcategoryResource linkForRelation:@"self"].URL];
}

- (void)testName
{
    STAssertEqualObjects(category.name, @"DVDs & Blu-Ray", nil);
}

- (void)testGetProducts
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [category getProducts:^(id<CSProductListPage> aPage, NSError *anError)
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
    
    STAssertEqualObjects(@(list.count), @1, nil);
    
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
    
    STAssertEqualObjects(product.name, productResource[@"name"], nil);
}

- (void)testGetImmediateSubcategories
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSCategoryListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [category getImmediateSubcategories:^(id<CSCategoryListPage> aPage,
                                              NSError *anError)
        {
             page = aPage;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    
    id<CSCategoryList> list = page.categoryList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @4, nil);
    
    __block id<CSCategory> subcategory = nil;
    error = [NSError errorWithDomain:@"not called" code:0 userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [list getCategoryAtIndex:0
                        callback:^(id<CSCategory> aCategory, NSError *anError)
        {
             subcategory = aCategory;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(subcategory, nil);
    
    STAssertEqualObjects(subcategory.name, subcategoryResource[@"name"], nil);
}

@end
