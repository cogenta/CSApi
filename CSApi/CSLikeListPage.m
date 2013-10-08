//
//  CSLikeListPage.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSLikeListPage.h"
#import "CSLikeList.h"

@implementation CSLikeListPage

@synthesize likeList;

- (id<CSLikeList>)likeList
{
    if (  ! likeList) {
        likeList = [[CSLikeList alloc] initWithPage:self
                                          requester:self.requester
                                         credential:self.credential];
    }
    
    return likeList;
}

- (id<CSListPage>)pageWithHal:(YBHALResource *)resource
                    requester:(id<CSRequester>)aRequester
                   credential:(id<CSCredential>)aCredential
{
    return [[CSLikeListPage alloc] initWithResource:resource
                                          requester:self.requester
                                         credential:self.credential];
}

@end

