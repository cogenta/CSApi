//
//  TestApi.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestApi.h"

@interface CSAPI ()

- (id)initWithBookmark:(NSString *)aBookmark
              username:(NSString *)aUsername
              password:(NSString *)aPassword;
@end

@implementation TestApi

@synthesize requester;
@synthesize store;

+ (instancetype)apiWithBookmark:(NSString *)bookmark username:(NSString *)username password:(NSString *)password
{
    return [[TestApi alloc] initWithBookmark:bookmark
                                    username:username
                                    password:password];
}

@end
