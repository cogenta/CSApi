//
//  CSListItem.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSListItem : CSCredentialEntity <CSListItem>

- (id)initWithRequester:(id<CSRequester>)requester
             credential:(id<CSCredential>)credential;

- (id<CSAPIRequest>)getSelf:(void (^)(YBHALResource *resource,
                                      NSError *error))callback;

@end
