//
//  CSProductSummaryList.m
//  CSApi
//
//  Created by Will Harris on 15/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummaryList.h"
#import "CSListItem.h"
#import "CSProductSummary.h"

@implementation CSProductSummaryList

- (void)getProductSummaryAtIndex:(NSUInteger)index
                        callback:(void (^)(id<CSProductSummary>, NSError *))callback
{
    [self getItemAtIndex:index callback:^(CSListItem *item, NSError *error) {
        if ( ! item) {
            callback(nil, error);
            return;
        }
        
        [item getSelf:^(YBHALResource *resource, NSError *error) {
            if (error) {
                callback(nil, error);
                return;
            }
            
            CSProductSummary *productSummary = [[CSProductSummary alloc]
                                                initWithHAL:resource
                                                requester:self.requester
                                                credential:self.credential];
            callback(productSummary, nil);
        }];
    }];
}


@end
