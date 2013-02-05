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
    [requester addGetCallback:^(id body, id etag, requester_callback_t cb) {
        cb(userResource, @"ORIGINAL ETAG", nil);
    } forURL:userURL];
    
    userPass = @{@"username": @"user",
                 @"password": @"pass"};
    id<CSCredential> credential = [CSBasicCredential
                                   credentialWithDictionary:userPass];
    
    __block id<CSUser> returnedUser = nil;
    __block NSError *returnedError = nil;
    [self callAndWait:^(void (^done)()) {
        [api getUser:userURL
          credential:credential
            callback:^(id<CSUser> aUser, NSError *error)
        {
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
    id originalEtag = user.etag;
    NSURL *userURL = [user url];
    YBHALResource *newUserResource = [self resourceForData:userPutRequestData()];
    __block id requestedEtag = nil;
    [requester addPutCallback:^(id body, id etag, requester_callback_t cb) {
        requestedEtag = etag;
        cb(newUserResource, @"NEW ETAG", nil);
    }
                       forURL:userURL];
    
    __block BOOL success = nil;
    __block NSError *error = nil;
    [self callAndWait:^(void (^done)()) {
        [user change:^(id<CSMutableUser> userToChange) {
            userToChange.reference = newUserResource[@"reference"];
            userToChange.meta = newUserResource[@"meta"];
        } callback:^(BOOL returnedSuccess, NSError *returnedError) {
            success = returnedSuccess;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertTrue(success, nil);
    STAssertNil(error, @"%@", [error localizedDescription]);
    
    STAssertEqualObjects(requestedEtag, originalEtag, nil);
    STAssertEqualObjects(user.etag, @"NEW ETAG", nil);
    
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
        const static int statusCode = 500;
        NSDictionary *userInfo =
            @{NSLocalizedDescriptionKey:
                  [NSHTTPURLResponse localizedStringForStatusCode:statusCode]};
        cb(nil, nil, [NSError errorWithDomain:@"Error"
                                         code:statusCode
                                     userInfo:userInfo]);
    }
                       forURL:userURL];
    
    NSString *originalReference = user.reference;
    NSDictionary *originalMeta = user.meta;
    id originalEtag = user.etag;
    NSURL *originalURL = user.url;
    
    __block BOOL success = nil;
    __block NSError *error = nil;
    [self callAndWait:^(void (^done)()) {
        [user change:^(id<CSMutableUser> userToChange) {
            userToChange.reference = newUserResource[@"reference"];
            userToChange.meta = newUserResource[@"meta"];
        } callback:^(BOOL returnedSuccess, NSError *returnedError) {
            success = returnedSuccess;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertFalse(success, nil);
    STAssertNotNil(error, nil);
    
    STAssertEqualObjects(user.reference, originalReference,
                         @"change:callback: does not change user reference on error");
    STAssertEqualObjects(user.meta, originalMeta,
                         @"change:callback: does not change user meta on error");
    STAssertEqualObjects(user.etag, originalEtag,
                         @"change:callback: does not change user etag on error");
    STAssertEqualObjects(user.url, originalURL,
                         @"change:callback: does not change user url on error");
}

- (void)testRetriesConflictedChange
{
    NSURL *userURL = [user url];
    YBHALResource *conflictResource = [self resourceForData:dataForFixture(@"user_conflict_1.json")];
    STAssertNotNil(conflictResource, nil);
    id originalEtag = user.etag;
    STAssertNotNil(originalEtag, nil);
    id newEtag = @"NEW ETAG";
    __block id currentEtag = newEtag;
    id lastEtag = @"LAST ETAG";
    NSMutableArray *getEtags = [NSMutableArray array];
    [requester addGetCallback:^(id body, id etag, requester_callback_t cb) {
        [getEtags addObject:etag ? etag : @"(nil)"];
        cb(conflictResource, newEtag, nil);
    } forURL:userURL];
    
    NSMutableArray *putEtags = [NSMutableArray array];
    [requester addPutCallback:^(id body, id etag, requester_callback_t cb) {
        [putEtags addObject:etag ? etag : @"(nil)"];
        if ( ! etag) {
            cb(nil, nil, [NSError errorWithDomain:@"test" code:412 userInfo:@{NSLocalizedDescriptionKey: @"HTTP error 412 Precondition Failed",
                          @"NSHTTPPropertyStatusCodeKey": @412}]);
            return;
        }
        if ( ! [etag isEqual:currentEtag]) {
            cb(nil, nil, [NSError errorWithDomain:@"test" code:409 userInfo:@{NSLocalizedDescriptionKey: @"HTTP error 409 Conflict",
                          @"NSHTTPPropertyStatusCodeKey": @409}]);
            return;
        }
        
        currentEtag = lastEtag;
        cb(body, lastEtag, nil);
    } forURL:userURL];
    
    NSMutableArray *counts = [NSMutableArray array];
    __block BOOL changeSuccess = NO;
    __block NSError *changeError = nil;
    [self callAndWait:^(void (^done)()) {
        [user change:^(id<CSMutableUser> mutableUser) {
            [counts addObject:mutableUser.meta[@"count"]];
            NSInteger num = [mutableUser.meta[@"count"] intValue] + 1;
            mutableUser.meta[@"count"] = @(num);
        } callback:^(BOOL success, NSError *error) {
            changeSuccess = success;
            changeError = error;
            done();
        }];
    }];
    
    STAssertEqualObjects(currentEtag, lastEtag, nil);
    STAssertEqualObjects(putEtags, (@[originalEtag, newEtag]), nil);
    STAssertEqualObjects(getEtags, (@[@"(nil)"]), nil);
    STAssertTrue(changeSuccess, nil);
    STAssertNil(changeError, @"%@", changeError);
    STAssertEqualObjects(counts, (@[@0, @1]), nil);
    STAssertEqualObjects(user.meta[@"count"], @2, nil);
    STAssertEqualObjects(user.etag, @"LAST ETAG", nil);
}

@end
