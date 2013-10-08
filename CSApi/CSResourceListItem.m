//
//  CSResourceListItem.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSResourceListItem.h"
#import <HyperBek/HyperBek.h>

@interface CSResourceListItem ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSResourceListItem

- (id)initWithResource:(YBHALResource *)resource
{
    self = [super init];
    if (self) {
        self.resource = resource;
    }
    return self;
}

- (id<CSAPIRequest>)getSelf:(void (^)(YBHALResource *, NSError *))callback
{
    callback(self.resource, nil);
    return nil;
}

- (NSURL *)URL
{
    return [self.resource linkForRelation:@"self"].URL;
}

@end

