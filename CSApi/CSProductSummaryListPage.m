//
//  CSProductSummaryListPage.m
//  CSApi
//
//  Created by Will Harris on 15/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummaryListPage.h"
#import "CSProductSummaryList.h"

@implementation CSProductSummaryListPage

@synthesize productSummaryList;

- (id<CSProductSummaryList>)productSummaryList
{
    if (  ! productSummaryList) {
        productSummaryList = [[CSProductSummaryList alloc]
                              initWithPage:self
                              requester:self.requester
                              credential:self.credential];
    }
    
    return productSummaryList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSProductSummaryListPage alloc] initWithHal:resource
                                               requester:self.requester
                                              credential:self.credential];
}

@end
