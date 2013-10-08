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

@interface CSCredentialEntity : NSObject <CSEntity>

@property (nonatomic, strong) YBHALResource *resource;
@property (nonatomic, strong) id etag;
@property (readonly, strong) id<CSRequester> requester;
@property (readonly, strong) id<CSCredential> credential;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential
                  etag:(id)etag;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
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

- (void)loadExtraProperties;

@end

