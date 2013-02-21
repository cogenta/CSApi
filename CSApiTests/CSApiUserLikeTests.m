//
//  CSApiUserLikeTests.m
//  CSApi
//
//  Created by Will Harris on 21/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSAPI.h"
#import "TestApi.h"
#import "TestRequester.h"
#import "TestConstants.h"
#import "TestFixtures.h"
#import "CSBasicCredential.h"
#import <OCMock/OCMock.h>

@interface CSApiUserLikeTests : CSAPITestCase

@property (weak) CSAPI *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;
@property (strong) id<CSUser> user;
@property (strong) NSURL *likesURL;

@end

@implementation CSApiUserLikeTests

@synthesize api;
@synthesize testApi;
@synthesize requester;
@synthesize user;
@synthesize likesURL;

- (void)setUp
{
    [super setUp];
    
    testApi = [TestApi apiWithBookmark:kBookmark
                              username:kUsername
                              password:kPassword];
    api = (CSAPI *)testApi;
    requester = [[TestRequester alloc] init];
    testApi.requester = requester;
    
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
    STAssertNotNil(returnedUser, nil);

    user = returnedUser;
    
    likesURL = [userResource linkForRelation:@"/rels/likes"].URL;
    STAssertNotNil(likesURL, nil);
}

- (void)testLikesInitiallyEmpty
{
    YBHALResource *postResponse = [self resourceForFixture:@"like.json"];
    __block YBHALResource *sentBody = nil;
    
    [requester addPostCallback:^(YBHALResource *body,
                                 id etag,
                                 requester_callback_t cb)
    {
        sentBody = body;
        
        cb(postResponse, nil, nil);
    } forURL:likesURL];
    
    NSURL *apiURL = [NSURL URLWithString:self.api.bookmark];
    NSURL *retailerURL = [[NSURL URLWithString:@"/retailers/test"
                                 relativeToURL:apiURL]
                          absoluteURL];
    id retailer = [OCMockObject mockForProtocol:@protocol(CSRetailer)];
    [[[retailer stub] andReturn:retailerURL] URL];
    
    __block id<CSLike> like = nil;
    __block NSError *error = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [user createLikeWithChange:^(id<CSMutableLike> mutableLike) {
             mutableLike.retailer = retailer;
        }
                          callback:^(id<CSLike> aLike, NSError *anError)
        {
            like = aLike;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(like, nil);
    STAssertNotNil(sentBody, nil);
    
    NSURL *sentRetailerURL = [sentBody linkForRelation:@"/rels/retailer"].URL;
    STAssertNotNil(sentRetailerURL, nil);
    STAssertEqualObjects(sentRetailerURL, retailerURL, nil);
}

@end
