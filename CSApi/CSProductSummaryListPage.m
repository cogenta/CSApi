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

- (NSString *)rel
{
    return @"/rels/productsummary";
}

@end
