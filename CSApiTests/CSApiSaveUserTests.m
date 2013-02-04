//
//  CSApiSaveUserTests.m
//  CSApi
//
//  Created by Will Harris on 04/02/2013.
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

@interface CSApiSaveUserTests : CSAPITestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;

@property (strong) id<CSUser> user;
@property (strong) NSDictionary *userPass;

- (void)loadUser;

@end

@implementation CSApiSaveUserTests

@synthesize api;
@synthesize testApi;
@synthesize requester;
@synthesize user;
@synthesize userPass;

- (void)setUp
{
    [super setUp];
    
    testApi = [[TestApi alloc] initWithBookmark:kBookmark
                                       username:kUsername
                                       password:kPassword];
    api = (CSApi *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
    [self loadUser];
}

- (void)loadUser
{
    NSURL *userURL = [NSURL URLWithString:@"http://localhost:5000/users/12345"];
    YBHALResource *userResource = [self resourceForData:userGetResponseData()];
    [requester addGetResponse:userResource forURL:userURL];
    
    userPass = @{@"username": @"user",
                 @"password": @"pass"};
    id<CSCredential> credential = [CSBasicCredential
                                   credentialWithDictionary:userPass];
    
    __block id<CSUser> returnedUser = nil;
    __block NSError *returnedError = nil;
    [self callAndWait:^(void (^done)()) {
        [api getUser:userURL credential:credential callback:^(id<CSUser> aUser, NSError *error) {
            returnedUser = aUser;
            returnedError = error;
            done();
        }];
    }];
    
    STAssertNil(returnedError, @"%@", [returnedError localizedDescription]);
    STAssertNotNil(returnedUser.etag, nil);
    user = returnedUser;
}

- (void)testChangeRefAndMeta
{
    NSURL *userURL = [user url];
    YBHALResource *newUserResource = [self resourceForData:userPutRequestData()];
    __block id requestedEtag = nil;
    [requester addPutCallback:^(id body, id etag, requester_callback_t cb) {
        requestedEtag = etag;
        cb(newUserResource, nil, nil);
    }
                       forURL:userURL];
    
    user.reference = newUserResource[@"reference"];
    user.meta = newUserResource[@"meta"];
    
    __block BOOL success = nil;
    __block NSError *error = nil;
    [self callAndWait:^(void (^done)()) {
        [user save:^(BOOL returnedSuccess, NSError *returnedError) {
            success = returnedSuccess;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertTrue(success, nil);
    STAssertNil(error, @"%@", [error localizedDescription]);
    
    STAssertEqualObjects(requestedEtag, user.etag, nil);
    
    STAssertNotNil(user.url, nil);
    STAssertEqualObjects(user.url, userURL, nil);
    
    STAssertEqualObjects(requester.lastUsername, userPass[@"username"], nil);
    STAssertEqualObjects(requester.lastPassword, userPass[@"password"], nil);
    
    STAssertEqualObjects(user.reference, newUserResource[@"reference"], nil);
    STAssertEqualObjects(user.meta, newUserResource[@"meta"], nil);
}

- (void)testSaveReturnsError
{
    NSURL *userURL = [user url];
    YBHALResource *newUserResource = [self resourceForData:userPutRequestData()];
    __block id requestedEtag = nil;
    [requester addPutCallback:^(id body, id etag, requester_callback_t cb) {
        requestedEtag = etag;
        const static int statusCode = 409;
        NSDictionary *userInfo =
            @{NSLocalizedDescriptionKey:
                  [NSHTTPURLResponse localizedStringForStatusCode:statusCode]};
        cb(nil, nil, [NSError errorWithDomain:@"Error"
                                         code:statusCode
                                     userInfo:userInfo]);
    }
                       forURL:userURL];
    
    user.reference = newUserResource[@"reference"];
    user.meta = newUserResource[@"meta"];
    
    __block BOOL success = nil;
    __block NSError *error = nil;
    [self callAndWait:^(void (^done)()) {
        [user save:^(BOOL returnedSuccess, NSError *returnedError) {
            success = returnedSuccess;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertFalse(success, nil);
    STAssertNotNil(error, nil);
}

@end
