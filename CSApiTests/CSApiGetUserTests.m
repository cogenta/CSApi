//
//  CSApiGetUserTests.m
//  CSApi
//
//  Created by Will Harris on 01/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"

#import "CSApi.h"
#import "CSAuthenticator.h"
#import "CSCredential.h"
#import "CSBasicCredential.h"

#import <OCMock/OCMock.h>
#import <HyperBek/HyperBek.h>

#import "TestFixtures.h"
#import "TestApi.h"
#import "TestRequester.h"
#import "TestConstants.h"

@interface CSApiGetUserTests : CSAPITestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;

@end

@implementation CSApiGetUserTests

@synthesize api;
@synthesize testApi;
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

- (void)testLoadsExistingUser
{
    NSURL *userURL = [NSURL URLWithString:@"http://localhost:5000/users/12345"];
    YBHALResource *userResource = [self resourceForData:userGetResponseData()];
    [requester addGetResponse:userResource forURL:userURL];
    
    NSDictionary *userPass = @{@"username": @"user",
                               @"password": @"pass"};
    id<CSCredential> credential = [CSBasicCredential
                                   credentialWithDictionary:userPass];
    
    __block id<CSUser> returnedUser = nil;
    __block NSError *returnedError = nil;
    [self callAndWait:^(void (^done)()) {
        [api getUser:userURL credential:credential callback:^(id<CSUser> user, NSError *error) {
            returnedUser = user;
            returnedError = error;
            done();
        }];
    }];
    
    STAssertNil(returnedError, @"%@", [returnedError localizedDescription]);
    
    STAssertNotNil(returnedUser.url, nil);
    STAssertEqualObjects(returnedUser.url, userURL, nil);
    
    STAssertEqualObjects(requester.lastUsername, userPass[@"username"], nil);
    STAssertEqualObjects(requester.lastPassword, userPass[@"password"], nil);
    
    STAssertNotNil(returnedUser.etag, nil);
    STAssertEqualObjects(returnedUser.reference, userResource[@"reference"], nil);
    STAssertEqualObjects(returnedUser.meta, userResource[@"meta"], nil);
}

- (void)testFailsToLoadMissingUser
{
    NSURL *realURL = [NSURL URLWithString:@"http://localhost:5000/users/12345"];
    NSURL *missingURL = [NSURL URLWithString:@"http://localhost:5000/users/12346"];
    YBHALResource *userResource = [self resourceForData:userGetResponseData()];
    [requester addGetResponse:userResource forURL:realURL];
    
    NSDictionary *userPass = @{@"username": @"user",
                               @"password": @"pass"};
    id<CSCredential> credential = [CSBasicCredential
                                   credentialWithDictionary:userPass];
    
    __block id<CSUser> returnedUser = nil;
    __block NSError *returnedError = nil;
    [self callAndWait:^(void (^done)()) {
        [api getUser:missingURL credential:credential
            callback:^(id<CSUser> user, NSError *error)
        {
            returnedUser = user;
            returnedError = error;
            done();
        }];
    }];
    
    STAssertNotNil(returnedError, nil);
    STAssertNil(returnedUser, @"%@", returnedUser);
    
    STAssertEqualObjects(requester.lastUsername, userPass[@"username"], nil);
    STAssertEqualObjects(requester.lastPassword, userPass[@"password"], nil);
}

@end
