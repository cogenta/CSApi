//
//  CSNarrowList.m
//  CSApi
//
//  Created by Will Harris on 08/08/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSNarrowList.h"
#import "CSListItem.h"
#import "CSNarrow.h"

@implementation CSNarrowList

- (void)getNarrowAtIndex:(NSUInteger)index
                callback:(void (^)(id<CSNarrow>, NSError *))callback
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
            
            CSNarrow *narrow = [[CSNarrow alloc]
                                initWithResource:resource
                                requester:self.requester
                                credential:self.credential];
            callback(narrow, nil);
        }];
    }];
}

@end
