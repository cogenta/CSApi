//
//  CSCredentialEntity.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCredentialEntity.h"
#import <HyperBek/HyperBek.h>
#import "CSListItem.h"
#import "CSLinkListItem.h"
#import "CSResourceListItem.h"

@implementation CSCredentialEntity

@synthesize requester;
@synthesize credential;

- (id)initWithRequester:(id<CSRequester>)aRequester
             credential:(id<CSCredential>)aCredential
{
    self = [super init];
    if (self) {
        requester = aRequester;
        credential = aCredential;
    }
    return self;
}

- (id<CSAPIRequest>)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [requester postURL:URL
                                      credential:credential
                                            body:body
                                        callback:callback];
}

- (id<CSAPIRequest>)getURL:(NSURL *)URL callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [requester getURL:URL
                                     credential:credential
                                       callback:callback];
}

- (id<CSAPIRequest>)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [requester putURL:URL
           credential:credential
                 body:body
                 etag:etag
             callback:callback];
}

- (CSListItem *)itemForRelation:(NSString *)relation
                        resouce:(YBHALResource *)resource
{
    YBHALResource *itemResource = [resource resourceForRelation:relation];
    CSListItem *item = nil;
    if (itemResource) {
        return [[CSResourceListItem alloc] initWithResource:itemResource
                                                  requester:self.requester
                                                 credential:self.credential];
    } else {
        YBHALLink *itemLink = [resource linkForRelation:relation];
        
        if ( ! itemLink) {
            return nil;
        }
        
        return [[CSLinkListItem alloc] initWithLink:itemLink
                                          requester:self.requester
                                         credential:self.credential];
    }
}

- (id<CSAPIRequest>)getRelation:(NSString *)relation
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback
{
    CSListItem *item = [self itemForRelation:relation resouce:resource];
    
    if ( ! item) {
        callback(nil, nil);
        return nil;
    }
    
    return [item getSelf:callback];
}

- (id<CSAPIRequest>)getRelation:(NSString *)relation
      withArguments:(NSDictionary *)args
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback
{
    NSURL *URL = [self URLForRelation:relation
                            arguments:args
                             resource:resource];
    if ( ! URL) {
        callback(nil, nil);
        return nil;
    }
    
    return (id<CSAPIRequest>) [self.requester getURL:URL
                                          credential:self.credential
                                            callback:^(id result,
                                                       id etag,
                                                       NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback(result, nil);
    }];
}

- (NSURL *)URLForRelation:(NSString *)relation
                arguments:(NSDictionary *)args
                 resource:(YBHALResource *)resource
{
    YBHALLink *link = [resource linkForRelation:relation];
    if ( ! link) {
        link = [[resource resourceForRelation:relation]
                linkForRelation:@"self"];
    }
    
    if ( ! link) {
        return nil;
    }
    
    NSURL *baseURL = [[resource linkForRelation:@"self"] URL];
    NSURL *relativeURL = [link URLWithVariables:args];
    NSURL *URL = [[NSURL URLWithString:[relativeURL absoluteString]
                         relativeToURL:baseURL]
                  absoluteURL];
    return URL;
}

@end

