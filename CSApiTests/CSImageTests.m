//
//  CSImageTests.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSImage.h"
#import "TestRequester.h"
#import "CSBasicCredential.h"
#import <HyperBek/HyperBek.h>

@interface CSImageTests : CSAPITestCase

@end

@implementation CSImageTests

- (void)testProperties
{
    NSURL *baseURL = [NSURL URLWithString:@"http://localhost:5000/images/1"];
    NSDictionary *json = [self jsonForFixture:@"image.json"];
    STAssertNotNil(json, nil);
    CSBasicCredential *credential = [CSBasicCredential credentialWithUsername:@"user"
                                                                     password:@"password"];
    YBHALResource *resource = [[YBHALResource alloc] initWithDictionary:json baseURL:baseURL];
    STAssertNotNil(resource, nil);
    TestRequester *requester = [[TestRequester alloc] init];
    NSString *etag = @"an etag";
    CSImage *image = [[CSImage alloc] initWithResource:resource requester:requester credential:credential etag:etag];
    
    STAssertEquals(image.requester, requester, nil);
    STAssertEquals(image.credential, credential, nil);
    STAssertEqualObjects(image.etag, etag, nil);
    STAssertEqualObjects(image.URL, [resource linkForRelation:@"self"].URL, nil);
    STAssertEqualObjects(image.width, json[@"width"], nil);
    STAssertEqualObjects(image.height, json[@"height"], nil);
    STAssertEqualObjects(image.enclosureURL, [resource linkForRelation:@"enclosure"].URL, nil);
    STAssertEqualObjects(image.enclosureType, [resource linkForRelation:@"enclosure"].type, nil);
}

@end
