//
//  CSAPIRequesterTests.m
//  CSApi
//
//  Created by Will Harris on 05/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <OHHTTPStubs/OHHTTPStubs.h>
#import "CSAPIRequester.h"
#import "CSBasicCredential.h"

#import <HyperBek/HyperBek.h>
#import "CSAPITestCase.h"
#import "TestFixtures.h"
#import <OCMock/OCMock.h>
#import <Base64/MF_Base64Additions.h>

@interface CSAPIRequesterTests : CSAPITestCase

@property (nonatomic, strong) id<CSRequester> requester;
@property (nonatomic, strong) NSURL *baseUrl;
@property (nonatomic, strong) NSData *userData;
@property (nonatomic, strong) YBHALResource *expectedResource;
@property (nonatomic, strong) NSURL *userURL;
@property (nonatomic, strong) NSString *userEtag;
@property (nonatomic, strong) CSBasicCredential *basicCredential;
@property (nonatomic, strong) NSString *expectedAuth;

@end


@implementation CSAPIRequesterTests

@synthesize requester;
@synthesize baseUrl;
@synthesize userData;
@synthesize expectedResource;
@synthesize userURL;
@synthesize userEtag;
@synthesize basicCredential;
@synthesize expectedAuth;

- (void)setUp
{
    requester = [[CSAPIRequester alloc] init];
    baseUrl = [NSURL URLWithString:@"http://localhost:8192/"];
    
    userData = userGetResponseData();
    NSError *jsonError = nil;
    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData
                                                             options:0
                                                               error:&jsonError];
    STAssertNil(jsonError, @"@%", jsonError);
    STAssertNotNil(userDict, nil);
    
    
    expectedResource = [[YBHALResource alloc] initWithDictionary:userDict
                                                         baseURL:baseUrl];
    STAssertNotNil(expectedResource, nil);
    
    userURL = [expectedResource linkForRelation:@"self"].URL;
    STAssertNotNil(userURL, nil);
    
    userEtag = @"\"USERETAG\"";
    NSDictionary *credentailDict = @{@"username": @"user",
                                     @"password": @"pass"};
    basicCredential = [CSBasicCredential credentialWithDictionary:
                       credentailDict];
    expectedAuth = [NSString stringWithFormat:@"Basic %@",
                              [@"user:pass" base64String]];
}

- (void)testGetReturnsHAL
{
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *auth = [request valueForHTTPHeaderField:@"Authorization"];
        if ( ! [auth isEqualToString:expectedAuth]) {
            NSDictionary *headers = @{@"WWW-Authenticate":
                                          @"Basic realm=\"hyperapi\""};
            return [OHHTTPStubsResponse responseWithData:[NSData data]
                                              statusCode:401
                                            responseTime:0.0
                                                 headers:headers];
        }
        NSDictionary *headers = @{@"Etag": userEtag,
                                  @"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:200
                                        responseTime:0.0
                                             headers:headers];
    }];
    

    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester getURL:userURL
               credential:basicCredential
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];

    STAssertEqualObjects([(id)actualResource dictionary],
                         [(id)expectedResource dictionary],
                         nil);
    STAssertEqualObjects(actualEtag, userEtag, nil);
    STAssertNil(actualError, @"%@", actualError);
}

- (void)testGetReturnsErrorForInvalidJSON
{
    NSData *badData = [@"this is not valid JSON"
                       dataUsingEncoding:NSUTF8StringEncoding];
    
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSString *auth = [request valueForHTTPHeaderField:@"Authorization"];
        if ( ! [auth isEqualToString:expectedAuth]) {
            NSDictionary *headers = @{@"WWW-Authenticate":
                                          @"Basic realm=\"hyperapi\""};
            return [OHHTTPStubsResponse responseWithData:[NSData data]
                                              statusCode:401
                                            responseTime:0.0
                                                 headers:headers];
        }
        NSDictionary *headers = @{@"Etag": userEtag,
                                  @"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:badData
                                          statusCode:200
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester getURL:userURL
               credential:basicCredential
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testGetReturnsErrorForValidHalWithError
{    
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary *headers = @{@"Etag": userEtag,
                                  @"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:409
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester getURL:userURL
               credential:basicCredential
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
    STAssertEqualObjects(actualError.userInfo[@"NSHTTPPropertyStatusCodeKey"],
                         @409,
                         nil);
}

@end
