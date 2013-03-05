//
//  CSPicture.m
//  CSApi
//
//  Created by Will Harris on 05/03/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSPicture.h"
#import "CSImageList.h"

@implementation CSPicture

@synthesize imageList;

- (id<CSImageList>)imageList
{
    if (  ! imageList) {
        imageList = [[CSImageList alloc] initWithPage:self
                                            requester:self.requester
                                           credential:self.credential];
    }
    
    return imageList;
}

- (NSString *)rel
{
    return @"/rels/image";
}

@end
