//
//  CSRetailerListPage.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerListPage.h"
#import "CSRetailerList.h"

@implementation CSRetailerListPage

@synthesize retailerList;

- (id<CSRetailerList>)retailerList
{
    if (  ! retailerList) {
        retailerList = [[CSRetailerList alloc] initWithPage:self
                                                  requester:self.requester
                                                 credential:self.credential];
    }
    
    return retailerList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSRetailerListPage alloc] initWithHal:resource
                                         requester:self.requester
                                        credential:self.credential];
}

@end
