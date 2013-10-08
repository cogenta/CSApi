//
//  CSApplication.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSApplication.h"
#import <HyperBek/HyperBek.h>
#import "CSMutableUser.h"
#import "CSUser.h"
#import "CSHALRepresentation.h"
#import "CSRetailerListPage.h"
#import "CSRetailer.h"

@implementation CSApplication

- (NSString *)name
{
    return self.resource[@"name"];
}

- (void)createUserWithChange:(void (^)(id<CSMutableUser>))change
                    callback:(void (^)(id<CSUser>, NSError *))callback
{
    NSURL *URL = [self.resource linkForRelation:@"/rels/users"].URL;
    NSURL *baseURL = self.URL;
    id<CSRepresentation> representation = [CSHALRepresentation
                                           representationWithBaseURL:baseURL];
    CSMutableUser *user = [[CSMutableUser alloc] init];
    if (change) {
        change(user);
    }
    
    [self postURL:URL
             body:[user representWithRepresentation:representation]
         callback:^(id result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         CSUser *user = [[CSUser alloc] initWithResource:result
                                               requester:self.requester
                                                    etag:etag];
         callback(user, nil);
     }];
}

- (void)getRetailers:(void (^)(id<CSRetailerListPage> page, NSError *error))callback
{
    NSURL *URL = [self.resource linkForRelation:@"/rels/retailers"].URL;
    [self getURL:URL callback:^(YBHALResource *result, id etag, NSError *error)
     {
         if (error) {
             callback(nil, error);
             return;
         }
         
         callback([[CSRetailerListPage alloc] initWithResource:result
                                                     requester:self.requester
                                                    credential:self.credential],
                  nil);
     }];
}


@end

