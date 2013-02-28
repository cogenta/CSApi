//
//  CSGroup.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSGroup : CSCredentialEntity <CSGroup>

@property (strong, nonatomic) YBHALResource *resource;
@property (readonly) id etag;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
             etag:(id)etag;
- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential;
@end
