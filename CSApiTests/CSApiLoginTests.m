//
//  CSApiLoginTests.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCClassMockObject.h>
#import "CSApi.h"
#import "CSCredentials.h"
#import "CSAuthenticator.h"
#import "TestApi.h"
#import "TestRequester.h"
#import "TestAPIStore.h"
#import <HyperBek/HyperBek.h>
#import "TestFixtures.h"

@interface CSApiLoginTests : SenTestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;
@property (strong) TestAPIStore *store;

@end

@implementation CSApiLoginTests

@synthesize api;
@synthesize testApi;
@synthesize requester;
@synthesize store;

static NSString *kBookmark = @"http://localhost:5000/apps/5106b3de704679b792c918c8";
static NSString *kUsername = @"c6dd81c6-af73-4ffd-ba8d-5419cbf8a0cb";
static NSString *kPassword = @"2af58818-c7c0-4503-b7e6-b95d661474f4";

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

+ (NSDictionary *)jsonForData:(NSData *)data
{
    __block NSError *error = nil;
    id json = [NSJSONSerialization JSONObjectWithData:data
                                              options:0
                                                error:&error];
    
    return json;
}

- (NSDictionary *)jsonForData:(NSData *)data
{
    return [[self class] jsonForData:data];
}

+ (YBHALResource *)resourceForJson:(NSDictionary *)json
{
    NSURL *url = [NSURL URLWithString:kBookmark];
    YBHALResource *resource = [json HALResourceWithBaseURL:url];
    return resource;
}

- (YBHALResource *)resourceForJson:(NSDictionary *)json
{
    return [[self class] resourceForJson:json];
}

- (YBHALResource *)resourceForData:(NSData *)data
{
    NSDictionary *json = [self jsonForData:data];
    return [self resourceForJson:json];
}

- (void)setUp
{
    [super setUp];
    
    testApi = [[TestApi alloc] initWithBookmark:kBookmark
                                       username:kUsername
                                       password:kPassword];
    api = (CSApi *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
    store = [[TestAPIStore alloc] init];
    testApi.store = store;
}

- (void)testFirstLoginCreatesNewUser
{
    YBHALResource *appResource = [self resourceForData:appData()];
    [requester addGetResponse:appResource forURL:[NSURL URLWithString:kBookmark]];
    
    YBHALResource *userResource = [self resourceForData:userPostReponseData()];
    [requester addPostResponse:userResource forURL:[appResource linkForRelation:@"/rels/users"].URL];
    
    [store resetToFirstLogin];
    
    __block id<CSUser> returnedUser = nil;
    __block NSError *returnedError = nil;
    [self callAndWait:^(void (^done)()) {
        [api login:^(id<CSUser> user, NSError *error) {
            returnedUser = user;
            returnedError = error;
            done();
        }];
    }];
    STAssertNil(returnedError, @"%@", [returnedError localizedDescription]);
    
    STAssertNotNil(returnedUser.url, nil);
    STAssertNotNil(store.userUrl, nil);
    STAssertEqualObjects(store.userUrl, returnedUser.url, nil);
    
    id mockAuthenticator = [OCMockObject mockForProtocol:@protocol(CSAuthenticator)];
    [[mockAuthenticator expect] applyBasicAuthWithUsername:userResource[@"credential"][@"username"]
                                                  password:userResource[@"credential"][@"password"]];
    [store.userCredential applyWith:mockAuthenticator];
    [mockAuthenticator verify];
}

@end
