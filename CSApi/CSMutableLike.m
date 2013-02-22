//
//  CSMutableLike.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSMutableLike.h"
#import "CSRepresentation.h"
#import <objc/runtime.h>

@implementation CSMutableLike

@synthesize likedURL;

- (id)representWithRepresentation:(id<CSRepresentation>)representation
{
    return [representation representMutableLike:self];
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"<%s likedURL=%@>",
            class_getName([self class]),
            self.likedURL];
}

@end
