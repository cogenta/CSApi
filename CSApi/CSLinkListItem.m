//
//  CSLinkListItem.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSLinkListItem.h"

#import <HyperBek/HyperBek.h>

@implementation CSLinkListItem

@synthesize URL;

- (id)initWithLink:(YBHALLink *)link
         requester:(id<CSRequester>)aRequester
        credential:(id<CSCredential>)aCredential;
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        URL = link.URL;
    }
    return self;
}

- (void)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    [self getURL:URL callback:^(id result, id etag, NSError *error) {
        callback(result, error);
    }];
}

@end
