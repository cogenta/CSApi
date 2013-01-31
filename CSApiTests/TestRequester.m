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

- (void)addGetResponse:(id)response forURL:(NSURL *)url
{
    [responses setObject:^(id body, void (^cb)(id, NSError *)) {
        cb(response, nil);
    } forKey:url];
}

- (void)addGetError:(id)error forURL:(NSURL *)url
{
    [responses setObject:^(id body, void (^cb)(id, NSError *)) {
        cb(nil, error);
    } forKey:url];
}

- (void)addPostResponse:(id)response forURL:(NSURL *)url
{
    [self addGetResponse:response forURL:url];
}

- (void)addPostCallback:(void (^)(id, void (^)(id, NSError *)))callback
                 forURL:(NSURL *)url
{
    [responses setObject:^(id body, void (^cb)(id, NSError *)) {
        callback(body, cb);
    } forKey:url];
}

- (void)resetLastCredentails
{
    lastUsername = nil;
    lastPassword = nil;
}

- (void)getURL:(NSURL *)url
   credentials:(id<CSCredentials>)credentials
      callback:(void (^)(id, NSError *))callback
{
    [self resetLastCredentails];
    [credentials applyWith:self];
    
    void (^response)(id, void (^)(id, NSError *)) = [responses objectForKey:url];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain
                                          code:404
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(nil, callback);
}

- (void)postURL:(NSURL *)url
    credentials:(id<CSCredentials>)credentials
           body:(id)body
       callback:(void (^)(id, NSError *))callback
{
    [self resetLastCredentails];
    [credentials applyWith:self];
    
    void (^response)(id, void (^)(id, NSError *)) = [responses objectForKey:url];
    
    if ( ! response) {
        NSString *message = [NSString stringWithFormat:
                             @"%@ not in test requester",
                             url];
        callback(nil, [NSError errorWithDomain:NSURLErrorDomain
                                          code:404
                                      userInfo:@{NSLocalizedDescriptionKey: message}]);
        return;
    }
    
    response(body, callback);
}


- (void)applyBasicAuthWithUsername:(NSString *)username password:(NSString *)password
{
    lastUsername = username;
    lastPassword = password;
}

@end
