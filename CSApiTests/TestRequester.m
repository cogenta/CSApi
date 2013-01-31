//
//  TestRequester.m
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "TestRequester.h"
#import "CSAuthenticator.h"
#import "CSCredentials.h"

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


- (void)addCallback:(void (^)(id body, void (^)(id, NSError *)))cb
          forMethod:(NSString *)method
                url:(NSURL *)url
{
    [[self methodsForURL:url]
     setObject:cb
     forKey:method];
}

- (void)addResponse:(id)response forMethod:(NSString *)method url:(NSURL *)url
{
    [self addCallback:^(id body, void (^cb)(id, NSError *))
    {
         cb(response, nil);
     }
            forMethod:method
                  url:url];
}

- (void)addError:(NSError *)error forMethod:(NSString *)method url:(NSURL *)url
{
    [self addCallback:^(id body, void (^cb)(id, NSError *))
     {
          cb(nil, error);
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

- (void)addPostResponse:(id)response forURL:(NSURL *)url
{
    [self addResponse:response forMethod:@"POST" url:url];
}

- (void)addPostCallback:(void (^)(id, void (^)(id, NSError *)))callback
                 forURL:(NSURL *)url
{
    [self addCallback:^(id body, void (^cb)(id, NSError *))
     {
         callback(body, cb);
     }
            forMethod:@"POST"
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
      credentials:(id<CSCredentials>)credentials
         callback:(void (^)(id, NSError *))callback
{
    [self resetLastCredentails];
    [credentials applyWith:self];
    
    NSDictionary *methods = [responses objectForKey:url];
    
    
    if ( ! [methods count]) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain
                                          code:404
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    void (^response)(id, void (^)(id, NSError *)) = [methods objectForKey:method];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not allowed on %@ in test requester",
                             method, url];
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain
                                          code:405
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(body, callback);
}

- (void)getURL:(NSURL *)url
   credentials:(id<CSCredentials>)credentials
      callback:(void (^)(id, NSError *))callback
{
    [self invokeURL:url method:@"GET" body:nil credentials:credentials callback:callback];
}

- (void)postURL:(NSURL *)url
    credentials:(id<CSCredentials>)credentials
           body:(id)body
       callback:(void (^)(id, NSError *))callback
{
    [self invokeURL:url
             method:@"POST"
               body:body
        credentials:credentials
           callback:callback];
}


- (void)applyBasicAuthWithUsername:(NSString *)username password:(NSString *)password
{
    lastUsername = username;
    lastPassword = password;
}

@end
