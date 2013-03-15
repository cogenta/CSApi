//
//  CSRetailer.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSRetailer : CSCredentialEntity <CSRetailer, CSListItem>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential;

@end