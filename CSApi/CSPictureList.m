//
//  CSPictureList.m
//  CSApi
//
//  Created by Will Harris on 11/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPictureList.h"
#import "CSListItem.h"
#import "CSPicture.h"

@implementation CSPictureList

- (void)getPictureAtIndex:(NSUInteger)index
                 callback:(void (^)(id<CSPicture>, NSError *))callback
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
            
            CSPicture *picture = [[CSPicture alloc] initWithHal:resource
                                                      requester:self.requester
                                                     credential:self.credential];
            callback(picture, nil);
        }];
    }];
}

@end
