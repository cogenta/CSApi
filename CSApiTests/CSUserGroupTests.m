//
//  CSUserGroupTests.m
//  CSApi
//
//  Created by Will Harris on 25/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSUser.h"
#import "CSGroup.h"
#import "TestRequester.h"
#import "CSBasicCredential.h"
#import <HyperBek/HyperBek.h>

@interface CSUserGroupTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;

@end

@implementation CSUserGroupTests

@synthesize requester;
@synthesize credential;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
}

- (void)testCreateGroupTests
{
    YBHALResource *groupResource = [self resourceForFixture:@"group.json"];
    STAssertNotNil(groupResource, nil);
    YBHALResource *userResource = [self resourceForFixture:@"user_get_response.json"];
    CSUser *user = [[CSUser alloc] initWithResource:userResource
                                          requester:requester
                                         credential:credential
                                               etag:@"ORIGINAL ETAG"];
    
    __block YBHALResource *postBody = nil;
    [requester addPostCallback:^(id body, id etag, requester_callback_t cb) {
        postBody = body;
        cb(groupResource, @"GROUP ETAG", nil);
    } forURL:[userResource linkForRelation:@"/rels/groups"].URL];
    
    __block id<CSGroup> createdGroup = nil;
    __block NSError *createError = [NSError errorWithDomain:@"not implemented"
                                                       code:0
                                                   userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [user createGroupWithChange:^(id<CSMutableGroup> group) {
            group.reference = groupResource[@"reference"];
            group.meta = [groupResource[@"meta"] mutableCopy];
        } callback:^(id<CSGroup> group, NSError *error) {
            createdGroup = group;
            createError = error;
            done();
        }];
    });
    
    STAssertNotNil(postBody, nil);
    STAssertEqualObjects(postBody[@"reference"],
                         groupResource[@"reference"],
                         nil);
    STAssertEqualObjects(postBody[@"meta"], groupResource[@"meta"], nil);
    STAssertNil(createError, @"%@", createError);
    STAssertNotNil(createdGroup, nil);
    STAssertEqualObjects(createdGroup.reference,
                         groupResource[@"reference"],
                         nil);
    STAssertEqualObjects(createdGroup.meta, groupResource[@"meta"], nil);
}

- (void)testGetGroups
{
    YBHALResource *groupsResource = [self resourceForFixture:@"groups.json"];
    STAssertNotNil(groupsResource, nil);
    YBHALResource *userResource = [self resourceForFixture:@"user_get_response.json"];
    CSUser *user = [[CSUser alloc] initWithResource:userResource
                                          requester:requester
                                         credential:credential
                                               etag:@"ORIGINAL ETAG"];
    [requester addGetResponse:groupsResource
                       forURL:[userResource linkForRelation:@"/rels/groups"].URL];
    
    __block NSError *getError = [NSError errorWithDomain:@"not called"
                                                    code:0
                                                userInfo:nil];
    __block id<CSGroupListPage> gotPage = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [user getGroups:^(id<CSGroupListPage> firstPage, NSError *error) {
            gotPage = firstPage;
            getError = error;
            done();
        }];
    });
    
    STAssertNil(getError, @"%@", getError);
    STAssertNotNil(gotPage, nil);
    NSNumber *expectedCount = groupsResource[@"count"];
    STAssertEqualObjects(@(gotPage.count), expectedCount, nil);
    STAssertEqualObjects(@(gotPage.groupList.count), expectedCount, nil);
}

- (void)testGetGroupsWithReference
{
    YBHALResource *groupsResource = [self resourceForFixture:@"groups.json"];
    STAssertNotNil(groupsResource, nil);
    YBHALResource *userResource = [self resourceForFixture:@"user_get_response.json"];
    CSUser *user = [[CSUser alloc] initWithResource:userResource
                                          requester:requester
                                         credential:credential
                                               etag:@"ORIGINAL ETAG"];
    NSURL *url = [[userResource linkForRelation:@"/rels/groupsbyreference"]
                  URLWithVariables:@{@"reference": @"foo"}];
    url = [[NSURL URLWithString:[url absoluteString]
                  relativeToURL:user.URL] absoluteURL];
    [requester addGetResponse:groupsResource
                       forURL:url];
    
    __block NSError *getError = [NSError errorWithDomain:@"not called"
                                                    code:0
                                                userInfo:nil];
    __block id<CSGroupListPage> gotPage = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [user getGroupsWithReference:@"foo"
                            callback:^(id<CSGroupListPage> firstPage,
                                       NSError *error)
        {
            gotPage = firstPage;
            getError = error;
            done();
        }];
    });
    
    STAssertNil(getError, @"%@", getError);
    STAssertNotNil(gotPage, nil);
    NSNumber *expectedCount = groupsResource[@"count"];
    STAssertEqualObjects(@(gotPage.count), expectedCount, nil);
    STAssertEqualObjects(@(gotPage.groupList.count), expectedCount, nil);
}

@end
