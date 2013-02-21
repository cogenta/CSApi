//
//  CSRequester.h
//  CSApi
//
//  Created by Will Harris on 31/01/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol CSCredential;

typedef void (^requester_callback_t)(id result, id etag, NSError *error);

@protocol CSRequester <NSObject>

- (void)getURL:(NSURL *)URL
    credential:(id<CSCredential>)credential
      callback:(requester_callback_t)callback;

- (void)postURL:(NSURL *)URL
     credential:(id<CSCredential>)credential
           body:(id)body
       callback:(requester_callback_t)callback;

- (void)putURL:(NSURL *)URL
    credential:(id<CSCredential>)credential
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback;

- (void)deleteURL:(NSURL *)URL
       credential:(id<CSCredential>)credential
         callback:(requester_callback_t)callback;

@end
