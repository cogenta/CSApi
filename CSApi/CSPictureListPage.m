//
//  CSPictureListPage.m
//  CSApi
//
//  Created by Will Harris on 11/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPictureListPage.h"
#import "CSPictureList.h"

@implementation CSPictureListPage

@synthesize pictureList;

- (id<CSPictureList>)pictureList
{
    if (  ! pictureList) {
        pictureList = [[CSPictureList alloc] initWithPage:self
                                                requester:self.requester
                                               credential:self.credential];
    }
    
    return pictureList;
}

- (NSString *)rel
{
    return @"/rels/picture";
}

@end