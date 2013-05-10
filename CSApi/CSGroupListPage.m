//
//  CSGroupListPage.m
//  CSApi
//
//  Created by Will Harris on 22/02/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSGroupListPage.h"
#import "CSGroupList.h"

@implementation CSGroupListPage

@synthesize groupList;

- (id<CSGroupList>)groupList
{
    if (  ! groupList) {
        groupList = [[CSGroupList alloc] initWithPage:self
                                            requester:self.requester
                                           credential:self.credential];
    }
    
    return groupList;
}

- (NSString *)rel
{
    return @"/rels/group";
}

@end
