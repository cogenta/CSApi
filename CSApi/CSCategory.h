//
//  CSCategory.h
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSCategory : CSCredentialEntity <CSCategory>

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end
