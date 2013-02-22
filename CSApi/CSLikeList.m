//
//  CSLikeList.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSLikeList.h"
#import "CSListItem.h"
#import "CSLike.h"

@implementation CSLikeList

- (void)getLikeAtIndex:(NSUInteger)index
              callback:(void (^)(id<CSLike>, NSError *))callback
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
            
            CSLike *like = [[CSLike alloc] initWithResource:resource
                                                  requester:self.requester
                                                 credential:self.credential];
            callback(like, nil);
        }];
    }];
}

@end

