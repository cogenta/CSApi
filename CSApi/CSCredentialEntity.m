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

- (void)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback
{
    [requester postURL:URL credential:credential body:body callback:callback];
}

- (void)getURL:(NSURL *)URL callback:(requester_callback_t)callback
{
    [requester getURL:URL credential:credential callback:callback];
}

- (void)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    [requester putURL:URL
           credential:credential
                 body:body
                 etag:etag
             callback:callback];
}

- (void)getRelation:(NSString *)relation
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback
{
    YBHALResource *itemResource = [resource resourceForRelation:relation];
    CSListItem *item = nil;
    if (itemResource) {
        item = [[CSResourceListItem alloc] initWithResource:itemResource
                                                  requester:self.requester
                                                 credential:self.credential];
    } else {
        YBHALLink *itemLink = [resource linkForRelation:relation];
        
        if ( ! itemLink) {
            callback(nil, nil);
            return;
        }
        
        item = [[CSLinkListItem alloc] initWithLink:itemLink
                                          requester:self.requester
                                         credential:self.credential];
    }
    
    [item getSelf:callback];
}

- (void)getRelation:(NSString *)relation
      withArguments:(NSDictionary *)args
        forResource:(YBHALResource *)resource
           callback:(void (^)(YBHALResource *, NSError *))callback
{
    YBHALLink *link = [resource linkForRelation:relation];
    if ( ! link) {
        link = [[resource resourceForRelation:relation]
                linkForRelation:@"self"];
    }
    
    if ( ! link) {
        callback(nil, nil);
        return;
    }
    
    NSURL *baseURL = [[resource linkForRelation:@"self"] URL];
    NSURL *relativeURL = [link URLWithVariables:args];
    NSURL *URL = [[NSURL URLWithString:[relativeURL absoluteString]
                         relativeToURL:baseURL]
                  absoluteURL];
    [self.requester getURL:URL
                credential:self.credential
                  callback:^(id result, id etag, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback(result, nil);
    }];
}

@end

