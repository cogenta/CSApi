//
//  CSUser.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSUser : CSCredentialEntity <CSUser>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
                  etag:(id)etag;

@end