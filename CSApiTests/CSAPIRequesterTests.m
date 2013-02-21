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
@property (nonatomic, strong) YBHALResource *userResource;
@property (nonatomic, strong) NSURL *userURL;
@property (nonatomic, strong) NSString *userEtag;
@property (nonatomic, strong) CSBasicCredential *basicCredential;
@property (nonatomic, strong) NSString *expectedAuth;
@property (nonatomic, strong) NSData *badData;
@property (nonatomic, strong) id putEtag;

@end


@implementation CSAPIRequesterTests

@synthesize requester;
@synthesize baseUrl;
@synthesize userData;
@synthesize userResource;
@synthesize userURL;
@synthesize userEtag;
@synthesize basicCredential;
@synthesize expectedAuth;
@synthesize badData;
@synthesize putEtag;

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
    
    
    userResource = [[YBHALResource alloc] initWithDictionary:userDict
                                                         baseURL:baseUrl];
    STAssertNotNil(userResource, nil);
    
    userURL = [userResource linkForRelation:@"self"].URL;
    STAssertNotNil(userURL, nil);
    
    userEtag = @"\"USERETAG\"";
    NSDictionary *credentailDict = @{@"username": @"user",
                                     @"password": @"pass"};
    basicCredential = [CSBasicCredential credentialWithDictionary:
                       credentailDict];
    expectedAuth = [NSString stringWithFormat:@"Basic %@",
                              [@"user:pass" base64String]];
    
    badData = [@"this is not valid JSON" dataUsingEncoding:NSUTF8StringEncoding];
    
    putEtag = @"\"SENTETAG\"";
}

- (void)tearDown
{
    [OHHTTPStubs removeAllRequestHandlers];
}

#pragma mark - GET requests

- (void)testGetReturnsHAL
{
    __block id actualMethod = @"NOT SET";
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        actualMethod = request.HTTPMethod;
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

    STAssertEqualObjects(actualMethod, @"GET", nil);
    STAssertEqualObjects([(id)actualResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    STAssertEqualObjects(actualEtag, userEtag, nil);
    STAssertNil(actualError, @"%@", actualError);
}

- (void)testGetReturnsErrorForInvalidJSON
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

#pragma mark - POST requests

- (void)testPostReturnsHAL
{
    __block id actualMethod = @"NOT SET";
    __block id actualPostBody = [@"{\"not\": \"set\"}" dataUsingEncoding:NSUTF8StringEncoding];
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        actualMethod = request.HTTPMethod;
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
                                  @"Content-Type": @"application/hal+json",
                                  @"Location": [userURL absoluteString]};
        actualPostBody = request.HTTPBody;
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:201
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester postURL:userURL
                credential:basicCredential
                      body:userResource
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertEqualObjects(actualMethod, @"POST", nil);
    STAssertNotNil(actualPostBody, nil);
    NSError *jsonError = nil;
    NSDictionary *bodyJSON = [NSJSONSerialization
                              JSONObjectWithData:actualPostBody
                              options:0
                              error:&jsonError];
    STAssertNotNil(bodyJSON, nil);
    STAssertNil(jsonError, @"%@", jsonError);
    YBHALResource *bodyResource = [[YBHALResource alloc]
                                   initWithDictionary:bodyJSON
                                   baseURL:userURL];
    
    STAssertEqualObjects([(id)bodyResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    
    STAssertEqualObjects([(id)actualResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    STAssertEqualObjects(actualEtag, userEtag, nil);
    STAssertNil(actualError, @"%@", actualError);
}

- (void)testPostReturnsErrorForInvalidResponseJSON
{
    __block id actualPostBody = [@"{\"not\": \"set\"}" dataUsingEncoding:NSUTF8StringEncoding];
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
                                  @"Content-Type": @"application/hal+json",
                                  @"Location": [userURL absoluteString]};
        actualPostBody = request.HTTPBody;
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
        [requester postURL:userURL
                credential:basicCredential
                      body:userResource
                  callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertNotNil(actualPostBody, nil);
    NSError *jsonError = nil;
    NSDictionary *bodyJSON = [NSJSONSerialization
                              JSONObjectWithData:actualPostBody
                              options:0
                              error:&jsonError];
    STAssertNotNil(bodyJSON, nil);
    STAssertNil(jsonError, @"%@", jsonError);
    YBHALResource *bodyResource = [[YBHALResource alloc]
                                   initWithDictionary:bodyJSON
                                   baseURL:userURL];
    
    STAssertEqualObjects([(id)bodyResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPostReturnsErrorForNilRequestBody
{
    __block BOOL didMakeRequest = NO;
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        didMakeRequest = YES;
        return nil;
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester postURL:userURL
                credential:basicCredential
                      body:@"BAD RESOURCE"
                  callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertFalse(didMakeRequest, nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPostReturnsErrorForInvalidRequestBody
{
    NSMutableDictionary *circularJSON = [NSMutableDictionary dictionary];
    [circularJSON setObject:circularJSON forKey:@"self"];
    id badResource = [OCMockObject mockForClass:[YBHALResource class]];
    [[[badResource stub] andReturn:circularJSON] dictionary];
    
    __block BOOL didMakeRequest = NO;
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        didMakeRequest = YES;
        return nil;
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester postURL:userURL
                credential:basicCredential
                      body:badResource
                  callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertFalse(didMakeRequest, nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPostReturnsErrorForValidHalWithError
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
        [requester postURL:userURL
                credential:basicCredential
                      body:userResource
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

#pragma mark - PUT requests

- (void)testPutReturnsHAL
{
    __block id actualMethod = @"NOT SET";
    __block id actualPutBody = [@"{\"not\": \"set\"}" dataUsingEncoding:NSUTF8StringEncoding];
    __block id actualIfMatch = @"NOT SET";
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        actualMethod = request.HTTPMethod;
        NSString *auth = [request valueForHTTPHeaderField:@"Authorization"];
        if ( ! [auth isEqualToString:expectedAuth]) {
            NSDictionary *headers = @{@"WWW-Authenticate":
                                          @"Basic realm=\"hyperapi\""};
            return [OHHTTPStubsResponse responseWithData:[NSData data]
                                              statusCode:401
                                            responseTime:0.0
                                                 headers:headers];
        }
        
        actualIfMatch = [request valueForHTTPHeaderField:@"If-Match"];
        
        NSDictionary *headers = @{@"Etag": userEtag,
                                  @"Content-Type": @"application/hal+json",
                                  @"Location": [userURL absoluteString]};
        actualPutBody = request.HTTPBody;
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:201
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester putURL:userURL
               credential:basicCredential
                     body:userResource
                     etag:putEtag
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertEqualObjects(actualMethod, @"PUT", nil);
    STAssertNotNil(actualPutBody, nil);
    NSError *jsonError = nil;
    NSDictionary *bodyJSON = [NSJSONSerialization
                              JSONObjectWithData:actualPutBody
                              options:0
                              error:&jsonError];
    STAssertNotNil(bodyJSON, nil);
    STAssertNil(jsonError, @"%@", jsonError);
    YBHALResource *bodyResource = [[YBHALResource alloc]
                                   initWithDictionary:bodyJSON
                                   baseURL:userURL];
    
    STAssertEqualObjects([(id)bodyResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    
    STAssertEqualObjects([(id)actualResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    STAssertEqualObjects(actualEtag, userEtag, nil);
    STAssertNil(actualError, @"%@", actualError);
    STAssertEqualObjects(actualIfMatch, putEtag, nil);
}

- (void)testPutReturnsErrorForInvalidResponseJSON
{
    __block id actualPostBody = [@"{\"not\": \"set\"}" dataUsingEncoding:NSUTF8StringEncoding];
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
                                  @"Content-Type": @"application/hal+json",
                                  @"Location": [userURL absoluteString]};
        actualPostBody = request.HTTPBody;
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
        [requester putURL:userURL
               credential:basicCredential
                     body:userResource
                     etag:putEtag
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertNotNil(actualPostBody, nil);
    NSError *jsonError = nil;
    NSDictionary *bodyJSON = [NSJSONSerialization
                              JSONObjectWithData:actualPostBody
                              options:0
                              error:&jsonError];
    STAssertNotNil(bodyJSON, nil);
    STAssertNil(jsonError, @"%@", jsonError);
    YBHALResource *bodyResource = [[YBHALResource alloc]
                                   initWithDictionary:bodyJSON
                                   baseURL:userURL];
    
    STAssertEqualObjects([(id)bodyResource dictionary],
                         [(id)userResource dictionary],
                         nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPutReturnsErrorForNilRequestBody
{
    __block BOOL didMakeRequest = NO;
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        didMakeRequest = YES;
        return nil;
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester putURL:userURL
               credential:basicCredential
                     body:@"BAD RESOURCE"
                     etag:putEtag
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertFalse(didMakeRequest, nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPutReturnsErrorForInvalidRequestBody
{
    NSMutableDictionary *circularJSON = [NSMutableDictionary dictionary];
    [circularJSON setObject:circularJSON forKey:@"self"];
    id badResource = [OCMockObject mockForClass:[YBHALResource class]];
    [[[badResource stub] andReturn:circularJSON] dictionary];
    
    __block BOOL didMakeRequest = NO;
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        didMakeRequest = YES;
        return nil;
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester putURL:userURL
               credential:basicCredential
                     body:badResource
                     etag:putEtag
                 callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertFalse(didMakeRequest, nil);
    
    STAssertNil(actualResource, nil);
    STAssertNil(actualEtag, nil);
    STAssertNotNil(actualError, nil);
}

- (void)testPutReturnsErrorForValidHalWithError
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
        [requester putURL:userURL
               credential:basicCredential
                     body:userResource
                     etag:putEtag
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

#pragma mark - DELETE requests

- (void)testDeleteReturnsHAL
{
    __block id actualMethod = @"NOT SET";
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        actualMethod = request.HTTPMethod;
        NSString *auth = [request valueForHTTPHeaderField:@"Authorization"];
        if ( ! [auth isEqualToString:expectedAuth]) {
            NSDictionary *headers = @{@"WWW-Authenticate":
                                          @"Basic realm=\"hyperapi\""};
            return [OHHTTPStubsResponse responseWithData:[NSData data]
                                              statusCode:401
                                            responseTime:0.0
                                                 headers:headers];
        }
        NSDictionary *headers = @{@"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:[NSData data]
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
        [requester deleteURL:userURL
                  credential:basicCredential
                    callback:^(id result, id etag, NSError *error)
         {
             actualResource = result;
             actualEtag = etag;
             actualError = error;
             done();
         }];
    }];
    
    STAssertEqualObjects(actualMethod, @"DELETE", nil);
    STAssertNil(actualResource, @"%@", actualResource);
    STAssertNil(actualEtag, @"%@", actualEtag);
    STAssertNil(actualError, @"%@", actualError);
}

- (void)testDeleteReturnsErrorResponseWithError
{
    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary *headers = @{@"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:404
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET"
                                                       code:0
                                                   userInfo:nil];
    [self callAndWait:^(void (^done)()) {
        [requester deleteURL:userURL
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
                         @404,
                         nil);
}

@end
