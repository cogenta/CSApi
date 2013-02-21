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

- (NSMutableDictionary *)methodsForURL:(NSURL *)URL
{
    NSMutableDictionary *result = [responses objectForKey:URL];
    if ( ! result) {
        result = [NSMutableDictionary dictionary];
        [responses setObject:result forKey:URL];
    }
    return result;
}


- (void)addCallback:(request_handler_t)cb
          forMethod:(NSString *)method
                URL:(NSURL *)URL
{
    if ( ! URL) {
        @throw [NSException
                exceptionWithName:@"bad URL"
                reason:@"cannot mock requests with nil URL"
                userInfo:nil];
    }
    [[self methodsForURL:URL]
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

- (void)addResponse:(id)response forMethod:(NSString *)method URL:(NSURL *)URL
{
    Class selfClass = [self class];
    [self addCallback:^(id body, id etag, requester_callback_t cb)
    {
        cb(response, [selfClass etagForBody:response], nil);
    }
            forMethod:method
                  URL:URL];
}

- (void)addError:(NSError *)error forMethod:(NSString *)method URL:(NSURL *)URL
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
          cb(nil, nil, error);
     }
            forMethod:method
                  URL:URL];
}

- (void)addGetResponse:(id)response forURL:(NSURL *)URL
{
    [self addResponse:response forMethod:@"GET" URL:URL];
}

- (void)addGetError:(id)error forURL:(NSURL *)URL
{
    [self addError:error forMethod:@"GET" URL:URL];
}

- (void)addGetCallback:(request_handler_t)callback forURL:(NSURL *)URL
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"GET"
                  URL:URL];
}

- (void)addPostResponse:(id)response forURL:(NSURL *)URL
{
    [self addResponse:response forMethod:@"POST" URL:URL];
}

- (void)addPostCallback:(request_handler_t)callback forURL:(NSURL *)URL
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"POST"
                  URL:URL];
}

- (void)addPutResponse:(id)response forURL:(NSURL *)URL
{
    [self addResponse:response forMethod:@"PUT" URL:URL];
}

- (void)addPutCallback:(request_handler_t)callback forURL:(NSURL *)URL
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"PUT"
                  URL:URL];
}

- (void)addDeleteResponse:(id)response forURL:(NSURL *)URL
{
    [self addResponse:response forMethod:@"DELETE" URL:URL];
}

- (void)addDeleteCallback:(request_handler_t)callback forURL:(NSURL *)URL
{
    [self addCallback:^(id body, id etag, requester_callback_t cb)
     {
         callback(body, etag, cb);
     }
            forMethod:@"DELETE"
                  URL:URL];
}

- (void)resetLastCredentails
{
    lastUsername = nil;
    lastPassword = nil;
}

- (void)invokeURL:(NSURL *)URL
           method:(NSString *)method
             body:(id)body
             etag:(id)etag
       credential:(id<CSCredential>)credential
         callback:(void (^)(id, id, NSError *))callback
{
    [self resetLastCredentails];
    [credential applyWith:self];
    
    NSDictionary *methods = [responses objectForKey:URL];
    
    
    if ( ! [methods count]) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             URL];
        callback(nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                               code:404
                                           userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    void (^response)(id, id, void (^)(id, id, NSError *)) = [methods objectForKey:method];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not allowed on %@ in test requester",
                             method, URL];
        callback(nil, nil, [NSError errorWithDomain:NSURLErrorDomain
                                               code:405
                                           userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(body, etag, callback);
}

- (void)getURL:(NSURL *)URL
    credential:(id<CSCredential>)credential
      callback:(void (^)(id, id, NSError *))callback
{
    [self invokeURL:URL
             method:@"GET"
               body:nil
               etag:nil
         credential:credential
           callback:callback];
}

- (void)postURL:(NSURL *)URL
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(requester_callback_t)callback
{
    [self invokeURL:URL
             method:@"POST"
               body:body
               etag:nil
         credential:credential
           callback:callback];
}

- (void)putURL:(NSURL *)URL
    credential:(id<CSCredential>)credential
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    if ( ! body) {
        callback(nil, nil, [NSError errorWithDomain:@"NO PUT BODY" code:0 userInfo:nil]);
        return;
    }
    [self invokeURL:URL
             method:@"PUT"
               body:body
               etag:etag
         credential:credential
           callback:callback];
}

- (void)deleteURL:(NSURL *)URL
       credential:(id<CSCredential>)credential
         callback:(requester_callback_t)callback
{
    [self invokeURL:URL
             method:@"DELETE"
               body:nil
               etag:nil
         credential:credential
           callback:callback];
}


- (void)applyBasicAuthWithUsername:(NSString *)username password:(NSString *)password
{
    lastUsername = username;
    lastPassword = password;
}

@end
