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

#import "CSApi.h"

@interface CSApiTests : SenTestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;

@end

@implementation CSApiTests

static NSString *kBookmark = @"http://localhost:5000/apps/5106b3de704679b792c918c8";
static NSString *kUsername = @"c6dd81c6-af73-4ffd-ba8d-5419cbf8a0cb";
static NSString *kPassword = @"2af58818-c7c0-4503-b7e6-b95d661474f4";

@synthesize testApi;
@synthesize api;
@synthesize requester;

- (void)setUp
{
    [super setUp];
    
    testApi = [[TestApi alloc] initWithBookmark:kBookmark
                                       username:kUsername
                                       password:kPassword];
    api = (CSApi *)testApi;
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

- (void)callAndWait:(void (^)(void (^done)()))blk
{
    dispatch_semaphore_t semaphore = dispatch_semaphore_create(0);
    
    void (^done)() = ^{
        dispatch_semaphore_signal(semaphore);
    };
    
    blk(done);
    [self waitForSemaphore:semaphore];
}

- (void)waitForSemaphore:(dispatch_semaphore_t)semaphore
{
    long timedout;
    for (int tries = 0; tries < 1; tries++) {
        timedout = dispatch_semaphore_wait(semaphore, DISPATCH_TIME_NOW);
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode
                                 beforeDate:[NSDate dateWithTimeIntervalSinceNow:0.1]];
    }
    
    STAssertFalse(timedout, @"Timed out waiting for callback");
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
        [api getApplication:[NSURL URLWithString:kBookmark]
                   callback:^(id<CSApplication> anApp, NSError *anError)
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
        [api getApplication:[NSURL URLWithString:kBookmark]
                   callback:^(id<CSApplication> anApp, NSError *anError)
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

- (void)testUsesCredentials
{
    [self callAndWait:^(void (^done)()) {
        [api getApplication:[NSURL URLWithString:kBookmark]
                   callback:^(id<CSApplication> anApp, NSError *anError)
         {
             done();
         }];
    }];
    
    STAssertEqualObjects(requester.lastUsername, kUsername, nil);
    STAssertEqualObjects(requester.lastPassword, kPassword, nil);
}

@end
