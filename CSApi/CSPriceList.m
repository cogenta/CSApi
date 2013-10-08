//
//  CSPriceList.m
//  CSApi
//
//  Created by Will Harris on 22/04/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPriceList.h"
#import "CSListItem.h"
#import "CSPrice.h"

@implementation CSPriceList

- (void)getPriceAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSPrice>, NSError *))callback
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
            
            CSPrice *price = [[CSPrice alloc] initWithResource:resource
                                                     requester:self.requester
                                                    credential:self.credential];
            callback(price, nil);
        }];
    }];
}

@end
