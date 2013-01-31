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
#import "TestConstants.h"

#import "CSAPITestCase.h"

@interface CSApiLoginTests : CSAPITestCase

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
    
    YBHALResource *userResource = [self resourceForData:userPostResponseData()];
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

- (void)testSecondLoginReusesExistingUser
{
    NSURL *userURL = [NSURL URLWithString:@"http://localhost:5000/users/12345"];
    YBHALResource *userResource = [self resourceForData:userGetResponseData()];
    [requester addGetResponse:userResource forURL:userURL];
    
    [store resetWithURL:userURL
             credential:@{@"username": @"user",
                          @"password": @"pass"}];
    
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
    STAssertEqualObjects(store.userUrl, userURL, nil);
    STAssertEqualObjects(returnedUser.url, userURL, nil);
    
    id mockAuthenticator = [OCMockObject mockForProtocol:@protocol(CSAuthenticator)];
    [[mockAuthenticator expect] applyBasicAuthWithUsername:@"user"
                                                  password:@"pass"];
    [returnedUser.credential applyWith:mockAuthenticator];
    [mockAuthenticator verify];
}

@end
