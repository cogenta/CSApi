//
//  CSAuthorTests.m
//  CSApi
//
//  Created by Will Harris on 12/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSAuthor.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSAuthorTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSDictionary *json;
@property (strong) YBHALResource *resource;
@property (strong) NSURL *URL;
@property (strong) CSAuthor *author;

@end

@implementation CSAuthorTests

- (void)setUp
{
    [super setUp];
    
    _requester = [[TestRequester alloc] init];
    
    
    _credential = [CSBasicCredential credentialWithUsername:@"user"
                                                   password:@"pass"];
    
    _json = [self jsonForFixture:@"author.json"];
    STAssertNotNil(_json, nil);
    
    _resource = [self resourceForJson:_json];
    STAssertNotNil(_resource, nil);

    _URL = [_resource linkForRelation:@"self"].URL;
    [_requester addGetResponse:_resource forURL:_URL];
    
    _author = [[CSAuthor alloc] initWithResource:_resource
                                       requester:_requester
                                      credential:_credential];
}

- (void)testProperties
{
    STAssertEquals(_author.credential, _credential, nil);
    STAssertEquals(_author.requester, _requester, nil);
    STAssertEqualObjects(_author.name, _resource[@"name"], nil);
}

@end

