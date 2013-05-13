//
//  CSImage.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSImage.h"
#import <HyperBek/HyperBek.h>

@interface CSImage ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSImage

@synthesize URL = _URL;
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
        _resource = aResource;
        etag = anEtag;
        width = aResource[@"width"];
        height = aResource[@"height"];
    }
    return self;
}

- (NSURL *)URL
{
    if ( ! _URL) {
        _URL = [_resource linkForRelation:@"self"].URL;
    }
    
    return _URL;
}

- (void)loadEnclosure
{
    YBHALLink *enclosure = [_resource linkForRelation:@"enclosure"];
    enclosureURL = enclosure.URL;
    enclosureType = enclosure.type;
}

- (NSString *)enclosureType
{
    if ( ! enclosureType && ! enclosureURL) {
        [self loadEnclosure];
    }
    
    return enclosureType;
}

- (NSURL *)enclosureURL
{
    if ( ! enclosureType && ! enclosureURL) {
        [self loadEnclosure];
    }
    
    return enclosureURL;
}

@end
