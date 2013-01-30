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

#import "CSApi.h"

@interface CSApplicationTests : SenTestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;
@property (strong) YBHALResource *appResource;
@property (strong) id<CSApplication> app;

@end

NSData *
appData() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/app.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}

@implementation CSApplicationTests

static NSString *kBookmark = @"http://localhost:5000/apps/5106b3de704679b792c918c8";
static NSString *kUsername = @"c6dd81c6-af73-4ffd-ba8d-5419cbf8a0cb";
static NSString *kPassword = @"2af58818-c7c0-4503-b7e6-b95d661474f4";



@synthesize testApi;
@synthesize api;
@synthesize requester;
@synthesize appResource;
@synthesize app;

- (void)setUp
{
    [super setUp];
    
    testApi = [[TestApi alloc] initWithBookmark:kBookmark
                                       username:kUsername
                                       password:kPassword];
    api = (CSApi *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
    
    __block NSError *error = nil;
    
    id appJson = [NSJSONSerialization JSONObjectWithData:appData()
                                                 options:0
                                                   error:&error];
    STAssertTrue([NSJSONSerialization isValidJSONObject:appJson], nil);
    
    STAssertNotNil(appJson, nil);
    STAssertNil(error, nil);
    
    NSURL *url = [NSURL URLWithString:kBookmark];
    appResource = [appJson HALResourceWithBaseURL:url];
    STAssertNotNil(appResource, nil);
    
    [requester addGetResponse:appResource forURL:url];
    
    [self callAndWait:^(void (^done)()) {
        [api getApplication:[NSURL URLWithString:kBookmark]
                   callback:^(id<CSApplication> anApp, NSError *anError)
         {
             app = anApp;
             error = anError;
             done();
         }];
    }];
    
    STAssertNil(error, nil);
}

- (void)tearDown
{
    self.api = nil;
    self.testApi = nil;
    self.requester = nil;
    self.app = nil;
    
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

- (void)testName
{
    STAssertEquals(app.name, appResource[@"name"], nil);
}

@end
