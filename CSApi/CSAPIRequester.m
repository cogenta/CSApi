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
#import <SBJson/SBJson.h>

@interface CSHALRequestOperation : AFJSONRequestOperation

@property (readwrite, nonatomic, strong) NSError *JSONError;

@end

@implementation CSHALRequestOperation

+ (instancetype)JSONRequestOperationWithRequest:(NSURLRequest *)urlRequest
       success:(void (^)(NSURLRequest *request,
                         NSHTTPURLResponse *response,
                         id JSON))success
       failure:(void (^)(NSURLRequest *request,
                         NSHTTPURLResponse *response,
                         NSError *error,
                         id JSON))failure
{
    CSHALRequestOperation *requestOperation = [[self alloc]
                                               initWithRequest:urlRequest];
    [requestOperation
     setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation,
                                     id responseObject)
    {
        if (success) {
            success(operation.request, operation.response, responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(operation.request, operation.response, error,
                    [(AFJSONRequestOperation *)operation responseJSON]);
        }
    }];
    requestOperation.allowsInvalidSSLCertificate = YES;

    return requestOperation;
}

+ (NSSet *)acceptableContentTypes
{
    return [NSSet setWithObjects:@"application/hal+json", @"text/plain", nil];
}

- (NSError *)error {
    if (_JSONError) {
        return _JSONError;
    } else {
        return [super error];
    }
}

- (id)responseJSON {
    NSError *error = nil;
    
    if ([self.responseData length] == 0 ||
        [self.responseString isEqualToString:@" "]) {
        return nil;
    }
    
    NSData *JSONData = [self.responseString
                        dataUsingEncoding:NSUTF8StringEncoding];
    SBJsonParser *parser = [[SBJsonParser alloc] init];
    id responseObj = [parser objectWithData:JSONData];
    if ( ! responseObj) {
        NSDictionary *ui = [NSDictionary dictionaryWithObjectsAndKeys:error, NSLocalizedDescriptionKey, nil];
        self.JSONError = [NSError errorWithDomain:@"CSAPI" code:0 userInfo:ui];
        return nil;
    }
    return responseObj;
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

@interface CSAPIRequest : NSObject <CSRequest>

@property (strong, nonatomic) AFHTTPRequestOperation *operation;
- (id)initWithOperation:(AFHTTPRequestOperation *)operation;

@end

@implementation CSAPIRequest

- (id)initWithOperation:(AFHTTPRequestOperation *)operation
{
    self = [super init];
    if (self) {
        self.operation = operation;
    }
    return self;
}

- (void)cancel
{
    [self.operation cancel];
}

@end

@interface CSAPIRequester ()

@property (strong, nonatomic) NSOperationQueue *halDecoderQueue;

@end

@implementation CSAPIRequester

- (id)init
{
    self = [super init];
    if (self) {
        _halDecoderQueue = [[NSOperationQueue alloc] init];
        _halDecoderQueue.maxConcurrentOperationCount = 4;
    }
    return self;
}

- (NSData *)dataForBodyObject:(id)body {
    if ( ! [body respondsToSelector:@selector(dictionary)]) {
        return nil;
    }
    
    NSDictionary *bodyJSON = [body dictionary];

    if ( ! [NSJSONSerialization isValidJSONObject:bodyJSON]) {
        return nil;
    }
    
    NSError *jsonError = nil;
    NSData *bodyData = [NSJSONSerialization dataWithJSONObject:bodyJSON
                                                       options:0
                                                         error:&jsonError];
    return bodyData;
}

- (void)applyCredential:(id)credential request:(NSMutableURLRequest *)request
{
    CSRequestAuthenticator *authenticator = [CSRequestAuthenticator
                                             authenticatorWithRequest:request];
    [credential applyWith:authenticator];
}

- (void)applyEtag:(id)etag request:(NSMutableURLRequest *)request
{
    if (etag) {
        [request addValue:etag forHTTPHeaderField:@"If-Match"];
    }
}

- (void)applyAccept:(NSString *)accept request:(NSMutableURLRequest *)request
{
    if (accept) {
        [request addValue:accept forHTTPHeaderField:@"Accept"];
    }
}

- (BOOL)applyBody:(id)body request:(NSMutableURLRequest *)request
{
    if ( ! body) {
        return YES;
    }
    
    NSData *bodyData = [self dataForBodyObject:body];
    if ( ! bodyData) {
        return NO;
    }
        
    [request setHTTPBody:bodyData];
    return YES;
}

- (id<CSRequest>)requestURL:(NSURL *)URL
                     method:(NSString *)method
                 credential:(id<CSCredential>)credential
                       body:(id)body
                       etag:(id)etag
                   callback:(requester_callback_t)callback
{
    if ( ! URL) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:@"URL is nil"};
        NSError *error = [NSError errorWithDomain:@"CSAPI"
                                             code:0
                                         userInfo:userInfo];
        callback(nil, nil, error);
        return nil;
    }
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:URL];
    request.HTTPMethod = method;
    request.timeoutInterval = 5.0;
    request.HTTPShouldUsePipelining = YES;
    
    [self applyCredential:credential request:request];
    [self applyEtag:etag request:request];
    [self applyAccept:@"application/hal+json;version=0.1" request:request];
    
    if ( ! [self applyBody:body request:request]) {
        NSDictionary *userInfo = @{NSLocalizedDescriptionKey:
                                       @"body object is not valid"};
        NSError *error = [NSError errorWithDomain:@"CSAPI"
                                             code:0
                                         userInfo:userInfo];
        callback(nil, nil, error);
        return nil;
    }

    AFHTTPRequestOperation *operation =
    [CSHALRequestOperation
     JSONRequestOperationWithRequest:request
     success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON)
     {
         NSBlockOperation *op = [NSBlockOperation blockOperationWithBlock:^{
             YBHALResource *resource = [[YBHALResource alloc]
                                        initWithDictionary:JSON
                                        baseURL:URL];
             id etag = [[response allHeaderFields] objectForKey:@"Etag"];
             dispatch_async(dispatch_get_main_queue(), ^{
                 callback(resource, etag, nil);
             });
         }];
         [self.halDecoderQueue addOperation:op];
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
         NSLog(@"HTTP Error: %@", error);
         callback(nil, nil, error);
     }];
    
    // The Authorization header is forgotten when redirecting, so we reapply it.
    [operation setRedirectResponseBlock:^NSURLRequest *(NSURLConnection *conn,
                                                        NSURLRequest *request,
                                                        NSURLResponse *redirect)
    {
        if ( ! redirect) {
            return request;
        }
        
        NSMutableURLRequest *result = [request mutableCopy];
        [self applyCredential:credential request:result];
        return result;
    }];
    
    if ( ! operation) {
        NSError *error = [NSError errorWithDomain:@"Operation is nil"
                                             code:0
                                         userInfo:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            callback(nil, nil, error);
        });
        return nil;
    }

    [operation start];
    return [[CSAPIRequest alloc] initWithOperation:operation];
}

- (id<CSRequest>)getURL:(NSURL *)URL
             credential:(id<CSCredential>)credential
               callback:(requester_callback_t)callback
{
    return [self requestURL:URL
                     method:@"GET"
                 credential:credential
                       body:nil
                       etag:nil
                   callback:callback];
}

- (id<CSRequest>)postURL:(NSURL *)URL
              credential:(id<CSCredential>)credential
                    body:(id)body
                callback:(requester_callback_t)callback
{
    return [self requestURL:URL
                     method:@"POST"
                 credential:credential
                       body:body
                       etag:nil
                   callback:callback];
}

- (id<CSRequest>)putURL:(NSURL *)URL
             credential:(id<CSCredential>)credential
                   body:(id)body
                   etag:(id)etag
               callback:(requester_callback_t)callback
{
    return [self requestURL:URL
                     method:@"PUT"
                 credential:credential
                       body:body
                       etag:etag
                   callback:callback];
}

- (id<CSRequest>)deleteURL:(NSURL *)URL
                credential:(id<CSCredential>)credential
                  callback:(requester_callback_t)callback
{
    return [self requestURL:URL
                     method:@"DELETE"
                 credential:credential
                       body:nil
                       etag:nil
                   callback:callback];
}

@end
