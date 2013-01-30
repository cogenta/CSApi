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
    [responses setObject:^(void (^cb)(id, NSError *)) {
        cb(response, nil);
    } forKey:url];
}

- (void)addGetError:(id)error forURL:(NSURL *)url
{
    [responses setObject:^(void (^cb)(id, NSError *)) {
        cb(nil, error);
    } forKey:url];    
}

- (void)getURL:(NSURL *)url callback:(void (^)(id, NSError *))callback
{
    void (^response)(void (^)(id, NSError *)) = [responses objectForKey:url];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain
                                          code:404
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(callback);
}

@end
