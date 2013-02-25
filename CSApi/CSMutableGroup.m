//
//  CSMutableGroup.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSMutableGroup.h"
#import "CSRepresentation.h"
#import <objc/runtime.h>

@implementation CSMutableGroup

@synthesize URL;
@synthesize reference;
@synthesize meta;

- (id)init
{
    return [self initWithGroup:nil];
}

- (id)initWithGroup:(id<CSGroup>)group
{
    self = [super init];
    if (self) {
        URL = group.URL;
        self.reference = group.reference;
        self.meta = [group.meta mutableCopy];
    }
    return self;
}

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    id result = [representation representMutableGroup:self];
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end
