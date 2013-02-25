//
//  CSGroupTests.m
//  CSApi
//
//  Created by Will Harris on 25/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSGroup.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSGroupTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *groupURL;
@property (strong) NSMutableDictionary *groupDict;
@property (strong) NSString *initialEtag;
@property (strong) YBHALResource *groupResource;
@property (strong) CSGroup *group;

@end

@implementation CSGroupTests

@synthesize requester;
@synthesize credential;
@synthesize groupURL;
@synthesize groupDict;
@synthesize initialEtag;
@synthesize groupResource;
@synthesize group;

- (void)setUp
{
    [super setUp];

    requester = [[TestRequester alloc] init];
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    groupURL = [NSURL URLWithString:@"http://localhost:5000/users/12345/groups/1"];
    
    groupDict = [NSMutableDictionary dictionary];
    NSMutableDictionary *links = [NSMutableDictionary dictionary];
    links[@"self"] = @{@"href": [groupURL path]};
    links[@"/rels/user"] = @{@"href": @"/users/12345"};
    links[@"/rels/likes"] = @{@"href": @"/users/12345/groups/1/likes/"};
    groupDict[@"_links"] = links;
    groupDict[@"meta"] = @{@"count": @(0)};
    groupDict[@"reference"] = @"reference";
    initialEtag = @"\"Initial ETag\"";
    groupResource = [self resourceForJson:groupDict];
    STAssertNotNil(groupResource, nil);
    group = [[CSGroup alloc] initWithHal:groupResource
                               requester:requester
                              credential:credential
                                    etag:initialEtag];
}

- (void)testProperties
{
    STAssertEqualObjects(group.URL, groupURL, nil);
    STAssertEqualObjects(group.reference, groupDict[@"reference"], nil);
    STAssertEqualObjects(group.meta, groupDict[@"meta"], nil);
}

- (void)testChange
{
    __block YBHALResource *putBody = nil;
    __block NSString *putEtag = nil;
    __block NSNumber *putSuccess = nil;
    __block NSError *putError = [NSError errorWithDomain:@"NOT CALLED"
                                                    code:0
                                                userInfo:nil];
    NSDictionary *dict = groupDict;
    [requester addPutCallback:^(id aBody, id anEtag, requester_callback_t cb) {
        putBody = aBody;
        putEtag = anEtag;
        NSMutableDictionary *newBody = [dict mutableCopy];
        [newBody addEntriesFromDictionary:[aBody dictionary]];
        cb([CSAPITestCase resourceForJson:newBody], @"New ETag", nil);
    } forURL:groupURL];
    [group change:^(id<CSMutableGroup> aGroup) {
        aGroup.reference = @"NEW REFERENCE";
        aGroup.meta = [@{@"new": @"meta"} mutableCopy];
    } callback:^(BOOL success, NSError *error) {
        putSuccess = @(success);
        putError = error;
    }];
    
    STAssertNil(putError, @"%@", putError);
    STAssertEqualObjects(putSuccess, @(YES), nil);
    STAssertEqualObjects(putEtag, initialEtag, nil);
    STAssertEqualObjects(requester.lastUsername, @"user", nil);
    STAssertEqualObjects(requester.lastPassword, @"pass", nil);
    STAssertNotNil(putBody, nil);
    
    STAssertEqualObjects(putBody[@"reference"], @"NEW REFERENCE", nil);
    STAssertEqualObjects(putBody[@"meta"], @{@"new": @"meta"}, nil);
}

- (void)testChangeWithConflict
{
    NSDictionary *dict = groupDict;
    NSString *serverEtag = @"\"Server ETag\"";
    NSString *newEtag = @"New ETag";
    
    __block YBHALResource *putBody = nil;
    __block NSString *putEtag = nil;
    [requester addPutCallback:^(id aBody, id anEtag, requester_callback_t cb) {
        putBody = aBody;
        putEtag = anEtag;
        if ( ! [anEtag isEqualToString:serverEtag]) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                           @"HTTP error 409 Conflict",
                                       @"NSHTTPPropertyStatusCodeKey": @409};
            cb(nil, nil, [NSError errorWithDomain:@"test"
                                             code:409
                                         userInfo:userInfo]);
            return;
        }
        NSMutableDictionary *newBody = [dict mutableCopy];
        [newBody addEntriesFromDictionary:[aBody dictionary]];
        cb([CSAPITestCase resourceForJson:newBody], newEtag, nil);
    } forURL:groupURL];
    [requester addGetCallback:^(id body, id etag, requester_callback_t cb) {
        NSMutableDictionary *result = [dict mutableCopy];
        result[@"meta"] = @{@"count": @10};
        cb([CSAPITestCase resourceForJson:result], serverEtag, nil);
    } forURL:groupURL];
    
    __block NSNumber *putSuccess = nil;
    __block NSError *putError = [NSError errorWithDomain:@"NOT CALLED"
                                                    code:0
                                                userInfo:nil];
    
    [self callAndWait:^(void (^done)()) {
        [group change:^(id<CSMutableGroup> aGroup) {
            aGroup.reference = @"NEW REFERENCE";
            aGroup.meta[@"count"] = @([aGroup.meta[@"count"] intValue] + 1);
        } callback:^(BOOL success, NSError *error) {
            putSuccess = @(success);
            putError = error;
            done();
        }];
    }];
    
    STAssertNil(putError, @"%@", putError);
    STAssertEqualObjects(putSuccess, @(YES), nil);
    STAssertEqualObjects(putEtag, serverEtag, nil);
    STAssertEqualObjects(requester.lastUsername, @"user", nil);
    STAssertEqualObjects(requester.lastPassword, @"pass", nil);
    STAssertEqualObjects(putBody[@"meta"][@"count"], @11, nil);
}

- (void)testGetLikes
{
    NSMutableArray *likedURLs = [NSMutableArray array];
    NSUInteger count = 0;
    for (NSString *fixture in @[
         @"likes_page_0_embedded.json",
         @"likes_page_1_embedded.json",
         @"likes_page_2_embedded.json"]) {
        NSMutableDictionary *likesJSON = [[self jsonForFixture:fixture]
                                          mutableCopy];
        NSMutableDictionary *links = [likesJSON[@"_links"] mutableCopy];
        likesJSON[@"_links"] = links;
        for (NSString *rel in @[@"self", @"first", @"last", @"prev", @"next"]) {
            NSMutableDictionary *linkDict = [likesJSON[@"_links"][rel]
                                             mutableCopy];
            if ( ! linkDict) {
                continue;
            }
            NSString *href =
            [linkDict[@"href"]
             stringByReplacingOccurrencesOfString:@"/users/12345/likes/"
             withString:@"/users/12345/groups/1/likes/"];
            linkDict[@"href"] = href;
            links[rel] = linkDict;
        }
        
        YBHALResource *likesResource = [self resourceForJson:likesJSON];
        NSURL *url = [likesResource linkForRelation:@"self"].URL;
        
        [requester addGetResponse:likesResource forURL:url];
        
        NSArray *likes = [likesResource resourcesForRelation:@"/rels/like"];
        count += [likes count];
        for (YBHALResource *like in likes) {
            [likedURLs addObject:[like linkForRelation:@"/rels/liked"].URL];
        }
    }
    
    STAssertEqualObjects(@([likedURLs count]), @(count), nil);
    
    __block id<CSLikeList> list = nil;
    __block NSError *error = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [self.group getLikes:^(id<CSLikeListPage> firstPage, NSError *anError) {
            list = firstPage.likeList;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(list, nil);
    STAssertEqualObjects(@(list.count), @(count), nil);
    
    NSMutableArray *returnedURLs = [NSMutableArray arrayWithCapacity:count];
    for (int i = 0; i < count; ++i) {
        [returnedURLs addObject:@"(not set)"];
        [list getLikeAtIndex:i callback:^(id<CSLike> like, NSError *error) {
            if (like) {
                returnedURLs[i] = like.likedURL;
                return;
            }
            
            if (error) {
                returnedURLs[i] = error;
                return;
            }
            
            returnedURLs[i] = @"(nil)";
        }];
    }
    
    CALL_AND_WAIT(^(void (^done)()) {
        dispatch_async(dispatch_get_main_queue(), done);
    });
    
    STAssertEqualObjects(returnedURLs, likedURLs, nil);
}

- (void)testCreateLike
{
    YBHALResource *postResponse = [self resourceForFixture:@"like.json"];
    __block YBHALResource *sentBody = nil;

    NSURL *likesURL = [groupResource linkForRelation:@"/rels/likes"].URL;
    
    [requester addPostCallback:^(YBHALResource *body,
                                 id etag,
                                 requester_callback_t cb)
    {
        sentBody = body;

        cb(postResponse, nil, nil);
    } forURL:likesURL];

    CSAPI *api = [CSAPI apiWithBookmark:kBookmark
                               username:kUsername
                               password:kPassword];
    NSURL *apiURL = [NSURL URLWithString:api.bookmark];
    NSURL *retailerURL = [[NSURL URLWithString:@"/retailers/test"
                                 relativeToURL:apiURL]
                          absoluteURL];

    __block id<CSLike> like = nil;
    __block NSError *error = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [group createLikeWithChange:^(id<CSMutableLike> mutableLike) {
             mutableLike.likedURL = retailerURL;
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

    NSURL *sentRetailerURL = [sentBody linkForRelation:@"/rels/liked"].URL;
    STAssertNotNil(sentRetailerURL, nil);
    STAssertEqualObjects(sentRetailerURL, retailerURL, nil);
}

- (void)testRemoveGroup
{
    __block BOOL deleted = NO;
    [requester addDeleteCallback:^(id body, id etag, requester_callback_t cb) {
        deleted = YES;
        cb(nil, nil, nil);
    } forURL:groupURL];

    __block NSNumber *success = nil;
    __block NSError *error = [NSError errorWithDomain:@"NOT CALLED"
                                                 code:0
                                             userInfo:nil];;
    CALL_AND_WAIT(^(void (^done)()) {
        [group remove:^(BOOL removeSuccess, NSError *removeError) {
            success = @(removeSuccess);
            error = removeError;
            done();
        }];
    });

    STAssertTrue(deleted, nil);
    STAssertNil(error, @"%@", error);
    STAssertEqualObjects(success, @(YES), nil);
}

@end
