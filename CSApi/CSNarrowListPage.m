//
//  CSNarrowListPage.m
//  CSApi
//
//  Created by Will Harris on 08/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNarrowListPage.h"
#import "CSNarrowList.h"
#import <HyperBek/HyperBek.h>

@implementation CSNarrowListPage

@synthesize narrowList;

- (id<CSNarrowList>)narrowList
{
    if ( ! narrowList) {
        narrowList = [[CSNarrowList alloc] initWithPage:self
                                              requester:self.requester
                                             credential:self.credential];
    }
    
    return narrowList;
}

- (id<CSNarrowListPage>)pageWithHal:(YBHALResource *)aResource
                          requester:(id<CSRequester>)aRequester
                         credential:(id<CSCredential>)aCredential
{
    return [[CSNarrowListPage alloc] initWithHal:aResource
                                       requester:self.requester
                                      credential:self.credential];
}

@end
