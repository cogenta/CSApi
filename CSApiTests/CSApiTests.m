//
//  CSApiTests.m
//  CSApiTests
//
//  Created by Will Harris on 28/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <HyperBek/HyperBek.h>
#import "TestRequester.h"
#import "TestApi.h"
#import "TestConstants.h"

#import "CSAPI.h"

#import "CSAPITestCase.h"

@interface CSApiTests : CSAPITestCase

@property (weak) CSAPI *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;

@end

@implementation CSApiTests

@synthesize testApi;
@synthesize api;
@synthesize requester;

- (void)setUp
{
    [super setUp];
    
    testApi = [TestApi apiWithBookmark:kBookmark
                              username:kUsername
                              password:kPassword];
    api = (CSAPI *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
}

- (void)tearDown
{
    self.api = nil;
    self.testApi = nil;
    self.requester = nil;
    
    [super tearDown];
}

- (void)testGetApplicationWithResult
{
    NSDictionary *resultDict = [NSDictionary dictionary];
    NSURL *url = [NSURL URLWithString:kBookmark];
    YBHALResource *result = [resultDict HALResourceWithBaseURL:url];
    [requester addGetResponse:result forURL:url];
    
    __block id<CSApplication> app = nil;
    __block NSError *error = nil;
    [self callAndWait:^(void (^done)()) {
        [api getApplication:^(id<CSApplication> anApp, NSError *anError)
        {
            app = anApp;
            error = anError;
            done();
        }];
    }];
    
    STAssertNotNil(app, nil);
    STAssertNil(error, [error localizedDescription]);
}

- (void)testGetApplicationWithError
{
    NSURL *url = [NSURL URLWithString:kBookmark];
    NSString *message = @"Not Authorized";
    NSDictionary *userInfo = @{NSLocalizedDescriptionKey: message};
    NSError *expectedError = [NSError errorWithDomain:NSURLErrorDomain
                                                 code:404
                                             userInfo:userInfo];
    [requester addGetError:expectedError forURL:url];
    
    __block id<CSApplication> app = nil;
    __block NSError *errorResponse = nil;
    [self callAndWait:^(void (^done)()) {
        [api getApplication:^(id<CSApplication> anApp, NSError *anError)
         {
             app = anApp;
             errorResponse = anError;
             done();
         }];
    }];
    
    STAssertNil(app, nil);
    STAssertNotNil(errorResponse, nil);
    STAssertEqualObjects(errorResponse, expectedError, nil);
}

- (void)testUsesCredential
{
    [self callAndWait:^(void (^done)()) {
        [api getApplication:^(id<CSApplication> anApp, NSError *anError)
         {
             done();
         }];
    }];
    
    STAssertEqualObjects(requester.lastUsername, kUsername, nil);
    STAssertEqualObjects(requester.lastPassword, kPassword, nil);
}

@end
