//
//  CSNominal.m
//  CSApi
//
//  Created by Will Harris on 12/09/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNominal.h"
#import <HyperBek/HyperBek.h>

@implementation CSNominal

- (NSString *)name
{
    return self.resource[@"name"];
}

@end
