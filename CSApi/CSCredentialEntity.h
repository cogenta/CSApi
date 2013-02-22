//
//  CSCredentialEntity.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
#import "CSRequester.h"

@interface CSCredentialEntity : NSObject

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) id<CSCredential> credential;

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential;

- (void)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback;

- (void)getURL:(NSURL *)URL callback:(requester_callback_t)callback;

- (void)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback;

@end

