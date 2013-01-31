//
//  CSApplicationTests.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>

#import <HyperBek/HyperBek.h>
#import "TestRequester.h"
#import "TestApi.h"

#import "CSApi.h"
#import "TestFixtures.h"
#import "TestConstants.h"

#import "CSAPITestCase.h"

@interface CSApplicationTests : CSAPITestCase

@property (weak) CSApi *api;
@property (strong) TestApi *testApi;
@property (strong) TestRequester *requester;
@property (strong) YBHALResource *appResource;
@property (strong) id<CSApplication> app;

@end



@implementation CSApplicationTests

@synthesize testApi;
@synthesize api;
@synthesize requester;
@synthesize appResource;
@synthesize app;

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
    
    
    NSURL *url = [NSURL URLWithString:kBookmark];
    appResource = [self resourceForData:appData()];
    STAssertNotNil(appResource, nil);
    
    [requester addGetResponse:appResource forURL:url];
    
    __block NSError *error = nil;

    [self callAndWait:^(void (^done)()) {
        [api getApplication:[NSURL URLWithString:kBookmark]
                   callback:^(id<CSApplication> anApp, NSError *anError)
         {
             app = anApp;
             error = anError;
             done();
         }];
    }];
    
    STAssertNil(error, @"%@", error);
}

- (void)tearDown
{
    self.api = nil;
    self.testApi = nil;
    self.requester = nil;
    self.app = nil;
    
    [super tearDown];
}

- (void)testName
{
    STAssertEquals(app.name, appResource[@"name"], nil);
}

void (^postCallback)(id body, void (^cb)(id, NSError *)) =
^(id body, void (^cb)(id, NSError *)) {
    YBHALResource *halBody = body;
    NSData *data = userPostResponseData();
    NSMutableDictionary *json = [[CSApplicationTests jsonForData:data] mutableCopy];
    if (halBody[@"reference"]) {
        json[@"reference"] = halBody[@"reference"];
    }
    if (halBody[@"meta"]) {
        json[@"meta"] = halBody[@"meta"];
    }
    YBHALResource *userResource = [CSApplicationTests resourceForJson:json];
    cb(userResource, nil);
};

- (void)testCreateUser
{
    NSURL *postUrl = [appResource linkForRelation:@"/rels/users"].URL;
    
    [requester addPostCallback:postCallback forURL:postUrl];
    
    id<CSUser> user = [self.api newUser];
    
    __block NSError *error = nil;
    __block id<CSUser> createdUser = nil;
    [self callAndWait:^(void (^done)()) {
        [self.app createUser:user
                    callback:^(id<CSUser> returnedUser, NSError *returnedError)
        {
            createdUser = returnedUser;
            error = returnedError;
            done();
        }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(createdUser, nil);
    STAssertNotNil(createdUser.url, nil);
    STAssertNil(createdUser.reference, nil);
    STAssertNil(createdUser.meta, nil);
}

- (void)testCreateUserWithReferenceAndMeta
{
    NSURL *postUrl = [appResource linkForRelation:@"/rels/users"].URL;
    
    NSData *data = userPostReponseDataWithReferenceAndMeta();
    YBHALResource *userResource = [self resourceForData:data];
    
    [requester addPostCallback:postCallback forURL:postUrl];
    
    id<CSUser> user = [self.api newUser];
    user.reference = userResource[@"reference"];
    user.meta = userResource[@"meta"];
    
    __block NSError *error = nil;
    __block id<CSUser> createdUser = nil;
    [self callAndWait:^(void (^done)()) {
        [self.app createUser:user
                    callback:^(id<CSUser> returnedUser, NSError *returnedError)
         {
             createdUser = returnedUser;
             error = returnedError;
             done();
         }];
    }];
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(createdUser, nil);
    STAssertEqualObjects(createdUser.url,
                         [userResource linkForRelation:@"self"].URL,
                         nil);
    STAssertEqualObjects(createdUser.reference, userResource[@"reference"], nil);
    STAssertEqualObjects(createdUser.meta, userResource[@"meta"], nil);
}

- (void)testUsesCredentials
{
    id<CSUser> user = [self.api newUser];
    [self callAndWait:^(void (^done)()) {
        [self.app createUser:user
                    callback:^(id<CSUser> returnedUser, NSError *returnedError)
         {
             done();
         }];
    }];
    
    STAssertEqualObjects(requester.lastUsername, kUsername, nil);
    STAssertEqualObjects(requester.lastPassword, kPassword, nil);
}

@end
