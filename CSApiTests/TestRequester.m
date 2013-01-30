//
//  TestRequester.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestRequester.h"


@interface TestRequester ()

@property (strong) NSMutableDictionary *responses;

@end

@implementation TestRequester

@synthesize responses;

- (id)init
{
    self = [super init];
    if (self) {
        responses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addGetResponse:(id)response forURL:(NSURL *)url
{
    [responses setObject:response forKey:url];
}

- (void)getURL:(NSURL *)url callback:(void (^)(id, NSError *))callback
{
    id response = [responses objectForKey:url];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, [NSError errorWithDomain:@"com.cogenta.CSApi"
                                          code:404
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    callback(response, nil);
}

@end
