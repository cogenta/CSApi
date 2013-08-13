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
    productsDict[@"_links"][@"item"] = [NSMutableDictionary dictionary];
    productsDict[@"_links"][@"item"][@"href"] = productHref;
    productsDict[@"count"] = @1;
    productsResource = [self resourceForJson:productsDict];
    STAssertNotNil(productsResource, nil);
    
    [requester addGetResponse:productResource
                       forURL:[productResource linkForRelation:@"self"].URL];
    [requester addGetResponse:productsResource
                       forURL:[productsResource linkForRelation:@"self"].URL];
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
    
    STAssertEqualObjects(product.name, self.productResource[@"name"], nil);
}

@end
