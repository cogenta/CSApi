//
//  TestRequester.h
//  CSApi
//
//  Created by Will Harris on 30/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CSRequester.h"

typedef void (^request_handler_t)(id body, id etag, requester_callback_t cb);

@interface TestRequester : NSObject <CSRequester>

@property (nonatomic, readonly) NSString *lastUsername;
@property (nonatomic, readonly) NSString *lastPassword;

- (void)addGetResponse:(id)response forURL:(NSURL *)URL;
- (void)addGetError:(NSError *)error forURL:(NSURL *)URL;
- (void)addGetCallback:(request_handler_t)callback forURL:(NSURL *)URL;

- (void)addPostResponse:(id)response forURL:(NSURL *)URL;
- (void)addPostCallback:(request_handler_t)callback forURL:(NSURL *)URL;

- (void)addPutResponse:(id)response forURL:(NSURL *)URL;
- (void)addPutCallback:(request_handler_t)callback forURL:(NSURL *)URL;

- (void)addDeleteResponse:(id)response forURL:(NSURL *)URL;
- (void)addDeleteCallback:(request_handler_t)callback forURL:(NSURL *)URL;

@end
