//
//  TestFixtures.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestFixtures.h"

NSData *
dataForFixture(NSString *fixture)
{
    static NSMutableDictionary *results = nil;
    NSData *result = results[fixture];
    
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *fixturesURL = [NSURL URLWithString:@"Fixtures/"
                                relativeToURL:thisURL];
    NSURL *dataURL = [NSURL URLWithString:fixture
                            relativeToURL:fixturesURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    if ( ! results) {
        results = [[NSMutableDictionary alloc] init];
    }
    
    results[fixture] = result;
    
    return result;
}

NSData *
appData() {
    return dataForFixture(@"app.json");
}

NSData *
userPostResponseData() {
    return dataForFixture(@"user_post_response.json");
}

NSData *
userGetResponseData() {
    return dataForFixture(@"user_get_response.json");
}

NSData *
userPutRequestData() {
    return dataForFixture(@"user_get_response_2.json");
}

NSData *
userPostReponseDataWithReferenceAndMeta() {
    return dataForFixture(@"user_post_response_with_reference_and_meta.json");
}