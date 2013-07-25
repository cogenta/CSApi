//
//  CSRequester.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSCredential;
@protocol CSRequest;

typedef void (^requester_callback_t)(id result, id etag, NSError *error);

@protocol CSRequester <NSObject>

- (id<CSRequest>)getURL:(NSURL *)URL
             credential:(id<CSCredential>)credential
               callback:(requester_callback_t)callback;

- (id<CSRequest>)postURL:(NSURL *)URL
              credential:(id<CSCredential>)credential
                    body:(id)body
                callback:(requester_callback_t)callback;

- (id<CSRequest>)putURL:(NSURL *)URL
             credential:(id<CSCredential>)credential
                   body:(id)body
                   etag:(id)etag
               callback:(requester_callback_t)callback;

- (id<CSRequest>)deleteURL:(NSURL *)URL
                credential:(id<CSCredential>)credential
                  callback:(requester_callback_t)callback;

@end


@protocol CSRequest <NSObject>

- (void)cancel;

@end