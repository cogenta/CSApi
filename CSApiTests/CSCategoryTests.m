//
//  CSCategoryTests.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSCategory.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSCategoryTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) YBHALResource *resource;
@property (strong) CSCategory *category;

@end

@implementation CSCategoryTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize resource;
@synthesize category;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    resource = [self resourceForFixture:@"category.json"];
    STAssertNotNil(resource, nil);
    
    URL = [resource linkForRelation:@"self"].URL;
    
    category = [[CSCategory alloc] initWithHAL:resource
                                     requester:requester
                                    credential:credential];
}

- (void)testName
{
    STAssertEqualObjects(category.name, @"DVDs & Blu-Ray", nil);
}

@end
