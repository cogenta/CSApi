//
//  CSLinkListItem.h
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListItem.h"

@class YBHALLink;

@interface CSLinkListItem : CSListItem

- (id)initWithLink:(YBHALLink *)link
         requester:(id<CSRequester>)requester
        credential:(id<CSCredential>)credential;

@end