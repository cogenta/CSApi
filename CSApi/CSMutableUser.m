//
//  CSMutableUser.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSMutableUser.h"
#import "CSRepresentation.h"
#import <objc/runtime.h>

@implementation CSMutableUser

@synthesize URL;
@synthesize reference;
@synthesize meta;

- (id)init
{
    return [self initWithUser:nil];
}

- (id)initWithUser:(id<CSUser>)user
{
    self = [super init];
    if (self) {
        URL = user.URL;
        self.reference = user.reference;
        self.meta = [user.meta mutableCopy];
    }
    return self;
}

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    id result = [representation representMutableUser:self];
    return result;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s URL=%@>",
            class_getName([self class]), URL];
}

@end
