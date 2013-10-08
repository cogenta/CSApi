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

@property (readonly) NSURL *next;
@property (readonly) NSURL *prev;
@property (readonly) NSString *rel;

- (NSUInteger) getCountForResource:(YBHALResource *)resource;


@end

@implementation CSListPage

@synthesize count;
@synthesize items;
@synthesize next;
@synthesize prev;

- (void)loadExtraProperties
{
    count = [self getCountForResource:self.resource];
}

- (NSArray *)items
{
    if ( ! items) {
        NSArray *resources = [self.resource resourcesForRelation:self.rel];
        if (resources) {
            items = [resources mapUsingBlock:^id(id obj) {
                return [[CSResourceListItem alloc] initWithResource:obj];
            }];
        } else {
            NSArray *links = [self.resource linksForRelation:self.rel];
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

- (NSURL *)next
{
    if ( ! next) {
        next = [self.resource linkForRelation:@"next"].URL;
    }
    return next;
}

- (NSURL *)prev
{
    if ( ! prev) {
        prev = [self.resource linkForRelation:@"prev"].URL;
    }
    return prev;
}

- (NSUInteger)getCountForResource:(YBHALResource *)aResource
{
    return [self.resource[@"count"] unsignedIntegerValue];
}

- (NSNumber *)page
{
    return self.resource[@"page"];
}

- (NSNumber *)pages
{
    return self.resource[@"pages"];
}

- (NSNumber *)size
{
    return self.resource[@"size"];
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
    return [[CSListPage alloc] initWithResource:aResource
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
    return [self.resource linkForRelation:@"/rels/pages"] != nil;
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

- (instancetype)pageWithHal:(YBHALResource *)aResource
{
    return [[[self class] alloc] initWithResource:aResource
                                        requester:self.requester
                                       credential:self.credential];
}

@end
