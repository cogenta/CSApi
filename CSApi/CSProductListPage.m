//
//  CSProductListPage.m
//  CSApi
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductListPage.h"
#import "CSProductList.h"

@implementation CSProductListPage

@synthesize productList;

- (id<CSProductList>)productList
{
    if (  ! productList) {
        productList = [[CSProductList alloc]
                       initWithPage:self
                       requester:self.requester
                       credential:self.credential];
    }
    
    return productList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSProductListPage alloc] initWithHal:resource
                                        requester:self.requester
                                       credential:self.credential];
}

- (NSString *)rel
{
    return @"/rels/product";
}

@end
