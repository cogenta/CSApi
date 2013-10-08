//
//  CSLinkListItem.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSLinkListItem.h"

#import <HyperBek/HyperBek.h>

@interface CSLinkListItem ()

@property (strong, nonatomic) id<CSRequester> requester;
@property (strong, nonatomic) id<CSCredential> credential;
@property (copy, nonatomic) NSURL *URL;

@end

@implementation CSLinkListItem

- (id)initWithLink:(YBHALLink *)link
         requester:(id<CSRequester>)aRequester
        credential:(id<CSCredential>)aCredential;
{
    self = [super init];
    if (self) {
        self.URL = link.URL;
        self.requester = aRequester;
        self.credential = aCredential;
    }
    return self;
}

- (id<CSAPIRequest>)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    return (id<CSAPIRequest>) [self.requester getURL:self.URL
                                          credential:self.credential
                                            callback:^(id result,
                                                       id etag,
                                                       NSError *error)
    {
        callback(result, error);
    }];
}

@end
