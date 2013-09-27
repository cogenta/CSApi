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

@property (readonly) YBHALResource *resource;
- (NSUInteger) getCountForResource:(YBHALResource *)resource;
@end

@implementation CSListPage

@synthesize resource;
@synthesize count;
@synthesize items;
@synthesize URL;
@synthesize next;
@synthesize prev;

- (id)initWithHal:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    if ( ! aResource) {
        return nil;
    }
    self = [super initWithRequester:aRequester credential:aCredential];
    if (self) {
        resource = aResource;
        count = [self getCountForResource:resource];
    }
    return self;
}

- (NSArray *)items
{
    if ( ! items) {
        NSArray *resources = [resource resourcesForRelation:self.rel];
        if (resources) {
            items = [resources mapUsingBlock:^id(id obj) {
                return [[CSResourceListItem alloc] initWithResource:obj
                                                          requester:self.requester
                                                         credential:self.credential];
            }];
        } else {
            NSArray *links = [resource linksForRelation:self.rel];
            items = [links mapUsingBlock:^id(id obj) {
                return [[CSLinkListItem alloc] initWithLink:obj
                                                  requester:self.requester
                                                 credential:self.credential];
            }];
        }
    }
    
    if ( ! items && self.count > 0) {
        NSLog(@"WARNING: %@ list page found no items", self);
    }

    return items;
}

- (NSURL *)URL
{
    if ( ! URL) {
        URL = [resource linkForRelation:@"self"].URL;
    }
    
    return URL;
}

- (NSURL *)next
{
    if ( ! next) {
        next = [resource linkForRelation:@"next"].URL;
    }
    return next;
}

- (NSURL *)prev
{
    if ( ! prev) {
        prev = [resource linkForRelation:@"prev"].URL;
    }
    return prev;
}

- (NSUInteger)getCountForResource:(YBHALResource *)aResource
{
    return [resource[@"count"] unsignedIntegerValue];
}

- (NSNumber *)page
{
    return resource[@"page"];
}

- (NSNumber *)pages
{
    return resource[@"pages"];
}

- (NSNumber *)size
{
    return resource[@"size"];
}

- (NSString *)rel
{
    return @"item";
}

- (BOOL)hasNext
{
    return self.next != nil;
}

- (BOOL)hasPrev
{
    return self.prev != nil;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)aResource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSListPage alloc] initWithHal:aResource
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
    [self getListURL:self.next callback:callback];
}

- (void)getPrev:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getListURL:self.prev callback:callback];
}

- (BOOL)supportsRandomAccess
{
    return [self.resource linkForRelation:@"/rels/pages"];
}

- (void)getPage:(NSUInteger)page callback:(void (^)(id<CSListPage>, NSError *))callback
{
    [self getRelation:@"/rels/pages"
        withArguments:@{@"page": @(page)}
          forResource:self.resource
             callback:^(YBHALResource *result, NSError *error)
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), self.URL];
}

@end
