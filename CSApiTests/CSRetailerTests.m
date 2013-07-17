//
//  CSRetailerTests.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSRetailer.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSRetailerTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) NSDictionary *json;
@property (strong) YBHALResource *resource;
@property (strong) YBHALResource *pictureResource;
@property (strong) YBHALResource *imageResource;
@property (strong) YBHALResource *productSummariesResource;
@property (strong) YBHALResource *productSummaryResource;
@property (strong) YBHALResource *productsResource;
@property (strong) YBHALResource *productResource;
@property (strong) YBHALResource *categoriesResource;
@property (strong) YBHALResource *categoryResource;
@property (strong) YBHALResource *productSearchResource;
@property (strong) CSRetailer *retailer;

@end

@implementation CSRetailerTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize json;
@synthesize resource;
@synthesize pictureResource;
@synthesize imageResource;
@synthesize productSummaryResource;
@synthesize productSummariesResource;
@synthesize productsResource;
@synthesize productResource;
@synthesize retailer;
@synthesize categoriesResource;
@synthesize categoryResource;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    json = [self jsonForFixture:@"retailer.json"];
    STAssertNotNil(json, nil);
    
    resource = [self resourceForJson:json];
    STAssertNotNil(resource, nil);

    pictureResource = [self resourceForFixture:@"picture.json"];
    STAssertNotNil(pictureResource, nil);

    imageResource = [self resourceForFixture:@"image.json"];
    STAssertNotNil(imageResource, nil);
    
    productSummaryResource = [self resourceForFixture:@"productsummary.json"];
    STAssertNotNil(productSummaryResource, nil);
    
    NSString *productSummariesHref = [resource linkForRelation:@"/rels/productsummaries"].href;
    STAssertNotNil(productSummariesHref, nil);
    
    NSString *productSummaryHref = [productSummaryResource linkForRelation:@"self"].href;
    STAssertNotNil(productSummaryHref, nil);
    
    NSMutableDictionary *productSummariesDict = [NSMutableDictionary dictionary];
    productSummariesDict[@"_links"] = [NSMutableDictionary dictionary];
    productSummariesDict[@"_links"][@"self"] = [NSMutableDictionary dictionary];
    productSummariesDict[@"_links"][@"self"][@"href"] = productSummariesHref;
    productSummariesDict[@"_links"][@"/rels/productsummary"] = [NSMutableDictionary dictionary];
    productSummariesDict[@"_links"][@"/rels/productsummary"][@"href"] = productSummaryHref;
    productSummariesDict[@"count"] = @1;
    
    productSummariesResource = [self resourceForJson:productSummariesDict];
    STAssertNotNil(productSummariesResource, nil);

    URL = [resource linkForRelation:@"self"].URL;
    [requester addGetResponse:resource forURL:URL];
    [requester addGetResponse:pictureResource
                       forURL:[pictureResource linkForRelation:@"self"].URL];
    [requester addGetResponse:imageResource
                       forURL:[imageResource linkForRelation:@"self"].URL];
    [requester addGetResponse:productSummaryResource
                       forURL:[productSummaryResource linkForRelation:@"self"].URL];
    [requester addGetResponse:productSummariesResource
                       forURL:[productSummariesResource linkForRelation:@"self"].URL];

    retailer = [[CSRetailer alloc] initWithResource:resource
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
    
    categoriesResource = [self resourceForFixture:@"categories.json"];
    [requester addGetResponse:categoriesResource
                       forURL:[categoriesResource linkForRelation:@"self"].URL];
    
    self.categoryResource = [self resourceForFixture:
                             @"category_4-dvds-and-blu-ray.json"];
    [requester addGetResponse:self.categoryResource
                       forURL:[self.categoryResource linkForRelation:@"self"].URL];

    //
    
    self.productSearchResource = [self resourceForFixture:@"retailer_products_search.json"];
    NSURL *searchURL = [self.productSearchResource linkForRelation:@"self"].URL;
    [requester addGetResponse:self.productSearchResource
                       forURL:searchURL];
    
}

- (void)testProperties
{
    STAssertEqualObjects(retailer.URL, URL, nil);
    STAssertEquals(retailer.credential, credential, nil);
    STAssertEquals(retailer.requester, requester, nil);
    STAssertEqualObjects(retailer.name, resource[@"name"], nil);
}

- (void)testRetailerLinkOverridesSelfForURL
{
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost/"];
    NSString *path = @"/retailers/foo";
    NSURL *expectedURL = [[NSURL URLWithString:path relativeToURL:baseURL]
                          absoluteURL];
    
    json = @{@"_links":
                 @{@"self": @{@"href": @"/filers/bar"},
                   @"api:retailer": @{@"href": path},
                   @"curies": @[@{@"href": @"/rels/{rel}",
                                  @"name": @"api",
                                  @"templated": @(YES)}
                                ]
                   }
             };
    
    resource = [[YBHALResource alloc] initWithDictionary:json baseURL:baseURL];
    retailer = [[CSRetailer alloc] initWithResource:resource
                                          requester:self.requester
                                         credential:self.credential];
                                           
    
    STAssertEqualObjects(retailer.URL, expectedURL, nil);
}

- (void)testGetPicture
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSPicture> picture = nil;
    CALL_AND_WAIT(^(void (^done)()) {
       [retailer getLogo:^(id<CSPicture> aPicture, NSError *anError) {
           error = anError;
           picture = aPicture;
           done();
       }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(picture, nil);
    
    id<CSImageList> imageList = picture.imageList;
    STAssertNotNil(imageList, nil);
    
    STAssertEqualObjects(@(imageList.count), @(1), nil);
    
    error = [NSError errorWithDomain:@"not called"
                                code:0
                            userInfo:nil];
    __block id<CSImage> image = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [imageList getImageAtIndex:0 callback:^(id<CSImage> anImage, NSError *anError) {
            image = anImage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(image, nil);

    STAssertEqualObjects(image.enclosureURL, [imageResource linkForRelation:@"enclosure"].URL, nil);
    STAssertEqualObjects(image.enclosureType, [imageResource linkForRelation:@"enclosure"].type, nil);
    STAssertEqualObjects(image.width, imageResource[@"width"], nil);
    STAssertEqualObjects(image.height, imageResource[@"height"], nil);
}

- (void)testGetProductSummaries
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductSummaryListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [retailer getProductSummaries:^(id<CSProductSummaryListPage> aPage, NSError *anError)
        {
            page = aPage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);

    id<CSProductSummaryList> list = page.productSummaryList;
    STAssertNotNil(list, nil);
    
    STAssertEqualObjects(@(list.count), @1, nil);
    
    __block id<CSProductSummary> summary = nil;
    error = [NSError errorWithDomain:@"not called" code:0 userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [list getProductSummaryAtIndex:0
                              callback:^(id<CSProductSummary> aSummary, NSError *anError)
        {
            summary = aSummary;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(summary, nil);
    
    STAssertEqualObjects(summary.name, productSummaryResource[@"name"], nil);
}


- (void)testGetProducts
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [retailer getProducts:^(id<CSProductListPage> aPage, NSError *anError)
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
    
    STAssertEqualObjects(product.name, productSummaryResource[@"name"], nil);
}

- (void)testGetCategories
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSCategoryListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [retailer getCategories:^(id<CSCategoryListPage> aPage,
                                    NSError *anError) {
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
    
    __block id<CSCategory> category = nil;
    error = [NSError errorWithDomain:@"not called" code:0 userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [list getCategoryAtIndex:0
                        callback:^(id<CSCategory> aCategory, NSError *anError)
         {
             category = aCategory;
             error = anError;
             done();
         }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(category, nil);
    
    STAssertEqualObjects(category.name, @"DVDs & Blu-Ray", nil);
}

- (void)testProductSearch
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSProductListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [retailer getProductsWithQuery:@"iPod"
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
    
    STAssertEqualObjects(@(list.count), @1310, nil);
    
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
                         @"Apple iPod classic 160GB - Silver",
                         nil);
}

@end
