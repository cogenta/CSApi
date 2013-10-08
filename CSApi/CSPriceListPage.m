//
//  CSPriceListPage.m
//  CSApi
//
//  Created by Will Harris on 22/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceListPage.h"
#import "CSPriceList.h"
#import <HyperBek/HyperBek.h>

@implementation CSPriceListPage

@synthesize priceList;

- (id<CSPriceList>)priceList
{
    if (  ! priceList) {
        priceList = [[CSPriceList alloc] initWithPage:self
                                            requester:self.requester
                                           credential:self.credential];
    }
    
    return priceList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSPriceListPage alloc] initWithResource:resource
                                           requester:self.requester
                                          credential:self.credential];
}

- (NSUInteger)getCountForResource:(YBHALResource *)resource
{
    NSArray *resources = [resource resourcesForRelation:[self rel]];
    if (resources) {
        return [resources count];
    }
    
    return [[resource linksForRelation:[self rel]] count];
}

- (NSString *)rel
{
    return @"/rels/price";
}

@end
