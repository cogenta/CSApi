//
//  CSAPIRequester.m
//  CSApi
//
//  Created by Will Harris on 05/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPIRequester.h"
#import "AFNetworking.h"
#import <HyperBek/HyperBek.h>

@interface CSHALRequestOperation : AFJSONRequestOperation

@end

@implementation CSHALRequestOperation

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"application/hal+json", @"text/plain", nil];
}

@end

@implementation CSAPIRequester

- (void)sendNotImplementedToCallback:(requester_callback_t)callback
{
    callback(nil, nil,
             [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:@{}]);
}

- (void)getURL:(NSURL *)url
    credential:(id<CSCredential>)credential
      callback:(requester_callback_t)callback
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    AFHTTPRequestOperation *operation =
    [CSHALRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
    {
        YBHALResource *resource = [[YBHALResource alloc] initWithDictionary:JSON baseURL:url];
        id etag = [[response allHeaderFields] objectForKey:@"Etag"];
        callback(resource, etag, nil);
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        callback(nil, nil, error);
    }];
    
    if ( ! operation) {
        NSError *error = [NSError errorWithDomain:@"Operation is nil" code:0 userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, nil, error);
        });
        return;
    }
    
    [operation setSuccessCallbackQueue:dispatch_get_main_queue()];
    [operation setFailureCallbackQueue:dispatch_get_main_queue()];
    [operation start];
    [operation waitUntilFinished];
}

- (void)postURL:(NSURL *)url
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(requester_callback_t)callback
{
    [self sendNotImplementedToCallback:callback];
}

- (void)putURL:(NSURL *)url
    credential:(id<CSCredential>)credential
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    [self sendNotImplementedToCallback:callback];
}

@end
