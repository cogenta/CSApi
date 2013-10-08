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
    
    product = [[CSProduct alloc] initWithResource:resource
                                        requester:requester
                                       credential:credential];
    
    [self addGetFixture:@"author.json" requester:requester];
    [self addGetFixture:@"covertype.json" requester:requester];
    [self addGetFixture:@"manufacturer.json" requester:requester];
    [self addGetFixture:@"softwareplatform.json" requester:requester];
}

- (void)testProperties
{
    STAssertEquals(product.credential, credential, nil);
    STAssertEquals(product.requester, requester, nil);
    STAssertEqualObjects(product.name, resource[@"name"], nil);
    STAssertEqualObjects(product.description_, resource[@"description"], nil);
    STAssertEqualObjects(product.views, resource[@"views"], nil);
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
        [pictures getPictureAtIndex:0 callback:^(id<CSPicture> aPicture,
                                                 NSError *anError)
        {
            picture = aPicture;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(picture, nil);
    
    STAssertEqualObjects(@(picture.count), @(4), nil);
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
        [prices getPriceAtIndex:0 callback:^(id<CSPrice> aPrice,
                                             NSError *anError) {
            price = aPrice;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(price, nil);
}

- (void)testGetAuthor
{
    __block id error = @"NOT CALLED";
    __block id<CSAuthor> thing = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getAuthor:^(id<CSAuthor> aThing, NSError *anError) {
            thing = aThing;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(thing, nil);
    
    STAssertEqualObjects(thing.name, @"William Shakespeare", nil);
}

- (void)testGetCovertType
{
    __block id error = @"NOT CALLED";
    __block id<CSCoverType> thing = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getCoverType:^(id<CSCoverType> aThing, NSError *anError) {
            thing = aThing;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(thing, nil);
    
    STAssertEqualObjects(thing.name, @"Ebook", nil);
}

- (void)testGetManufacturer
{
    __block id error = @"NOT CALLED";
    __block id<CSManufacturer> thing = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getManufacturer:^(id<CSManufacturer> aThing,
                                   NSError *anError)
        {
            thing = aThing;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(thing, nil);
    
    STAssertEqualObjects(thing.name, @"Amazon", nil);
}

- (void)testGetSoftwarePlatform
{
    __block id error = @"NOT CALLED";
    __block id<CSSoftwarePlatform> thing = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [product getSoftwarePlatform:^(id<CSSoftwarePlatform> aThing,
                                       NSError *anError)
        {
            thing = aThing;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(thing, nil);
    
    STAssertEqualObjects(thing.name, @"Kindle", nil);
}

@end

