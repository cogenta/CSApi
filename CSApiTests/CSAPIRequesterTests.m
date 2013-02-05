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

@interface CSAPIRequesterTests : CSAPITestCase

@property (nonatomic, strong) id<CSRequester> requester;
@property (nonatomic, strong) NSURL *baseUrl;

@end


@implementation CSAPIRequesterTests

@synthesize requester;
@synthesize baseUrl;

- (void)setUp
{
    requester = [[CSAPIRequester alloc] init];
    baseUrl = [NSURL URLWithString:@"http://localhost:8192/"];
}

- (void)testGetReturnsHAL
{
    NSData *userData = userGetResponseData();
    NSError *jsonError = nil;
    NSDictionary *userDict = [NSJSONSerialization JSONObjectWithData:userData
                                                             options:0
                                                               error:&jsonError];
    STAssertNil(jsonError, @"@%", jsonError);
    STAssertNotNil(userDict, nil);
    
    
    YBHALResource *expectedResource = [[YBHALResource alloc] initWithDictionary:userDict
                                                                        baseURL:baseUrl];
    STAssertNotNil(expectedResource, nil);
    
    NSURL *userURL = [expectedResource linkForRelation:@"self"].URL;
    STAssertNotNil(userURL, nil);
    
    NSString *userEtag = @"\"USERETAG\"";

    [OHHTTPStubs shouldStubRequestsPassingTest:^BOOL(NSURLRequest *request) {
        return [request.URL isEqual:userURL];
    } withStubResponse:^OHHTTPStubsResponse *(NSURLRequest *request) {
        NSDictionary *headers = @{@"Etag": userEtag,
                                  @"Content-Type": @"application/hal+json"};
        return [OHHTTPStubsResponse responseWithData:userData
                                          statusCode:200
                                        responseTime:0.0
                                             headers:headers];
    }];
    
    NSDictionary *credentailDict = @{@"username": @"user",
                                     @"password": @"pass"};
    CSBasicCredential *basicCredential = [CSBasicCredential credentialWithDictionary:
                                          credentailDict];
    __block id actualResource = @"NOT SET";
    __block id actualEtag = @"NOT SET";
    __block NSError *actualError = [NSError errorWithDomain:@"NOT SET" code:0 userInfo:nil];
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

    STAssertEqualObjects([(id)actualResource dictionary], [(id)expectedResource dictionary], nil);
    STAssertEqualObjects(actualEtag, userEtag, nil);
    STAssertNil(actualError, @"%@", actualError);
}

@end
