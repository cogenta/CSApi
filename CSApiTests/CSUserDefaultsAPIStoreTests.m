//
//  CSUserDefaultsAPIStoreTests.m
//  CSApi
//
//  Created by Will Harris on 06/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import <OCMock/OCMock.h>
#import "CSUserDefaultsAPIStore.h"
#import "CSCredential.h"
#import "CSAuthenticator.h"
#import "CSAPI.h"
#import "CSBasicCredential.h"

@interface MockUserDefaultsAPIStore : CSUserDefaultsAPIStore
@property (nonatomic, strong) NSUserDefaults *userDefaults;
@end

@implementation MockUserDefaultsAPIStore
@end

@interface MockKeyUserDefaultsAPIStore : MockUserDefaultsAPIStore

- (NSString *)userUrlKey;
- (NSString *)userCredentialKey;
@end

@implementation MockKeyUserDefaultsAPIStore

- (NSString *)userUrlKey
{
    return @"CSAPI_mock_userURL";
}

- (NSString *)userCredentialKey
{
    return @"CSAPI_mock_userCredential";
}

@end



@interface CSUserDefaultsAPIStoreTests : SenTestCase

@property (nonatomic, strong) id<CSAPIStore> apiStore;
@property (nonatomic, strong) MockKeyUserDefaultsAPIStore *testAPIStore;
@property (nonatomic, strong) id mockUserDefaults;

@end

@implementation CSUserDefaultsAPIStoreTests

- (void)setUp
{
    self.mockUserDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
    self.testAPIStore = [[MockKeyUserDefaultsAPIStore alloc]
                         initWithBookmark:@"test"];
    self.testAPIStore.userDefaults = self.mockUserDefaults;
    self.apiStore = self.testAPIStore;
}

- (void)testGetsUserUrlFromUserDefaults
{
    NSURL *expectedURL = [NSURL URLWithString:@"http://localhost:5000/users/12345"];
    [[[self.mockUserDefaults expect] andReturn:expectedURL]
     URLForKey:[self.testAPIStore userUrlKey]];
    
    NSURL *url = [self.apiStore userUrl];
    STAssertEqualObjects(url, expectedURL, nil);
    
    STAssertNoThrow(([self.mockUserDefaults verify]), nil);
}

- (void)testGetsCredentialFromUserDefaults
{
    NSDictionary *expectedCredentialDict = @{@"type": @"basic",
                                             @"username": @"user",
                                             @"password": @"pass"};
    [[[self.mockUserDefaults expect] andReturn:expectedCredentialDict]
     objectForKey:[self.testAPIStore userCredentialKey]];

    id<CSCredential> credential = [self.apiStore userCredential];

    id mockAuthenticator = [OCMockObject mockForProtocol:@protocol(CSAuthenticator)];
    [[mockAuthenticator expect] applyBasicAuthWithUsername:expectedCredentialDict[@"username"]
                                                  password:expectedCredentialDict[@"password"]];
    [credential applyWith:mockAuthenticator];
    
    STAssertNoThrow([mockAuthenticator verify], nil);
    STAssertNoThrow([self.mockUserDefaults verify], nil);
}

- (void)testSavesUserUrlAndCredentialsInUserDefaults
{
    NSURL *expectedURL = [NSURL URLWithString:
                          @"http://localhost:5000/users/12345"];
    
    NSDictionary *expectedCredentialDict = @{@"type": @"basic",
                                             @"username": @"user",
                                             @"password": @"pass"};
    CSBasicCredential *credential = [[CSBasicCredential alloc]
                                     initWithDictionary:
                                     @{@"username": @"user",
                                     @"password": @"pass"}];

    id mockUser = [OCMockObject mockForProtocol:@protocol(CSUser)];
    [[[mockUser stub] andReturn:expectedURL] url];
    [[[mockUser stub] andReturn:credential] credential];
    
    [[self.mockUserDefaults expect] setURL:expectedURL
                                    forKey:[self.testAPIStore userUrlKey]];
    [[self.mockUserDefaults expect] setObject:expectedCredentialDict
                                       forKey:[self.testAPIStore userCredentialKey]];
    [[self.mockUserDefaults expect] synchronize];
    
    [self.apiStore didCreateUser:mockUser];
    
    STAssertNoThrow([self.mockUserDefaults verify], nil);
}

@end

@interface CSUserDefaultsAPIStoreKeysTests : SenTestCase

@property (nonatomic, strong) id<CSAPIStore> apiStore;
@property (nonatomic, strong) MockUserDefaultsAPIStore *testAPIStore1;
@property (nonatomic, strong) MockUserDefaultsAPIStore *testAPIStore2;
@property (nonatomic, strong) id mockUserDefaults;

@end

@implementation CSUserDefaultsAPIStoreKeysTests

- (void)setUp
{
    self.mockUserDefaults = [OCMockObject mockForClass:[NSUserDefaults class]];
    self.testAPIStore1 = [[MockUserDefaultsAPIStore alloc]
                          initWithBookmark:@"http://localhost:5000/apps/1"];
    self.testAPIStore1.userDefaults = self.mockUserDefaults;
    self.testAPIStore2 = [[MockUserDefaultsAPIStore alloc]
                         initWithBookmark:@"http://localhost:5000/apps/2"];
    self.testAPIStore2.userDefaults = self.mockUserDefaults;
}

- (void)testUsesDifferentKeysForDifferentBookmarks
{
    __block NSString *urlKey = @"NOT SET";
    [[[self.mockUserDefaults stub] andDo:^(NSInvocation *inv) {
        NSString *key = nil;
        [inv getArgument:&key atIndex:2];
        urlKey = key;
        [inv setReturnValue:
         (void *)CFBridgingRetain([NSURL URLWithString:@"http://localhost"])];
    }] URLForKey:OCMOCK_ANY];
    
    [self.testAPIStore1 userUrl];
    NSString *key1 = urlKey;
    [self.testAPIStore2 userUrl];
    NSString *key2 = urlKey;
    
    STAssertNotNil(key1, nil);
    STAssertNotNil(key2, nil);
    
    STAssertFalse([key1 isEqualToString:key2], @"%@ == %@", key1, key2);
}

@end
