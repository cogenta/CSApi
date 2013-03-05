//
//  CSRetailerTests.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPITestCase.h"
#import "CSRetailer.h"
#import "CSBasicCredential.h"
#import "TestRequester.h"
#import <HyperBek/HyperBek.h>
#import "TestConstants.h"

@interface CSRetailerTests : CSAPITestCase

@property (strong) TestRequester *requester;
@property (strong) id<CSCredential> credential;
@property (strong) NSURL *URL;
@property (strong) NSDictionary *json;
@property (strong) YBHALResource *resource;
@property (strong) YBHALResource *pictureResource;
@property (strong) YBHALResource *imageResource;
@property (strong) CSRetailer *retailer;

@end

@implementation CSRetailerTests

@synthesize requester;
@synthesize credential;
@synthesize URL;
@synthesize json;
@synthesize resource;
@synthesize pictureResource;
@synthesize imageResource;
@synthesize retailer;

- (void)setUp
{
    [super setUp];
    
    requester = [[TestRequester alloc] init];
    
    
    credential = [CSBasicCredential credentialWithUsername:@"user"
                                                  password:@"pass"];
    
    json = [self jsonForFixture:@"retailer.json"];
    STAssertNotNil(json, nil);
    
    resource = [self resourceForJson:json];
    STAssertNotNil(resource, nil);

    pictureResource = [self resourceForFixture:@"picture.json"];
    STAssertNotNil(pictureResource, nil);

    imageResource = [self resourceForFixture:@"image.json"];
    STAssertNotNil(imageResource, nil);

    URL = [resource linkForRelation:@"self"].URL;
    [requester addGetResponse:resource forURL:URL];
    [requester addGetResponse:pictureResource
                       forURL:[pictureResource linkForRelation:@"self"].URL];
    [requester addGetResponse:imageResource
                       forURL:[imageResource linkForRelation:@"self"].URL];

    retailer = [[CSRetailer alloc] initWithResource:resource
                                          requester:requester
                                         credential:credential];
}

- (void)testProperties
{
    STAssertEqualObjects(retailer.URL, URL, nil);
    STAssertEquals(retailer.credential, credential, nil);
    STAssertEquals(retailer.requester, requester, nil);
    STAssertEqualObjects(retailer.name, resource[@"name"], nil);
}

- (void)testGetPicture
{
    __block NSError *error = [NSError errorWithDomain:@"not called"
                                                 code:0
                                             userInfo:nil];
    __block id<CSPicture> picture = nil;
    CALL_AND_WAIT(^(void (^done)()) {
       [retailer getLogo:^(id<CSPicture> aPicture, NSError *anError) {
           error = anError;
           picture = aPicture;
           done();
       }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(picture, nil);
    
    id<CSImageList> imageList = picture.imageList;
    STAssertNotNil(imageList, nil);
    
    STAssertEqualObjects(@(imageList.count), @(1), nil);
    
    error = [NSError errorWithDomain:@"not called"
                                code:0
                            userInfo:nil];
    __block id<CSImage> image = nil;
    CALL_AND_WAIT(^(void (^done)()) {
        [imageList getImageAtIndex:0 callback:^(id<CSImage> anImage, NSError *anError) {
            image = anImage;
            error = anError;
            done();
        }];
    });
    
    STAssertNil(error, @"%@", error);
    STAssertNotNil(image, nil);

    STAssertEqualObjects(image.enclosureURL, [imageResource linkForRelation:@"enclosure"].URL, nil);
    STAssertEqualObjects(image.enclosureType, [imageResource linkForRelation:@"enclosure"].type, nil);
    STAssertEqualObjects(image.width, imageResource[@"width"], nil);
    STAssertEqualObjects(image.height, imageResource[@"height"], nil);
}

@end
