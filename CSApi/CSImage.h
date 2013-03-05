//
//  CSImage.h
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"
@class YBHALResource;

@interface CSImage : CSCredentialEntity <CSImage>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential
                  etag:(id)etag;

@property (nonatomic, readonly) NSURL *URL;
@property (nonatomic, readonly) id etag;

@end
