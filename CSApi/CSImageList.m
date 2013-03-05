//
//  CSImageList.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSImageList.h"
#import "CSListItem.h"
#import "CSImage.h"

@implementation CSImageList

- (void)getImageAtIndex:(NSUInteger)index
               callback:(void (^)(id<CSImage>, NSError *))callback
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
            
            CSImage *image = [[CSImage alloc] initWithResource:resource
                                                     requester:self.requester
                                                    credential:self.credential
                                                          etag:nil];
            callback(image, nil);
        }];
    }];
}

@end
