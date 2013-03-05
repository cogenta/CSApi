//
//  CSRetailer.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailer.h"
#import <HyperBek/HyperBek.h>
#import <objc/runtime.h>
#import "CSPicture.h"
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"


@interface CSRetailer ()

@property (readonly) CSListItem *logoItem;

@end

@implementation CSRetailer

@synthesize URL;
@synthesize name;
@synthesize logoItem;

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)aRequester
            credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        URL = [resource linkForRelation:@"self"].URL;
        name = resource[@"name"];
        YBHALResource *logoResource = [resource resourceForRelation:@"/rels/logo"];
        if (logoResource) {
            logoItem = [[CSResourceListItem alloc] initWithResource:logoResource
                                                          requester:aRequester
                                                         credential:aCredential];
        } else {
            YBHALLink *logoLink = [resource linkForRelation:@"/rels/logo"];
            logoItem = [[CSLinkListItem alloc] initWithLink:logoLink
                                                  requester:aRequester
                                                 credential:aCredential];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

- (void)getLogo:(void (^)(id<CSPicture>, NSError *))callback
{
    [logoItem getSelf:^(YBHALResource *resource, NSError *error) {
        if (error) {
            callback(nil, error);
        }
        
        CSPicture *result =  [[CSPicture alloc] initWithHal:resource
                                                  requester:self.requester
                                                 credential:self.credential];
        callback(result, nil);
    }];
}

@end

