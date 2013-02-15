//
//  CSApplicationTests.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <HyperBek/HyperBek.h>
#import "TestRequester.h"
#import "TestApi.h"

#import "CSAPI.h"
#import "TestFixtures.h"
#import "TestConstants.h"

#import "CSAPITestCase.h"
#import <NSArray+Functional.h>

@interface CSApplicationTests : CSAPITestCase

@property (weak) CSAPI *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;
@property (strong) YBHALResource *appResource;
@property (strong) id<CSApplication> app;

@end



@implementation CSApplicationTests

@synthesize testApi;
@synthesize api;
@synthesize requester;
@synthesize appResource;
@synthesize app;

- (void)setUp
{
    [super setUp];
    
    testApi = [TestApi apiWithBookmark:kBookmark
                              username:kUsername
                              password:kPassword];
    api = (CSAPI *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
    
    
    NSURL *url = [NSURL URLWithString:kBookmark];
    appResource = [self resourceForData:appData()];
    STAssertNotNil(appResource, nil);
    
    [requester addGetResponse:appResource forURL:url];
    
    __block NSError *error = nil;

    [self callAndWait:^(void (^done)()) {
        [api getApplication:^(id<CSApplication> anApp, NSError *anError)
         {
             app = anApp;
             error = anError;
             done();
         }];
    }];
    
    STAssertNil(error, @"%@", error);
}

- (void)tearDown
{
    self.api = nil;
    self.testApi = nil;
    self.requester = nil;
    self.app = nil;
    
    [super tearDown];
}

- (void)testName
{
    STAssertEquals(app.name, appResource[@"name"], nil);
}

request_handler_t postCallback =
^(id body, id etag, requester_callback_t cb) {
    YBHALResource *halBody = body;
    NSData *data = userPostResponseData();
    NSMutableDictionary *json = [[CSApplicationTests jsonForData:data] mutableCopy];
    if (halBody[@"reference"]) {
        json[@"reference"] = halBody[@"reference"];
    }
    if (halBody[@"meta"]) {
        json[@"meta"] = halBody[@"meta"];
    }
    YBHALResource *userResource = [CSApplicationTests resourceForJson:json];
    cb(userResource, nil, nil);
};

- (void)testCreateUser
{
    NSURL *postUrl = [appResource linkForRelation:@"/rels/users"].URL;
    
    [requester addPostCallback:postCallback forURL:postUrl];
    
    __block NSError *error = nil;
    __block id<CSUser> createdUser = nil;
    [self callAndWait:^(void (^done)()) {
        [self.app
         createUserWithChange:nil
         callback:^(id<CSUser> returnedUser, NSError *returnedError)
        {
            createdUser = returnedUser;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(createdUser, nil);
    STAssertNotNil(createdUser.url, nil);
    STAssertNil(createdUser.reference, nil);
    STAssertNil(createdUser.meta, nil);
}

- (void)testCreateUserWithReferenceAndMeta
{
    NSURL *postUrl = [appResource linkForRelation:@"/rels/users"].URL;
    
    NSData *data = userPostReponseDataWithReferenceAndMeta();
    YBHALResource *userResource = [self resourceForData:data];
    
    [requester addPostCallback:postCallback forURL:postUrl];
    
    __block NSError *error = nil;
    __block id<CSUser> createdUser = nil;
    [self callAndWait:^(void (^done)()) {
        [self.app createUserWithChange:^(id<CSMutableUser> user) {
            user.reference = userResource[@"reference"];
            user.meta = userResource[@"meta"];
        } callback:^(id<CSUser> returnedUser, NSError *returnedError)
        {
            createdUser = returnedUser;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(createdUser, nil);
    STAssertEqualObjects(createdUser.url,
                         [userResource linkForRelation:@"self"].URL,
                         nil);
    STAssertEqualObjects(createdUser.reference, userResource[@"reference"], nil);
    STAssertEqualObjects(createdUser.meta, userResource[@"meta"], nil);
}

- (void)testCreateUserUsesCredential
{
    [self callAndWait:^(void (^done)()) {
        [self.app
         createUserWithChange:nil
         callback:^(id<CSUser> returnedUser, NSError *returnedError)
         {
             done();
         }];
    }];
    
    STAssertEqualObjects(requester.lastUsername, kUsername, nil);
    STAssertEqualObjects(requester.lastPassword, kPassword, nil);
}

- (void)checkNoNextForPage:(id<CSListPage>)page
{
    STAssertFalse(page.hasNext, nil);
    
    __block id nextPage = @"not set";
    __block id nextPageError = @"not set";
    [self callAndWait:^(void (^done)()) {
        [page getNext:^(id<CSListPage> page, NSError *error) {
            nextPage = page;
            nextPageError = error;
            done();
        }];
    }];
    
    STAssertNil(nextPage, @"%@", nextPage);
    STAssertNil(nextPageError, @"%@", nextPageError);
}

- (void)checkNoPrevForPage:(id<CSListPage>)page
{
    STAssertFalse(page.hasPrev, nil);
    
    __block id prevPage = @"not set";
    __block id prevPageError = @"not set";
    [self callAndWait:^(void (^done)()) {
        [page getPrev:^(id<CSListPage> page, NSError *error) {
            prevPage = page;
            prevPageError = error;
            done();
        }];
    }];
    
    STAssertNil(prevPage, @"%@", prevPage);
    STAssertNil(prevPageError, @"%@", prevPageError);
}

- (void)checkNoNextOfPrevPageForPage:(id<CSListPage>)page
{
    [self checkNoNextForPage:page];
    [self checkNoPrevForPage:page];
}

- (void)testGetRetailersLoadsSinglePageOfRetailerLinks
{
    YBHALResource *retailersResource = [self resourceForFixture:
                                        @"retailers_single_page.json"];
    NSURL *retailersURL = [appResource linkForRelation:@"/rels/retailers"].URL;
    [requester addGetResponse:retailersResource forURL:retailersURL];
    
    __block id<CSListPage> page = nil;
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    [self callAndWait:^(void (^done)()){
        [app getRetailers:^(id<CSListPage> firstPage, NSError *theError) {
            page = firstPage;
            error = theError;
            done();
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    STAssertNotNil(page.items, nil);
    
    NSArray *links = [retailersResource linksForRelation:@"/rels/retailer"];
    NSArray *expectedURLs = [links valueForKey:@"URL"];
    NSArray *actualURLs = [page.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs, expectedURLs, nil);
    
    STAssertEqualObjects(@(page.count), retailersResource[@"count"], nil);
    
    [self checkNoNextOfPrevPageForPage:page];
}


- (void)testGetRetailersLoadsSinglePageOfEmbeddedRetailers
{
    YBHALResource *retailersResource = [self resourceForFixture:
                                        @"retailers_single_page_embedded.json"];
    NSURL *retailersURL = [appResource linkForRelation:@"/rels/retailers"].URL;
    [requester addGetResponse:retailersResource forURL:retailersURL];
    
    __block id<CSListPage> page = nil;
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    [self callAndWait:^(void (^done)()){
        [app getRetailers:^(id<CSListPage> firstPage, NSError *theError) {
            page = firstPage;
            error = theError;
            done();
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page, nil);
    STAssertNotNil(page.items, nil);
    
    NSArray *resources = [retailersResource resourcesForRelation:@"/rels/retailer"];
    NSArray *expectedURLs = [resources mapUsingBlock:^id(id obj) {
        return [obj linkForRelation:@"self"].URL;
    }];
    STAssertNotNil(expectedURLs, nil);
    NSArray *actualURLs = [page.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs, expectedURLs, nil);
    
    STAssertEqualObjects(@(page.count), retailersResource[@"count"], nil);
    
    [self checkNoNextOfPrevPageForPage:page];
}

- (void)testGetRetailersUsesCredential
{
    [self callAndWait:^(void (^done)()) {
        [app getRetailers:^(id<CSListPage> page, NSError *theError) {
            done();
        }];

    }];
    
    STAssertEqualObjects(requester.lastUsername, kUsername, nil);
    STAssertEqualObjects(requester.lastPassword, kPassword, nil);
}

- (void)testGetRetailersReturnsError
{
    NSURL *retailersURL = [appResource linkForRelation:@"/rels/retailers"].URL;
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                   @"HTTP error 500 Internal Server Error",
                               @"NSHTTPPropertyStatusCodeKey":
                                   @500};
    NSError *expectedError = [NSError errorWithDomain:@"test"
                                                 code:409
                                             userInfo:userInfo];
    [requester addGetError:expectedError forURL:retailersURL];
    
    __block NSArray *retailers = nil;
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    [self callAndWait:^(void (^done)()){
        [app getRetailers:^(id<CSListPage> page, NSError *theError) {
            retailers = page.items;
            error = theError;
            done();
        }];
    }];
    
    STAssertNotNil(error, nil);
    STAssertNil(retailers, @"%@", retailers);
    
    STAssertEqualObjects(error, expectedError, nil);
}

- (void)testGetRetailersLoadsPagesOfRetailerLinks
{
    YBHALResource *page0resource = [self resourceForFixture:
                                    @"retailers_page_0_links.json"];
    YBHALResource *page1resource = [self resourceForFixture:
                                    @"retailers_page_1_links.json"];
    YBHALResource *page2resource = [self resourceForFixture:
                                    @"retailers_page_2_links.json"];
    
    NSURL *page0URL = [appResource linkForRelation:@"/rels/retailers"].URL;
    [requester addGetResponse:page0resource forURL:page0URL];
    
    NSURL *page1URL = [page0resource linkForRelation:@"next"].URL;
    [requester addGetResponse:page1resource forURL:page1URL];

    NSURL *page2URL = [page1resource linkForRelation:@"next"].URL;
    [requester addGetResponse:page2resource forURL:page2URL];
    
    NSArray *links0 = [page0resource linksForRelation:@"/rels/retailer"];
    NSArray *expectedURLs0 = [links0 valueForKey:@"URL"];
    
    NSArray *links1 = [page1resource linksForRelation:@"/rels/retailer"];
    NSArray *expectedURLs1 = [links1 valueForKey:@"URL"];
    
    NSArray *links2 = [page2resource linksForRelation:@"/rels/retailer"];
    NSArray *expectedURLs2 = [links2 valueForKey:@"URL"];
    
    //
    
    __block id<CSListPage> page0 = nil;
    __block NSError *error0 = [NSError errorWithDomain:@"not called"
                                                      code:0
                                                  userInfo:nil];
    [self callAndWait:^(void (^done)()){
        [app getRetailers:^(id<CSListPage> page, NSError *error) {
            page0 = page;
            error0 = error;
            done();
        }];
    }];
    
    STAssertNil(error0, @"%@", error0);
    STAssertNotNil(page0, nil);
    STAssertNotNil(page0.items, nil);
    
    NSArray *actualURLs0 = [page0.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs0, expectedURLs0, nil);
    STAssertEqualObjects(@(page0.count), page0resource[@"count"], nil);
    [self checkNoPrevForPage:page0];
    STAssertTrue(page0.hasNext, nil);
    
    //
    
    __block id<CSListPage> page1 = nil;
    __block NSError *error1 = [NSError errorWithDomain:@"not called"
                                                  code:0
                                              userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page0 getNext:^(id<CSListPage> page, NSError *error) {
            page1 = page;
            error1 = error;
            done();
        }];
    }];
    
    STAssertNil(error1, @"%@", error1);
    STAssertNotNil(page1, nil);
    STAssertNotNil(page1.items, nil);
    
    NSArray *actualURLs1 = [page1.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs1, expectedURLs1, nil);
    STAssertEqualObjects(@(page1.count), page1resource[@"count"], nil);
    STAssertEqualObjects(@(page1.count), page0resource[@"count"], nil);
    STAssertTrue(page1.hasPrev, nil);
    STAssertTrue(page1.hasNext, nil);
    
    //
    
    __block id<CSListPage> page2 = nil;
    __block NSError *error2 = [NSError errorWithDomain:@"not called"
                                                  code:0
                                              userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page1 getNext:^(id<CSListPage> page, NSError *error) {
            page2 = page;
            error2 = error;
            done();
        }];
    }];
    
    STAssertNil(error2, @"%@", error1);
    STAssertNotNil(page2, nil);
    STAssertNotNil(page2.items, nil);
    
    NSArray *actualURLs2 = [page2.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs2, expectedURLs2, nil);
    STAssertEqualObjects(@(page2.count), page2resource[@"count"], nil);
    STAssertEqualObjects(@(page2.count), page0resource[@"count"], nil);
    STAssertTrue(page2.hasPrev, nil);
    [self checkNoNextForPage:page2];
    
    //
    
    __block id<CSListPage> page1again = nil;
    __block NSError *error1again = [NSError errorWithDomain:@"not called"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page2 getPrev:^(id<CSListPage> page, NSError *error) {
            page1again = page;
            error1again = error;
            done();
        }];
    }];
    
    STAssertNil(error1again, @"%@", error1);
    STAssertNotNil(page1again, nil);
    STAssertNotNil(page1again.items, nil);
    
    NSArray *actualURLs1again = [page1again.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs1again, expectedURLs1, nil);
    STAssertEqualObjects(@(page1again.count), page1resource[@"count"], nil);
    STAssertEqualObjects(@(page1again.count), page0resource[@"count"], nil);
    STAssertTrue(page1again.hasPrev, nil);
    STAssertTrue(page1again.hasNext, nil);
    
    //
    
    __block id<CSListPage> page0again = nil;
    __block NSError *error0again = [NSError errorWithDomain:@"not called"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page1 getPrev:^(id<CSListPage> page, NSError *error) {
            page0again = page;
            error0again = error;
            done();
        }];
    }];
    
    STAssertNil(error0again, @"%@", error1);
    STAssertNotNil(page0again, nil);
    STAssertNotNil(page0again.items, nil);
    
    NSArray *actualURLs0again = [page0again.items valueForKey:@"URL"];
    STAssertEqualObjects(actualURLs0again, expectedURLs0, nil);
    STAssertEqualObjects(@(page0again.count), page0resource[@"count"], nil);
    [self checkNoPrevForPage:page0again];
    STAssertTrue(page0again.hasNext, nil);
}

- (void)testGetRetailersNextAndPrevPassOnErrors
{
    YBHALResource *page0resource = [self resourceForFixture:
                                    @"retailers_page_0_links.json"];
    YBHALResource *page1resource = [self resourceForFixture:
                                    @"retailers_page_1_links.json"];
    
    NSURL *page0URL = [appResource linkForRelation:@"/rels/retailers"].URL;
    [requester addGetResponse:page0resource forURL:page0URL];
    
    NSURL *page1URL = [page0resource linkForRelation:@"next"].URL;
    [requester addGetResponse:page1resource forURL:page1URL];
    
    NSURL *page2URL = [page1resource linkForRelation:@"next"].URL;
    
    //
    
    __block id<CSListPage> page1 = nil;
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    [self callAndWait:^(void (^done)()){
        [app getRetailers:^(id<CSListPage> page0, NSError *error0) {
            if (error0) {
                error = error0;
                done();
                return;
            }
            [page0 getNext:^(id<CSListPage> page, NSError *error1) {
                page1 = page;
                error = error1;
                done();
            }];
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(page1, nil);
    STAssertTrue(page1.hasNext, nil);
    STAssertTrue(page1.hasPrev, nil);
    
    //

    NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                   @"HTTP error 500 Internal Server Error",
                               @"NSHTTPPropertyStatusCodeKey":
                                   @500};
    NSError *expectedError = [NSError errorWithDomain:@"test"
                                                 code:409
                                             userInfo:userInfo];
    [requester addGetError:expectedError forURL:page0URL];
    [requester addGetError:expectedError forURL:page2URL];
    
    __block id nextPage = @"not set";
    __block NSError *nextError = [NSError errorWithDomain:@"not called"
                                                     code:0
                                                 userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page1 getNext:^(id<CSListPage> page, NSError *error) {
            nextPage = page;
            nextError = error;
            done();
        }];
    }];
    
    STAssertNil(nextPage, @"%@", nextPage);
    STAssertEqualObjects(nextError, expectedError, nil);
    
    
    __block id prevPage = @"not set";
    __block NSError *prevError = [NSError errorWithDomain:@"not called"
                                                     code:0
                                                 userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [page1 getPrev:^(id<CSListPage> page, NSError *error) {
            prevPage = page;
            prevError = error;
            done();
        }];
    }];
    
    STAssertNil(prevPage, @"%@", prevPage);
    STAssertEqualObjects(prevError, expectedError, nil);
}


@end
