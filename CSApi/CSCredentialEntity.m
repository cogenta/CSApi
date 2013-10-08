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
#import <objc/runtime.h>

@interface YBHALResource (NSCodingAdditions) <NSCoding>

@end

@implementation YBHALResource (NSCodingAdditions)

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:[(id)self dictionary] forKey:@"dictionary"];
    [aCoder encodeObject:[(id)self baseURL] forKey:@"baseURL"];
}

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithDictionary:[aDecoder decodeObjectForKey:@"dictionary"]
                            baseURL:[aDecoder decodeObjectForKey:@"baseURL"]];
}

@end

@interface CSCredentialEntity ()

@property (readonly, strong) NSURL *cacheURL;

@end

@implementation CSCredentialEntity

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential
                  etag:(id)etag
{
    self = [super init];
    if (self) {
        _resource = resource;
        _requester = requester;
        _credential = credential;
        _etag = etag;
        [self loadExtraProperties];
    }
    return self;
}

- (id)initWithResource:(YBHALResource *)resource
             requester:(id<CSRequester>)requester
            credential:(id<CSCredential>)credential
{
    return [self initWithResource:resource
                        requester:requester
                       credential:credential
                             etag:nil];
}

- (void)loadExtraProperties
{
    // Do nothing. Override this method in subclasses to initialize extra
    // properties.
}

- (NSURL *)URL
{
    if ( ! _cacheURL) {
        _cacheURL = [self.resource linkForRelation:@"self"].URL;
    }
    
    return _cacheURL;
}


- (id<CSAPIRequest>)postURL:(NSURL *)URL
           body:(id)body
       callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [self.requester postURL:URL
                                           credential:self.credential
                                                 body:body
                                             callback:callback];
}

- (id<CSAPIRequest>)getURL:(NSURL *)URL callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [self.requester getURL:URL
                                          credential:self.credential
                                            callback:callback];
}

- (id<CSAPIRequest>)putURL:(NSURL *)URL
          body:(id)body
          etag:(id)etag
      callback:(requester_callback_t)callback
{
    return (id<CSAPIRequest>) [self.requester putURL:URL
                                          credential:self.credential
                                                body:body
                                                etag:etag
                                            callback:callback];
}

- (CSListItem *)itemForRelation:(NSString *)relation
                        resouce:(YBHALResource *)resource
{
    YBHALResource *itemResource = [resource resourceForRelation:relation];
    if (itemResource) {
        return [[CSResourceListItem alloc] initWithResource:itemResource];
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

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]),
            self.URL];
}

#pragma mark - NSCoding

- (id)initWithCoder:(NSCoder *)aDecoder
{
    return [self initWithResource:[aDecoder decodeObjectForKey:@"resource"]
                        requester:[aDecoder decodeObjectForKey:@"requester"]
                       credential:[aDecoder decodeObjectForKey:@"credential"]
                             etag:[aDecoder decodeObjectForKey:@"etag"]];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:self.resource forKey:@"resource"];
    [aCoder encodeObject:self.requester forKey:@"requester"];
    [aCoder encodeObject:self.credential forKey:@"credential"];
    [aCoder encodeObject:self.etag forKey:@"etag"];
}

@end

