//
//  CSNominal.h
//  CSApi
//
//  Created by Will Harris on 12/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"

@class YBHALResource;

@interface CSNominal : CSCredentialEntity
<CSAuthor,
CSCoverType,
CSManufacturer,
CSSoftwarePlatform>

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential;

@end