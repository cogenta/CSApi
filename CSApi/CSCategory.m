//
//  CSCategory.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategory.h"
#import <HyperBek/HyperBek.h>

@interface CSCategory ()
@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSCategory

@synthesize name;

- (id)initWithHAL:(YBHALResource *)resource
        requester:(id<CSRequester>)requester
       credential:(id<CSCredential>)credential
{
    self = [super initWithRequester:requester credential:credential];
    if (self) {
        self.resource = resource;
        name = self.resource[@"name"];
    }
    return self;
}

@end
