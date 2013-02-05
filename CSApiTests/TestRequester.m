//
//  TestRequester.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestRequester.h"
#import "CSAuthenticator.h"
#import "CSCredential.h"
#import <CommonCrypto/CommonCrypto.h>   // For etag generation

@interface NSData (CSHexString)

- (NSString *)hexString;

@end

@implementation NSData (CSHexString)

- (NSString *)hexString
{
    const char *bytes = [self bytes];
    NSUInteger length = [self length];
    NSMutableString *hex = [NSMutableString string];
    for (NSUInteger i = 0; i < length; ++i) {
        [hex appendFormat:@"%02X", *bytes++];
    }
    return hex;
}

@end

@interface TestRequester () <CSAuthenticator>

@property (strong) NSMutableDictionary *responses;

@end

@implementation TestRequester

@synthesize responses;
@synthesize lastUsername;
@synthesize lastPassword;

- (id)init
{
    self = [super init];
    if (self) {
        responses = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (NSMutableDictionary *)methodsForURL:(NSURL *)url
{
    NSMutableDictionary *result = [responses objectForKey:url];
    if ( ! result) {
        result = [NSMutableDictionary dictionary];
        [responses setObject:result forKey:url];
    }
    return result;
}


- (void)addCallback:(request_handler_t)cb
          forMethod:(NSString *)method
                url:(NSURL *)url
{
    [[self methodsForURL:url]
     setObject:cb
     forKey:method];
}

+ (id)etagForBody:(id)body
{
    if ( ! body) {
        return nil;
    }
    
    NSError *error = nil;
    NSData *data = [NSJSONSerialization dataWithJSONObject:[body dictionary]
                                                   options:0
                                                     error:&error];
    NSString *tag = nil;
    if ( ! data) {
        tag = [error description];
    } else {
        unsigned char digest[CC_SHA1_DIGEST_LENGTH];
        if (CC_SHA1([data bytes], [data length], digest)) {
            tag = [data hexString];
        }
    }
    
    return [NSString stringWithFormat:@"\"%@\"", tag];
}

- (void)addResponse:(id)response forMethod:(NSString *)method url:(NSURL *)url
{
    Class selfClass = [self class];
    [self addCallback:^(id body, id etag, requester_callback_t cb)
    {
        cb(response, [selfClass etagForBody:response], nil);
    }
            forMethod:method
                  url:url];
}

- (void)addError:(NSError *)error forMethod:(NSString *)method url:(NSURL *)url
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
          cb(nil, nil, error);
     }
            forMethod:method
                  url:url];
}

- (void)addGetResponse:(id)response forURL:(NSURL *)url
{
    [self addResponse:response forMethod:@"GET" url:url];
}

- (void)addGetError:(id)error forURL:(NSURL *)url
{
    [self addError:error forMethod:@"GET" url:url];
}

- (void)addGetCallback:(request_handler_t)callback forURL:(NSURL *)url
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"GET"
                  url:url];
}

- (void)addPostResponse:(id)response forURL:(NSURL *)url
{
    [self addResponse:response forMethod:@"POST" url:url];
}

- (void)addPostCallback:(request_handler_t)callback forURL:(NSURL *)url
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"POST"
                  url:url];
}

- (void)addPutResponse:(id)response forURL:(NSURL *)url
{
    [self addResponse:response forMethod:@"PUT" url:url];
}

- (void)addPutCallback:(request_handler_t)callback forURL:(NSURL *)url
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"PUT"
                  url:url];
}

- (void)resetLastCredentails
{
    lastUsername = nil;
    lastPassword = nil;
}

- (void)invokeURL:(NSURL *)url
           method:(NSString *)method
             body:(id)body
             etag:(id)etag
       credential:(id<CSCredential>)credential
         callback:(void (^)(id, id, NSError *))callback
{
    [self resetLastCredentails];
    [credential applyWith:self];
    
    NSDictionary *methods = [responses objectForKey:url];
    
    
    if ( ! [methods count]) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                               code:404
                                           userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    void (^response)(id, id, void (^)(id, id, NSError *)) = [methods objectForKey:method];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not allowed on %@ in test requester",
                             method, url];
        callback(nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                               code:405
                                           userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(body, etag, callback);
}

- (void)getURL:(NSURL *)url
    credential:(id<CSCredential>)credential
      callback:(void (^)(id, id, NSError *))callback
{
    [self invokeURL:url
             method:@"GET"
               body:nil
               etag:nil
         credential:credential
           callback:callback];
}

- (void)postURL:(NSURL *)url
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(requester_callback_t)callback
{
    [self invokeURL:url
             method:@"POST"
               body:body
               etag:nil
         credential:credential
           callback:callback];
}

- (void)putURL:(NSURL *)url
    credential:(id<CSCredential>)credential
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    if ( ! body) {
        callback(nil, nil, [NSError errorWithDomain:@"NO PUT BODY" code:0 userInfo:nil]);
        return;
    }
    [self invokeURL:url
             method:@"PUT"
               body:body
               etag:etag
         credential:credential
           callback:callback];
}


- (void)applyBasicAuthWithUsername:(NSString *)username password:(NSString *)password
{
    lastUsername = username;
    lastPassword = password;
}

@end
