//
//  CSApiLoginTests.m
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCClassMockObject.h>
#import "CSAPI.h"
#import "CSCredential.h"
#import "CSAuthenticator.h"
#import "TestApi.h"
#import "TestRequester.h"
#import "TestAPIStore.h"
#import <HyperBek/HyperBek.h>
#import "TestFixtures.h"
#import "TestConstants.h"

#import "CSAPITestCase.h"

@interface CSApiLoginTests : CSAPITestCase

@property (weak) CSAPI *api;
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
    api = (CSAPI *)testApi;
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
    
    STAssertEqualObjects(returnedUser.reference, userResource[@"reference"], nil);
    STAssertEqualObjects(returnedUser.meta, userResource[@"meta"], nil);
}

- (void)testNewUserCanBeChanged
{
    YBHALResource *appResource = [self resourceForData:appData()];
    YBHALResource *userResource = [self resourceForData:userPostResponseData()];
    YBHALResource *userGetResource = [self resourceForData:userGetResponseData()];
    STAssertNotNil(userGetResource, nil);
    [requester addGetResponse:appResource forURL:[NSURL URLWithString:kBookmark]];
    
    NSURL *createUserURL = [appResource linkForRelation:@"/rels/users"].URL;
    [requester addPostCallback:^(id body, id etag, requester_callback_t cb) {
        cb(userResource, nil, nil);
    } forURL:createUserURL];
    __block BOOL didCallGet = NO;
    
    [requester addGetCallback:^(id body, id etag, requester_callback_t cb) {
        didCallGet = YES;
        cb(userGetResource, @"ETAG FROM GET", nil);
    } forURL:[userResource linkForRelation:@"self"].URL];
    
    [store resetToFirstLogin];
    
    __block id<CSUser> returnedUser = nil;
    [self callAndWait:^(void (^done)()) {
        [api login:^(id<CSUser> user, NSError *error) {
            returnedUser = user;
            done();
        }];
    }];
    
    id originalEtag = returnedUser.etag;
    STAssertNil(originalEtag, [originalEtag description]);
    
    __block id putEtag = nil;
    [requester addPutCallback:^(id body, id etag, requester_callback_t cb) {
        putEtag = etag;
        if ( ! etag) {
            cb(nil, nil, [NSError errorWithDomain:@"test" code:412 userInfo:@{NSLocalizedDescriptionKey: @"HTTP error 412 Precondition Failed",
                          @"NSHTTPPropertyStatusCodeKey": @412}]);
            return;
        }
        if ( ! [etag isEqual:@"ETAG FROM GET"]) {
            cb(nil, nil, [NSError errorWithDomain:@"test" code:409 userInfo:@{NSLocalizedDescriptionKey: @"HTTP error 409 Conflict",
                      @"NSHTTPPropertyStatusCodeKey": @409}]);
            return;
        }
        cb(body, @"NEW ETAG", nil);
    } forURL:returnedUser.url];

    __block BOOL returnedSuccess = NO;
    __block NSError *returnedError = nil;
    
    [self callAndWait:^(void (^done)()){
        [returnedUser change:^(id<CSMutableUser> user) {
            user.reference = @"changed reference";
        } callback:^(BOOL success, NSError *error) {
            returnedSuccess = success;
            returnedError = error;
            done();
        }];
    }];
    
    STAssertTrue(didCallGet, nil);
    STAssertEqualObjects(putEtag, @"ETAG FROM GET", nil);
    STAssertTrue(returnedSuccess, nil);
    STAssertNil(returnedError, @"%@", [returnedError localizedDescription]);
    STAssertEqualObjects(returnedUser.reference, @"changed reference", nil);
    STAssertEqualObjects(@"NEW ETAG", returnedUser.etag, nil);
}

@end
