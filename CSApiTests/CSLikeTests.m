//
//  CSLikeTests.m
//  CSApi
//
//  Created by Will Harris on 25/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSLike.h"
#import "TestRequester.h"
#import "CSBasicCredential.h"
#import <HyperBek/HyperBek.h>

@interface CSLikeTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;

@end

@implementation CSLikeTests

@synthesize requester;
@synthesize credential;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
}

- (void)testProperties
{
    YBHALResource *resource = [self resourceForFixture:@"like.json"];
    CSLike *like = [[CSLike alloc] initWithResource:resource
                                          requester:requester
                                         credential:credential];
    STAssertEqualObjects(like.URL, [resource linkForRelation:@"self"].URL, nil);
    STAssertEqualObjects(like.likedURL,
                         [resource linkForRelation:@"/rels/liked"].URL,
                         nil);
}

- (void)testRemoveLike
{
    YBHALResource *resource = [self resourceForFixture:@"like.json"];
    CSLike *like = [[CSLike alloc] initWithResource:resource
                                          requester:requester
                                         credential:credential];
    STAssertNotNil(like.URL, nil);
    __block BOOL didDelete = NO;
    [requester addDeleteCallback:^(id body, id etag, requester_callback_t cb) {
        didDelete = YES;
        cb(nil, nil, nil);
    } forURL:like.URL];
    
    __block NSNumber *success = nil;
    __block NSError *error = [NSError errorWithDomain:@"NOT CALLED"
                                                 code:0
                                             userInfo:nil];
    CALL_AND_WAIT(^(void (^done)()) {
        [like remove:^(BOOL aSuccess, NSError *anError) {
            success = @(aSuccess);
            error = anError;
            done();
        }];
    });
    
    STAssertTrue(didDelete, nil);
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(@(YES), success, nil);
}

@end
