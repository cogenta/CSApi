//
//  CSRetailerList.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailerList.h"
#import "CSListItem.h"
#import "CSRetailer.h"

@implementation CSRetailerList

- (void)getRetailerAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSRetailer>, NSError *))callback
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
            
            CSRetailer *retailer = [[CSRetailer alloc]
                                    initWithResource:resource
                                    requester:self.requester
                                    credential:self.credential];
            callback(retailer, nil);
        }];
    }];
}

@end
