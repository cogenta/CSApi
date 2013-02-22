//
//  CSListPage.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSListPage : CSCredentialEntity <CSListPage>

@property (readonly) NSURL *URL;
@property (readonly) NSURL *next;
@property (readonly) NSURL *prev;
@property (readonly) NSString *rel;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end
