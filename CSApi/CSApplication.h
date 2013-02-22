//
//  CSApplication.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSAPI.h"
#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSApplication : CSCredentialEntity <CSApplication>

@property (strong, nonatomic) YBHALResource *resource;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential;

@end

