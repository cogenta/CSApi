//
//  CSAPIRequester.m
//  CSApi
//
//  Created by Will Harris on 05/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPIRequester.h"
#import "CSAuthenticator.h"
#import "CSCredential.h"
#import "AFNetworking.h"
#import <HyperBek/HyperBek.h>
#import <Base64/MF_Base64Additions.h>

@interface CSHALRequestOperation : AFJSONRequestOperation

@end

@implementation CSHALRequestOperation

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"application/hal+json", @"text/plain", nil];
}

@end

@interface CSRequestAuthenticator : NSObject <CSAuthenticator>

@property (nonatomic, strong) NSMutableURLRequest *request;

- (id)initWithRequest:(NSMutableURLRequest *)request;
+ (instancetype)authenticatorWithRequest:(NSMutableURLRequest *)request;

@end

@implementation CSRequestAuthenticator

@synthesize request;

- (id)initWithRequest:(NSMutableURLRequest *)aRequest
{
    self = [super init];
    if (self) {
        request = aRequest;
    }
    return self;
}

+ (instancetype)authenticatorWithRequest:(NSMutableURLRequest *)request
{
    return [[CSRequestAuthenticator alloc] initWithRequest:request];
}

- (void)applyBasicAuthWithUsername:(NSString *)username
                          password:(NSString *)password
{
    NSString *userPass = [NSString stringWithFormat:@"%@:%@",
                          username, password];
    NSString *basicAuth = [NSString stringWithFormat:@"Basic %@",
                           [userPass base64String]];
    [request addValue:basicAuth forHTTPHeaderField:@"Authorization"];
}

@end

@implementation CSAPIRequester

- (void)sendNotImplementedToCallback:(requester_callback_t)callback
{
    callback(nil, nil,
             [NSError errorWithDomain:@"Not Implemented" code:0 userInfo:@{}]);
}

- (void)requestURL:(NSURL *)url
            method:(NSString *)method
        credential:(id<CSCredential>)credential
              body:(id)body
              etag:(id)etag
          callback:(requester_callback_t)callback
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = method;
    CSRequestAuthenticator *authenticator = [CSRequestAuthenticator
                                             authenticatorWithRequest:request];
    [credential applyWith:authenticator];
    
    if (etag) {
        [request addValue:etag forHTTPHeaderField:@"If-Match"];
    }
    
    if (body) {
        if ( ! [body respondsToSelector:@selector(dictionary)]) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey: @"bad body"};
            NSError *error = [NSError errorWithDomain:@"CSAPI"
                                                 code:0
                                             userInfo:userInfo];
            callback(nil, nil, error);
            return;
        }
        
        NSDictionary *bodyJSON = [body dictionary];
        if ( ! [NSJSONSerialization isValidJSONObject:bodyJSON]) {
            NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                           @"body object is not valid"};
            NSError *error = [NSError errorWithDomain:@"CSAPI" code:0 userInfo:userInfo];
            callback(nil, nil, error);
            return;
        }
        
        NSError *jsonError = nil;
        NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyJSON
                                                           options:0
                                                             error:&jsonError];
        
        [request setHTTPBody:bodyData];
    }

    AFHTTPRequestOperation *operation =
    [CSHALRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         YBHALResource *resource = [[YBHALResource alloc]
                                    initWithDictionary:JSON
                                    baseURL:url];
         id etag = [[response allHeaderFields] objectForKey:@"Etag"];
         callback(resource, etag, nil);
     } failure:^(NSURLRequest *request,
                 NSHTTPURLResponse *response,
                 NSError *error,
                 id JSON) {
         NSMutableDictionary *userInfo = [error.userInfo mutableCopy];
         if (response) {
             userInfo[@"NSHTTPPropertyStatusCodeKey"] = @(response.statusCode);
         }
         
         error = [NSError errorWithDomain:error.domain
                                     code:error.code
                                 userInfo:userInfo];
         callback(nil, nil, error);
     }];
    
    if ( ! operation) {
        NSError *error = [NSError errorWithDomain:@"Operation is nil"
                                             code:0
                                         userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, nil, error);
        });
        return;
    }
    
    [operation start];
}

- (void)getURL:(NSURL *)url
    credential:(id<CSCredential>)credential
      callback:(requester_callback_t)callback
{
    [self requestURL:url
              method:@"GET"
          credential:credential
                body:nil
                etag:nil
            callback:callback];
}

- (void)postURL:(NSURL *)url
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(requester_callback_t)callback
{
    [self requestURL:url
              method:@"POST"
          credential:credential
                body:body
                etag:nil
            callback:callback];
}

- (void)putURL:(NSURL *)url
    credential:(id<CSCredential>)credential
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    [self requestURL:url
              method:@"PUT"
          credential:credential
                body:body
                etag:etag
            callback:callback];
}

@end
