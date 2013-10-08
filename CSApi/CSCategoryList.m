//
//  CSCategoryList.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategoryList.h"
#import "CSListItem.h"
#import "CSCategory.h"

@implementation CSCategoryList

- (void)getCategoryAtIndex:(NSUInteger)index
                  callback:(void (^)(id<CSCategory>, NSError *))callback
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
            
            CSCategory *category = [[CSCategory alloc]
                                    initWithResource:resource
                                    requester:self.requester
                                    credential:self.credential];
            callback(category, nil);
        }];
    }];
}

@end
