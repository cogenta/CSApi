//
//  CSProductList.m
//  CSApi
//
//  Created by Will Harris on 09/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductList.h"
#import "CSListItem.h"
#import "CSProduct.h"

@implementation CSProductList

- (void)getProductAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSProduct>, NSError *))callback
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
            
            CSProduct *product = [[CSProduct alloc]
                                  initWithResource:resource
                                  requester:self.requester
                                  credential:self.credential];
            callback(product, nil);
        }];
    }];
}

@end
