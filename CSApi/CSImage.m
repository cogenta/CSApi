//
//  CSImage.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSImage.h"
#import <HyperBek/HyperBek.h>

@implementation CSImage

@synthesize URL;
@synthesize etag;
@synthesize width;
@synthesize height;
@synthesize enclosureURL;
@synthesize enclosureType;

- (id)initWithResource:(YBHALResource *)aResource
             requester:(id<CSRequester>)aReqester
            credential:(id<CSCredential>)aCredential
                  etag:(id)anEtag
{
    self = [super initWithRequester:aReqester credential:aCredential];
    if (self) {
        URL = [aResource linkForRelation:@"self"].URL;
        etag = anEtag;
        width = aResource[@"width"];
        height = aResource[@"height"];
        YBHALLink *enclosure = [aResource linkForRelation:@"enclosure"];
        enclosureURL = enclosure.URL;
        enclosureType = enclosure.type;
    }
    return self;
}

@end
