//
//  CSListPage.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSListPage.h"
#import <HyperBek/HyperBek.h>
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"
#import <NSArray+Functional/NSArray+Functional.h>
#import <objc/runtime.h>

@interface CSListPage ()

- (NSUInteger) getCountForResource:(YBHALResource *)resource;

@end

@implementation CSListPage

@synthesize count;
@synthesize items;
@synthesize URL;
@synthesize next;
@synthesize prev;

- (id)initWithHal:(YBHALResource *)resource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        count = [self getCountForResource:resource];
        URL = [resource linkForRelation:@"self"].URL;
        next = [resource linkForRelation:@"next"].URL;
        prev = [resource linkForRelation:@"prev"].URL;
        NSArray *resources = [resource resourcesForRelation:self.rel];
        if (resources) {
            items = [resources mapUsingBlock:^id(id obj) {
                return [[CSResourceListItem alloc] initWithResource:obj
                                                          requester:aRequester
                                                         credential:aCredential];
            }];
        } else {
            NSArray *links = [resource linksForRelation:self.rel];
            items = [links mapUsingBlock:^id(id obj) {
                return [[CSLinkListItem alloc] initWithLink:obj
                                                  requester:aRequester
                                                 credential:aCredential];
            }];
        }
    }
    return self;
}

- (NSUInteger)getCountForResource:(YBHALResource *)resource
{
    return [resource[@"count"] unsignedIntegerValue];
}

- (NSString *)rel
{
    return @"item";
}

- (BOOL)hasNext
{
    return next != nil;
}

- (BOOL)hasPrev
{
    return prev != nil;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSListPage alloc] initWithHal:resource
                                 requester:self.requester
                                credential:self.credential];
}

- (void)getListURL:(NSURL *)aURL
          callback:(void (^)(id<CSListPage>, NSError *))callback
{
    if ( ! aURL) {
        callback(nil, nil);
        return;
    }
    
    [self getURL:aURL callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([self pageWithHal:result
                          requester:self.requester
                         credential:self.credential],
                  nil);
     }];
}

- (void)getNext:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getListURL:next callback:callback];
}

- (void)getPrev:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getListURL:prev callback:callback];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end
