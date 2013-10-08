//
//  CSRetailer.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSRetailer.h"
#import <HyperBek/HyperBek.h>
#import "CSPicture.h"
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"
#import "CSProductListPage.h"
#import "CSCategoryListPage.h"

@implementation CSRetailer

- (NSString *)name
{
    return self.resource[@"name"];
}

- (void)getLogo:(void (^)(id<CSPicture>, NSError *))callback
{
    [self getRelation:@"/rels/logo"
          forResource:self.resource
             callback:^(YBHALResource *logoResource, NSError *error)
     {
        if (error) {
            callback(nil, error);
        }
        
        CSPicture *result =  [[CSPicture alloc] initWithResource:logoResource
                                                       requester:self.requester
                                                      credential:self.credential];
        callback(result, nil);
    }];
}

@end

