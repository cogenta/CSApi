//
//  CSProductSummary.m
//  CSApi
//
//  Created by Will Harris on 11/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSProductSummary.h"
#import <HyperBek/HyperBek.h>
#import "CSPictureListPage.h"
#import "CSListItem.h"
#import "CSResourceListItem.h"
#import "CSLinkListItem.h"

@interface CSProductSummary ()

@property (strong, nonatomic) YBHALResource *resource;

@end

@implementation CSProductSummary

@synthesize resource;
@synthesize name;

- (id)initWithHAL:(YBHALResource *)aResource
        requester:(id<CSRequester>)aRequester
       credential:(id<CSCredential>)aCredential
{
    self = [super initWithRequester:aRequester
                         credential:aCredential];
    if (self) {
        resource = aResource;
        
        name = resource[@"name"];
    }
    return self;
}

- (void)getPictures:(void (^)(id<CSPictureListPage>, NSError *))callback
{
    [self getRelation:@"/rels/pictures"
          forResource:resource
             callback:^(YBHALResource *page, NSError *error)
    {
        if (error) {
            callback(nil, error);
            return;
        }
        
        callback([[CSPictureListPage alloc] initWithHal:page
                                              requester:self.requester
                                             credential:self.credential],
                 nil);
     }];
}

@end