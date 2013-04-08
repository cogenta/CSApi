//
//  CSProductSummaryTests.m
//  CSApi
//
//  Created by Will Harris on 15/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

//
//  CSRetailerTests.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSProductSummary.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSProductSummaryTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) YBHALResource *resource;
@property (strong) CSProductSummary *productSummary;

@end

@implementation CSProductSummaryTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize resource;
@synthesize productSummary;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    resource = [self resourceForFixture:@"productsummary.json"];
    STAssertNotNil(resource, nil);
    
    
    URL = [resource linkForRelation:@"self"].URL;
    
    productSummary = [[CSProductSummary alloc] initWithHAL:resource
                                                 requester:requester
                                                credential:credential];
}

- (void)testProperties
{
    STAssertEquals(productSummary.credential, credential, nil);
    STAssertEquals(productSummary.requester, requester, nil);
    STAssertEqualObjects(productSummary.name, resource[@"name"], nil);
    STAssertEqualObjects(productSummary.description, resource[@"description"], nil);
}

- (void)testGetPictures
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSPictureListPage> page = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [productSummary getPictures:^(id<CSPictureListPage> aPage, NSError *anError) {
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

@end

