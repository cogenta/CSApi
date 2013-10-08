//
//  CSCategoryListPage.m
//  CSApi
//
//  Created by Will Harris on 22/05/2013.
//  Copyright (c) 2013 Cogenta Systems Ltd. All rights reserved.
//

#import "CSCategoryListPage.h"
#import "CSCategoryList.h"
#import <HyperBek/HyperBek.h>

@implementation CSCategoryListPage

@synthesize categoryList;

- (id<CSCategoryList>)categoryList
{
    if (  ! categoryList) {
        categoryList = [[CSCategoryList alloc] initWithPage:self
                                                  requester:self.requester
                                                 credential:self.credential];
    }
    
    return categoryList;
}

@end
