//
//  CSCredentialEntity.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
#import "CSRequester.h"

@class YBHALResource;

@interface CSCredentialEntity : NSObject

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) id<CSCredential> credential;

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential;

- (id<CSAPIRequest>)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback;

- (id<CSAPIRequest>)getURL:(NSURL *)URL callback:(requester_callback_t)callback;

- (id<CSAPIRequest>)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback;

- (id<CSAPIRequest>)getRelation:(NSString *)relation
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback;

- (id<CSAPIRequest>)getRelation:(NSString *)relation
      withArguments:(NSDictionary *)args
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback;

- (NSURL *)URLForRelation:(NSString *)relation
                arguments:(NSDictionary *)args
                 resource:(YBHALResource *)resource;

@end

