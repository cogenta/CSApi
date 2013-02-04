//
//  TestFixtures.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestFixtures.h"

NSData *
appData() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/app.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}

NSData *
userPostResponseData() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/user_post_response.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}

NSData *
userGetResponseData() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/user_get_response.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}

NSData *
userPutRequestData() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/user_get_response_2.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}

NSData *
userPostReponseDataWithReferenceAndMeta() {
    static NSData *result = nil;
    if (result) {
        return result;
    }
    
    NSString *thisPath = @"" __FILE__;
    NSURL *thisURL = [NSURL fileURLWithPath:thisPath];
    NSURL *dataURL = [NSURL URLWithString:@"Fixtures/user_post_response_with_reference_and_meta.json"
                            relativeToURL:thisURL];
    NSError *error = nil;
    result = [NSData dataWithContentsOfURL:dataURL
                                   options:0
                                     error:&error];
    
    return result;
}