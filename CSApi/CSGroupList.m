//
//  CSGroupList.m
//  CSApi
//
//  Created by Will Harris on 25/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSGroupList.h"
#import "CSListItem.h"
#import "CSGroup.h"

@implementation CSGroupList

- (void)getGroupAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSGroup>, NSError *))callback
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
            
            CSGroup *group = [[CSGroup alloc] initWithResource:resource
                                                     requester:self.requester
                                                    credential:self.credential];
            callback(group, nil);
        }];
    }];
}

@end
